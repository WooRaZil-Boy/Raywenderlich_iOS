import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "Hello, world!" example
    router.get("hello") { req in
        //GET 요청 처리하는 경로. http://localhost:8080/hello
        return "Hello, world!"
    }
    
    router.post("api", "acronyms") { req -> Future<Acronym> in //Future<Acronym> 타입을 반환한다.
        //POST 요청을 처리하는 경로. 여기서는 http://localhost:8080/api/acronyms 이 된다.
        return try req.content.decode(Acronym.self)
            //request JSON을 Codeable을 사용해, Acronym 모델로 디코딩한다.
            .flatMap(to: Acronym.self) { acronym in
                //디코더가 Future<Acronym>을 반환하므로, flatMap(to:)를 사용한다.
                return acronym.save(on: req) //Fluent의 모델 저장 메서드
                //Fluent (Acronym)을 사용하여 모델을 저장한다.
                //Fluent는 저장되면서 모델을 반환한다(여기서는 Future<Acronym>).
                
                //Fluent와 Vapor의 Codable을 사용하면 간단히 작업할 수 있다.
                //Acronym는 Content를 구현했으므로, JSON과 Model간에 쉽게 변환할 수 있다.
                //Vapor는 손쉽게 response에서 Model을 JSON으로 반환한다.
        }
    }
    
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
