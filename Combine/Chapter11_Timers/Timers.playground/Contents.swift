import Foundation
import Combine

//Using RunLoop
let runLoop = RunLoop.main

let subscription = runLoop.schedule(after: runLoop.now, interval: .seconds(1), tolerance: .milliseconds(100)) {
    print("Timer fired")
}

runLoop.schedule(after: .init(Date(timeIntervalSinceNow: 3.0))) {
    cancellable.cancel()
}




//Using the Timer class
let publisher = Timer.publish(every: 1.0, on: .main, in: .common)

let publisher = Timer.publish(every: 1.0, on: .current, in: .common)

let publisher = Timer
    .publish(every: 1.0, on: .main, in: .common)
    .autoconnect()

let subscription = Timer
    .publish(every: 1.0, on: .main, in: .common)
    .autoconnect()
    .scan(0) { counter, _ in counter + 1 }
    .sink { counter in
        print("Counter is \(counter)")
    }




//Using DispatchQueue
let queue = DispatchQueue.main
let source = PassthroughSubject<Int, Never>()
//타이머 값을 내보낼 Subject를 생성한다.
var counter = 0 //타이머가 실행될 때마다 증가하게 될 것이다.

let cancellable = queue.schedule(after: queue.now, interval: .seconds(1)) {
    //매 초마다 반복작업을 예약한다. 즉시 시작된다.
    source.send(counter)
    counter += 1
}

let subscription = source.sink { //구독하여 타이머 값을 출력한다.
    print("Timer emitted \($0)")
}




//Key points
// • Objective-C 코드에 대한 경험이 있다면(nostalgia), 오래된 클래스(class)인 RunLoop를 사용하여 타이머를 만들 수 있다.
// •  Timer.publish를 사용하여 지정된(specified) RunLoop에서 지정된(given) 간격(intervals)으로 값(values)을
//  생성(generates)하는 publisher를 얻을(obtain) 수 있다.
// // • dispatch queue에서 이벤트(events)를 내보내(emitting)는 최신(modern) 타이머(timers)인 DispatchQueue.schedule을 사용한다.
