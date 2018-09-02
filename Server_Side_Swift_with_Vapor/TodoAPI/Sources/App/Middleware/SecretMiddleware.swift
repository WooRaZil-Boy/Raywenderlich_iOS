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

/// Rejects requests that do not contain correct secret.
final class SecretMiddleware:Middleware {
    let secret: String //비밀 키를 저장할 프로퍼티
    
    init(secret: String) {
        self.secret = secret
    }
    
    func respond(to request: Request, chainingTo next: Responder) throws -> Future<Response> {
        //미들웨어 프로토콜 요구사항 구현 //이 미들웨어를 통과하는 각 request와 함께 호출된다.
        guard request.http.headers.firstValue(name: .xSecret) == secret else {
            //들어오는 request의 X-secret 헤더에서 key를 확인
            throw Abort(.unauthorized, reason: "Incorrect X-Secret header.")
            //헤더 값이 일치하지 않으면 승인되지 않은 HTTP status로 오류를 던진다.
        }
        
        return try next.respond(to: request)
        //헤더가 일치하면 다음 미들웨어로 연결한다.
    }
}

extension SecretMiddleware: ServiceType {
    static func makeService(for worker: Container) throws -> SecretMiddleware {
        let secret: String //구성된 비밀 키를 저장할 local 변수
        
        switch worker.environment { //현재 환경
        case .development: //개발 중인 경우 foo를 키로 사용한다.
            secret = "foo"
        default:
            guard let envSecret = Environment.get("SECRET") else { //$SECRET 키에서 프로세스 환경의 키를 가져온다.
                let reason = """
                    No $SECRET set on environment. \
                    Use "export SECRET=<secret>"
                    """
                
                throw Abort(.internalServerError, reason: reason)
                //없는 경우 오류 발생
            }
            
            secret = envSecret //키 지정
        }
        
        return SecretMiddleware(secret: secret) //구성된 키를 사용해서 SecretMiddleware 인스턴스 초기화
    }
}

extension HTTPHeaderName {
  /// Contains a secret key.
  ///
  /// `HTTPHeaderName` wrapper for "X-Secret".
  static var xSecret: HTTPHeaderName {
    return .init("X-Secret")
  }
}

//SecretMiddleware
//SecretMiddleware는 비공개 키를 요구해 private route가 permission없이 액세스되는 것을 보호한다.
//Todo List API 경로 중 아래 두 가지는 DB를 변경할 수 있다.
// • POST /todos
// • DELETE /todos/:id
//public API인 경우 미들웨어를 사용하여 비밀 키로 이러한 경로를 보호해야 한다. 이를 SecretMiddleware로 구현한다.



