import Vapor
@testable import App
import Authentication
//토큰을 사용하고 인증 모듈을 가져올 수 있다.
import FluentPostgreSQL

extension Application {
    static func testable(envArgs: [String]? = nil) throws -> Application {
        //테스트할 수 있는 Application 객체 생성.
        //테스트 때마다 생성할 필요없이, 환경 변수 인자를 받아 생성해 코드 중복을 줄일 수 있다.
        var config = Config.default()
        var services = Services.default()
        var env = Environment.testing
        
        if let environmentArgs = envArgs {
            env.arguments = environmentArgs
        }
        
        try App.configure(&config, &env, &services)
        let app = try Application(
            config: config,
            environment: env,
            services: services)
        
        try App.boot(app)
        return app
    }
    
    static func reset() throws {
        //DB 재설정
        let revertEnvironment = ["vapor", "revert", "--all", "-y"]
        try Application.testable(envArgs: revertEnvironment)
            .asyncRun()
            .wait()
        
        let migrateEnvironment = ["vapor", "migrate", "-y"]
        try Application.testable(envArgs: migrateEnvironment)
            .asyncRun()
            .wait()
        
        //revert 후 migrate 해, DB를 초기화한다.
        //각 테스트에서 DB를 간단하게 재설정할 수 있다.
    }
    
    //Request
    func sendRequest<T>(
        to path: String,
        method: HTTPMethod,
        headers: HTTPHeaders = .init(),
        body: T? = nil,
        loggedInRequest: Bool = false,
        loggedInUser: User? = nil
        ) throws -> Response where T: Content {
        //해당 경로에 request를 보내고, response를 반환하는 메서드
        //파라미터의 method와 headers를 설정하도록 한다(테스트 시 사용).
        //request body를 설정할 수 있도록 한다(제네릭 optional).
        //loggedInRequest와 loggedInUser를 추가해 인증할 수 있도록 한다.
        
        var headers = headers
        
        if (loggedInRequest || loggedInUser != nil) { //해당 request에 인증이 필요한지 판별한다.
            let username: String
            
            if let user = loggedInUser { //사용자가 파라미터로 있는 경우 해당 정보로 사용
                username = user.username
            } else { //사용자가 지정되어 있지 않은 경우 "admin" 사용
                username = "admin"
            }
            
            let credentials = BasicAuthorization(username: username, password: "password")
            //BasicAuthorization 생성
            var tokenHeaders = HTTPHeaders()
            tokenHeaders.basicAuthorization = credentials
            //로그인 request에 대한 basic authorization 헤더 추가
            
            let tokenResponse = try self.sendRequest(to: "/api/users/login", method: .POST, headers: tokenHeaders)
            //로그인 request를 하고 response를 받는다.
            let token = try tokenResponse.content.syncDecode(Token.self)
            //response에서 토큰을 디코딩한다.
            headers.add(name: .authorization, value: "Bearer \(token.token)")
            //진행하려는 request(하단에서 진행)의 header에 token을 추가한다.
        }
        
        let responder = try self.make(Responder.self)
        //responder 생성
        
        let request = HTTPRequest(
            method: method,
            url: URL(string: path)!,
            headers: headers)
        let wrappedRequest = Request(http: request, using: self)
        //래핑된 request를 생성한다.
        
        if let body = body { //해당 테스트에 body가 있다면
            try wrappedRequest.content.encode(body)
            //본문을 request body로 인코딩한다.
            //Vapor의 encode(_ :)를 사용해 설정한 모든 사용자 정의 인코더를 사용할 수 있다.
        }
        
        return try responder.respond(to: wrappedRequest).wait()
        //request를 보내고, response를 반환한다.
    }
    
    func sendRequest(
        to path: String,
        method: HTTPMethod,
        headers: HTTPHeaders = .init(),
        loggedInRequest: Bool = false,
        loggedInUser: User? = nil
        ) throws -> Response {
        //body가 없이 경우 사용할 수 있는 convenience method
        
        let emptyContent: EmptyContent? = nil
        //빈 Content 객체
        
        return try sendRequest(
            to: path,
            method: method,
            headers: headers,
            body: emptyContent,
            loggedInRequest: loggedInRequest,
            loggedInUser: loggedInUser)
            //위의 request 메서드에 빈 Content 객체를 사용해 request를 보낸다.
    }
    
    func sendRequest<T>(
        to path: String,
        method: HTTPMethod,
        headers: HTTPHeaders,
        data: T,
        loggedInRequest: Bool = false,
        loggedInUser: User? = nil
        ) throws where T: Content {
        //경로에 request를 보내고, 일반 Content 유형을 받는 메서드
        //이 convenience method를 사용하면, response를 신경 쓰지 않아도 request를 보낼 수 있다.
        
        _ = try self.sendRequest(
            to: path,
            method: method,
            headers: headers,
            body: data,
            loggedInRequest: loggedInRequest,
            loggedInUser: loggedInUser)
        //위에서 작성한 request 메서드로 request를 보내고 response를 무시한다.
    }
    
    
    
    
    //Response
    func getResponse<C, T>(
        to path: String,
        method: HTTPMethod = .GET,
        headers: HTTPHeaders = .init(),
        data: C? = nil,
        decodeTo type: T.Type,
        loggedInRequest: Bool = false,
        loggedInUser: User? = nil
        ) throws -> T where C: Content, T: Decodable {
        //Content 형식과 Decodable 형식의 제네릭 request에 response하는 메서드
        
        let response = try self.sendRequest(
            to: path,
            method: method,
            headers: headers,
            body: data,
            loggedInRequest: loggedInRequest,
            loggedInUser: loggedInUser)
        //위에서 작성한 request 메서드로 response를 생성한다.
        
        return try response.content.decode(type).wait()
        //response의 body를 제네릭 형식으로 디코딩하고 결과를 반환한다.
    }
    
    func getResponse<T>(
        to path: String,
        method: HTTPMethod = .GET,
        headers: HTTPHeaders = .init(),
        decodeTo type: T.Type,
        loggedInRequest: Bool = false,
        loggedInUser: User? = nil
        ) throws -> T where T: Decodable {
        //response의 body가 없는 제네릭 response 메서드. convenience method. Decodable형식만 있으면 된다.
        
        let emptyContent: EmptyContent? = nil
        //빈 Content 객체
        
        return try self.getResponse(
            to: path,
            method: method,
            headers: headers,
            data: emptyContent,
            decodeTo: type,
            loggedInRequest: loggedInRequest,
            loggedInUser: loggedInUser)
        //위에서 작성한 response 메서드에 빈 Content 객체를 사용해 request에 대한 response를 받는다.
    }
}

struct EmptyContent: Content {}
//request에서 본문이 없을 때 사용할 빈 Content 유형
//제네릭 형식에 대해 nil을 정의할 수 없으므로, EmptyContent를 사용해 제공한다.

//Test extensions
//테스트에 사용할 공통적인 코드는 한 곳에 묶어서 관리하는 것이 좋다.
