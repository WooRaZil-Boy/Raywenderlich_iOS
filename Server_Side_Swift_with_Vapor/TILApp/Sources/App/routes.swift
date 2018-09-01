import Vapor
import Fluent

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "Hello, world!" example
    router.get("hello") { req in
        //GET 요청 처리하는 경로. http://localhost:8080/hello
        return "Hello, world!"
    }
    
    //CRUD and REST
    //CRUD는 4가지 기본 기능, Create(생성), Retrieve(검색), Update(수정), Delete(삭제)
    //RESTful API는 클라이언트가 애플리케이션에서 CRUD 함수를 호출할 수 있게 한다.
    //일반적으로 모델에 대한 리소스 URL(여기서는 https://localhost:8080/api/acronyms)로 적절한 HTTP request 경로를 정의하여 CRUD 한다.
    //다음과 같은 예가 있다.
    //• GET https://localhost:8080/api/acronyms/ : 모든 acronyms를 가져온다.
    //• POST https://localhost:8080/api/acronyms : 새로운 acronym을 생성한다.
    //• GET https://localhost:8080/api/acronyms/1 : ID가 1 인 acronym을 가져온다.
    //• PUT https://localhost:8080/api/acronyms/1 : ID가 1 인 acronym를 업데이트 한다.
    //• DELETE https://localhost:8080/api/acronyms/1 : ID가 1 인 acronym를 삭제 한다.
    
    //Create
//    router.post("api", "acronyms") { req -> Future<Acronym> in //Future<Acronym> 타입을 반환한다.
//        //POST 요청을 처리하는 경로. 여기서는 http://localhost:8080/api/acronyms 이 된다.
//        return try req.content.decode(Acronym.self)
//            //request JSON을 Codeable을 사용해, Acronym 모델로 디코딩한다.
//            //Acronym이 Content를 구현하므로 간단히 처리할 수 있다.
//            //decode는 Future를 반환한다.
//            .flatMap(to: Acronym.self) { acronym in
//                //디코더가 Future<Acronym>을 반환하므로, flatMap(to:)를 사용한다.
//                return acronym.save(on: req) //Fluent의 모델 저장 메서드
//                //Fluent (Acronym)을 사용하여 모델을 저장한다.
//                //Fluent는 저장되면서 모델을 반환한다(여기서는 Future<Acronym>).
//
//                //Fluent와 Vapor의 Codable을 사용하면 간단히 작업할 수 있다.
//                //Acronym는 Content를 구현했으므로, JSON과 Model간에 쉽게 변환할 수 있다.
//                //Vapor는 손쉽게 response에서 Model을 JSON으로 반환한다.
//        }
//    }
    
    //Retrieve
//    router.get("api", "acronyms") { req -> Future<[Acronym]> in
//        //GET 요청을 처리하는 경로. 여기서는 http://localhost:8080/api/acronyms 이 된다.
//        return Acronym.query(on: req).all() //질의 수행
//        //모든 Acronym를 검색한다.
//
//        //Fluent로 직접 쿼리를 쓰지 않아도 간단하게 구현할 수 있다. 단 DatabaseConnectable를 구현해야 한다.
//        //결국 SQL의 SELECT * FROM Acronyms; 와 같다.
//    }
    
//    router.get("api", "acronyms", Acronym.parameter) { req -> Future<Acronym> in
//        //GET 요청을 처리하는 경로. 여기서는 http://localhost:8080/api/acronyms/<ID> 가 된다.
//        //id 속성을 최종 경로 세그먼트로 사용해 특정 조건을 만족하는 객체만 검색한다. Future<Acronym>를 반환한다.
//        return try req.parameters.next(Acronym.self)
//        //request의 parameters를 사용해서, 해당 조건을 만족하는 객체만 추출한다.
//        //존재하지 않거나 id유형이 잘못된 경우 오류 처리를 해야 한다.
//    }
    
    //Update
//    router.put("api", "acronyms", Acronym.parameter) { req -> Future<Acronym> in
//        //업데이트는 PUT 요청을 사용한다. 경로는 http://localhost:8080/api/acronyms/<ID> 가 된다.
//        //id 속성을 최종 경로 세그먼트로 사용해 특정 조건을 만족하는 객체만 가져온다.
//        //request로 새로운 정보를 가진 데이터를 가져온다. Future<Acronym>를 반환한다.
//        return try flatMap(to: Acronym.self, req.parameters.next(Acronym.self), req.content.decode(Acronym.self)) { acronym, updatedAcronym in
//            //flatMap으로 매개 변수 추출과 디코딩이 완료될 때까지 기다린다.
//            //파라미터로 to: DB의 모델 객체(Acronym), id로 요청해서 가져온 객체(수정할 객체), 디코딩 객체
//            //DB의 객체와 수정할 객체를 가져온다.
//
//            acronym.short = updatedAcronym.short
//            acronym.long = updatedAcronym.long
//            //업데이트
//
//            return acronym.save(on: req) //Fluent의 모델 저장 메서드
//            //Fluent (Acronym)을 사용하여 모델을 저장한다.
//            //Fluent는 저장되면서 모델을 반환한다(여기서는 Future<Acronym>).
//        }
//    }
    
    //Delete
//    router.delete("api", "acronyms", Acronym.parameter) { req -> Future<HTTPStatus> in
//        //삭제는 DELETE 요청을 사용한다. 경로는 http://localhost:8080/api/acronyms/<ID> 가 된다.
//        //id 속성을 최종 경로 세그먼트로 사용해 특정 조건을 만족하는 객체만 가져온다. Future<HTTPStatus>를 반환한다.
//        return try req.parameters.next(Acronym.self)
//            //request의 파라미터에서 삭제할 Acronym 객체를 가져온다.
//            .delete(on: req) //삭제
//            //Future를 unwrapping 하는 대신, Fluent는 해당 Future에서 직접 delete(on :)를 호출 할 수 있다.
//            //이렇게 처리하면, 코드를 정리하고 중첩을 줄일 수 있다.
//            .transform(to: HTTPStatus.noContent)
//            //결과를 204 No Content response로 변환한다. 클라이언트에게 요청이 성공했음을 알려주지만, 리턴할 내용이 없을 때 쓴다.
//    }
    
    
    
    
    //Fluent queries
    //기본적인 CRUD 외에도, Fluent를 사용해 다양한 쿼리를 쉽게 사용할 수 있다.
    
    //Filter
//    router.get("api", "acronyms", "search") { req -> Future<[Acronym]> in
//        //필터링은 GET 요청을 사용한다. 경로는 http://localhost:8080/api/acronyms/search 가 된다.
//        //Future<[Acronym]>를 반환한다.
//        guard let searchTerm = req.query[String.self, at: "term"] else {
//            //URL query string로 검색용어를 만든다. 클라이언트의 경로에 적합하지 않는 정보를 전달할 수도 있어 적절한 경우에만 사용하는 것이 좋다.
//            //req.query.decode(_ :) 를 사용해, Codable로 작업을 할 수도 있다.
//            //최종 경로는 http://localhost:8080/api/acronyms/search?term= 이 된다.
//            throw Abort(.badRequest) //Vapor의 Error
//            //실패하면 400 Bad Request error 를 throw 한다.
//        }
//
////        return Acronym.query(on: req)
////            .filter(\.short == searchTerm) //필터로 short 속성이 searchTerm과 일치하는 acronym을 찾는다.
////            //key paths를 사용하므로, 컴파일러는 속성 및 유형을 필터링하여 안정성을 강화해 런타임 오류를 방지할 수 있다.
////            .all()
//
//        return Acronym.query(on: req).group(.or) { or in
//            //다중 필드를 사용해 필터를 적용하려면, 쿼리를 변경해야 한다. 이 경우에는 group을 사용해 필터링한다.
//            //.or 관계를 사용하는 필터 그룹 생성
//            or.filter(\.short == searchTerm)
//            //그룹에 short 필터 추가
//            or.filter(\.long == searchTerm)
//            //그룹에 long 필터 추가
//        }.all()
//        //두 개의 필터에 하나라도 일치하는 모든 결과를 반환한다.
//    }
    
    //First result
//    router.get("api", "acronyms", "first") { req -> Future<Acronym> in
//        //First result는 GET 요청을 사용한다. 경로는 http://localhost:8080/api/acronyms/first 가 된다.
//        //쿼리의 첫 번째 결과만 필요할 때 사용할 수 있다. 모든 결과를 메모리에 로드하는 대신 하나의 결과만 반환한다.
//        //Future<Acronym>를 반환한다.
//        return Acronym.query(on: req)
//            .first() //첫 결과를 가져온다.
//            //first()를 필터 결과와 같이 모든 쿼리에 적용할 수 있다.
//            .map(to: Acronym.self) { acronym in
//                guard let acronym = acronym else {
//                    //결과가 nil인 경우
//                    throw Abort(.notFound)
//                    //404 Not Found error 발생
//                }
//
//                return acronym //해당 Acronym 반환
//            }
//    }
    
    //Sorting results
//    router.get("api", "acronyms", "sorted") { req -> Future<[Acronym]> in
//        //정렬은 GET 요청을 사용한다. 경로는 http://localhost:8080/api/acronyms/sorted 가 된다.
//        //Future<[Acronym]>를 반환한다.
//        return Acronym.query(on: req)
//            .sort(\.short, .ascending) //정렬할 필드와 순서를 정해 준다. //오름차순 정렬
//            .all()
//    }
    
    
    
    
    //Controller
    //위의 모든 routes 들을 AcronymsController를 사용해 경로를 관리하도록 수정
    let acronymsController = AcronymsController() //Acronym의 경로 처리를 담당하는 Controller 생성
    try router.register(collection: acronymsController) //라우터에 등록한다.
    
    let usersController = UsersController() //User의 경로 처리를 담당하는 Controller 생성
    try router.register(collection: usersController) //라우터에 등록한다.
    
    let categoriesController = CategoriesController() //Category의 경로 처리를 담당하는 Controller 생성
    try router.register(collection: categoriesController) //라우터에 등록한다.
    
    let websiteController = WebsiteController() //Website의 경로를 처리하는 Controller 생성
    try router.register(collection: websiteController) //라우터에 등록한다.
    
    let imperialController = ImperialController() //OAuh2.0 경로를 처리하는 Controller 생성
    try router.register(collection: imperialController) //라우터에 등록한다.
    
    
    
    
    //    // Example of configuring a controller
    //    let todoController = TodoController()
    //    router.get("todos", use: todoController.index)
    //    router.post("todos", use: todoController.create)
    //    router.delete("todos", Todo.parameter, use: todoController.delete)
    //Default 컨트롤러(예제)
}



//Deploying to Vapor Cloud
//Vapor Cloud는 Vapor 응용 프로그램을 호스팅하기 위해 Vapor에서 제작한 PaaS(Platform as a Service)이다.
//서버 구성 및 배포 관리를 단순화하여 코드 작성에 집중할 수 있도록 해 준다.
//Vapor Cloud를 사용하는 응용 프로그램 구성은 cloud.yml에서 작성한다.

//Vapor Toolbox를 사용하면 Vapor Cloud 명령과 상호 작용할 수 있다.
//터미널에서 해당 폴더에서 vapor cloud login 로 로그인 후,
//vapor cloud deploy 로 응용 프로그램을 배포한다.

//Adding a repository
//GitHub repository에 추가해야 Vapor Cloud에 배포할 수 있다.
//생성 후, github ssh를 입력해 주면된다.

//Creating a project and application
//repository에 추가 후 자동으로 커밋이 되면, 애플리케이션을 생성할 지 물어본다.
//프로젝트를 소유할 조직을 선택하고, 프로젝트의 이름을 지정해 주면 된다.
//프로젝트를 Run한 이후에 진행해야 해야 Error가 나지 않는다.
//Slug는 URL의 일부를 구성하는 애플리케이션 고유 식별자이다(중복되어선 안 된다.).

//Setting up hosting
//호스팅 서비스를 추가하면 클라우드에 코드를 배포할 수 있다.
//위에서 선택한 Github URL로 설정할 수 있다.

//Setting up environments
//이후 environment 설정을 묻는다. environment에 대한 이름을 설정해 주면 된다.
//환경 설정은 기본적으로 다른 git 브런치에 적용할 수 있다. master를 지정해 줘도 된다.

//Final configuration
//환경을 구성했으면 해당 환경의 복제본 크기를 선택해야 한다.
//복제본 크기는 응용 프로그램을 호스팅하는 하드웨어로 용량이 클수록 처리 능력이 좋지만, 유료이다.
//다음으로 Vapor Cloud가 DB를 구성할 것인지 묻는다. 현재 SQLite를 사용하고 있으므로 추가적으로 필요하진 않다.
//마지막으로 build type을 설정한다.
//• Incremental : 기존 빌드 아티팩트를 사용해 코드를 컴파일해 빌드시간을 단축한다.
//• Update : 매니페시트에서 허용하는 모든 종속성을 업데이트 한다.
//• Clean : 모든 종속성 밒 기존 빌드 아티팩트를 정리한다.
//초기 빌드는 Clean을 사용하는 것이 좋다.

//Build, deploy and test
//build를 하면, 애플리케이션을 컴파일하고, Docker 이미지를 생성해 Vapor Cloud 컨테이너 저장소에 푸시한다.
//빌드가 끝나면, 앱에 대한 URL과 성공 메시지를 출력한다.




//Docker를 사용해 DB를 호스팅할 수 있다. Docker는 가상 시스템의 오버 헤드없이 시스템에서 독립적인 이미지를 실행할 수 있는 컨테이너 기술이다.
//서로 다른 DB를 생성할 수 있으며 종속성 또는 DB를 서로 간섭하지 않는다.

//Choosing a database
//Vapor의 공식적인 Swift-native driver는 SQLite, MySQL, PostgreSQL이 있다.
//Vapor는 관계형 DB만 지원한다(NoSQL 지원하지 않는다).
//• SQLite : 파일 기반 간단한 관계형 DB. 응용 프로그램에 내장되도록 설계. iOS 같은 단일 프로세스 프로그램에 유용
//  파일 잠금을 사용하여 DB 무결성을 유지하므로 쓰기가 많은 응용프로그램에는 적합하지 않다.
//• MySQL : LAMP web application stack (Linux, Apache, MySQL, PHP)에서 널리 사용되는 관계형 DB
//• PostgreSQL : 확장성 및 표준성에 중점을 둔 오픈소스 DB로 기업용으로 설계되었다.
//  좌표같은 기하학적 기본요소를 지원한다. Fluent는 Dictionary 같은 중첩된 유형을 Postgres에 직접저장하고, 프리미티브를 지원한다.




//Configuring Vapor
//Vapor가 DB를 사용하도록 구성하면, 다음 단계를 수행한다.
//• 해당 DB의 Fluent Provider를 응용 프로그램의 서비스에 추가한다.
//• 데이터베이스를 구성한다.
//• 마이그레이션을 구성한다.
//서비스는 컨테이너에서 생성하고 액세스하는 방법을 말한다. Vapor에서 상호작용하는 가장 일반적인 컨테이너는
//애플리케이션 자체, 요청 및 응답이다. 이 응용프로그램을 사용해 부팅하는데 필요한 서비스를 만들어야 한다.
//해당 요청을 처리하는 동안 암호를 해시하려면 요청 및 응답 컨테이너를 사용해서 BCryptHasher 같은 서비스를 만들어야 한다.

//URL에서 공백을 사용하려면 %20 또는 + 로 인코딩해야 한다.
//ex) http://localhost:8080/api/acronyms/search?term=Oh+My+God




//Deploy to Vapor Cloud
//변경된 사항을 Vapor Cloud에 Deploy 하려면 터미널에서 vapor cloud deploy --env=production --build=incremental -y 를 입력한다.
//이전에서 사용하던 deploy 명령과 동일하지만 추가 매개 변수가 있다.
//production environment에 응용 프로그램을 배포
//새 패키지를 포함하지 않았으므로 incremental build 유형
//확인 화면에서 대기하지 않고 자동으로 배포한다.


