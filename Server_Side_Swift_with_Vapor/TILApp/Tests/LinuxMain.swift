import XCTest

@testable import AppTests
//테스트가 포함 된 AppTests 모듈을 가져온다.

XCTMain([
    testCase(AcronymTests.allTests),
    testCase(CategoryTests.allTests),
    testCase(UserTests.allTests)
])
//각 XCTestCase에 대해 XCTMain(_ :)에 대한 테스트 배열 제공한다.
//Linux에서 응용 프로그램을 테스트 할 때 실행된다.
//Linux에서 테스트할 코드들을 각 테스트 파일의 allTests에 구현해 놓는다.
//Linux에서 Swift 테스트 또는 Vapor 테스트를 호출하면 테스트 실행 파일은 이 배열(allTests에)을 사용해 실행할 테스트를 결정한다.




//Testing on Linux
//server- side Swift의 경우, Linux에서의 테스트가 중요하다. 응용 프로그램을 배포하면, 개발에 사용했던 운영 체제와 다른 운영체제에서 배포될 수 있기 때문이다.
//Linux 버전은 Swift는 많은 기능이 완벽하게 구현되지 않으므로(ex. macOS의 Foundation은 Objective-C, Linux의 Foundation은 Testing on Linux),
//응용 프로그램이 예기치 않게 중단될 수도 있다.

//Declaring tests on Linux
//리눅스의 테스트는 macOS에서 실행되는 테스트와 다르다. Objective-C는 XCTestCases 를 사용하지만, Linux에서는 이를 수행할 수 없다.
//따라서 리눅스에서 테스트를 위한 클래스를 따로 설정해 줘야 한다.
//여기서 LinuxMain.swift는 Xcode 프로젝트의 일부가 아니다. Finder에서 따로 편집해 줘야 한다.

//Running tests in Linux
//Docker를 사용해 PostgreSQL DB를 실행하는 Linux를 이미 실행하고 있다.
//따라서 Docker의 Linux 환경을 변경해 테스트할 수 있다.
//Dockerfile(확장자 없음) 작성해 테스트를 진행한다. p.184

//리눅스 Docker를 설치하고 docker-compose up --abort-on-container-exit 명령어로 테스트를 하면 된다. p.186
