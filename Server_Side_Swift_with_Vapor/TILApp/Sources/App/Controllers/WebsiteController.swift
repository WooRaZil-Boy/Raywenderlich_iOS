import Vapor
import Leaf
import Fluent
import Authentication

struct WebsiteController: RouteCollection {
    //Website 관리하는 객체. API와 달리 보여지는 뷰가 있어여 한다.
    func boot(router: Router) throws {
        //RouteCollection에서는 반드시 이 메서드를 구현해야 한다.
        
//        router.get(use: indexHandler)
//        //router의 경로로 GET request. 등록된 메서드(indexHandler)를 처리한다. 경로는 http://localhost:8080/ 가 된다.
//        router.get("acronyms", Acronym.parameter, use: acronymHandler)
//        //acronyms 상세보기 페이지 GET request. 경로는 http://localhost:8080/acronyms/<ID> 가 된다.
//        router.get("users", User.parameter, use: userHandler)
//        //user 보기 페이지 GET request. 경로는 http://localhost:8080/users/<ID> 가 된다.
//        router.get("users", use: allUsersHandler)
//        //모든 user 보기 페이지 GET request. 경로는 http://localhost:8080/users 가 된다.
//        router.get("categories", use: allCategoriesHandler)
//        //모든 category 보기 페이지 GET request. 경로는 http://localhost:8080/categories 가 된다.
//        router.get("categories", Category.parameter, use: categoryHandler)
//        //category 보기 페이지 GET request. 경로는 http://localhost:8080/categories/<ID> 가 된다.
//        router.get("acronyms", "create", use: createAcronymHandler)
//        //acronym 생성 페이지 GET request. 경로는 http://localhost:8080/acronyms/create 가 된다.
////        router.post(Acronym.self, at: "acronyms", "create", use: createAcronymPostHandler)
//        router.post(CreateAcronymData.self, at: "acronyms", "create", use: createAcronymPostHandler)
//        //acronym 생성 페이지 POST request. 경로는 http://localhost:8080/acronyms/create 가 된다.
//        router.get("acronyms", Acronym.parameter, "edit", use: editAcronymHandler)
//        //acronym 수정 페이지 GET request. 경로는 http://localhost:8080/acronyms/<ID>/edit 가 된다.
//        router.post("acronyms", Acronym.parameter, "edit", use: editAcronymPostHandler)
//        //acronym 수정 페이지 POST request. 경로는 http://localhost:8080/acronyms/<ID>/edit 가 된다.
//        router.post("acronyms", Acronym.parameter, "delete", use: deleteAcronymHandler)
//        //acronym 삭제 페이지 POST request. 경로는 http://localhost:8080/acronyms/<ID>/delete 가 된다.
//        //브라우저는 페이지 request를 요청하는 GET과 form을 사용해 데이터를 보내는 POST request만 보낼 수 있다.
//        //cf. JavaScript로 DELETE request를 보낼 수도 있다.
//        //따라서 POST request를 삭제 경로에 보내야 한다.
//        router.get("login", use: loginHandler)
//        //로그인 페이지 GET request. 경로는 http://localhost:8080/login 가 된다.
//        router.post(LoginPostData.self, at: "login", use: loginPostHandler)
//        //로그인 페이지 POST request. 경로는 http://localhost:8080/login 가 된다.
        
        
        
        
        let authSessionRoutes = router.grouped(User.authSessionsMiddleware())
        //이 미들웨어는 request에서 쿠키를 읽고 응용 프로그램의 세션 목록에서 세션 id를 조회한다.
        //세션에 사용자가 포함되어 있으면 AuthenticationSessionsMiddleware가
        //이를 AuthenticationCache에 추가하여 나중에 해당 프로세스에서 사용자를 사용할 수 있게 한다.
        
        //Protecting routes
        //API에서 GuardAuthenticationMiddleware를 사용하여 request에 인증된 사용자가 포함된 것을 확인한다.
        //이 미들웨어는 사용자가 없으면 인증 오류를 발생시켜 클라이언트에 대한 401 Unauthorized response 를 발생시킨다.
        //웹에서 이것은 좋은 UX가 아니다. 대신 RedirectMiddleware를 사용하여 로그인하지 않고 보호된 경로에 액세스 하려 할 때 로그인 페이지로 리디렉션한다.
        //이 리디렉션을 사용하려면 먼저 브라우저에서 보낸 세션 쿠키를 인증된 사용자로 변환해야 한다.
        
        authSessionRoutes.get(use: indexHandler)
        //router의 경로로 GET request. 등록된 메서드(indexHandler)를 처리한다. 경로는 http://localhost:8080/ 가 된다.
        authSessionRoutes.get("acronyms", Acronym.parameter, use: acronymHandler)
        //acronyms 상세보기 페이지 GET request. 경로는 http://localhost:8080/acronyms/<ID> 가 된다.
        authSessionRoutes.get("users", User.parameter, use: userHandler)
        //user 보기 페이지 GET request. 경로는 http://localhost:8080/users/<ID> 가 된다.
        authSessionRoutes.get("users", use: allUsersHandler)
        //모든 user 보기 페이지 GET request. 경로는 http://localhost:8080/users 가 된다.
        authSessionRoutes.get("categories", use: allCategoriesHandler)
        //모든 category 보기 페이지 GET request. 경로는 http://localhost:8080/categories 가 된다.
        authSessionRoutes.get("categories", Category.parameter, use: categoryHandler)
        //category 보기 페이지 GET request. 경로는 http://localhost:8080/categories/<ID> 가 된다.
        authSessionRoutes.get("login", use: loginHandler)
        //로그인 페이지 GET request. 경로는 http://localhost:8080/login 가 된다.
        authSessionRoutes.post(LoginPostData.self, at: "login", use: loginPostHandler)
        //로그인 페이지 POST request. 경로는 http://localhost:8080/login 가 된다.
        authSessionRoutes.post("logout", use: logoutHandler)
        //로그아웃 페이지 POST request. 경로는 http://localhost:8080/logout 이 된다.
        //응용 프로그램 상태를 변견하는 모든 것은 항상 POST request를 사용해야 한다.
        //최신 브라우저는 GET request를 미리 가져오므로 POST를 사용하지 않으면 사용자가 예기치 않게 로그아웃 될 수 있다.
        authSessionRoutes.get("register", use: registerHandler)
        //가입 페이지 GET request. 경로는 http://localhost:8080/register 가 된다.
        authSessionRoutes.post(RegisterData.self, at: "register", use: registerPostHandler)
        //가입 페이지 POST request. 경로는 http://localhost:8080/register 가 된다.
        
        //이렇게 authSessionRoutes를 추가시켜 놓으면, 페이지에서 User를 사용할 수 있다.
        //지금 당장은 사용하지 않는 페이지도 있지만, 원하는 페이지에 사용자 별 콘텐츠(ex. 프로필 등)을 표시하는 데 유용하다.
        
        let protectedRoutes = authSessionRoutes
            .grouped(RedirectMiddleware<User>(path: "/login"))
        //authSessionRoutes에서 확장되는 RedirectMiddleware를 포함한 새 route 그룹을 생성한다.
        //응용 프로그램은 route handler에 도달하기 전에 RedirectMiddleware로 request를 실행한다.
        //하지만 RedirectMiddleware은 AuthenticationSessionsMiddleware 다음에 request를 실행한다.
        //그래야 RedirectMiddleware가 인증된 사용자를 확인할 수 있다.
        //RedirectMiddleware는 인증되지 않은 사용자를 리디렉션할 경로와 확인할 인증 가능 유형(여기서는 User)을 지정해야 한다.
        
        protectedRoutes.get("acronyms", "create", use: createAcronymHandler)
        //acronym 생성 페이지 GET request. 경로는 http://localhost:8080/acronyms/create 가 된다.
        protectedRoutes.post(CreateAcronymData.self, at: "acronyms", "create", use: createAcronymPostHandler)
        //acronym 생성 페이지 POST request. 경로는 http://localhost:8080/acronyms/create 가 된다.
        protectedRoutes.get("acronyms", Acronym.parameter, "edit", use: editAcronymHandler)
        //acronym 수정 페이지 GET request. 경로는 http://localhost:8080/acronyms/<ID>/edit 가 된다.
        protectedRoutes.post("acronyms", Acronym.parameter, "edit", use: editAcronymPostHandler)
        //acronym 수정 페이지 POST request. 경로는 http://localhost:8080/acronyms/<ID>/edit 가 된다.
        protectedRoutes.post("acronyms", Acronym.parameter, "delete", use: deleteAcronymHandler)
        //acronym 삭제 페이지 POST request. 경로는 http://localhost:8080/acronyms/<ID>/delete 가 된다.
        //브라우저는 페이지 request를 요청하는 GET과 form을 사용해 데이터를 보내는 POST request만 보낼 수 있다.
        //cf. JavaScript로 DELETE request를 보낼 수도 있다.
        //따라서 POST request를 삭제 경로에 보내야 한다.
        
        //보안이 필요한 경로를 protectedRoutes에 등록한다.
    }
    
    func indexHandler(_ req: Request) throws -> Future<View> { //Future<View> 반환
        //Index page
        return Acronym.query(on: req)
            .all() //DB의 모든 Acronym을 가져온다.
            .flatMap(to: View.self) { acronyms in
                let acronymsData = acronyms.isEmpty ? nil : acronyms //비어 있는 경우 : 1개라도 있는 경우
                let userLoggedIn = try req.isAuthenticated(User.self)
                //request에 인증된 사용자가 있는지 확인한다.
                let showCookieMessage = req.http.cookies["cookies-accepted"] == nil
                //cookies-accepted라는 쿠키가 있는지 확인한다. 존재하지 않으면 true
                let context = IndexContext(title: "Homepage",
                                           acronyms: acronymsData,
                                           userLoggedIn: userLoggedIn,
                                           showCookieMessage: showCookieMessage)
                //title과 Acronym 배열을 포함하는 IndexContext를 생성한다.
                
                return try req.view().render("index", context) //IndexContext를 템플릿에 전달한다.
                //템플릿을 렌더링하고, 결과를 반환한다.
                //렌더러를 얻기 위해 일반적으로 req.view()를 사용하면 다른 템플릿 엔진으로 쉽게 전환할 수 있다.
                //req.view()에 Vapor에 ViewRenderer를 준수하는 유형을 사용해야 한다.
                //Leaf가 빌드된 모듈인 TemplateKit은 PlaintextRenderer를 제공하고, Leaf는 LeafRenderer를 제공한다.
                
                //기본적으로 Leaf 템플릿은 Resources/Views 에 위치해야 한다.
                //Leaf는 Resources/Views 디렉토리의 index.leaf라는 템플릿에서 페이지를 생성한다(render 파라미터로 확장자는 생략한다).
            }
    }
    
    func acronymHandler(_ req: Request) throws -> Future<View> { //Future<View> 반환
        //Acronym detail page
        return try req.parameters.next(Acronym.self)
            //매개 변수에서 Acronym를 추출하고
            .flatMap(to: View.self) { acronym in
                //flatMap으로 result를 unwrapping한다.
                return acronym.user //acronym의 user를 가져오고
                    .get(on: req)
                    .flatMap(to: View.self) { user in //flatMap으로 result를 unwrapping한다.
//                        let context = AcronymContext(title: acronym.short, acronym: acronym, user: user)
//                        //세부 정보가 있는 AcronymContext를 생성
                        let categories = try acronym.categories.query(on: req).all()
                        let context = AcronymContext(
                            title: acronym.short,
                            acronym: acronym,
                            user: user,
                            categories: categories)
                        //카테고리 정보를 추가한 AcronymContext 생성
                        //Future를 Leaf로 넘겨, 이것이 필요할 때 처리한다.
                        
                        return try req.view().render("acronym", context)
                        //acronym.leaf 템플릿을 사용해서 페이지를 렌더링한다.
                    }
            }
    }
    
    func userHandler(_ req: Request) throws -> Future<View> { //Future<View> 반환
        //User page
        return try req.parameters.next(User.self)
            //매개 변수에서 User를 추출하고
            .flatMap(to: View.self) { user in
                //flatMap으로 result를 unwrapping한다.
                return try user.acronyms //user의 acronyms를 가져오고
                    .query(on: req)
                    .all()
                    .flatMap(to: View.self) { acronyms in //flatMap으로 result를 unwrapping한다.
                        let context = UserContext(title: user.name, user: user, acronyms: acronyms)
                        //세부 정보가 있는 UserContext를 생성
                        
                        return try req.view().render("user", context)
                        //user.leaf 템플릿을 사용해서 페이지를 렌더링한다.
                    }
            }
    }
    
    func allUsersHandler(_ req: Request) throws -> Future<View> { //Future<View> 반환
        //All User page
        return User.query(on: req)
            .all()
            .flatMap(to: View.self) { users in
                //flatMap으로 result를 unwrapping한다.
                let context = AllUsersContext(title: "All Users", users: users)
                //세부 정보가 있는 AllUsersContext를 생성
                
                return try req.view().render("allUsers", context)
                //allUsers.leaf 템플릿을 사용해서 페이지를 렌더링한다.
            }
    }
    
    func allCategoriesHandler(_ req: Request) throws -> Future<View> { //Future<View> 반환
        //All Category page
        let categories = Category.query(on: req).all() //all() 이후 flatMap할 필요 없다.
        let context = AllCategoriesContext(categories: categories)
        //이전과 달리 AllCategoriesContext에서는 Leaf가 Future를 처리할 수 있으므로 context에 쿼리 결과를 바로 포함한다.
        //AllCategoriesContext의 categories는 Future<[Category]> 타입이다. 따라서 flatMap으로 unwrapping할 필요 없다.
        
        return try req.view().render("allCategories", context)
        //allCategories.leaf 템플릿을 사용해서 페이지를 렌더링한다.
    }
    
    func categoryHandler(_ req: Request) throws -> Future<View> { //Future<View> 반환
        //Category page
        return try req.parameters.next(Category.self)
            //매개 변수에서 Category를 추출하고
            .flatMap(to: View.self) { category in
                //flatMap으로 result를 unwrapping한다.
                let acronyms = try category.acronyms.query(on: req).all() //all() 이후 flatMap할 필요 없다.
                let context = CategoryContext(title: category.name, category: category, acronyms: acronyms)
                //이전과 달리 CategoryContext에서는 Leaf가 Future를 처리할 수 있으므로 context에 쿼리 결과를 바로 포함한다.
                //CategoryContext의 acronyms는 Future<[Acronym]> 타입이다. 따라서 flatMap으로 unwrapping할 필요 없다.
                
                return try req.view().render("category", context)
                //category.leaf 템플릿을 사용해서 페이지를 렌더링한다.
            }
    }
    
    func createAcronymHandler(_ req: Request) throws -> Future<View> { //Future<View> 반환
        //Creating Acronym page for GET
//        let context = CreateAcronymContext(users: User.query(on: req).all()) //all() 이후 flatMap할 필요 없다.
        //모든 User를 가져온다.
        //CreateAcronymContext에서는 Leaf가 Future를 처리할 수 있으므로 context에 쿼리 결과를 바로 포함한다.
        //CreateAcronymContext의 acronyms는 Future<[User]> 타입이다. 따라서 flatMap으로 unwrapping할 필요 없다.
        
        let token = try CryptoRandom()
            .generateData(count: 16)
            .base64EncodedString()
        //base64로 인코딩된 임의 생성 16바이트 데이터를 사용해 토큰을 생성한다.
        let context = CreateAcronymContext(csrfToken: token)
        //Session에서 User를 가져오므로 쿼리해서 가져올 필요 없어진다.
        //생성된 토큰으로 CreateAcronymContext생성
        
        try req.session()["CSRF_TOKEN"] = token
        //토큰을 request session의 "CSRF_TOKEN" 키로 저장한다.
        //Vapor는 다양한 request에 따라 session에서 토큰을 지속한다.
        //사용자가 새로운 request를 하고 세션을 식별하는 쿠키를 제공하면 모든 세션 데이터를 사용할 수 있다.
        
        return try req.view().render("createAcronym", context)
        //createAcronym.leaf 템플릿을 사용해서 페이지를 렌더링한다.
    }
    
//    func createAcronymPostHandler(_ req: Request, acronym: Acronym) throws -> Future<Response> { //Future<Response> 반환
//        //Creating Acronym page for POST //Vapor는 form 데이터를 Acronym으로 자동 디코딩한다.
//        return acronym.save(on: req).map(to: Response.self) { acronym in
//            //매개 변수의 Acronym을 DB에 저장. //unwrapping한다.
//            //map()과 flatMap()은 모두 Future를 다른 유형의 Future로 매핑한다.
//            //단, 클로저의 매개 변수(in 앞의 값)가 map()에서는 실제 값이이고, flatMap()에서는 Futrue이다.
//            guard let id = acronym.id else { //id 유효성 확인
//                throw Abort(.internalServerError)
//                //500 Internal Server Error
//            }
//
//            return dreq.redirect(to: "/acronyms/\(id)")
//            //새로 생성된 acronym 상세 정보 페이지로 redicrection 한다.
//        }
//    }
    
    func createAcronymPostHandler(_ req: Request, data: CreateAcronymData) throws -> Future<Response> { //Future<Response> 반환
        //Creating Acronym page for POST //Category를 설정할 수 있는 CreateAcronymData로 변경한다.
        let expectedToken = try req.session()["CSRF_TOKEN"] //request session에서 토큰을 가져온다.
        //createAcronymHandler(_:) 에서 저장한 토큰
        try req.session()["CSRF_TOKEN"] = nil //토큰을 지운다. 각 form은 새 토큰을 생성해야 한다.
        
        guard expectedToken == data.csrfToken else { //제공된 토큰이 hidden input에서 전송된 토큰과 일치하는 지 확인한다.
            throw Abort(.badRequest) //일치하지 않는다면 400 Bad Request error
        }
        
        let user = try req.requireAuthenticated(User.self) //로그인 된 User를 가져온다.
        let acronym = try Acronym(short: data.short, long: data.long, userID: user.requireID())
        //저장할 acronym 객체 생성
        
        return acronym.save(on: req)
            .flatMap(to: Response.self) { acronym in
                //매개 변수의 Acronym을 DB에 저장. //unwrapping한다.
                //map()과 flatMap()은 모두 Future를 다른 유형의 Future로 매핑한다.
                //단, 클로저의 매개 변수(in 앞의 값)가 map()에서는 실제 값이이고, flatMap()에서는 Futrue이다.
                //여기서는 Future<Response>를 반환하므로 map(to :) 대신 flatMap(to :)을 써야 한다.
                guard let id = acronym.id else { //id 유효성 확인
                    throw Abort(.internalServerError)
                    //500 Internal Server Error
                }
                
                var categorySaves: [Future<Void>] = []
                //카테고리를 저장할 Future 배열
                
                for category in data.categories ?? [] {
                    try categorySaves.append(
                        Category.addCategory(category, to: acronym, on: req))
                    //카테고리 관계를 설정하고 배열에 추가
                }
                
                let redirect = req.redirect(to: "/acronyms/\(id)")
                
                return categorySaves.flatten(on: req) //모든 Fluent 작업을 완료하고, 결과를 Response로 변환하기 위해 flatten
                    .transform(to: redirect) //새로 생성된 acronym 상세 정보 페이지로 redicrection 한다.
            }
    }
    
    //웹 응용 프로그램에서 Acronym을 생성하려면 두 개의 경로를 구현해야 한다.
    //Acronym 생성 시 정보를 입력하는 GET request와, 입력된 정보를 DB로 보내 생성하고 승인하는 POST request가 필요하다.
    //Acronym 생성 페이지에는 모든 User의 목록이 있어야 생성시, 소유 User 목록을 선택하게 할 수 있다.
    
    func editAcronymHandler(_ req: Request) throws -> Future<View> { //Future<View> 반환
        //Editing Acronym page for GET
        return try req.parameters.next(Acronym.self)
            .flatMap(to: View.self) { acronym in
//                let context = EditAcronymContext(acronym: acronym, users: User.query(on: req).all())
//                //Acronym을 편집하여 모든 User 를 전달하는 Context
//                //모든 User를 가져온다.
//                let users = User.query(on: req).all() //모든 user를 가져온다
                let categories = try acronym.categories.query(on: req).all() //모든 category를 가져온다
//                let context = EditAcronymContext(acronym: acronym, users: users, categories: categories)
                let context = EditAcronymContext(acronym: acronym, categories: categories)
                //Acronym을 편집하여 모든 Category 를 전달하는 Context
                
                return try req.view().render("createAcronym", context)
                //createAcronym.leaf 템플릿을 사용해서 페이지를 렌더링한다.
            }
    }
    
//    func editAcronymPostHandler(_ req: Request) throws -> Future<Response> { //Future<Response> 반환
//        //Editing Acronym page for POST
//        return try flatMap(to: Response.self, req.parameters.next(Acronym.self), req.content.decode(Acronym.self)) { acronym, data in
//            //파라미터로 to: Response(최종 반환형), id로 요청해서 가져온 객체(수정할 객체), 디코딩 객체(form 에서 입력한 정보)
//
//            acronym.short = data.short
//            acronym.long = data.long
//            acronym.userID = data.userID
//            //Acronym 업데이트
//
//            return acronym.save(on: req) //DB에 저장
//                .map(to: Response.self) { savedAcronym in
//                    //반환된 Futuref를 unwrapping
//                    guard let id = savedAcronym.id else { //id가 유효한지 확인
//                        throw Abort(.internalServerError)
//                        //500 Internal Server
//                    }
//
//                    return req.redirect(to: "/acronyms/\(id)")
//                    //업데이트가 된 acronym 상세 정보 페이지로 redicrection 한다.
//                }
//            }
//    }
    
    func editAcronymPostHandler(_ req: Request) throws -> Future<Response> {
        return try flatMap(to: Response.self,
                           req.parameters.next(Acronym.self),
                           req.content
                            //파라미터로 to: Response(최종 반환형), id로 요청해서 가져온 객체(수정할 객체), 디코딩 객체(form 에서 입력한 정보)
                            .decode(CreateAcronymData.self)) { acronym, data in
                                let user = try req.requireAuthenticated(User.self)
                                //로그인된 사용자를 가져온다.
                                
                                acronym.short = data.short
                                acronym.long = data.long
                                acronym.userID = try user.requireID()
                                
                                return acronym.save(on: req)
                                    .flatMap(to: Response.self) { savedAcronym in
                                        //클로저가 Future를 반환하므로 flatMap을 사용해야 한다.
                                        guard let id = savedAcronym.id else {
                                            throw Abort(.internalServerError)
                                        }
                                        
                                        return try acronym.categories.query(on: req).all()
                                            .flatMap(to: Response.self) { existingCategories in //모든 카테고리 가져온다.
                                                let existingStringArray = existingCategories.map { $0.name }
                                                //카테고리의 이름을 가져온다.
                                                
                                                let existingSet = Set<String>(existingStringArray) //카테고리에 대한 Set 생성
                                                let newSet = Set<String>(data.categories ?? []) //request data이 카테고리 Set
                                                
                                                let categoriesToAdd = newSet.subtracting(existingSet) //추가할 카테고리 Set
                                                let categoriesToRemove = existingSet.subtracting(newSet) //삭제할 카테고리 Set
                                                
                                                var categoryResults: [Future<Void>] = [] //작업 결과
                                                
                                                for newCategory in categoriesToAdd { //추가하려는 모든 카테고리 반복하여
                                                    categoryResults.append(try Category.addCategory(
                                                        newCategory,
                                                        to: acronym,
                                                        on: req))
                                                    //배열에 추가하고 관계 설정
                                                }
                                                
                                                for categoryNameToRemove in categoriesToRemove { //제거하려는 모든 카테고리 반복
                                                    let categoryToRemove = existingCategories.first {
                                                        $0.name == categoryNameToRemove
                                                        //제거할 카테고리 이름에서 Category 객체를 가져온다.
                                                    }
                                                    
                                                    if let category = categoryToRemove {
                                                        categoryResults.append(acronym.categories.detach(category, on: req))
                                                        //카테고리가 있다면, detach로 관계 제거하고 피벗 삭제
                                                    }
                                                }
                                                
                                                return categoryResults
                                                    .flatten(on: req)
                                                    .transform(to: req.redirect(to: "/acronyms/\(id)"))
                                                    //업데이트가 된 acronym 상세 정보 페이지로 redicrection 한다.
                                        }
                                }
                                
                                
        }
    }
    
    //웹 응용 프로그램에서 Acronym을 수정하려면 두 개의 경로를 구현해야 한다.
    //Acronym 수정 시 정보를 입력하는 GET request와, 입력된 정보를 DB로 보내 생성하고 승인하는 POST request가 필요하다.
    //Acronym 생수정 페이지에는 모든 User의 목록이 있어야 생성시, 소유 User 목록을 선택하게 할 수 있다.
    
    func deleteAcronymHandler(_ req: Request) throws -> Future<Response> { //Future<Response> 반환
        //Deleting Acronym page
        //삭제는 위의 Creat, Update와 달리 단일 경로만 있으면 된다.
        //그러나, 웹 브라우저에서는 DELETE request를 보내는 간단한 방법이 없다.
        //브라우저는 페이지 request를 요청하는 GET과 form을 사용해 데이터를 보내는 POST request만 보낼 수 있다.
        //cf. JavaScript로 DELETE request를 보낼 수도 있다.
        //따라서 POST request를 삭제 경로에 보내야 한다.
        //이전 AcronymsController에서는 따로 HTML문서 없이 API JSON만 보내므로 상관 없었다.
        return try req.parameters.next(Acronym.self).delete(on: req)
            //Request의 매개변수에서 Acronym을 추출하고, delete(on :) 호출해 삭제
            .transform(to: req.redirect(to: "/"))
            //삭제 후 root 페이지로 redicrection 한다.
    }
    
    
    
    
    //Log in
    func loginHandler(_ req: Request) throws -> Future<View> { //Future<View> 반환
        //Log in page for GET
        let context: LoginContext
        
        if req.query[Bool.self, at: "error"] != nil { //request에 error가 있을 시
            context = LoginContext(loginError: true)
        } else {
            context = LoginContext()
        }
        
        return try req.view().render("login", context)
        //login.leaf 템플릿을 사용해서 페이지를 렌더링한다.
    }
    
    func loginPostHandler(_ req: Request, userData: LoginPostData) throws -> Future<Response> { //Future<Response> 반환
        //Log in page for POST
        return User.authenticate(username: userData.username, password: userData.password, using: BCryptDigest(), on: req)
            .map(to: Response.self) { user in
                //User를 생성한다. 문제가 있으면 nil을 반환한다.
                guard let user = user else { //인증된 사용자를 반환했는지 확인
                    return req.redirect(to: "/login?error")
                    //오류가 있으면 로그인 페이지로 redirection
                }
                
                try req.authenticateSession(user) //request session 인증
                //인증된 사용자가 session에 저장되어 Vapor 가 이후 request에서 이를 검색할 수 있다.
                //사용자가 로그인할 때 Vapor가 인증을 유지하는 방법이다.
                
                return req.redirect(to: "/")
                //로그인이 성공하면 홈페이지 메인 화면으로 redirection
        }
    }
    
    //로그인 구현에는 필요한 정보를 입력 받는 GET page와 해당 페이지의 POST request를 처리하는 페이지, 2개의 페이지가 필요하다.
    
    func logoutHandler(_ req: Request) throws -> Response { //Response 반환 //이 메서드에 비동기 작업이 없으므로 Future를 반환할 필요 없다.
        //Log out
        try req.unauthenticateSession(User.self)
        //unauthenticateSession를 호출해 세션의 사용자를 삭제한다.
        
        return req.redirect(to: "/")
        //홈페이지 메인 화면으로 redirection
    }
    
    
    
    
    //Register
    func registerHandler(_ req: Request) throws -> Future<View> { //Future<View> 반환
        //Register page for GET
        let context: RegisterContext
        
        if let message = req.query[String.self, at: "message"] { //message 존재하는 경우
            //경로가 /register?message=some-string 인 경우
            context = RegisterContext(message: message)
        } else {
            context = RegisterContext()
        }
        
        return try req.view().render("register", context)
        //register.leaf 템플릿을 사용해서 페이지를 렌더링한다.
    }
    
    func registerPostHandler(_ req: Request, data: RegisterData) throws -> Future<Response> { //Future<Response> 반환
        //Register in page for POST
        do {
            try data.validate() //유효성 검사를 한다(RegisterData가 Validatable를 구현했다).
            //validate()는 ValidationError를 발생시킬 수 있다.
            //API에서는 이 오류를 사용자에게 전달하는 것이 좋지만, 웹 사이트에서는 UX를 고려해야 한다.
        } catch (let error) { //오류 시
            //ValidationError에서 message를 추출해 URL에 포함되도록 한다.
            let redirect: String
            
            if let error = error as? ValidationError,
                let message = error.reason.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                redirect = "/register?message=\(message)"
            } else {
                redirect = "/register?message=Unknown+error"
            }
            
            return req.future(req.redirect(to: redirect))
            //register 페이지로 redirection
        }
        
        let password = try BCrypt.hash(data.password) //password 해시
        
        var twitterURL: String?
        
        if let twitter = data.twitterURL, !twitter.isEmpty { //twitterURL 이 있으면 추가. 없으면 nil
            twitterURL = twitter
        }
        
        let user = User(name: data.name, username: data.username, password: password, twitterURL: twitterURL)
        //user 생성
        
        return user.save(on: req).map(to: Response.self) { user in
            //새로운 user 저장하고 반환된 future를 unwarpping한다.
            try req.authenticateSession(user) //새 사용자에 대한 세션 인증
            //이렇게 하면 등록 할 때 자동으로 사용자를 기록하므로 사이트에 가입할 때 향상된 UX를 제공한다.
            
            return req.redirect(to: "/")
            //홈페이지 메인 화면으로 redirection
        }
    }
}

struct IndexContext: Encodable {
    //메인 페이지에서 보여줄 타이틀과, 각 acronyms를 가지고 있는 Encodable 유형
    let title: String
    let acronyms: [Acronym]? //Acronym 배열
    //Acronym이 DB에 하나도 없는 경우가 있으므로 optional이다.
    
    //leaf 파일에서 #()는 Leaf 함수를 나타낸다.
    //이 함수의 파라미터를 사용해 데이터를 가져올 수 있다.
    //데이터는 오직 Leaf에서만 처리되기 때문에, Encodable만 구현하면됩니다.
    //즉, IndexContext는 MVVM 디자인 패턴의 View Model과 비슷한 view에 데이터를 전달해 주는 역할이다.
    let userLoggedIn: Bool
    //로그인한 사용자가 있음을 알리기 위해 설정하는 flag
    let showCookieMessage: Bool
    //쿠키 동의 여부
}

struct AcronymContext: Encodable {
    //하나의 acronym의 세부 정보를 표시하는 페이지의 Encodable 유형
    let title: String
    let acronym: Acronym
    let user: User
    let categories: Future<[Category]>
}

struct UserContext: Encodable {
    //User 정보를 표시하는 페이지의 Encodable 유형
    let title: String
    let user: User
    let acronyms: [Acronym]
}

struct AllUsersContext: Encodable {
    //모든 User 정보를 표시하는 페이지의 Encodable 유형
    let title: String
    let users: [User]
}

struct AllCategoriesContext: Encodable {
    //모든 Category 정보를 표시하는 페이지의 Encodable 유형
    let title = "All Categories"
    let categories: Future<[Category]>
    //Leaf에서도 Future를 처리할 수 있다.
    //Handler에서 wrapping된 Future에 접근할 필요 없을 경우 이렇게 선언하면, 코드를 간단하게 정리할 수 있다.
}

struct CategoryContext: Encodable {
    //Category 정보를 표시하는 페이지의 Encodable 유형
    let title: String
    let category: Category //title을 설정하려면 카테고리의 이름이 필요하므로 Future<Category>가 아니다.
    //따라서 handler에서 해당 속성의 Future를 unwrapping해야 한다.
    let acronyms: Future<[Acronym]>
    //Leaf에서도 Future를 처리할 수 있다.
    //Handler에서 wrapping된 Future에 접근할 필요 없을 경우 이렇게 선언하면, 코드를 간단하게 정리할 수 있다.
}

struct CreateAcronymContext: Encodable {
    //Acronym 생성 페이지의 Encodable 유형
    let title = "Create An Acronym"
//    let users: Future<[User]>
    //Leaf에서도 Future를 처리할 수 있다.
    //Handler에서 wrapping된 Future에 접근할 필요 없을 경우 이렇게 선언하면, 코드를 간단하게 정리할 수 있다.
    
    //Session이 사용자 정보를 가지고 있게 되면서, leaf 템플릿이 더 이상 사용자를 쓸 필요없어진다.
    
    let csrfToken: String //템플릿(leaf)에 전달한 CRSF 토큰
    //세션은 인증을 비롯한 여러 시나리오에서 유용하게 사용된다.
    //ross-Site Request Forgery(CSRF: 사이트 간 요청 위조) 방지에도 사용할 수 있다.
    //CSRF는 예기치 않거나 의도치 않은 POST request를 보내는 것이다.
    //사용자가 로그인한 경우, 사이트는 아무 문제없이 request를 처리한다.
    //현재까지 구현된 웹 사이트는 이미 인증된 사용자가 POST 요청을 보내도록 속이면, 응용 프로그램은 작동한다(ex. Acronym 생성).
    //이 문제를 해결하는 일반적인 방법은 CSRF 토큰을 form에 포함시키는 것이다.
    //응용 프로그램은 POST request를 받으면 CSRF 토큰이 form에서 발행된 토큰과 일치하는지 확인한다.
    //토큰이 일치하면 응용 프로그램이 request를 처리한다. 그렇지 않으면 거부한다.
}

struct EditAcronymContext: Encodable {
    //Acronym 수정 페이지의 Encodable 유형
    let title = "Edit Acronym"
    let acronym: Acronym
//    let users: Future<[User]>
    //Leaf에서도 Future를 처리할 수 있다.
    //Handler에서 wrapping된 Future에 접근할 필요 없을 경우 이렇게 선언하면, 코드를 간단하게 정리할 수 있다.
    //Session에서 User를 관리하므로 필요없어진다.
    let editing = true //수정 인지 생성인지 템플릿에 알려주는 flag
    let categories: Future<[Category]>
}

struct CreateAcronymData: Content {
    //Acronym에 생성 페이지의 Encodable 유형. Category를 추가하는 배열이 추가되었다.
//    let userID: User.ID
    //API와 마찬가지로 Web에서도 사용자가 로그인해야 하므로 애플리케이션은 어느 사용자가 Acronym를 생성하고 수정하는 지 알고 있으므로 필요없어 진다.
    //인증된 사용자에서 가져올 수 있다.
    let short: String
    let long: String
    let categories: [String]?
    let csrfToken: String //form이 hidden input으로 보낸 CSRF 토큰
    //ross-Site Request Forgery(CSRF: 사이트 간 요청 위조) 방지에도 사용할 수 있다.
    //CSRF는 예기치 않거나 의도치 않은 POST request를 보내는 것이다.
    //사용자가 로그인한 경우, 사이트는 아무 문제없이 request를 처리한다.
    //현재까지 구현된 웹 사이트는 이미 인증된 사용자가 POST 요청을 보내도록 속이면, 응용 프로그램은 작동한다(ex. Acronym 생성).
    //이 문제를 해결하는 일반적인 방법은 CSRF 토큰을 form에 포함시키는 것이다.
    //응용 프로그램은 POST request를 받으면 CSRF 토큰이 form에서 발행된 토큰과 일치하는지 확인한다.
    //토큰이 일치하면 응용 프로그램이 request를 처리한다. 그렇지 않으면 거부한다.
}

//Vapor와 마찬가지로 Leaf는 Codable을 사용하여 데이터를 처리한다.




//Leaf
//Leaf는 Vapor의 템플릿 언어이다. 템플릿 언어를 사용하면 front에 대한 지식이 많지 않아도 쉽게 HTML을 생성하고 정보를 보낼 수 있다.
//ex. 이 앱에서 모든 Acronym 정보를 알 지 않아도 템플릿을 사용하면, 쉽게 처리할 수 있다.
//템플릿 언어를 사용하면 웹 페이지의 중복을 줄일 수 있다. Acronym에 대한 여러 페이지 대신 단일 템플릿을 작성하고 특정 Acronym에 관련된 정보를 설정한다.
//Acronym를 표시하는 방식을 변경하려는 경우, 한 곳에서만 코드를 변경하면 모든 페이지에 새 형식이 적용된다.
//템플릿 언어를 사용하면, 템플릿을 다른 템플릿에 포함시킬 수도 있다.




//Log in
struct LoginContext: Encodable {
    //로그인 페이지의 Encodable 유형
    //사용자 로그인을 구현하려면 두 개의 route가 필요하다(로그인에 필요한 정보를 입력 받는 GET page와 해당 페이지의 POST request를 처리하는 페이지).
    let title = "Log In"
    let loginError: Bool //로그인 오류를 나타내는 flag
    
    init(loginError: Bool = false) {
        self.loginError = loginError
    }
}

struct LoginPostData: Content {
    //로그인 페이지의 POST 데이터
    let username: String
    let password: String
}


//Cookies
//인증을 구현하기 위해 쿠키를 사용했지만, 때로는 쿠키를 수동으로 설정하고 읽을 수 있다.




//Register
struct RegisterContext: Encodable {
    //가입 페이지의 Encodable 유형
    let title = "Register"
    //The registration page
    //Vapor Validation 라이브러리를 사용하여 사용자가 응용 프로그램을 전송하는 정보 중 일부를 확인할 수 있다.
    
    let message: String? //register page에 표시할 error message
    
    init(message: String? = nil) { //register에 error가 없는 경우 default로 nil
        self.message = message
    }
}

struct RegisterData: Content {
    //가입 페이지의 POST 데이터
    let name: String
    let username: String
    let password: String
    let confirmPassword: String
    let twitterURL: String?
    //register.leaf의 context 변수명과 일치해야 한다.
}




extension RegisterData: Validatable, Reflectable {
    //Validatable를 구현하면 Vapor로 유형을 검증할 수 있다.
    //Reflectable를 구현하면 유형의 내부 구성 요소를 찾는 방법을 제공받을 수 있다.
    static func validations() throws -> Validations<RegisterData> {
        //Validatable을 구현하려면 이 메서드를 구현해야 한다.
        var validations = Validations(RegisterData.self) //해당 모델의 유효성을 검사하는 Validations을 생성한다.
        
        try validations.add(\.name, .ascii) //RegisterData의 name이 ASCII 문자만 포함하도록 한다(일부 국가에선 주의해야 한다).
        //.ascii 유효성 검사는 String 유형에서만 작동한다(Int에서는 작동하지 않는다.).
        try validations.add(\.username, .alphanumeric && .count(3...)) //count(_:)는 Swift Range를 사용한다.
        //RegisterData의 username이 영어 숫자만으로 되어 있고, 길이가 3자 이상인지 확인한다.
        try validations.add(\.password, .count(8...))
        //RegisterData의 password가 8자 이상인지 확인한다.
        
        validations.add("passwords match") { model in //Custom validation
            //Validation의 add(_:_:)를 메서드를 사용해 사용자 정의 유효성 검사를 추가한다.
            //첫 번째 매개변수는 message, 두 번째 매개변수는 유효성 검사가 실패할 경우 throw 해야할 클로저 이다.
            guard model.password == model.confirmPassword else { //password와 confirmPassword 일치 여부 확인
                throw BasicValidationError("passwords don’t match") //BasicValidationError 생성
            }
        }
        
        return validations
    }
    
    //Basic validation
    //Vapor는 데이터 및 모델을 확인하는 데 도움이 되는 유효성(validation) 검사 모듈을 제공한다.
    //Vapor는 Key paths를 사용하므로, 형식에 대한 유효성 검사를 만들 수 있다.
}
