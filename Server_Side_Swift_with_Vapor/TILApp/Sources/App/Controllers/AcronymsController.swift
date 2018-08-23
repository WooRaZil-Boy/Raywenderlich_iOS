import Vapor
import Fluent

struct AcronymsController: RouteCollection {
    //RouteCollection를 구현해, route를 관리하는 Controller를 구현할 수 있다.
    
    func boot(router: Router) throws {
        //RouteCollection에서는 반드시 이 메서드를 구현해야 한다.
        
        let acronymsRoutes = router.grouped("api", "acronyms")
        //모든 REST는 동일한 초기 경로(api/acronyms)를 사용한다.
        //따라서 중복을 피하고, 경로 수정시 관리를 route group을 정의할 수 있다.
        
//        router.get("api", "acronyms", use: getAllHandler)
        acronymsRoutes.get(use: getAllHandler) //route group를 정의했으므로, 간단하게 줄일 수 있다.
        //해당 메서드(GET) 으로, 해당 경로에 (http://localhost:8080/api/acronyms) 핸들러(getAllHandler)를 등록한다.
        //이렇게 구현하면, http://localhost:8080/api/acronyms 에 대한 GET request가 getAllHandler(_:)를 호출하게 된다.
        //routes.swift에서 구현한 것과 동일하다.
        
        //각 메서드들을 등록해 준다.
//        acronymsRoutes.post(use: createHandler)
//        //POST 요청을 처리하는 경로. 여기서는 http://localhost:8080/api/acronyms 이 된다.
        acronymsRoutes.post(Acronym.self, use: createHandler)
        //위의 메서드를 helper를 사용하는 메서드로 대체한다.
        //POST 요청을 처리하는 경로. 여기서는 http://localhost:8080/api/acronyms 이 된다.
        acronymsRoutes.get(Acronym.parameter, use: getHandler)
        //GET 요청을 처리하는 경로. 여기서는 http://localhost:8080/api/acronyms/<ID> 가 된다.
        //id 속성을 최종 경로 세그먼트로 사용해 특정 조건을 만족하는 객체만 검색한다.
        acronymsRoutes.put(Acronym.parameter, use: updateHandler)
        //업데이트는 PUT 요청을 사용한다. 경로는 http://localhost:8080/api/acronyms/<ID> 가 된다.
        //id 속성을 최종 경로 세그먼트로 사용해 특정 조건을 만족하는 객체만 가져온다.
        //request로 새로운 정보를 가진 데이터를 가져온다.
        acronymsRoutes.delete(Acronym.parameter, use: deleteHandler)
        //삭제는 DELETE 요청을 사용한다. 경로는 http://localhost:8080/api/acronyms/<ID> 가 된다.
        //id 속성을 최종 경로 세그먼트로 사용해 특정 조건을 만족하는 객체만 가져온다.
        acronymsRoutes.get("search", use: searchHandler)
        //필터링은 GET 요청을 사용한다. 경로는 http://localhost:8080/api/acronyms/search 가 된다.
        acronymsRoutes.get("first", use: getFirstHandler)
        //First result는 GET 요청을 사용한다. 경로는 http://localhost:8080/api/acronyms/first 가 된다.
        acronymsRoutes.get("sorted", use: sortedHandler)
        //정렬은 GET 요청을 사용한다. 경로는 http://localhost:8080/api/acronyms/sorted 가 된다.
        acronymsRoutes.get(Acronym.parameter, "user", use: getUserHandler)
        //Getting the parent는 GET 요청을 사용한다. 경로는 http://localhost:8080/api/acronyms/<ID>/user 가 된다.
        acronymsRoutes.post(Acronym.parameter, "categories", Category.parameter, use: addCategoriesHandler)
        //형제 관계 생성은 POST 요청을 사용한다. 경로는 http://localhost:8080/api/acronyms/<ID>/categories/<ID> 가 된다.
        acronymsRoutes.get(Acronym.parameter, "categories", use: getCategoriesHandler)
        //형제 관계 검색은 GET 요청을 사용한다. 경로는 http://localhost:8080/api/acronyms/<ID>/categories/ 가 된다.
        acronymsRoutes.delete(Acronym.parameter, "categories", Category.parameter, use: removeCategoriesHandler)
        //형제 관계 삭제는 DELETE 요청을 사용한다. 경로는 http://localhost:8080/api/acronyms/<ID>/categories/<ID> 가 된다.
    }
    
    //Create
//    func createHandler(_ req: Request) throws -> Future<Acronym> { //Future<Acronym> 타입을 반환한다.
//        return try req //request JSON을 Codeable을 사용해, Acronym 모델로 디코딩한다.
//            .content //Acronym이 Content를 구현하므로 간단히 처리할 수 있다.
//            .decode(Acronym.self) //decode는 Future를 반환한다.
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
    
    func createHandler(_ req: Request, acronym: Acronym) throws -> Future<Acronym> {
        //위의 createHandler(_:) 메서드를 대체한다.
        //이 메서드는 매개변수로 Acronym를 가져온다. Acronym는 이미 decode 되었기 때문에 따로 decode()할 필요 없다.
        return acronym.save(on: req)
        //Vapor는 들어오는 데이터를 decoding 하기 위해 PUT, POST, PATCH 경로에 대한 helper 기능을 제공한다.
        //이를 사용하면, 중첩되는 코드를 간단하게 정리할 수 있다.
    }
    
    //Retrieve
    func getAllHandler(_ req: Request) throws -> Future<[Acronym]> { //Future<Acronym> 타입을 반환한다.
        //routes.swift에서 작성한 클로저 핸들러 바디 부분과 동일하다.
        return Acronym.query(on: req).all() //질의 수행
        //모든 Acronym를 검색한다.
        
        //Fluent로 직접 쿼리를 쓰지 않아도 간단하게 구현할 수 있다. 단 DatabaseConnectable를 구현해야 한다.
        //결국 SQL의 SELECT * FROM Acronyms; 와 같다.

    }
    
    func getHandler(_ req: Request) throws -> Future<Acronym> { //Future<Acronym>를 반환한다.
        return try req.parameters.next(Acronym.self)
        //request의 parameters를 사용해서, 해당 조건을 만족하는 객체만 추출한다.
        //존재하지 않거나 id유형이 잘못된 경우 오류 처리를 해야 한다.
    }
    
    //Update
    func updateHandler(_ req: Request) throws -> Future<Acronym> { //Future<Acronym>를 반환한다.
        return try flatMap(
            to: Acronym.self,
            req.parameters.next(Acronym.self),
            req.content.decode(Acronym.self)
            //flatMap으로 매개 변수 추출과 디코딩이 완료될 때까지 기다린다.
            //파라미터로 to: DB의 모델 객체(Acronym), id로 요청해서 가져온 객체(수정할 객체), 디코딩 객체
        ) { acronym, updatedAcronym in
            //DB의 객체와 수정할 객체를 가져온다.
            acronym.short = updatedAcronym.short
            acronym.long = updatedAcronym.long
            acronym.userID = updatedAcronym.userID
            //업데이트
            
            return acronym.save(on: req) //Fluent의 모델 저장 메서드
            //Fluent (Acronym)을 사용하여 모델을 저장한다.
            //Fluent는 저장되면서 모델을 반환한다(여기서는 Future<Acronym>).
        }
    }

    //Delete
    func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> { //Future<HTTPStatus>를 반환한다.
        return try req
            .parameters
            .next(Acronym.self) //request의 파라미터에서 삭제할 Acronym 객체를 가져온다.
            .delete(on: req) //삭제
            //Future를 unwrapping 하는 대신, Fluent는 해당 Future에서 직접 delete(on :)를 호출 할 수 있다.
            //이렇게 처리하면, 코드를 정리하고 중첩을 줄일 수 있다.
            .transform(to: HTTPStatus.noContent)
        //결과를 204 No Content response로 변환한다. 클라이언트에게 요청이 성공했음을 알려주지만, 리턴할 내용이 없을 때 쓴다.
    }
    
    
    
    
    //Filter
    func searchHandler(_ req: Request) throws -> Future<[Acronym]> { //Future<[Acronym]>를 반환한다.
        guard let searchTerm = req
            .query[String.self, at: "term"] else {
                //URL query string로 검색용어를 만든다. 클라이언트의 경로에 적합하지 않는 정보를 전달할 수도 있어 적절한 경우에만 사용하는 것이 좋다.
                //req.query.decode(_ :) 를 사용해, Codable로 작업을 할 수도 있다.
                //최종 경로는 http://localhost:8080/api/acronyms/search?term= 이 된다.
                throw Abort(.badRequest)
                //실패하면 400 Bad Request error 를 throw 한다.
        }
        
        return Acronym.query(on: req).group(.or) { or in
            //다중 필드를 사용해 필터를 적용하려면, 쿼리를 변경해야 한다. 이 경우에는 group을 사용해 필터링한다.
            //.or 관계를 사용하는 필터 그룹 생성
            or.filter(\.short == searchTerm) //그룹에 short 필터 추가
            or.filter(\.long == searchTerm) //그룹에 long 필터 추가
            }.all() //두 개의 필터에 하나라도 일치하는 모든 결과를 반환한다.
    }
    
    //First result
    func getFirstHandler(_ req: Request) throws -> Future<Acronym> { //Future<Acronym>를 반환한다.
        //쿼리의 첫 번째 결과만 필요할 때 사용할 수 있다. 모든 결과를 메모리에 로드하는 대신 하나의 결과만 반환한다.
        return Acronym.query(on: req)
            .first() //첫 결과를 가져온다.
            //first()를 필터 결과와 같이 모든 쿼리에 적용할 수 있다.
            .map(to: Acronym.self) { acronym in
                guard let acronym = acronym else {
                    //결과가 nil인 경우
                    throw Abort(.notFound)
                    //404 Not Found error 발생
                }
                
                return acronym //해당 Acronym 반환
        }
    }
    
    //Sorting results
    func sortedHandler(_ req: Request) throws -> Future<[Acronym]> { //Future<[Acronym]>를 반환한다.
        return Acronym.query(on: req).sort(\.short, .ascending).all() //정렬할 필드와 순서를 정해 준다. //오름차순 정렬
    }
    
    
    
    
    //Getting the parent
    func getUserHandler(_ req: Request) throws -> Future<User> { //Future<User>를 반환한다.
        return try req
            .parameters.next(Acronym.self) //request의 파라미터에서 해당 Acronym 객체를 가져온다.
            .flatMap(to: User.self) { acronym in
                //flatMap(to:)는 해당하는 유형으로 최종 반환한다.
                acronym.user.get(on: req)
                //computed property에서 user를 가져온다.
            }
    }
    
    
    
    
    //Sibling relationship
    func addCategoriesHandler(_ req: Request) throws -> Future<HTTPStatus> { //Future<HTTPStatus> 반환
        return try flatMap( //flatMap으로 request의 파라미터에서 Acronym와 Category를 추출한다(클로저의 파라미터가 된다).
            to: HTTPStatus.self, //flatMap 이후 최종 반환형
            req.parameters.next(Acronym.self),
            req.parameters.next(Category.self)) { acronym, category in
                return acronym.categories
                    .attach(category, on: req)
                    //attach(_: on:)로 Acronym와 Category 사이의 관계를 설정한다.
                    //피벗 모델이 만들어지며 DB에 저장된다.
                    .transform(to: .created)
                    //201 Created response로 결과를 변환한다.
            }
    }
    
    //Querying the relationship
    func getCategoriesHandler(_ req: Request) throws -> Future<[Category]> { //Future<[Category]> 반환
        return try req.parameters.next(Acronym.self) //파라미터를 가져온다.
            .flatMap(to: [Category].self) { acronym in //flatMap으로 request의 파라미터에서 Acronym를 추출하고 wrapping한다.
                try acronym.categories.query(on: req).all()
                //computed property에서 Category를 가져오고 Fluent 쿼리를 사용해서 모든 Category를 반환한다.
            }
    }
    
    //Removing the relationship
    func removeCategoriesHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try flatMap( //flatMap으로 request의 파라미터에서 Acronym와 Category를 추출한다(클로저의 파라미터가 된다).
            to: HTTPStatus.self, //flatMap 이후 최종 반환형
            req.parameters.next(Acronym.self),
            req.parameters.next(Category.self)) { acronym, category in
                return acronym.categories
                    .detach(category, on: req)
                    //detach(_: on:)로 Acronym와 Category 사이의 관계를 삭제한다.
                    //피벗 모델을 찾아 DB에서 삭제한다.
                    .transform(to: .noContent)
                    //204 No Content response로 결과를 변환한다.
        }
    }
}

//큰 프로젝트의 경우, routes에서 모든 경로를 처리하는 것은 파일이 커지고 복잡해지기 때문에 적절하지 않다.
//기본 컨트롤러와 RESTful 컨트롤러를 분리하여 관리하는 것이 좋다.

//Controllers
//Vapor의 Controller는 iOS의 컨트롤러와 비슷하다. request와 같은 클라이언트의 상호 작용을 처리하고 response를 처리한다.
//전용 컨트롤러에서 모델과 모든 상호 작용을 하는 것이 좋다.
//또한 컨트롤러는 응용 프로그램을 구성하는 데 사용된다. 하나의 컨트롤러를 사용하여 이전 버전의 API를 관리하고,
//다른 컨트롤러를 사용하여 현재 버전을 관리하는 등으로 활용 가능하다.

//컨트롤러에 액세스 하려면, 핸들러를 router에 등록해야 한다. routes.swift에서 컨트롤러 내부 함수를 아래와 같이 호출해서 구현할 수 있다.
//router.get(
//  "api",
//  "acronyms",
//  use: acronymsController.getAllHandler)
//이런 식의 구현은 작은 응용 프로그램에 적합하지만, 경로가 많아지만 관리가 어려워 진다.
//컨트롤러가 제어하는 route를 등록하는 것은 컨트롤러의 책임이다. Vapor에서는 RouteCollection를 구현해 처리할 수 있다.




//Fluent는 Future<Model> 유형에 대해 save(on:), create(on:), update(on:), delete(on:)의 편리한 함수를 제공한다.
//모델을 저장하기 전에 조작할 필요 없는 경우 유용하게 사용할 수 있다.


