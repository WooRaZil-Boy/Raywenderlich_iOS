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

struct DispatchTimerConfiguration {
    let queue: DispatchQueue?
    //타이머가 지정된 대기열에서 실행된다. optional로 선언하여 상관없는 경우에는 타이머의 대기열에서 실행된다.
    let interval: DispatchTimeInterval
    //구독시간부터 시작하여 타이머가 실행되는 간격
    let leeway: DispatchTimeInterval
    //시스템이 타이머 이벤트 전달을 지연시킬 수 있는 최대 시간
    let times: Subscribers.Demand
    //수신할 타이머 이벤트의 개수. custom 타이머를 만들고 있으므로, 완료 전에 제한된 수의 이벤트를 유연하게 제공할 수 있도록 한다.
}

extension Publishers {
    struct DispatchTimer: Publisher {
        typealias Output = DispatchTime
        typealias Failure = Never
        //타이머는 현재 시간을 DispatchTime으로 내보낸다. 실패 유형은 Never로 결코 실패하지 않는다.
        
        let configuration: DispatchTimerConfiguration
        //주어진 configuration의 사본을 보관한다. 지금은 사용하지 않지만, subscriber를 받을 때 필요하다.
        
        init(configuration: DispatchTimerConfiguration) {
            self.configuration = configuration
        }
        
        func receive<S: Subscriber>(subscriber: S) where Failure == S.Failure, Output == S.Input {
            //제네릭 함수. subscriber의 type에 맞는 compile-time specialization이 필요하다.
            let subscription = DispatchTimerSubscription(subscriber: subscriber, configuration: configuration)
            //뒤에서 정의하는 DispatchTimerSubscription 내의 작업을 수행한다.
            
            subscriber.receive(subscription: subscription)
            //2장 "Publishers & Subscribers"에서 학습했듯이, subscriber는 Subscription을 받은 다음 값을 request를 할 수 있다.
        }
    }
}

private final class DispatchTimerSubscription<S: Subscriber>: Subscription where S.Input == DispatchTime {
    //외부에서 사용하지 않으므로 private, 참조를 전달해야 하므로 class
    //Input 유형이 해당 구독에서 내보내는 DispatchTime인 subscribers를 대상으로 한다.
    let configuration: DispatchTimerConfiguration
    //subscriber가 전달한 configuration
    var times: Subscribers.Demand
    //configuration에서 복사한 타이머의 최대 실행횟수. 값을 보낼 때마다 감소시키는 counter로 사용한다.
    var requested: Subscribers.Demand = .none
    //subscriber의 현재 demand. 값을 내보낼때마다 감소시킨다.
    var source: DispatchSourceTimer? = nil
    //타이머 이벤트를 생성할 내부 DispatchSourceTimer
    var subscriber: S?
    //subscriber. 구독이 complete, fail 또는 cancel 되지 않는 한 subscriber를 유지할 책임이 있음을 분명히 한다.
    //the subscription is responsible for retaining the subscriber for as long as it doesn’t complete, fail or cancel
    
    init(subscriber: S,
         configuration: DispatchTimerConfiguration) {
        self.configuration = configuration
        self.subscriber = subscriber
        self.times = configuration.times
    }
    
    func request(_ demand: Subscribers.Demand) {
        //이 필수 method는 subscriber로부터 demands를 받는다.
        //demands는 누적된다. subscriber가 요청한 총 value의 개수를 합한다.
        //Demands are cumulative: They add up
        guard times > .none else {
            //configuration에 지정된 대로, subscriber에게 충분한 value를 이미 보냈는지 확인한다.
            //해당 guard문의 경우는 publisher가 받은 demands와 무관하게 value의 최대 개수를 내보낸 경우이다.
            subscriber?.receive(completion: .finished)
            //publisher가 value 전송을 완료했음을 subscriber에게 통지한다.
            return
        }
        
        requested += demand
        //새로운 demand를 추가하여 요청된 value의 총 수를 증가시킨다.
        
        if source == nil, requested > .none {
            //타이머가 이미 존재하는지 확인한다.
            //그렇지 않고 이미 요청된 value이 존재한다면 타이머를 시작한다.
            let source = DispatchSource.makeTimerSource(queue: configuration.queue)
            //optional인 requested queue에서 DispatchSourceTimer를 생성한다.
            source.schedule(deadline: .now() + configuration.interval,
                            repeating: configuration.interval,
                            leeway: configuration.leeway)
            //configuration.interval 간격 이후에 타이머가 실행되도록 예약한다.
            
            source.setEventHandler { [weak self] in
                //타이머에 대한 event handle를 설정한다. 이는 타이머가 실행될 때마다 호출하는 간단한 클로저이다.
                //weak self를 사용하여 구독이 해제될 수 있도록 한다.
                guard let self = self, self.requested > .none else { return }
                //현재 요청된 value가 있는지 확인한다. backpressure에서 살펴보겠지만, 현재의 demand 없이 publisher를 중지할 수 있다.
                
                self.requested -= .max(1)
                self.times -= .max(1)
                //두 counter의 값을 감소시킨다.
                
                _ = self.subscriber?.receive(.now())
                //subscriber에게 값을 내보낸다.
                
                if self.times == .none {
                    //내보낸 값의 수가 지정한 최대 개수를 충족하면, publisher가 완료된 것으로 간주하고 completion 이벤트를 내보낸다.
                    self.subscriber?.receive(completion: .finished)
                }
            }
            
            self.source = source
            source.activate()
        }
    }
    
    func cancel() {
        source = nil
        subscriber = nil
    }
}

extension Publishers {
    static func timer(queue: DispatchQueue? = nil,
                      interval: DispatchTimeInterval,
                      leeway: DispatchTimeInterval = .nanoseconds(0),
                      times: Subscribers.Demand = .unlimited)
        -> Publishers.DispatchTimer {
        return Publishers.DispatchTimer(configuration: .init(queue: queue,
                                                             interval: interval,
                                                             leeway: leeway,
                                                             times: times))
    }
}

var logger = TimeLogger(sinceOrigin: true)
//해당 playground는 10장, "Debugging"에서 생성한 것과 매우 유사한 클래스인 TimeLogger를 정의한다.
//유일한 차이점은 두 개의 연속 값 사이의 시간 차이 또는 타이머가 생성된 이후 경과 시간을 표시할 수 있다는 것이다.
//여기서는 logging을 시작한 이후 시간을 표시한다.
let publisher = Publishers.timer(interval: .seconds(1), times: .max(6))
//publisher는 매초마다 한 번씩, 정확히 6번 실행된다.
let subscription = publisher.sink { time in
    print("Timer emits: \(time)", to: &logger)
    //TimeLogger를 사용해 받은 값을 기록한다.
}

DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) { //취소 테스트
    subscription.cancel()
}

//: [Next](@next)
