import Routing
import Vapor

/// Register your application's routes here.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#routesswift)
public func routes(_ router: Router) throws {
    // Basic "Hello, world!" example
    router.get("hello", "vapor") { req -> String in
        //GET 요청을 처리할 새 경로를 추가한다. //http://localhost:8080/hello/vapor 가 된다.
        //위 경로를 호출할 때 클로저 내부가 실행된다. 클로저는 request를 받는다.
        
        return "Hello, Vapor!" //반환
    }
    
    router.get("hello", String.parameter) { req -> String in
        //String.parameter를 사용해 GET 요청의 두번째 경로를 임의의 String으로 받는다.
        let name = try req.parameter(String.self)
        //여기서 request의 parameter 메서드를 이용해 매개변수를 가져온다.
        //request에 전달된 파라미터를 변수에 저장한다.
        
        return "Hello, \(name)!" //반환
    }
    
    router.post(InfoData.self, at: "info1") { req, data -> String in
        //POST 요청. 첫 매개변수로 Content 유형을 설정하고, at으로 경로를 설정한다.
        
        return "Hello \(data.name)!"
    }
    
    router.post(InfoData.self, at: "info2") { req, data -> InfoResponse in
        //POST 요청. 첫 매개변수로 Content 유형을 설정하고, at으로 경로를 설정한다.
        //InfoResponse(Content) 유형을 반환한다.
        
        return InfoResponse(request: data)
        //InfoResponse를 생성해 반환한다.
        //JSON 형태의 객체로 반환된다.
    }
    
    // Example of configuring a controller
    let todoController = TodoController()
    router.get("todos", use: todoController.index)
    router.post("todos", use: todoController.create)
    router.delete("todos", Todo.parameter, use: todoController.delete)
}


struct InfoData: Content {
    //Content는 HTTP의 메시지를 표현하는 객체로 Codable를 랩핑한다.
    //Vapor는 Content를 사용하여 기본 JSON 인코딩 또는 URL 인코딩 형식의 request Data를 추출한다.
    
    let name: String
}

struct InfoResponse: Content {
    //iOS 앱에서 요청을 보내고 Vapor에서 처리해 JSON으로 보내줄 수 있다.
    //Vapor는 Content를 사용해 request를 JSON으로 인코딩한다.
    
    let request: InfoData
}

//터미널에서 vapor build로 vapor 프로젝트를 만든다.
//vapor 프로젝트를 만들면, Git을 통해 dependency와 다른 필요한 요소들을 구축하고 .gitignore로 제외된다.
//Xcode에서 작업 하려면 터미널에서 vapor xcode -y를 입력해 Xcode를 실행 시킬 수 있다.
//터미널에서 vapor run으로 서버를 실행 시킨다.
//Xcode에서는 툴바에서 Run scheme와 My Mac 디바이스를 선택하고 실행 시키면 서버가 작동한다.


