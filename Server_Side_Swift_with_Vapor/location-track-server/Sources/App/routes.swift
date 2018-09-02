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
/// merger, publicat로on, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import Routing
import Vapor
import WebSocket
import Foundation

// MARK: For the purposes of this example, we're using a simple global collection.
// in production scenarios, this will not be scalable beyonnd a single server
// make sure to configure appropriately with a database like Redis to properly
// scale
let sessionManager = TrackingSessionManager()

public func routes(_ router: Router) throws {
  
  // MARK: Status Checks
  
  router.get("status") { _ in "ok \(Date())" }
    
  router.get("word-test") { request in //이전에는 따로 handler function을 만들었지만 클로저로도 가능하다.
    //경로는 http://localhost:8080/word-test
    
    return wordKey(with: request)
    //단순히 wordKey에 대한 호출을 반환
  }
    
    
    
    
  //Poster endpoint
  router.post("create", use: sessionManager.createTrackingSession)
  // /create에 대한 빈 POST request는 tracking session을 생성해 클라이언트에 반환한다.
  //터미널에서 curl -X POST http://localhost:8080/create 으로 session을 생성한다. p.418
    
  router.post("close", TrackingSession.parameter) { req -> HTTPStatus in
    let session = try req.parameters.next(TrackingSession.self) //TrackingSession을 가져온다.
    sessionManager.close(session) //세션을 닫는다.
    
    return .ok //빈 HTTPResponse를 반환해 success를 나타낸다.
  }
  // curl -w "%{response_code}\n" -X POST \http://localhost:8080/close/<tracking.session.id.goes.here>
  //해당 세션의 id로 세션을 닫는다. p.419
    
  router.post("update", TrackingSession.parameter) { req -> Future<HTTPStatus> in
    let session = try req.parameters.next(TrackingSession.self) //URL에서 세션 id 추출
    
    return try Location.decode(from: req) //POST request body에서 Location을 만든다.
        .map(to: HTTPStatus.self) { location in
            sessionManager.update(location, for: session) //sessionManager를 생성해 업데이트된 위치를 broadcasting 한다.
            return .ok //200 OK HTTP status 반환
    }
  }
  //curl -w "%{response_code}\n" \
  //-d '{"latitude": 37.331, "longitude": -122.031}' \
  //-H "Content-Type: application/json" -X POST \
  //http://localhost:8080/update/<tracking.session.id.goes.here>
  //해당 세션의 id로 세션을 업데이트 한다.
}

//Endpoints
//Poster를 지원하는 end point는 모두 일반 HTTP route 를 구현할 수 있다.
//실시간 업데이트가 필요 없기 때문에 WebSocket을 사용할 필요가 없다.


