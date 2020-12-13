/// Copyright (c) 2019 Razeware LLC
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

import Foundation
import Combine

var subscriptions = Set<AnyCancellable>()

//Hello Publisher
example(of: "Publisher") {
    let myNotification = Notification.Name("MyNotification") //알림을 만든다.
    
    let publisher = NotificationCenter.default
        .publisher(for: myNotification, object: nil)
    //기본 NotificationCenter에 액세스하고, publisher(for:object:)의 반환값을 지역 상수에 할당한다.
    
    let center = NotificationCenter.default
    //기본 NotificationCenter를 가져온다.
    
    let observer = center.addObserver(forName: myNotification, object: nil, queue: nil) { notification in
        print("Notification received!")
    } //알림을 받을 옵저버를 생성한다.
    
    center.post(name: myNotification, object: nil) //알림 개시
    
    center.removeObserver(observer) //NotificationCenter에서 옵저버를 제거한다.
}




//Hello Subscriber
example(of: "Subscriber") {
    let myNotification = Notification.Name("MyNotification")
    
    let publisher = NotificationCenter.default
        .publisher(for: myNotification, object: nil)
    
    let center = NotificationCenter.default
    
    let subscription = publisher
        .sink { _ in
            print("Notification received from a publisher!")
        } //publisher에서 sink를 호출하여 구독을 만든다.
    
    center.post(name: myNotification, object: nil) //알림 개시
    
    subscription.cancel() //구독 취소
    //Subscription 프로토콜이 Cancellable을 상속하기 때문에 cancel()을 호출할 수 있다.
}

example(of: "Just") {
    let just = Just("Hello world!") //각 subscriber에게 한 번만 작동하는 publisher
    //Just는 primitive value로 publisher를 생성할 수 있다.
    
    _ = just
        .sink( //publisher에 대한 구독을 하고 수신된 각 이벤트에 대한 메시지를 출력한다.
            receiveCompletion: { //완료 이벤트에 대한 클로저
                print("Received completion", $0)
            }, receiveValue: { //수신 값에 대한 클로저
                print("Received value", $0)
            }
        )
    
    _ = just
        .sink(
            receiveCompletion: {
                print("Received completion (another)", $0)
            }, receiveValue: {
                print("Received value (another)", $0)
            }
        )
}

example(of: "assign(to:on:)") {
    class SomeObject { //클래스
        var value: String = "" {
            didSet { //속성 옵저버
                print(value)
            }
        }
    }
    
    let object = SomeObject() //클래스의 인스턴스 생성
    
    let publisher = ["Hello", "world"].publisher //문자열 배열으로 publisher를 만든다.
    
    _ = publisher
        .assign(to: \.value, on: object) //수신된 각 값을 객체의 value 속성에 할당하여 publisher를 구독한다.
    //KVO에서 \.변수명 으로 관찰하고자 하는 속성에 접근할 수 있다. keyPath를 \.변수명 으로 쓸수 있다.
}

example(of: "assign(to:)") {
    class SomeObject {
        @Published var value = 0
    }
    //@Published 속성 래퍼로 annotated된 속성을 사용하여 class의 인스턴스를 정의하고 생성한다.
    //이는 일반 속성으로 액세스할 수 있는 값에 대한 게시자를 만든다.

    let object = SomeObject()

    object.$value
        .sink {
            print($0)
        }
    //@Published 속성에 $ 접두사를 사용하여, 기본 publisher에 대한 액세스 권한을 얻고
    //subscribe하여 수신된 각 값을 출력한다.

    (0..<10).publisher
        .assign(to: &object.$value)
    //숫자의 publisher를 만들고, 그것이 내보낸 각 값을 객체의 value publisher에 할당한다.
    //&를 사용하여 속성에 대한 inout 참조를 나타낸다.
}




//Creating a custom subscriber
example(of: "Custom Subscriber") {
    let publisher = (1...6).publisher
    //range publisher를 사용하여, 정수형의 publisher를 생성한다.
    
//    let publisher = ["A", "B", "C", "D", "E", "F"].publisher //문자열 publisher
    //타입이 일치하지 않기 때문에 오류가 발생한다.
    
    final class IntSubscriber: Subscriber { //사용자 정의 subscriber인 IntSubscriber를 정의한다.
        typealias Input = Int
        typealias Failure = Never
        //type aliase로 정수를 Input으로 수신하고, Never을 오류로 수신(오류가 발생하지 않음)하는 것을 구현한다.
        
        func receive(subscription: Subscription) { //publisher가 구독을 전달하기 위해 호출하는 메서드
            subscription.request(.max(3))
            //subscriber는 구독시 최대 3개의 값을 수신한다.
        }
        
        func receive(_ input: Int) -> Subscribers.Demand { //publisher가 게시한 새 값을 보낼때 호출하는 메서드
            print("Received value", input) //수신한 각 값을 출력한다.
            return .none //subscriber가 수요를 조정하지 않음을 나타낸다.
            //.max(0)와 같다.
            
//            return .unlimited //무제한
            //이전에 수신 값의 최대 개수를 3으로 지정했지만, 여기서 변경될 수 있다.
            //.max(1)를 사용해도 최대 값의 수가 1씩 늘어나므로 같은 결과를 얻는다.
        }
        
        func receive(completion: Subscribers.Completion<Never>) { //publisher가 완료(혹은 오류)되었을 때 호출하는 메서드
            print("Received completion", completion) //완료 이벤트를 출력한다.
        }
    } //Subscriber 프로토콜은 반드시 이 5가지를 구현해야 한다.
    
    let subscriber = IntSubscriber() //subscriber 생성
    //publisher의 Output과 Failure이 일치해야 한다.
    
    publisher.subscribe(subscriber) //publisher에게 subscriber를 구독하도록 한다.
}




//Hello Future
//example(of: "Future") {
//    func futureIncrement(integer: Int, afterDelay delay: TimeInterval) -> Future<Int, Never> {
//        Future<Int, Never> { promise in
//            print("Original")
//            DispatchQueue.global().asyncAfter(deadline: .now() + delay) { //지정한 시간에 호출된다.
//                promise(.success(integer + 1))
//            }
//        }
//    }
//
//    let future = futureIncrement(integer: 1, afterDelay: 3)
//    //3초 지연 후, 전달한 정수(1)를 증가시킨다. 이전에 만든 팩토리함수를 사용하여 future를 생성한다.
//
//    future //sink로 future를 구독한다. //future는 publisher
//        .sink(receiveCompletion: { print($0) }, //수신한 완료 이벤트를 출력
//            receiveValue: { print($0) }) //수신한 값 출력
//        .store(in: &subscriptions) //결과를 subscriptions에 저장한다.
//
//    future
//        .sink(receiveCompletion: { print("Second", $0) },
//            receiveValue: { print("Second", $0) })
//        .store(in: &subscriptions)
//}




//Hello Subject
example(of: "PassthroughSubject") {
    enum MyError: Error { //커스텀 오류 유형을 정의한다.
        case test
    }
    
    final class StringSubscriber: Subscriber { //커스텀 Subscriber를 정의한다.
        typealias Input = String //문자열 수신
        typealias Failure = MyError //MyError 오류 수신
        
        func receive(subscription: Subscription) { //publisher가 구독을 전달하기 위해 호출하는 메서드
            subscription.request(.max(2))
        }
        
        func receive(_ input: String) -> Subscribers.Demand { //publisher가 게시한 새 값을 보낼때 호출하는 메서드
            print("Received value", input)
            return input == "World" ? .max(1) : .none
            //받은 값에 따라 demand를 조정한다.
        }
        
        func receive(completion: Subscribers.Completion<MyError>) { //publisher가 완료(혹은 오류)되었을 때 호출하는 메서드
            print("Received completion", completion)
        }
    }
    
    let subscriber = StringSubscriber() //StringSubscriber 인스턴스 생성
    
    let subject = PassthroughSubject<String, MyError>()
    //<String, MyError> 타입의 PassthroughSubject 생성
    
    subject.subscribe(subscriber) //subject에 구독한다. //첫 번째 구독
    
    let subscription = subject
        .sink( //sink를 사용해 구독을 생성한다. //두 번째 구독
            receiveCompletion: { completion in
                print("Received completion (sink)", completion)
            },
            receiveValue: { value in
                print("Received value (sink)", value)
            }
        )
    
    subject.send("Hello")
    subject.send("World")
    //값을 보낸다.
    
    subscription.cancel() //두 번째 구독을 취소한다.
    subject.send("Still there?") //다른 값을 보낸다.
    
    subject.send(completion: .failure(MyError.test)) //오류
    subject.send(completion: .finished) //완료
    subject.send("How about another one?")
}

example(of: "CurrentValueSubject") {
    var subscriptions = Set<AnyCancellable>() //subscriptions 집합 생성
    
    let subject = CurrentValueSubject<Int, Never>(0) //<Int, Never> 유형의 CurrentValueSubject 생성
    //정수가 게시되고, error는 발생하지 않으며 초기 값은 0이 된다.
    
    subject
        .print()
        .sink(receiveValue: { print($0) }) //subject에 대한 구독을 생성한다. 값을 출력
        .store(in: &subscriptions) //구독을 subscriptions 집합에 저장한다.
        //동일하게 업데이트 되도록 사본 대신 inout 매개변수를 사용해 원본을 전달한다.
    
    subject.send(1)
    subject.send(2)
    //두 개의 새 값을 내보낸다.
    
    print(subject.value) //subject의 현재 값을 언제든지 확인할 수 있다.
    
    subject.value = 3 //직접 속성에 접근하여 값을 변경해 줄 수도 있다.
    print(subject.value)
    
    subject
        .print()
        .sink(receiveValue: { print("Second subscription:", $0) }) //구독 생성
        .store(in: &subscriptions) //저장
    
//    subject.value = .finished //완료 이벤트를 할당할 수 없다.
    subject.send(completion: .finished) //완료 이벤트
}




//Dynamically adjusting demand
example(of: "Dynamically adjusting Demand") {
    final class IntSubscriber: Subscriber {
        typealias Input = Int //값 타입 Int
        typealias Failure = Never //오류 타입 Never
        
        func receive(subscription: Subscription) { //publisher가 구독을 전달하기 위해 호출하는 메서드
            subscription.request(.max(2))
        }
        
        func receive(_ input: Int) -> Subscribers.Demand { //publisher가 게시한 새 값을 보낼때 호출하는 메서드
            print("Received value", input)
            
            switch input {
            case 1:
                return .max(2) //새로운 max는 4가 된다(원래 max 2 + 새 max 2).
            case 3:
                return .max(1) //새로운 max는 5가 된다(이전 max 4 + 새 max 1).
            default:
                return .none //max는 5가 된다(이전 max 4 + 새 max 0).
            }
        }
        
        func receive(completion: Subscribers.Completion<Never>) { //publisher가 완료(혹은 오류)되었을 때 호출하는 메서드
            print("Received completion", completion)
        }
    }
    
    let subscriber = IntSubscriber()
    
    let subject = PassthroughSubject<Int, Never>()
    
    subject.subscribe(subscriber)
    
    subject.send(1)
    subject.send(2)
    subject.send(3)
    subject.send(4)
    subject.send(5)
    subject.send(6)
}




//Type erasure
example(of: "Type erasure") {
    let subject = PassthroughSubject<Int, Never>() //passthrough subject를 생성한다.
    
    let publisher = subject.eraseToAnyPublisher() //subject에서 type-erased publisher를 생성한다.
    
    publisher
        .sink(receiveValue: { print($0) }) //구독
        .store(in: &subscriptions) //저장
    
    subject.send(0) //passthrough subject에 새 값을 전달한다.
//    publisher.send(1) //Error
    //원래 PassthroughSubject는 send 연산자를 사용할 수 있다.
    //하지만 let publisher = subject.eraseToAnyPublisher() 에서
    //Type erasure되었기 때문에 send를 사용할 수 없다.
}
