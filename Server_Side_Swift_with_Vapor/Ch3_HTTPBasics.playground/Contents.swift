//웹 사이트를 방문할 때마다 브라우저는 HTTP 요청을 보내고, 서버로부터 응답을 받는다.

//HTTP requests
//서버는 요청을 처리하기 위한 추가정보가 필요할 수 있다. 그 추가 정보는 헤더(key - value)에 추가해 전송한다.

//HTTP responses
//response에 일부 응답 헤더가 포함될 수 있다.
//상태코드로 요청의 결과를 알수 있다. 첫 번째 숫자를 기준으로 5개의 그룹으로 나뉜다.
//• 1 : informational response. 잘 안 쓰인다.
//• 2 : success response. (ex. 200 OK)
//• 3 : redirection response.
//• 4 : client error. (ex. 404 Not Found)
//• 5 : server error.

//HTTP in web browsers
//웹 브라우저는 GET과 POST만 사용한다.
//<head>에서 참조하는 모든 외부 리소스를 수신한 후 페이지를 렌더링한다.

//HTTP in iOS apps
//웹 브라우저에 비해 제약이 훨씬 적다.

//HTTP 2.0
//대부분의 웹 서비스는 1997년 1 월에, RFC 2068에서 발표 된 HTTP 1.1을 사용한다.
//별도의 명시가 없으면 HTTP / 1.1이다(이 책도 마찬가지).
//HTTP / 2는 클라이언트와 서버 간의 통신을 확장하여 효율성을 높이고 대기 시간을 줄였다.
//개별 요청은 HTTP / 1.1의 요청과 동일하지만 병렬로 진행될 수 있다.
//서버는 클라이언트 요청을 예상하고 스타일 시트 및 이미지와 같은 데이터를 요청하기 전에 클라이언트에 푸시 할 수 있다.
//Vapor는 클라이언트 및 서버 기능 모두에서 HTTP / 1.1 및 HTTP / 2를 지원 한다.

//REST
//REST(Representational State Transfer)는 HTTP와 밀접한 관련이 있는 아키텍처 표준이다.
//앱에서 사용하는 많은 API는 REST API가 된다. REST는  API에서 리소스에 액세스하기 위한공통표준을 정의하는 방법을 제공한다.
//acronyms API의 경우, 다음과 같이 endpoint를 정의할 수 있다.
//• GET / api / acronyms : 모든 acronyms를 get.
//• POST / api / acronyms : 새로운 acronyms 생성.
//• GET / api / acronyms / 1 : ID가 1 인 acronyms를 get .
//• PUT / api / acronyms / 1 : acronyms를 ID 1로 업데이트.
//• DELETE / api / acronyms / 1 : ID가 1 인 acronyms를 삭제.
//REST API에서 리소스에 액세스하는 공통 패턴을 갖는 것은 클라이언트 빌드 프로세스를 단순화한다.

//Why use Vapor?
//Swift는 정적 유형의 프로그램 언어이므로, 오류를 사전에 처리하기 쉽고, 컴파일 언어이므로 성능 또한 향상된다.
//iOS 앱을 개발하는 경우 같은 언어를 사용하므로, 핵심 비즈니스 로직 코드 공유가 쉽다.
//Xcode로 코딩하게 되므로, IDE의 디버깅 기능을 활용할 수도 있다.
//Vapor 외에도 많은 Server-side-Swift 패키지들이 있지만, Vapor는 유일하게 Codable을 구현할 수 있다.
//따라서, 데이터베이스에 모델을 저장하고, JSON으로 변환하는 코드의 양이 줄어든다.
//또한, 간단하게 구조체로 변환할 수 있다.
//Vapor는 유일하게 fully non-blocking 아키텍처를 사용한다.
//서버가 HTTP 요청을 받으면 응답을 반환해야 하는데, blocking 아키텍처에서는 요청을 처리하는 데 오랜 시간이 걸리는 경우
//(ex. 데이터 베이스 쿼리 수신 대기중인 경우) 해당 스레드에 대한 추가 요청에 응답할 수 없다.
