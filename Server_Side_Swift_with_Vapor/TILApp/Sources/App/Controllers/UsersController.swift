import Vapor
import Crypto //암호화

struct UsersController: RouteCollection {
    //RouteCollection를 구현해, route를 관리하는 Controller를 구현할 수 있다.
    
    func boot(router: Router) throws {
        //RouteCollection에서는 반드시 이 메서드를 구현해야 한다.
        //필요한 경로들을 정의해 주면 된다.
        
        let usersRoute = router.grouped("api", "users")
        //반복되는 경로에 대해 새 초기 경로 그룹을 생성한다(/api/users).
        
//        usersRoute.post(User.self, use: createHandler)
//        //생성은 POST 요청을 사용한다. 경로는 http://localhost:8080/api/users 가 된다.
//        //POST helper 메서드를 사용해서, request body에서 User 객체로 디코딩한다.
        usersRoute.get(use: getAllHandler)
        //GET 요청을 처리하는 경로. 여기서는 http://localhost:8080/api/users 가 된다.
        usersRoute.get(User.parameter, use: getHandler)
        //GET 요청을 처리하는 경로. 여기서는 http://localhost:8080/api/users/<ID> 가 된다.
        usersRoute.get(User.parameter, "acronyms", use: getAcronymsHandler)
        //Getting the children는 GET 요청을 사용한다. 경로는 http://localhost:8080/api/users/<ID>/acronyms 가 된다.
        
        let basicAuthMiddleware = User.basicAuthMiddleware(using: BCryptDigest())
        //BCryptDigest를 사용해 암호를 확인하는 HTTP basic authentication 미들웨어를 인스턴스화한다.
        //User는 BasicAuthenticatable를 구현했기에 static method을 사용할 수 있다.
        //requireAuthenticated(_ :)는 사용자가 인증되지 않은 경우 오류를 발생 시키므로 AcronymsController에서와 달리
        //GuardAuthenticationMiddleware 를 따로 사용할 필요 없다.
        let basicAuthGroup = usersRoute.grouped(basicAuthMiddleware)
        //미들웨어 그룹을 생성한다.
        
        basicAuthGroup.post("login", use: loginHandler)
        //경로는 http://localhost:8080/api/users/login 이 된다. 보호된 그룹으로 loginHandler(_:)가 연결된다.
        //User 로그인은 password로 인증
        
        
        
        
        let tokenAuthMiddleware = User.tokenAuthMiddleware() //tokenAuthMiddleware 생성
        //BearerAuthenticationMiddleware로 request에서 Bearer Token을 추출한다.
        //그 후, 미들웨어는 해당 토큰을 로그인한 사용자로 변환한다.
        let guardAuthMiddleware = User.guardAuthMiddleware()
        //request에 유효한 인증이 포함되도록 보장하는 GuardAuthenticationMiddleware 인스턴스 생성
        let tokenAuthGroup = usersRoute.grouped(tokenAuthMiddleware, guardAuthMiddleware)
        //미들웨어 그룹을 생성한다. 토큰 인증으로 Acronym를 생성하는 경우, Routes를 보호한다.
        
        tokenAuthGroup.post(User.self, use: createHandler)
        //생성은 POST 요청을 사용한다. 경로는 http://localhost:8080/api/users 가 된다.
        //user create 로 들어오는 경로들이 미들웨어 그룹을 거쳐 createHandler(_:acronym:)를 호출하도록 연결한다.
        //따라서 Token authentication을 사용하여 User를 생성하는 인증된 request를 만들 수 있다.
        
        //REST API를 사용할 때 인증이 필요하다. Bearer <TOKEN STRING>로 Authorization header를 추가해 줘야 한다.
        //이전에 HTTP basic authentication를 사용 중이라면, 헤더에서 제거해 준다.
        
        //유저 생성을 Token authentication를 사용하도록 대체해 준다. //AcronymsController 참고
    }
    
    //Create
//    func createHandler(_ req: Request, user: User) throws -> Future<User>  {
//        //이 메서드는 매개변수로 User를 가져온다. User는 이미 decode 되었기 때문에 따로 decode()할 필요 없다.
//        user.password = try BCrypt.hash(user.password)
//        //사용자의 암호를 DB에 저장하기 전에 해시한다.
//
//        return user.save(on: req) //Fluent의 모델 저장 메서드
//    }
    
    func createHandler(_ req: Request, user: User) throws -> Future<User.Public> {
        //이 메서드는 매개변수로 User를 가져온다. User는 이미 decode 되었기 때문에 따로 decode()할 필요 없다.
        //Public한 정보만 담고 있는 Future<User.Public>를 반환한다.
        user.password = try BCrypt.hash(user.password)
        //사용자의 암호를 DB에 저장하기 전에 해시한다.
        
        return user.save(on: req).convertToPublic()
        //Future<User> 의 extension을 사용해, 결과를 직접 unwarpping할 필요 없다.
        //이를 사용하면, 사용자의 암호 해시를 노출하지 않는다.
    }
    
    //Retrieve
//    func getAllHandler(_ req: Request) throws -> Future<[User]> {
//        return User.query(on: req).all() //모든 User 반환
//    }
    
    func getAllHandler(_ req: Request) throws -> Future<[User.Public]> {
        return User.query(on: req).decode(data: User.Public.self).all()
        //createHandler와 달리 User 모델을 User.Public로 변환(convertToPublic)하지 않고 User.Public으로 디코딩 해서 구현할 수 있다.
    }
    
//    func getHandler(_ req: Request) throws -> Future<User> {
//        return try req.parameters.next(User.self)
//        //request의 매개 변수로 지정된 User를 반환한다.
//    }
    
    func getHandler(_ req: Request) throws -> Future<User.Public> {
        return try req.parameters.next(User.self).convertToPublic()
    }
    
    
    
    
    //Getting the children
    func getAcronymsHandler(_ req: Request) throws -> Future<[Acronym]> { //Future<[Acronym]>를 반환한다.
        return try req
            .parameters.next(User.self)
            .flatMap(to: [Acronym].self) { user in //request의 매개 변수로 지정된 User를 가져와 flatMap으로 Future를 unwrapping한다.
                //flatMap(to:)는 해당하는 유형으로 최종 반환한다.
                try user.acronyms.query(on: req).all()
                //computed property에서 acronym를 가져온다.
            }
    }
    
    
    
    
    //Login Token
    func loginHandler(_ req: Request) throws -> Future<Token> { //Future<Token>를 반환한다.
        let user = try req.requireAuthenticated(User.self)
        //request에서 인증된 사용자를 가져온다.
        //HTTP basic authentication 미들웨어로 이 경로를 보호한다. 이렇게 하면, request의 인증 캐시에 사용자 id가 저장되어 나중에 사용자 객체를 검색할 수 있다.
        //인증된 사용자가 없으면 requireAuthenticated(_:)가 인증 오류를 발생시킨다.
        let token = try Token.generate(for: user) //사용자 토큰 생성
        
        return token.save(on: req) //토큰을 저장하고 반환
    }
}

//Password storage
//Codable을 구현 했으므로, 사용자를 만들 때 추가로 변경할 필요 없다.
//기존의 UserController는 JSON에서 password 속성을 자동으로 찾는다.
//하지만, 추가적인 작업이 없으면 String으로 password를 저장하게 된다.
//Password는 일반 텍스트로 저장하면 안 된다. 항상 안전한 방법으로 암호를 저장해야 한다.
//BCrypt는 암호 해싱의 표준이며 Vapor에 내장되어 있다. 단방향 해싱 알고리즘으로, 암호를 해시로 변환할 수 있지만, 해시를 다시 암호로 변환할 수 없다.
//대신, BCrypt는 암호와 해시를 사용해 암호를 확인하는 메커니즘을 제공한다.
