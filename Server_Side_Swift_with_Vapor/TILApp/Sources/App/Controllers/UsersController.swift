import Vapor

struct UsersController: RouteCollection {
    //RouteCollection를 구현해, route를 관리하는 Controller를 구현할 수 있다.
    
    func boot(router: Router) throws {
        //RouteCollection에서는 반드시 이 메서드를 구현해야 한다.
        //필요한 경로들을 정의해 주면 된다.
        
        let usersRoute = router.grouped("api", "users")
        //반복되는 경로에 대해 새 초기 경로 그룹을 생성한다(/api/users).
        
        usersRoute.post(User.self, use: createHandler)
        //생성은 POST 요청을 사용한다. 경로는 http://localhost:8080/api/users 가 된다.
        //POST helper 메서드를 사용해서, request body에서 User 객체로 디코딩한다.
        usersRoute.get(use: getAllHandler)
        //GET 요청을 처리하는 경로. 여기서는 http://localhost:8080/api/users 가 된다.
        usersRoute.get(User.parameter, use: getHandler)
        //GET 요청을 처리하는 경로. 여기서는 http://localhost:8080/api/users/<ID> 가 된다.
        usersRoute.get(User.parameter, "acronyms", use: getAcronymsHandler)
        //Getting the children는 GET 요청을 사용한다. 경로는 http://localhost:8080/api/users/<ID>/acronyms 가 된다.
    }
    
    //Create
    func createHandler(_ req: Request, user: User) throws -> Future<User>  {
        //이 메서드는 매개변수로 User를 가져온다. User는 이미 decode 되었기 때문에 따로 decode()할 필요 없다.
        return user.save(on: req) //Fluent의 모델 저장 메서드
    }
    
    //Retrieve
    func getAllHandler(_ req: Request) throws -> Future<[User]> {
        return User.query(on: req).all() //모든 User 반환
    }
    
    func getHandler(_ req: Request) throws -> Future<User> {
        return try req.parameters.next(User.self)
        //request의 매개 변수로 지정된 User를 반환한다.
    }
    
    
    
    
    //Getting the children
    func getAcronymsHandler(_ req: Request) throws -> Future<[Acronym]> { //Future<[Acronym]>를 반환한다.
        return try req
            .parameters.next(User.self)
            .flatMap(to: [Acronym].self) { user in //request의 매개 변수로 지정된 User를 가져와 flatMap으로 Future를 wrapping한다.
                //flatMap(to:)는 해당하는 유형으로 최종 반환한다.
                try user.acronyms.query(on: req).all()
                //computed property에서 acronym를 가져온다.
            }
    }
}
