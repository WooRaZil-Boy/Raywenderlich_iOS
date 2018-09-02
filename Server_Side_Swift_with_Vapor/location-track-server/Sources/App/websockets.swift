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

public func sockets(_ websockets: NIOWebSocketServer) {
    websockets.get("echo-test") { ws, req in
        //route handler에 echo-test라는 end point를 생성한다. 경로는 ws://localhost:8080/echo-test 가 된다.
        //연결될 때 마다 메시지를 콘솔에 기록한다.
        print("ws connnected")
        
        ws.onText { ws, text in //end point가 text를 수신할 때 마다 실해되는 listener
            print("ws received: \(text)") //수신된 텍스트를 콘솔에 로깅
            ws.send("echo - \(text)") //prepending echo 이후, sender에게 다시 echo
        }
        
        //Echo server
        //크롬 확장 프로그램 Simple WebSocket Client를 실행 해 ws://localhost:8080/echo-test 를 입력한 후 Open 하면
        //Xcode Console에서 ws connected 를 확인해 볼 수 있다.
        //Simple WebSocket Client 에서 메시지를 입력하면 서버가 적절하게 reponse하는 것을 확인해 볼 수 있다.
    }
    
    
    
    
    //Observer endpoint
    websockets.get("listen", TrackingSession.parameter) { ws, req in
        // /listen/:tracking-session-id에 대한 WebSocket handler
        let session = try req.parameters.next(TrackingSession.self)
        //URL에서 id를 추출한다.
        
        guard sessionManager.sessions[session] != nil else { //세션이 유효한지 확인한다.
            ws.close()
            
            return
        }
        
        sessionManager.add(listener: ws, to: session) //WebSocket을 Observer로 세션에 추가한다.
    }
}

//HTTP와 같이 WebSockets은 두 장치 간의 통신에 사용되는 프로토콜을 정의한다.
//HTTP와 달리 WebSocket 프로토콜은 실시간 통신을 위해 설계 되었다. WebSocket은 채팅이나 실시간 동작이 필요한 기타 기능에 유용하다.
//Vapor는 WebSocket 서버 또는 클라이언트를 만들기 위한 간결한 API를 제공한다.




//Tools
//웹 소켓 테스트는 브라우저에서 URL로 접속하거나 간단한 CURL requst 를 사용할 수 없기 때문에 까다롭다.
//Chrome 확장 프로그램을 사용해 테스트할 수 있다. p.411
