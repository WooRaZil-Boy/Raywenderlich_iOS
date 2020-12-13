/// Copyright (c) 2020 Razeware LLC
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
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import Foundation
import RxSwift
import RxRelay

example(of: "PublishSubject") {
    let subject = PublishSubject<String>()
    
    subject.on(.next("Is anyone listening?"))
    
    let subscriptionOne = subject
        .subscribe(onNext: { string in
            print(string)
        })
    //구독 이전에 이벤트가 내보내졌으므로 아무것도 출력되지 않는다.
    
    subject.on(.next("1")) //구독 이후에 이벤트가 내보내졌으므로 출력이 된다.
    
    subject.onNext("2") //subject.on(.next("2"))의 단축 구문
    
    
    let subscriptionTwo = subject
        .subscribe { event in
            print("2)", event.element ?? event)
        }
    
    subject.onNext("3")
    
    subscriptionOne.dispose()

    subject.onNext("4")
    
    subject.onCompleted()
    //on(.completed)와 같다. completed 이벤트를 subject에 추가한다.
    //이는 subject의 observable sequence를 종료한다.
    
    subject.onNext("5")
    //subject에 다른 요소를 추가한다. 하지만, subject는 이미 종료되었기 때문에 이것은 방출되지 않고 출력되지 않는다.
    
    subscriptionTwo.dispose()
    //구독을 폐기한다.
    
    let disposeBag = DisposeBag()
    
    subject
        .subscribe { //subject를 subscribe한다.
            print("3)", $0.element ?? $0)
        }
        .disposed(by: disposeBag) //dispose bag에 추가한다.
    
    subject.onNext("?")
}




enum MyError: Error { //예제에서 사용할 오류 Erro 유형을 정의한다.
    case anError
}

func print<T: CustomStringConvertible>(label: String, event: Event<T>) {
    print(label, (event.element ?? event.error) ?? event)
    //앞선 예제에서 사용한 삼항 연산자(ternary operator)를 사용하여, 요소가 존재하는 경우 이를 출력하고, 오류가 있는 경우에는 이벤트 자체를 출력하는 helper 함수를 만든다.
}

example(of: "BehaviorSubject") { //새로운 예제를 시작한다.
    let subject = BehaviorSubject(value: "Initial value")
    //BehaviorSubject를 생성한다. 생성자는 초기값이 필요하다.
    let disposeBag = DisposeBag()
    subject.onNext("X")
    
    subject
        .subscribe {
            print(label: "1)", event: $0)
        }
        .disposed(by: disposeBag)
    
    subject.onError(MyError.anError)
    //subject에 error 이벤트를 추가한다.
    
    subject
        .subscribe { //새 구독을 생성한다.
            print(label: "2)", event: $0)
        }
        .disposed(by: disposeBag)
}




example(of: "ReplaySubject") {
    let subject = ReplaySubject<String>.create(bufferSize: 2)
    //버퍼 크기가 2인 ReplaySubject를 생성한다.
    //ReplaySubject는 create(bufferSize:) type method를 사용해 초기화한다.
    let disposeBag = DisposeBag()
    
    subject.onNext("1")
    subject.onNext("2")
    subject.onNext("3")
    //subject에 세 요소를 추가한다.
    
    subject
        .subscribe { //구독한다.
            print(label: "1)", event: $0)
        }
        .disposed(by: disposeBag)
    
    subject
        .subscribe { //구독한다.
            print(label: "2)", event: $0)
        }
        .disposed(by: disposeBag)
    
    subject.onNext("4")
    subject.onError(MyError.anError) //추가
    subject.dispose() //추가
    
    subject
        .subscribe {
            print(label: "3)", event: $0)
        }
        .disposed(by: disposeBag)
}




example(of: "PublishRelay") {
    let relay = PublishRelay<String>()
    let disposeBag = DisposeBag()
    
    relay.accept("Knock knock, anyone home?")
    
    relay
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)
    
    relay.accept("1") //replay는 onNext 대신 accept를 사용한다.
}

example(of: "BehaviorRelay") {
    let relay = BehaviorRelay(value: "Initial value")
    //초기값을 사용해 BehaviorRelay를 생성한다. Relay의 type을 유추할 수 있지만, BehaviorRelay<String>(value: "Initial value")와 같이 명시적으로 선언할 수도 있다.
    let disposeBag = DisposeBag()
  
    relay.accept("New initial value")
    //relay에 새 요소를 추가한다.
    
    relay
        .subscribe { //구독한다.
            print(label: "1)", event: $0)
        }
        .disposed(by: disposeBag)
    
    relay.accept("1") //relay에 새 요소를 추가한다.
    
    relay
        .subscribe { //구독한다.
            print(label: "2)", event: $0)
        }
        .disposed(by: disposeBag)
    
    relay.accept("2") //relay에 다른 새 요소를 추가한다.
    
    print(relay.value) //현재값에 접근할 수 있다.
}
