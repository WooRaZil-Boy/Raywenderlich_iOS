import Foundation
import Combine

//URLSession extensions
guard let url = URL(string: "https://mysite.com/mydata.json") else {
    return
}

let subscription = URLSession.shared
    //결과 구독을 유지하는 것이 중요하다. 그렇지 않으면 즉시 취소되고 요청이 실행되지 않는다.
    .dataTaskPublisher(for: url)
    //URL을 매개변수로 사용하는 dataTaskPublisher(for:)의 overload를 사용한다.
    .sink(receiveCompletion: { completion in
        if case .failure(let err) = completion {
            //항상 오류 처리를 해야 한다. 네트워크 연결은 실패하기 쉽다.
            print("Retrieving data failed with error \(err)")
        }
    }, receiveValue: { data, response in
        //결과는 Data와 URLResponse 객체의 튜플이다.
       print("Retrieved data of size \(data.count), response = \(response)")
    })




//Codable support
let subscription = URLSession.shared
    .dataTaskPublisher(for: url)
//    .tryMap { data, _ in
//        try JSONDecoder().decode(MyType.self, from: data)
//    }
    .map(\.data) //dataTaskPublisher는 튜플을 내보내므로, map을 사용하여 data 부분만 따로 가져온다.
    .decode(type: MyType.self, decoder: JSONDecoder())
    //Combine을 사용하여 tryMap 대신 위와 같이 구현할 수 있다.
    .sink(receiveCompletion: { completion in
        if case .failure(let err) = completion {
            print("Retrieving data failed with error \(err)")
        }
    }, receiveValue: { object in
        print("Retrieved object \(object)")
    })




//Publishing network data to multiple subscribers
let url = URL(string: "https://www.raywenderlich.com")!
let publisher = URLSession.shared
    .dataTaskPublisher(for: url) //DataTaskPublisher를 생성
    .map(\.data) //해당 데이터 매핑
    .multicast { PassthroughSubject<Data, URLError>() }
    //multicast의 클로저는 적절한 유형의 subject를 반환해야 한다.
    //혹은 multicast(subject:)에 subject를 전달해야 한다.

let subscription1 = publisher //publisher를 구독한다.
    //ConnectablePublisher이므로, 바로 작동하지 않는다.
    .sink(receiveCompletion: { completion in
        if case .failure(let err) = completion {
            print("Sink1 Retrieving data failed with error \(err)")
        }
    }, receiveValue: { object in
        print("Sink1 Retrieved object \(object)")
    })

let subscription2 = publisher //publisher를 구독한다.
    //ConnectablePublisher이므로, 바로 작동하지 않는다.
    .sink(receiveCompletion: { completion in
        if case .failure(let err) = completion {
            print("Sink2 Retrieving data failed with error \(err)")
        }
    }, receiveValue: { object in
        print("Sink2 Retrieved object \(object)")
    })

let subscription = publisher.connect()
//준비가 되면, publisher를 연결한다. 작업을 시작하고 모든 subscribers에게 값을 보낸다.




//Key points
// • Combine은 dataTaskPublisher(for:)라는 dataTask(with:completionHandler:)
//  메서드(method)에 대한 publisher-based 추상화(abstraction)를 제공한다.
// • 데이터 값(values)을 내보내는(emits) publisher에서 내장된(built-in) decode 연산자(operator)를 사용하여
//  Codable 준수(Codable-conforming) 모델(models)을 디코딩(decode)할 수 있다.
// • 여러(multiple) subscribers와 구독(subscription) 재생(replay)을 공유(share)하는 연산자(operator)는 없지만,
//  ConnectablePublisher 와 multicast 연산자(operator)를 사용하여 이 동작(behavior)을 만들 수 있다.
