import Foundation
import Combine

//Printing events
let subscription = (1...3).publisher
    .print("publisher")
    .sink { _ in }

class TimeLogger: TextOutputStream {
    private var previous = Date()
    private let formatter = NumberFormatter()
    
    init() {
        formatter.maximumFractionDigits = 5
        formatter.minimumFractionDigits = 5
    }
    
    func write(_ string: String) { //TextOutputStream 프로토콜은 해당 함수를 구현해야 한다.
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmed.isEmpty else { return }
        
        let now = Date()
        print("+\(formatter.string(for: now.timeIntervalSince(previous))!)s: \(string)")
        previous = now
    }
}

let subscription = (1...3).publisher
    .print("publisher", to: TimeLogger())
    .sink { _ in }




//Acting on events — performing side effects
let request = URLSession.shared
    .dataTaskPublisher(for: URL(string: "https://www.raywenderlich.com/")!)

let subscription = request //Cancellable을 유지해야 한다.
    //그렇지 않으면, 구독이 시작되자마자 즉시 취소된다.
    .handleEvents(receiveSubscription: { _ in
        print("Network request will start")
    }, receiveOutput: { _ in
        print("Network request data received")
    }, receiveCancel: {
        print("Network request cancelled")
    }) //디버깅에 활용할 수 있다.
    .sink(receiveCompletion: { completion in
        print("Sink received completion: \(completion)")
    }) { (data, _) in
        print("Sink received data: \(data)")
    }




//Using the debugger as a last resort
.breakpoint(receiveOutput: { value in
    return value > 10 && value < 15
})




//Key points
// • print 연산자(operator)를 사용해 publisher의 생명 주기(lifecycle)를 추적할 수 있다.
// • 자신만(own)의 TextOutputStream을 생성하여, 사용자 지정(customize) 출력(output) 문자열(strings)을 정의할 수 있다.
// • handleEvents 연산자(operator)를 사용하여 수명 주기(lifecycle) 이벤트(events)를 가져오고(intercept) 작업을 수행(perform)한다.
// • breakpointOnError 및 breakpoint 연산자(operators)를 사용하여 특정(specific) 이벤트(events)를 중단(break)한다.
