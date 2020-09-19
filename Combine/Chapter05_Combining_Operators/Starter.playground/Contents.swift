// Copyright (c) 2019 Razeware LLC
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
// distribute, sublicense, create a derivative work, and/or sell copies of the
// Software in any work that is designed, intended, or marketed for pedagogical or
// instructional purposes related to programming, coding, application development,
// or information technology.  Permission for such use, copying, modification,
// merger, publication, distribution, sublicensing, creation of derivative works,
// or sale is expressly withheld.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit
import Combine

var subscriptions = Set<AnyCancellable>()

//Prepending
example(of: "prepend(Output...)") {
    let publisher = [3, 4].publisher
    //3, 4를 내보내는 publisher를 생성한다.
    
    publisher
        .prepend(1, 2) //publisher의 자체 값 앞에 1, 2를 추가한다.
        .prepend(-1, 0) //추가. 가장 앞에 추가된다.
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions) //저장
}

example(of: "prepend(Sequence)") {
    let publisher = [5, 6, 7].publisher
    //5, 6, 7을 내보내는 publisher를 생성한다.
    
    publisher
        .prepend([3, 4]) //배열 추가
        .prepend(Set(1...2)) //집합 추가
        .prepend(stride(from: 6, to: 11, by: 2)) //6 ~ 11. 2씩 증가
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions) //저장
}

example(of: "prepend(Publisher)") {
    let publisher1 = [3, 4].publisher //3, 4를 내보내는 publisher를 생성한다.
    let publisher2 = [1, 2].publisher //1, 2를 내보내는 publisher를 생성한다.
    //2개의 publisher를 생성한다.
    
    publisher1
        .prepend(publisher2) //publisher1의 시작부분에 publisher2를 추가한다.
        //publisher1의 값은 publisher2가 완료된 후에만 내보내진다.
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions) //저장
}

example(of: "prepend(Publisher) #2") {
    let publisher1 = [3, 4].publisher //3, 4를 내보내는 publisher를 생성한다.
    let publisher2 = PassthroughSubject<Int, Never>() //동적으로 값을 받아들이는 PassthroughSubject
    //2개의 publisher를 생성한다.
    
    publisher1
        .prepend(publisher2) //앞에 추가
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
    
    publisher2.send(1)
    publisher2.send(2)
    publisher2.send(completion: .finished) //완료
    //반드시 완료되어야 계속 진행할 수 있는 상태라는 걸 알려 줄 수 있다.
    //1, 2를 Subject인 publisher2에 내보낸다.
}




//Appending
example(of: "append(Output...)") {
    let publisher = [1].publisher
    //단일 값 1을 내보내는 publisher를 생성한다.
    
    publisher
        .append(2, 3) //뒤에 추가
        .append(4) //뒤에 추가
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions) //저장
}

example(of: "append(Output...) #2") {
    let publisher = PassthroughSubject<Int, Never>()
    //값을 수동으로 내보내는 PassthroughSubject를 생성한다.
    
    publisher
        .append(3, 4) //뒤에 추가
        .append(5) //뒤에 추가
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions) //저장
    
    publisher.send(1)
    publisher.send(2)
    publisher.send(completion: .finished) //완료
    //반드시 완료되어야 계속 진행할 수 있는 상태라는 걸 알려 줄 수 있다.
    //1, 2를 PassthroughSubject로 내보낸다.
}

example(of: "append(Sequence)") {
    let publisher = [1, 2, 3].publisher
    //1, 2, 3를 내보내는 publisher를 생성한다.
    
    publisher
        .append([4, 5]) //배열로 4, 5를 추가한다(순서가 보장된다).
        .append(Set([6, 7])) //집합으로 6, 7을 추가한다(순서가 보장되지 않는다).
        .append(stride(from: 8, to: 11, by: 2)) //Strideable로 8, 10(8 ~ 11까지 2씩 증가)을 추가한다.
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions) //저장
}

example(of: "append(Publisher)") {
    let publisher1 = [1, 2].publisher //1, 2를 내보내는 publisher를 생성한다.
    let publisher2 = [3, 4].publisher //3, 4를 내보내는 publisher를 생성한다.
    //2개의 publisher를 생성한다.
    
    publisher1
        .append(publisher2)
        //publisher2를 publisher1에 추가하기 때문에 publisher2의 모든 값이 완료된 후 publisher1의 끝에 추가된다.
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions) //저장
}




//Advanced combining
example(of: "switchToLatest") {
    let publisher1 = PassthroughSubject<Int, Never>()
    let publisher2 = PassthroughSubject<Int, Never>()
    let publisher3 = PassthroughSubject<Int, Never>()
    //Int를 받고, 오류를 발생시키지 않는(Never) PassthroughSubject를 3개 생성한다.
    
    let publishers = PassthroughSubject<PassthroughSubject<Int, Never>, Never>()
    //다른 PassthroughSubject를 받는 두 번째 PassthroughSubject를 생성한다.
    //예를 들어, publisher1, publisher2, publisher3 등을 보낼 수 있다.
    
    publishers
        .switchToLatest()
        //publishers subject에서 다른 publisher를 내보낼 때마다 새로운 publisher로 전환화고, 이전 구독을 취소한다.
        .sink(receiveCompletion: { _ in print("Completed!") },
              receiveValue: { print($0) })
        .store(in: &subscriptions) //저장
    
    publishers.send(publisher1) //publisher1을 내보낸다.
    publisher1.send(1)
    publisher1.send(2)
    //publisher1에 1, 2를 내보낸다.
    
    publishers.send(publisher2) //publisher2를 내보낸다.
    //switchToLatest 때문에 publisher1에 대한 구독이 취소된다.
    publisher1.send(3) //구독이 취소되었기 때문에 무시된다.
    publisher2.send(4)
    publisher2.send(5)
    //publisher2는 현재 구독 중이므로 4, 5는 정상적으로 내보내진다.
    
    publishers.send(publisher3) //publisher3을 내보낸다.
    //switchToLatest 때문에 publisher2에 대한 구독이 취소된다.
    publisher2.send(6) //구독이 취소되었기 때문에 무시된다.
    publisher3.send(7)
    publisher3.send(8)
    publisher3.send(9)
    //publisher3은 현재 구독 중이므로 7, 8, 9는 정상적으로 내보내진다.
    
    publisher3.send(completion: .finished)
    publishers.send(completion: .finished)
    //모든 활성 구독이 완료된다.
}

//example(of: "switchToLatest - Network Request") {
//    let url = URL(string: "https://source.unsplash.com/random")! //url
//
//    func getImage() -> AnyPublisher<UIImage?, Never> { //getImage 함수
//        //네트워크 요청을 수행하여 이미지를 가져온다
//        return URLSession.shared
//            .dataTaskPublisher(for: url) //Combine extension for Foundation
//            .map { data, _ in UIImage(data: data) }
//            .print("image")
//            .replaceError(with: nil)
//            .eraseToAnyPublisher()
//    }
//
//    let taps = PassthroughSubject<Void, Never>()
//    //사용자의 탭을 시뮬레이션하는 PassthroughSubject를 생성한다.
//
//    taps
//        .map { _ in getImage() } //버튼을 누르면, getImage()를 호출하여 이미지에 대한 네트워크 요청을 매핑한다.
//        //Publisher<Void, Never>를 <Publisher<UIImage?, Never>, Never>로 변환한다. publisher of publishers가 된다.
//        .switchToLatest() //publisher of publishers가 있으므로, switchToLatest를 사용한다.
//        //하나의 publisher만 값을 내보내고, 이전 구독의 취소를 보장한다.
//        .sink(receiveValue: { _ in })
//        .store(in: &subscriptions) //저장
//
//    taps.send() //탭 시뮬레이션
//
//    DispatchQueue.main.asyncAfter(deadline: .now() + 3) { //탭 시뮬레이션
//        taps.send()
//    }
//
//    DispatchQueue.main.asyncAfter(deadline: .now() + 3.1) { //탭 시뮬레이션
//        taps.send()
//    }
//}

example(of: "merge(with:)") {
    let publisher1 = PassthroughSubject<Int, Never>()
    let publisher2 = PassthroughSubject<Int, Never>()
    //값을 수동으로 내보내는 PassthroughSubject를 생성한다.
    //정수를 내보내며, 오류가 발생하지 않는다.
    
    publisher1
        .merge(with: publisher2) //병합
        //양쪽에서 방출된 값을 interleaving한다.
        //Combine에서는 최대 8개의 publishers를 merge할 수 있다.
        .sink(receiveCompletion: { _ in print("Completed") },
              receiveValue: { print($0) })
        .store(in: &subscriptions) //저장
    
    publisher1.send(1)
    publisher1.send(2)
    
    publisher2.send(3)
    
    publisher1.send(4)
    
    publisher2.send(5)
    //값을 추가한다.
    
    publisher1.send(completion: .finished)
    publisher2.send(completion: .finished)
    //완료 이벤트를 내보낸다.
}

example(of: "combineLatest") {
    let publisher1 = PassthroughSubject<Int, Never>() //정수를 내보내며, 오류가 발생하지 않는다.
    let publisher2 = PassthroughSubject<String, Never>() //문자열을 내보내며, 오류가 발생하지 않는다.
    //값을 수동으로 내보내는 PassthroughSubject를 생성한다.
    
    publisher1
        .combineLatest(publisher2) //publisher2에서 최근에 방출된 값을 publisher1과 결합한다.
        //최대 4개의 다른 publishers를 결합할 수 있다.
        .sink(receiveCompletion: { _ in print("Completed") },
              receiveValue: { print("P1: \($0), P2: \($1)") })
        .store(in: &subscriptions) //저장
    
    publisher1.send(1)
    publisher1.send(2)
    
    publisher2.send("a")
    publisher2.send("b")
    
    publisher1.send(3)
    
    publisher2.send("c")
    //값을 내보낸다.
    
    publisher1.send(completion: .finished)
    publisher2.send(completion: .finished)
    //완료 이벤트를 내보낸다.
}

example(of: "zip") {
    let publisher1 = PassthroughSubject<Int, Never>() //정수를 내보내며, 오류가 발생하지 않는다.
    let publisher2 = PassthroughSubject<String, Never>() //문자열을 내보내며, 오류가 발생하지 않는다.
    //값을 수동으로 내보내는 PassthroughSubject를 생성한다.
    
    publisher1
        .zip(publisher2) //publisher1과 publisher2를 결합하여 새로운 값을 방출한다.
        .sink(receiveCompletion: { _ in print("Completed") },
              receiveValue: { print("P1: \($0), P2: \($1)") })
        .store(in: &subscriptions) //저장
    
    publisher1.send(1)
    publisher1.send(2)
    publisher2.send("a")
    publisher2.send("b")
    publisher1.send(3)
    publisher2.send("c")
    publisher2.send("d")
    //값을 내보낸다.
    
    publisher1.send(completion: .finished)
    publisher2.send(completion: .finished)
    //완료 이벤트를 내보낸다.
}
