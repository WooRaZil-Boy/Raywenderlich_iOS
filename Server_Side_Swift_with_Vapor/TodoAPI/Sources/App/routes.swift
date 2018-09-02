/// Copyright (c) 2018 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
  // register todo controller routes
  let todoController = TodoController()

  router.get("todos", use: todoController.index)
    
  router.group(SecretMiddleware.self) { secretGroup in //route group 생성
    secretGroup.post("todo", use: todoController.create)
    secretGroup.delete("todos", Todo.parameter, use: todoController.delete)
  }
    
  //Todo List API 경로 중 아래 두 가지는 DB를 변경할 수 있다.
  // • POST /todos
  // • DELETE /todos/:id
  //public API인 경우 미들웨어를 사용하여 비밀 키로 이러한 경로를 보호해야 한다. 이를 SecretMiddleware로 구현한다.
}




//미들웨어는 다음과 같은 일을 한다.
// • incoming request를 기록한다.
// • 오류를 catch하고 message를 표시한다.
// • Rate-limit 경로에 대한 트래픽을 제한한다.
//미들웨어 인스턴스는 라우터와 서버에 연결된 클라이언트 사이에 있다.
//들어오는 request가 사용자의 컨트롤러에 도달하기 전에 이를 변경할 수 있다.
//미들웨어 인스턴스는 자체 response를 생성하여 초기에 반환하도록 할 수 있고, chain의 다음 responder 에게 전달할 수도 있다.
//최종 responder는 항상 라우터이다. 다음 responder 로부터 response가 생성될 때 미들웨어는 필요한 것을 수정하거나 그대로 클라이언트에 전달할 수 있다.
//각 미들웨어 인스턴스가 들어오는 request와 나가는 response를 모두 제어할 수 있다. p.392
//미들웨어 프로토콜은 다음과 같다.

//public protocol Middleware {
//    func respond(to request: Request, chainingTo next: Responder) throws -> Future<Response>
//}




//Vapor’s middleware
//Vapor에서 일반적으로 사용하는 미들웨어들은 다음과 같다.

// • Error middleware
//Vapor에서 가장 일반적으로 사용되는 미들웨어로 ErrorMiddleware.
//동기 및 비동기식 Swift Error를 모두 HTTP response로 변환한다. ErrorMiddleware를 사용하면, 모든 오류가 적절한 HTTP response로 렌더링된다.
//프로덕션 모드에서 ErrorMiddleware는 모든 오류를 500 Internal Server Error response 로 변환한다.
//오류 유형을 AbortError에 일치시켜 다른 오류 response를 제공하도록 선택할 수 있으므로 HTTP status 코드와 오류 메시지를 지정할 수 있다.
//AbortError를 준수하는 구체적인 오류 유형인 Abort를 사용할 수도 있다.
//ex. throw Abort(.badRequest, "Something's not quite right.")

// • File middleware
//FileMiddleware 미들웨어는 응용 프로그램 디렉토리의 Public 폴더에 있는 파일을 제공한다.
//Vapor를 사용해 이미지나 스타일 시트와 같은 정적 파일이 필요한 프론트 엔드 웹 사이트를 만들 때 유용하다.

// • Other Middleware
//연결된 클라이언트와 세션을 추적하는 SessionsMiddleware가 있다.
//다른 패키지는 응용 프로그램에 통합 할 수 있도록 미들웨어를 제공할 수 있다.
//ex. Vapor의 인증 패키지에는 기본 암호, 단단한 bearer 토큰 및 JWT(JSON Web Token) 을 사용해 route를 보호하는 미들웨어도 있다.




//Example: Todo API
//이 애플리케이션에서는 두 가지 미들웨어를 생성한다.
//1. LogMiddleware : 들어오는 request에 대한 응답 시간을 기록한다.
//2. SecretMiddleware : 비공개 키를 요구해 private route가 permission없이 액세스되는 것을 보호한다.




// • Middleware: https://api.vapor.codes/vapor/latest/Vapor/Protocols/Middleware.html
// • MiddlewareConfig: https://api.vapor.codes/vapor/latest/Vapor/Structs/ MiddlewareConfig.html
