/*:
Copyright (c) 2019 Razeware LLC

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
distribute, sublicense, create a derivative work, and/or sell copies of the
Software in any work that is designed, intended, or marketed for pedagogical or
instructional purposes related to programming, coding, application development,
or information technology.  Permission for such use, copying, modification,
merger, publication, distribution, sublicensing, creation of derivative works,
or sale is expressly withheld.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

import Foundation
import Combine

fileprivate final class ShareReplaySubscription<Output, Failure: Error>: Subscription {
    //struct가 아닌 generic class를 사용하여 Subscription을 구현한다.
    //Publisher와 Subscriber 모두, 해당 subscription에 접근하고 변경할 수 있어야 한다.
    let capacity: Int
    //replay 버퍼의 최대용량. 초기화 중에 설정한 상수가 된다.
    var subscriber: AnySubscriber<Output,Failure>? = nil
    //구독 중에 subscriber에 대한 참조를 유지한다. 유형이 삭제된(type-erased) AnySubscriber를 사용하면 type 시스템에서 자유로울 수 있다.
    var demand: Subscribers.Demand = .none
    //publisher가 subscriber로부터 받은 누적 demand를 추적하여 request된 값을 수를 정확하게 전달할 수 있도록 한다.
    var buffer: [Output]
    //subscriber에게 전달되거나 버려질 때까지 버퍼에 pending values를 저장한다.
    var completion: Subscribers.Completion<Failure>? = nil
    //잠재적으로 completion 이벤트를 유지한다. 새로운 subscribers 가 값을 request 하자마자 즉시 제공해줄 수 있다.
    
    init<S>(subscriber: S,
            replay: [Output],
            capacity: Int,
            completion: Subscribers.Completion<Failure>?)
        where S: Subscriber,
              Failure == S.Failure,
              Output == S.Input {
        self.subscriber = AnySubscriber(subscriber)
        //유형이 지워진(type-erased) subscriber를 저장한다.
        self.buffer = replay
        self.capacity = capacity
        self.completion = completion
        //upstream publisher의 현재 버퍼, 최대 용량, 완료 이벤트를 저장한다.
    }
    
    private func complete(with completion: Subscribers.Completion<Failure>) {
        guard let subscriber = subscriber else { return }
        //메서드가 지속되는 동안 subscriber를 유지하지만, 클래스에서는 nil로 설정한다.
        //이 방어조치는 subscriber 완료 시, 잘못 발행될 수 있는 모든 호출을 무시하도록 보장한다.
        
        self.subscriber = nil
        self.completion = nil
        self.buffer.removeAll()
        //completion을 nil로 설정하여, 완료가 한 번만 보내지도록 한 다음 버퍼를 비운다.
        
        subscriber.receive(completion: completion)
        //completion 이벤트를 subscriber에게 relay 한다.
    }
    
    private func emitAsNeeded() {
        guard let subscriber = subscriber else { return }
        //subscriber가 있는지 확인한다.
        
        while self.demand > .none && !buffer.isEmpty {
            //buffer가 비어있지 않고, demand가 아직 남아있는 경우에만 값을 내보낸다.
            self.demand -= .max(1)
            //아직 처리되지 않은 demand를 하나 줄인다.
            
            let nextDemand = subscriber.receive(buffer.removeFirst())
            //subscriber에게 첫 번째 처리되지 않은 값을 내보내고, 그 대가로 새로운 demand를 받는다.
            if nextDemand != .none {
                self.demand += nextDemand
                //.none이 아닌 경우에만 새로운 demand를 추가한다.
                //Combine에서 Subscribers.Demand.none을 0으로 처리하지 않은 채, .none을 더하거나 빼면 exception이 발생한다.
            }
        }
        
        if let completion = completion {
            //completion가 pending 중이라면, 전송한다.
            complete(with: completion)
        }
    }
    
    func request(_ demand: Subscribers.Demand) {
        if demand != .none {
            self.demand += demand
        }
        
        emitAsNeeded()
    }
    
    func cancel() {
        complete(with: .finished)
    }
    
    func receive(_ input: Output) {
        guard subscriber != nil else { return }
        //subscriber가 있는지 확인한다.
        
        buffer.append(input)
        //버퍼에 value을 추가한다. demands에 제한이 없는 대부분의 경우에 이를 최적화할 수 있지만, 지금은 메서드 구현에 집중한다.
        if buffer.count > capacity {
            buffer.removeFirst()
            //request된 capacity보다 많은 value를 버퍼링하지 않도록 한다. 이 작업은 선입 선출 방식으로 처리한다.
            //이미 버퍼가 가득찬 상태에서 새 값을 받는다면, 첫 번째 값이 먼저 제거된다.
        }
        
        emitAsNeeded()
        //subscriber에게 결과를 전달한다.
    }
    
    func receive(completion: Subscribers.Completion<Failure>) {
        guard let subscriber = subscriber else { return }
        
        self.subscriber = nil
        self.buffer.removeAll()
        subscriber.receive(completion: completion)
    }
}

extension Publishers {
    final class ShareReplay<Upstream: Publisher>: Publisher {
        //여러 subscribers가 이 operator의 단일 instance를 공유할 수 있도록 하려면 구조체 대신 클래스를 사용한다.
        //또한, upstream publisher의 최종 유형을 매개변수로 사용하는 제네릭이다.
        typealias Output = Upstream.Output
        typealias Failure = Upstream.Failure
        //이 새로운 publisher는 upstream publisher의 output 또는 failure 유형을 변경하지 않고 그대로 사용한다.
        
        private let lock = NSRecursiveLock()
        //동시에 여러 subscribers에게 feed를 제공할 것이므로, 변경 가능한 변수에 독점적인(exclusive) 접근을 보장하려면 lock이 필요하다.
        private let upstream: Upstream
        //upstream publisher에 대한 참조를 유지한다. 구독 수명주기의 다양한 시점에서 필요한다.
        private let capacity: Int
        //초기화 중에 replay buffer의 최대 용량을 지정한다.
        private var replay = [Output]()
        //당연히 기록된 value에 대한 storage이 필요하다.
        private var subscriptions = [ShareReplaySubscription<Output, Failure>]()
        //여러 subscribers에게 feed를 제공하므로, 이벤트를 알리기 위해 이를 유지하고 있어야 한다.
        //각 subscriber는 전용 ShareReplaySubscription에서 값을 얻는다.
        private var completion: Subscribers.Completion<Failure>? = nil
        //operator는 완료 후에도 value를 replay할 수 있으므로 upstream publisher의 완료 여부를 기억해야 한다.
        
        init(upstream: Upstream, capacity: Int) {
            self.upstream = upstream
            self.capacity = capacity
        }
        
        func receive<S: Subscriber>(subscriber: S)
            where Failure == S.Failure,
                  Output == S.Input {
            lock.lock()
            defer { lock.unlock() }
            
            let subscription = ShareReplaySubscription(
                subscriber: subscriber,
                replay: replay,
                capacity: capacity,
                completion: completion)
            //새 구독은 subscriber를 참조하고, current replay buffer, capacity, outstanding completion event를 받는다.
            
            subscriptions.append(subscription)
            //구독을 계속 유지하여, 향후에 발생하는 이벤트를 전달한다.
            subscriber.receive(subscription: subscription)
            //subscriber에게 구독을 내보내면, 지금 또는 나중에 value를 request할 수 있다.
            
            guard subscriptions.count == 1 else { return }
            //upstream publisher를 한 번만 구독한다.
            
            let sink = AnySubscriber(receiveSubscription: { subscription in
                //클로저를 받는 AnySubscriber를 사용하여 구독 즉시 .unlimited 값을 request하여 publisher가 완료되도록 한다.
                subscription.request(.unlimited)
            }, receiveValue: { [weak self] (value: Output) -> Subscribers.Demand in
                //수신한 값을 downstream subscribers에게 relay 한다.
                self?.relay(value)
                return .none
            }, receiveCompletion: { [weak self] in
                //upstream에서 받은 완료 이벤트로 publisher를 완료한다.
                self?.complete($0)
            })
            
            upstream.subscribe(sink)
        }
        
        private func relay(_ value: Output) {
            lock.lock()
            defer { lock.unlock() }
            //여러 subscribers가 이 publisher를 공유하므로, lock으로 변경 가능한 변수에 대한 접근을 보호해야 한다.
            //defer를 꼭 사용해야 하는 것은 아니지만, 나중에 메서드를 수정하여 조기에 return 하면서
            //unlock 하는 것을 잊어비릴 경우를 대비하는 좋은 방법이다.
            
            guard completion == nil else { return }
            //upstream이 아직 완료되지 않은 경우에만 값을 relay한다.
            
            replay.append(value)
            if replay.count > capacity {
                replay.removeFirst()
            }
            //rolling buffer에 value를 추가하고, capacity의 최신 값들만 유지한다.
            //이 값들은 새 subscribers에게 replay 된다.
            
            subscriptions.forEach {
                _ = $0.receive(value)
                //버퍼링된 값을 연결된 각 subscriber에게 relay한다.
            }
        }
        
        private func complete(_ completion: Subscribers.Completion<Failure>) {
            lock.lock()
            defer { lock.unlock() }
            
            self.completion = completion
            //미래의 subscribers를 위해 완료 이벤트를 저장한다.
            subscriptions.forEach {
                _ = $0.receive(completion: completion)
                //연결된 각 subscriber에게 relay한다.
            }
        }
    }
}

extension Publisher {
    func shareReplay(capacity: Int = .max) -> Publishers.ShareReplay<Self> {
        return Publishers.ShareReplay(upstream: self, capacity: capacity)
    }
}

var logger = TimeLogger(sinceOrigin: true)
//이 playground에 정의된 TimeLogger 객체를 사용한다.
let subject = PassthroughSubject<Int,Never>()
//다른 시간에 value을 보내는 상황을 시뮬레이션하기 위해 subject를 사용한다.
let publisher = subject
    .print("shareReplay") //디버깅
    .shareReplay(capacity: 2)
//subject를 공유하고, 마지막 두 value만 replay한다.
subject.send(0)
//subject를 사용해 초기값을 내보낸다.
//shared publisher에 연결된 subscriber가 없으므로 출력이 표시되지 않는다.

let subscription1 = publisher.sink(receiveCompletion: {
    print("subscription1 completed: \($0)", to: &logger)
}, receiveValue: {
    print("subscription1 received \($0)", to: &logger)
})

subject.send(1)
subject.send(2)
subject.send(3)

let subscription2 = publisher.sink(receiveCompletion: {
    print("subscription2 completed: \($0)", to: &logger)
}, receiveValue: {
    print("subscription2 received \($0)", to: &logger)
})

subject.send(4)
subject.send(5)
subject.send(completion: .finished)

var subscription3: Cancellable? = nil

DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
    print("Subscribing to shareReplay after upstream completed")
    
    subscription3 = publisher.sink(receiveCompletion: {
        print("subscription3 completed: \($0)", to: &logger)
    }, receiveValue: {
        print("subscription3 received \($0)", to: &logger)
        
    })
}

//: [Next](@next)
