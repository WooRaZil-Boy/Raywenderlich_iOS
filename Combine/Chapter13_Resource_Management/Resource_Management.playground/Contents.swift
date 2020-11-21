import Foundation
import Combine

//The share() operator
let shared = URLSession.shared
    .dataTaskPublisher(for: URL(string: "https://www.raywenderlich.com")!)
    .map(\.data)
    .print("shared")
    .share()

print("subscribing first")

let subscription1 = shared.sink(receiveCompletion: { _ in }, receiveValue: { print("subscription1 received: '\($0)'") })

print("subscribing second")

//let subscription2 = shared.sink(receiveCompletion: { _ in }, receiveValue: { print("subscription2 received: '\($0)'") })

var subscription2: AnyCancellable? = nil

DispatchQueue.main.asyncAfter(deadline: .now() + 5) { //5초 뒤 실행
    print("subscribing second")

    subscription2 = shared.sink(receiveCompletion: { print("subscription2 completion \($0)") }, receiveValue: { print("subscription2 received: '\($0)'") })
}




//The multicast(_:) operator
let subject = PassthroughSubject<Data, URLError>()
//업 스트림 publisher가 내보내는 값과 완료 이벤트를 전달하는 subject

let multicasted = URLSession.shared
    .dataTaskPublisher(for: URL(string: "https://www.raywenderlich.com")!)
    .map(\.data)
    .print("shared")
    .multicast(subject: subject)
    //subject를 사용하여, multicast된 publisher를 준비한다.

let subscription1 = multicasted //구독
    .sink(receiveCompletion: { _ in }, receiveValue: { print("subscription1 received: '\($0)'") })

let subscription2 = multicasted //구독
    .sink(receiveCompletion: { _ in }, receiveValue: { print("subscription2 received: '\($0)'") })

multicasted.connect() //업 스트림 publisher에 connect 한다.

subject.send(Data()) //데이터 전송. 두 구독이 모두 데이터를 수신하는지 확인한다.




//Future
let future = Future<Int, Error> { fulfill in
    do {
        let result = try performSomeWork()
        fulfill(.success(result))
    } catch {
        fulfill(.failure(error))
    }
}
//Future는 네트워크 요청의 단일 결과를 공유해야 할 때 사용하기 좋다.


//Key points
// • 네트워킹(networking)과 같이 많은 리소스(resource-heavy)가 필요한 작업(processes)을 처리 할 때, 구독(subscription) 작업을 공유(sharing)하는 것이 중요하다.
// • 단순히 여러 subscribers에게 publisher를 공유(share)해야 하는 경우 share()를 사용한다.
// • 업 스트림(upstream) publisher가 작동하는 시기(when)와 값(values)이 subscribers에게 전달(propagate)되는 방법을 세밀하게(fine) 제어(control)해야 하는 경우,
//  multicast(_:)를 사용한다.
// • Future를 사용하여 계산(computation)의 단일(single) 결과(result)를 여러(multiple) subscribers와 공유(share)한다.
