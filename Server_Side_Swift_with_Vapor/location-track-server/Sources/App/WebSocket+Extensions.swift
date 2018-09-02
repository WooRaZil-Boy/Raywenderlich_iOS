import Vapor
import WebSocket
import Foundation

extension WebSocket {
    func send(_ location: Location) {
        //Location model을 활용해 JSON으로 쉽게 위치를 보낼 수 있도록 해 준다.
        let encoder = JSONEncoder()
        
        guard let data = try? encoder.encode(location) else {
            return
        }
        //Location model을 JSON으로 변환
        
        send(data)
    }
}

