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

import Combine
import Foundation

protocol Pausable {
    var paused: Bool { get }
    func resume()
}

final class PausableSubscriber<Input, Failure: Error>: Subscriber, Pausable, Cancellable {
    //pausable subscriber는 Pausable 및 Cancellable이다.
    //이것은 pausableSink 함수가 반환할 객체(object)로, struct가 아닌 class로 구현하는 이유이기도 하다.
    //객체가 복사되는 것을 원하지 않으며, lifetime 의 특정 지점에서 변경 가능해야 한다.
    let combineIdentifier = CombineIdentifier()
    //subscriber는 자신의 publisher streams를 관리하고 최적화하기 위해 Combine에 고유 식별자를 제공해야 한다.
    
    let receiveValue: (Input) -> Bool
    //receiveValue 클로저는 Bool을 반환한다.
    //true는 더 많은 값을 받을 수 있음을 나타내고, false는 구독을 pause 해야 함을 나타낸다.
    let receiveCompletion: (Subscribers.Completion<Failure>) -> Void
    //publisher로부터 완료 이벤트를 수신하면, completion 클로저가 호출된다.
    private var subscription: Subscription? = nil
    //pause 이후, 더 많은 값을 요청할 수 있도록 구독을 유지한다.
    //retain cycle을 피하기 위해, 더 이상 필요하지 않은 경우 해당 속성을 nil로 설정해야 한다.
    var paused = false
    //Pausable 프로토콜을 준수하기 위해 paused 속성을 노출한다.
    
    init(receiveValue: @escaping (Input) -> Bool,
         receiveCompletion: @escaping (Subscribers.Completion<Failure>) -> Void) {
        //initializer는 두 개의 클로저를 받는다.
        //subscriber는 publisher로부터 새 값을 받고 완료되는 즉시 이를 호출한다.
        //클로저는 sink 함수를 사용하는 것과 비슷하지만, 한 가지 예외가 있다.
        //receiveValue 클로저는 receiver가 더 많은 값을 받을 준비가 되었는지 혹은 구독을 보류해야 하는지 여부를 나타내는 Bool 값을 반환한다.
        self.receiveValue = receiveValue
        self.receiveCompletion = receiveCompletion
    }
    
    func cancel() {
        subscription?.cancel()
        subscription = nil
        //구독을 취소할 때 retain cycles을 방지하기 위해 subscription을 nil로 설정한다.
    }
    
    func receive(subscription: Subscription) {
        self.subscription = subscription
        //publisher가 만든 구독을 나중에 pause 상태에서 다시 시작할 수 있도록 저장한다.
        subscription.request(.max(1))
        //즉시 하나의 값을 요청한다.
        //subscriber는 pause할 수 있으며, pause가 필요한 시기를 여기서 예측할 수 없다.
        //여기서의 전략은 값을 하나씩 요청하는 것이다.
    }
    
    func receive(_ input: Input) -> Subscribers.Demand {
        paused = receiveValue(input) == false
        //새 값을 받으면, receiveValue를 호출하고 그에 따라 pause 상태를 업데이트 한다.
        return paused ? .none : .max(1)
        //subscriber가 pause된 경우 .none을 반환하면 현재 더 이상의 값을 원하지 않음을 나타낸다.
        //그렇지 않으면, cycle을 계속하기 위해 하나를 더 요청한다.
        //(초기값으로 하나를 요청했다는 것을 기억해야 한다)
    }
    
    func receive(completion: Subscribers.Completion<Failure>) {
        //완료 이벤트를 수신하면, receiveCompletion로 전달하고 구독이 더 이상 필요하지 않으므로 nil로 설정한다.
        receiveCompletion(completion)
        subscription = nil
    }
    
    func resume() {
        guard paused else { return }
        
        paused = false
        subscription?.request(.max(1))
        //publisher가 paused된 경우, 하나의 값을 요청하여 cycle을 다시 시작한다.
    }
}

extension Publisher {
    func pausableSink(receiveCompletion: @escaping ((Subscribers.Completion<Failure>) -> Void),
                      receiveValue: @escaping ((Output) -> Bool))
        -> Pausable & Cancellable {
        //pausableSink 연산자는 sink 연산자와 매우 비슷하다.
        //유일한 차이점은 receiveValue 클로저의 반환 유형이 Bool 이라는 것이다.
        let pausable = PausableSubscriber(receiveValue: receiveValue,
                                          receiveCompletion: receiveCompletion)
        self.subscribe(pausable)
        //새 PausableSubscriber 인스턴스를 생성하고 publisher인 self에 구독한다.
        
        return pausable
        //subscriber는 구독을 재개 및 취소할 때 사용할 객체이다.
    }
}

let subscription = [1, 2, 3, 4, 5, 6]
    .publisher
    .pausableSink(receiveCompletion: { completion in
        print("Pausable subscription completed: \(completion)")
    }) { value -> Bool in
        print("Receive value: \(value)")
        if value % 2 == 1 {
            print("Pausing")
            return false
        }
        
        return true
    }

let timer = Timer.publish(every: 1, on: .main, in: .common)
    .autoconnect()
    .sink { _ in
        guard subscription.paused else { return }
        print("Subscription is paused, resuming")
        subscription.resume()
    }

//: [Next](@next)
