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

/// Logs all requests that pass through it.
final class LogMiddleware: Middleware {
    let logger: Logger //Log를 기록하는 객체
    
    init(logger: Logger) {
        self.logger = logger
    }
    
    func respond(to req: Request, chainingTo next: Responder) throws -> Future<Response> {
        //Middleware 프로토콜은 이 메서드를 구현해야 한다.
        //이 미들웨어를 통과하는 각 request와 함께 호출된다.
        //        logger.info(req.description)
        //        //request의 description을 logger로 보낸다.
        //
        //        return try next.respond(to: req)
        //        //들어온 request를 다음 responder로 전달한다.
        
        //log를 좀 더 읽기 쉬운 형태로 바꾼다.
        
        let start = Date() //현재 시간을 생성한다.
        
        return try next.respond(to: req).map { res in
            //response를 직접 반환하지 않고, Response 객체에 액세스 할 수 있도록 매핑한다.
            self.log(res, start: start, for: req)
         
            return res
        }
    }
    
    func log(_ res: Response, start: Date, for req: Request) {
        //응답 시간을 사용하여, request에 대한 response를 로깅한다.
        let reqInfo = "\(req.http.method.string) \(req.http.url.path)"
        let resInfo = "\(res.http.status.code) " + "\(res.http.status.reasonPhrase)"
        
        let time = Date()
            .timeIntervalSince(start) //start의 시간과 현재 시간과의 차이를 구한다.
            .readableMilliseconds //읽기 쉽도록 바꾼다
        
        logger.info("\(reqInfo) -> \(resInfo) [\(time)]") //logger에 기록한다.
    }
}

extension LogMiddleware: ServiceType {
    static func makeService(for container: Container) throws -> LogMiddleware {
        //LogMiddleware가 응용 프로그램의 서비스로 등록되도록 한다.
        
        return try .init(logger: container.make())
        //컨테이너를 사용해 필요한 Logger를 작성하는 LogMiddleware를 초기화한다.
    }
}

extension TimeInterval {
  /// Converts the time internal to readable milliseconds format, i.e., "3.4ms"
  var readableMilliseconds: String {
    let string = (self * 1000).description
    // include one decimal point after the zero
    let endIndex = string.index(string.index(of: ".")!, offsetBy: 2)
    let trimmed = string[string.startIndex..<endIndex]
    return .init(trimmed) + "ms"
  }
}

//Log middleware
//Log middleware는 들어오는 request에 대한 응답 시간을 기록한다. 각 request에 다음 정보가 표시된다.
// • Request method
// • Request path
// • Response status
// • How long it took to generate the response(response에 대한 응답 시간)




//터미널에서 curl localhost:8080/todos 를 입력하면(GET /todos 로 request를 보낸다), xcode 콘솔에 정보가 출력다다.
