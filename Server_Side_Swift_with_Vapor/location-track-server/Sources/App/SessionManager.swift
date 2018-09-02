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
import WebSocket

// MARK: For the purposes of this example, we're using a simple global collection.
// in production scenarios, this will not be scalable beyond a single server
// make sure to configure appropriately with a database like Redis to properly
// scale
final class TrackingSessionManager {
    private(set) var sessions: LockedDictionary<TrackingSession, [WebSocket]> = [:]
    //각 TrackingSession은 Observer에 해당하는 WebSocket 배열에 저장되어 있다.
    
    func createTrackingSession(for request: Request) -> Future<TrackingSession> {
        //Poster는 tracking 세션이 필요하다.
        
        return wordKey(with: request)
            .flatMap(to: TrackingSession.self) { [unowned self] key in
                //새 세션 id를 생성한다. wordKey(with:)는 Future<String>을 반환하므로 unwrapping 해 준다.
                let session = TrackingSession(id: key) //생성된 id를 사용해 새 세션에 대한 TrackingSession을 생성한다.
                
                guard self.sessions[session] == nil else { //세션 id가 고유한지 확인
                    return self.createTrackingSession(for: request) //고유하지 않으면 재귀적으로 다시 시도
                }
                
                self.sessions[session] = [] //새 TrackingSession을 key로 sessions에 기록하고, Observers 의 빈 배열을 value로 준다.
                
                return Future.map(on: request) { session }
            }
    }
    
    
    
    
    //Poster behaviors
    func update(_ location: Location, for session: TrackingSession) {
        //Poster가 업데이트 된 위치를 서버에 전송하면, 위치가 등록된 각 Obsever에게 전송된다.
        guard let listeners = sessions[session] else {
            return
        }
        
        listeners.forEach { ws in
            ws.send(location) //업데이트 된 위치를 send
        }
    }
    
    func close(_ session: TrackingSession) { //Poster 세션을 닫는다.
        guard let listeners = sessions[session] else {
            return
        }
        
        listeners.forEach { ws in
            ws.close() //Observer의 WebSocket을 닫는다
        }
        
        sessions[session] = nil // 활성 세션 목록에서 해당 TrackingSession을 제거한다.
    }
    
    
    
    
    //Observer behaviors
    func add(listener: WebSocket, to session: TrackingSession) {
        guard var listeners = sessions[session] else { //세션이 있는 지 확인
            return
        }
        
        listeners.append(listener)
        sessions[session] = listeners
        //Observer의 WebSocket을 리스너 배열에 추가
        
        listener.onClose.always { [weak self, weak listener] in
            //Observer의 클라이언트가 WebSocket을 닫을 때 트리거하는 onClose 핸들러를 등록한다.
            guard let listener = listener else {
                return
            }
            
            self?.remove(listener: listener, from: session)
            //리스너 배열에서 WebSocket을 제거
        }
    }
    
    func remove(listener: WebSocket, from session: TrackingSession) {
        guard var listeners = sessions[session] else { //세션이 존재하는지 확인
            return
        }
        
        listeners = listeners.filter { $0 !== listener }
        sessions[session] = listeners
        //Observer의 WebSocket을 리스너 배열에서 제거
    }
}

//Session Manager
//서버 앱은 두 가지 유형의 클라이언트 사용자를 지원한다.
// • Poster : 다른 사람이 볼 수 있는 위치를 공유하는 클라이언트
// • Observer : Poster의 위치를 보고 차트로 만드는 클라이언트
//Poster와 Observer는 TrackingSession 를 사용해 연결되며 임의이 단어로 식별 된다.

//이 솔루션은 확장 할 수 없으며 단일 서버 인스턴스에서만 작동한다. 이 기능을 확장하려면, TrackingSessionManager를 Redis와 같은 대규모 실시간 DB에 연결해야 한다.




//Observer behaviors
//Tracking Session Manager는 Observer에게 다음 두 가지 기능을 제공한다.
// • 업데이트 등록
// • 서버와 연결 해제


