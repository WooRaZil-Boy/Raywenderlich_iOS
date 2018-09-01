@testable import App
import Vapor
import XCTest
import FluentPostgreSQL

final class UserTests: XCTestCase {
//    func testUsersCanBeRetrievedFromAPI() throws {
//        let revertEnvironmentArgs = ["vapor", "revert", "--all", "-y"]
//        //응용 프로그램 실행할 인수들
//
//        var revertConfig = Config.default() //Config
//        var revertServices = Services.default() //Service
//        var revertEnv = Environment.testing //Env
//        revertEnv.arguments = revertEnvironmentArgs
//        //실행할 인수들을 설정한다.
//
//        try App.configure(&revertConfig, &revertEnv, &revertServices)
//        let revertApp = try Application(
//            config: revertConfig,
//            environment: revertEnv,
//            services: revertServices)
//        try App.boot(revertApp)
//        //응용 프로그램 설정. revert 명령을 실행하는 다른 Application 객체가 만들어 진다.
//
//        try revertApp.asyncRun().wait()
//        //asyncRund으로 응용 프로그램을 시작하고, revert 실행
//
//        let migrateEnvironmentArgs = ["vapor", "migrate", "-y"]
//        var migrateConfig = Config.default()
//        var migrateServices = Services.default()
//        var migrateEnv = Environment.testing
//        migrateEnv.arguments = migrateEnvironmentArgs
//        try App.configure(&migrateConfig, &migrateEnv, &migrateServices)
//        let migrateApp = try Application(
//            config: migrateConfig,
//            environment: migrateEnv,
//            services: migrateServices)
//        try App.boot(migrateApp)
//        try migrateApp.asyncRun().wait()
//        //마이그레이션을 실행한다.
//        //테스트를 계속하면, User가 추가되면서 실패하기 때문에 위의 코드들을 추가해 시작할 때 DB를 초기화해 준다.
//
//
//
//
//        let expectedName = "Alice"
//        let expectedUsername = "alice"
//        //테스트의 예상 값을 정의한다.
//
//        var config = Config.default()
//        var services = Services.default()
//        var env = Environment.testing
//
//        try App.configure(&config, &env, &services)
//
//        let app = try Application(config: config, environment: env, services: services)
//        try App.boot(app)
//        //main.swift에서와 같이 응용 프로그램을 만든다.
//        //Vapor Application 개체가 만들어지지만 응용 프로그램 실행이 시작되지는 않는다.
//        //이렇게 테스트하면, 테스트 시에 동일한 App.configure(_ : _ : _ :)를 호출할 때
//        //실제 응용 프로그램을 올바르게 구성할 수 있다.
//
//        let conn = try app.newConnection(to: .psql).wait()
//        //DB connection을 생성한다. EventLoop에서 테스트를 실행하지 않으므로 wait()를 사용해 Future가 반환될 때까지 기다린다.
//
//        let user = User(name: expectedName, username: expectedUsername)
//        let savedUser = try user.save(on: conn).wait()
//        _ = try User(name: "Luke", username: "lukes").save(on: conn).wait()
//        //몇 명의 User를 생성해 DB에 저장한다. 두 User 생성 방식은 같다.
//
//        let responder = try app.make(Responder.self)
//        //responder를 생성한다. request에 response하는 객체이다.
//
//        let request = HTTPRequest(method: .GET, url: URL(string: "/api/users")!)
//        //모든 유저 데이터를 가져온다.
//        let wrappedRequest = Request(http: request, using: app)
//        //Request 객체는 HTTPRequest를 래핑한다.
//
//        let response = try responder
//            .respond(to: wrappedRequest)
//            .wait()
//        //요청을 보내고 응답을 받는다.
//
//        let data = response.http.body.data //응답 데이터
//        let users = try JSONDecoder().decode([User].self, from: data!)
//        //데이터를 User 배열로 디코딩한다.
//
//        XCTAssertEqual(users.count, 2) //User 수 일치 확인
//        XCTAssertEqual(users[0].name, expectedName) //name 확인
//        XCTAssertEqual(users[0].username, expectedUsername) //username 확인
//        XCTAssertEqual(users[0].id, savedUser.id) //id 확인
//
//        conn.close()
//        //테스트가 완료되면, DB에 대한 Connection을 해제한다.
//    }
    //공통적인 부분을 묶어서 관리한다.
    
    let usersName = "Alice"
    let usersUsername = "alicea"
    let usersURI = "/api/users/"
    var app: Application!
    var conn: PostgreSQLConnection!
    //모든 테스트에서 공통적으로 사용될 프로퍼티
    
    override func setUp() { //테스트 전에 실행해야 하는 공통적인 코드들은 setUp에서 처리한다.
        try! Application.reset()
        app = try! Application.testable()
        conn = try! app.newConnection(to: .psql).wait()
        //DB를 리셋하고, 테스트용 응용 프로그램과 DB연결을 생성한다.
    }
    
    override func tearDown() { //setUp과 반대로 각 테스트 메서드가 끝난 후에 정리하는 메서드
        conn.close()
        //connection을 닫는다.
    }
    
    func testUsersCanBeRetrievedFromAPI() throws { //공통된 부분을 따로 관리하고, 메서드를 다시 쓴다.
        //이전 테스트와 동일하지만, 코드 관리하기 훨씬 용이하다.
        let user = try User.create(name: usersName, username: usersUsername, on: conn)
        //유저 생성. 저장
        _ = try User.create(on: conn) //default 유저 생성. 저장
        //몇 명의 User를 생성해 DB에 저장한다. 두 User 생성 방식은 같다.
        
        let users = try app.getResponse(to: usersURI, decodeTo: [User.Public].self)
        //Response를 가져온다.
        
        XCTAssertEqual(users.count, 3)
        XCTAssertEqual(users[1].name, usersName)
        XCTAssertEqual(users[1].username, usersUsername)
        XCTAssertEqual(users[1].id, user.id)
        //response 값이 예상 값과 일치하는 지 확인
        //admin user account에 대한 assertion 테스트로 바꿔준다.
    }
    
    func testUserCanBeSavedWithAPI() throws {
        //사용자 저장 테스트
        
        let user = User(name: usersName, username: usersUsername, password: "password")
        //유저 생성 //인증을 사용하는 모델로 업데이트
        
        let receivedUser = try app.getResponse(
            to: usersURI,
            method: .POST,
            headers: ["Content-Type": "application/json"],
            data: user,
            decodeTo: User.Public.self,
            loggedInRequest: true)
        //API에 POST 요청을 보내고 response를 받는다. request body으로 유저 객체를 사용하고,
        //헤더를 JSON 형식으로 설정한다. response는 User 객체로 변환한다.
        
        XCTAssertEqual(receivedUser.name, usersName)
        XCTAssertEqual(receivedUser.username, usersUsername)
        XCTAssertNotNil(receivedUser.id)
        //response 값이 예상 값과 일치하는 지 확인
        
        let users = try app.getResponse(to: usersURI, decodeTo: [User.Public].self)
        //API에서 모든 사용자를 가져온다.
        
        XCTAssertEqual(users.count, 2)
        XCTAssertEqual(users[1].name, usersName)
        XCTAssertEqual(users[1].username, usersUsername)
        XCTAssertEqual(users[1].id, receivedUser.id)
        //DB에 생성 저장된 값이 예상 값과 일치하는 지 확인
        //default로 admin 사용자가 있으므로 새로 생성한 유저는 2번째가 된다.
    }
    
    func testGettingASingleUserFromTheAPI() throws {
        //단일 사용자 검색 테스트
        let user = try User.create(name: usersName, username: usersUsername, on: conn)
        //DB에 사용자 생성 후 저장
        let receivedUser = try app.getResponse(to: "\(usersURI)\(user.id!)", decodeTo: User.Public.self)
        //api/users/<ID> 경로로 User를 가져와 디코딩한다.
        //response에 더 이상 user의 password가 포함되지 않으므로 디코딩 유형을 User.Public으로 변경한다.
        
        XCTAssertEqual(receivedUser.name, usersName)
        XCTAssertEqual(receivedUser.username, usersUsername)
        XCTAssertEqual(receivedUser.id, user.id)
        //생성 시 입력한 값과 DB에서 가져온 유저의 값이 같은 지 확인
    }
    
    func testGettingAUsersAcronymsFromTheAPI() throws {
        let user = try User.create(on: conn)
        //Acronyms에 사용할 사용자
        
        let acronymShort = "OMG"
        let acronymLong = "Oh My God"
        //Acronyms 생성에 사용할 값
        
        let acronym1 = try Acronym.create(
            short: acronymShort,
            long: acronymLong,
            user: user,
            on: conn)
        //Acronym 생성
        
        _ = try Acronym.create(
            short: "LOL",
            long: "Laugh Out Loud",
            user: user,
            on: conn)
        //Acronym 생성
        
        let acronyms = try app.getResponse(to: "\(usersURI)\(user.id!)/acronyms", decodeTo: [Acronym].self)
        // api/users/<USER ID> 에 request를 보내, 생성된 사용자의 Acronym을 가져온다.
        
        XCTAssertEqual(acronyms.count, 2)
        XCTAssertEqual(acronyms[0].id, acronym1.id)
        XCTAssertEqual(acronyms[0].short, acronymShort)
        XCTAssertEqual(acronyms[0].long, acronymLong)
        //예상 값과 일치하는 지 확인
    }
    
    static let allTests = [
        ("testUsersCanBeRetrievedFromAPI",
         testUsersCanBeRetrievedFromAPI),
        ("testUserCanBeSavedWithAPI", testUserCanBeSavedWithAPI),
        ("testGettingASingleUserFromTheAPI",
         testGettingASingleUserFromTheAPI),
        ("testGettingAUsersAcronymsFromTheAPI",
         testGettingAUsersAcronymsFromTheAPI)
    ]
    //Linux 테스트를 위한 변수
}

//Scheme를 TILApp-Package로 변경 후 Command-U 로 테스트를 진행할 수 있다.

//테스트를 위한 DB를 새로 만들어야 한다(name과 port번호도 configure에서 설정해 줘야 한다).
//테스트 DB 또한 Docker 컨테이너로 생성할 수 있다. p.172
//컨테이너 이름과 DB 이름, 포트를 변경해 줘야 한다.




//Updating the tests
//인증을 추가했으므로, 테스트를 업데이트 해야 한다.
