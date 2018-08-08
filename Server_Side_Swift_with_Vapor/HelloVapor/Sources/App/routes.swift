import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "Hello, world!" example
    router.get("hello", "vapor") { req in // req -> String in
        //GET 요청을 처리할 경로를 추가한다. router.get의 각 매개 변수는 URL 경로의 구성요소이다.
        //router.get("hello")인 경우에는 http://localhost:8080/hello
        //router.get("hello", "vapor")인 경우에는 //http://localhost:8080/hello/vapor 가 된다.
        
        //위 경로를 호출할 때 클로저 내부가 실행된다. 클로저는 request 객체를 받는다.
        return "Hello, world!" //반환(String)
    }
    
    router.get("hello", String.parameter) { req -> String in
        //String.parameter를 사용해 GET 요청의 두번째 경로를 임의의 String으로 받는다.
        let name = try req.parameters.next(String.self)
        //여기서 request의 parameter 메서드를 이용해 매개변수를 가져온다.
        //request에 전달된 파라미터를 변수에 저장한다.
        
        return "Hello, \(name)!" //반환
    }
    
    router.post(InfoData.self, at: "info1") { req, data -> String in
        //POST 요청. 첫 매개변수로 Content 유형을 설정하고, at으로 경로를 설정한다.
        //http://localhost:8080/info1 의 POST request를 처리한다.
        
        //클로저에서 받는 data의 객체가 매개변수로 설정한 Content 유형이 된다.
        
        return "Hello \(data.name)" //반환
        //POST는 GET과 요청을 보내야 하므로 바로 문자열을 입력해 확인해 볼 수 없다.
        //단순히 데이터의 반환 여부를 확인하는 것이라면, API 툴을 사용하면 쉽게 확인해 볼 수 있다.
    }
    
    //Accepting data
    //Vapor3는 Swift 4의 Codable을 사용해 데이터를 쉽게 디코딩할 수 있다.
    //Vapor에 예상 데이터와 일치하는 Codable 구조체를 지정하면 Vapor가 나머지를 수행한다.
    
    router.post(InfoData.self, at: "info2") { req, data -> InfoResponse in
        //POST 요청. 첫 매개변수로 Content 유형을 설정하고, at으로 경로를 설정한다.
        //http://localhost:8080/info2 의 POST request를 처리한다.
        
        return InfoResponse(request: data) //InfoResponse형으로 반환
        //구조체라 따로 지정하지 않아도 기본 생성자가 있다.
        //이후 반환된 데이터를 iOS 앱에서 파싱해 사용하면 된다(ex. JSON 반환 API).
        
        //InfoResponse가 Codable(Content)를 구현하고 있기 때문에
        //웹 페이지에서는 JSON 형식으로 반환되어 보여진다. 이런식으로 API 가져오는 웹앱으로 사용할 수 있다.
    }
    
    //Returning JSON
    //Vapor로 JSON을 쉽게 반환할 수 있다.
    //ex. iOS 앱의 request를 처리하는 Vapor 앱은 JSON response를 iOS 앱으로 보낸다.
    //Vapor는 Content를 사용하여 response을 JSON으로 인코딩한다.

    // Example of configuring a controller
    let todoController = TodoController()
    router.get("todos", use: todoController.index)
    router.post("todos", use: todoController.create)
    router.delete("todos", Todo.parameter, use: todoController.delete)
}

struct InfoData: Content { //DTO에 해당하는 객체. request를 담당
    //Content는 HTTP의 메시지를 표현하는 객체로 Codable를 랩핑한다.
    //Vapor는 Content를 사용하여 기본 JSON 인코딩 또는 URL 인코딩 형식의 request Data를 추출한다.
    
    let name: String
}

struct InfoResponse: Content { //DTO에 해당하는 객체. response를 담당
    //Content는 HTTP의 메시지를 표현하는 객체로 Codable를 랩핑한다.
    //Vapor는 Content를 사용하여 기본 JSON 인코딩 또는 URL 인코딩 형식의 request Data를 추출한다.
    
    let request: InfoData
}

//Vapor는 Swift로 작성된 오픈 소스 웹 프레임워크로 SwiftNIO 라이브러리 위에서 구축된다.

//Vapor Toolbox
//Vapor 앱을 개발할 때 사용하는 command line interface (CLI) 툴
//• 템플릿에서 새 응용 프로그램 만들기
//• Swift toolchain을 사용하여 프로젝트 빌드 및 실행
//• Xcode 프로젝트 생성
//• Vapor Cloud로 프로젝트 배포

//터미널에서 eval "$(curl -sL check.vapor.sh)" 명령어를 입력해, 필요한 버전의 Swift가 설치되었는지 확인할 수 있다.




//Building your first app
//Vapor Toolbox을 사용해, 템플릿 프로젝트를 생성할 수 있다.
//vapor new HelloVapor : default 템플릿 "HelloVapor" 이름으로 생성
//vapor build : 앱 빌드
//vapor run : 앱 실행




//Swift Package Manager
//Vapor Toolbox는 Cocoapods과 유사한 종속성 관리 시스템 Swift Package Manager(SPM)을 사용하여 Vapor 앱을 구성 한다.
//앱을 실행하더라도 템플릿에는 Xcode 프로젝트가 없다. 프로젝트 파일은 gitignore로 소스 제어에서 제외된다.
//코드의 변경이 있어 SPM을 사용할 때마다 Xcode 프로젝트는 폐기 재 생성 된다.
//SPM 프로젝트는 Package.swift 파일에 정의되어 있다. 정의된 각 모듈은 소스 내 자체 디렉토리가 있다.
//default 템플릿에는 App 모듈과 Run 모듈이 있으므로, 소스에는 각각의 디렉토리가 존재한다.
//Run 디렉토리에 main.swift가 존재하는 데, 이것이 진입점이 된다.
//(보통 iOS에서는 AppDelegate의 @UIApplicationMain 속성으로 합쳐진다.)




//Creating your own routes
//터미널에서 vapor xcode -y 를 입력하면, Xcode로 해당 vapor 프로젝트를 편집할 수 있다.
//Xcode에서는 툴바에서 Run scheme와 My Mac 디바이스를 선택하고 실행 시키면 서버가 작동한다.
