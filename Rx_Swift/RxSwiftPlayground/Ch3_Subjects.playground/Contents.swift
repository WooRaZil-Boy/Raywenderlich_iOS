//: Please build the scheme 'RxSwiftPlayground' first
import RxSwift



/*:
 Copyright (c) 2014-2017 Razeware LLC
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

//********** Chapter 3: Subjects **********

//앱 개발 시에 필요한 것은 실시간으로 Observable에 새 값을 수동으로 추가한 후 전달하는 것
//Observable이고 observer 인 것을 Subjects라 한다.

example(of: "PublishSubject") {
    let subject = PublishSubject<String>()
    //Observable하고 observer인 객체 //Subject
    //값을 받아 subscriber에게 게시해 주는 역할을 한다 (신문사의 느낌).
    subject.onNext("Is anyone listening?")
    //subject에 문자열이 놓인다. subscriber가 없기 때문에 아무 일이 일어나지 않는다.
    
    let subscriptionOne = subject
        .subscribe(onNext: { string in //subject 구독
            print(string)
            //출력되지 않는다. 이벤트가 일어난 후 subscribe() 되었기 때문.
            //PublishSubject가 현재 subscriber에게만 emit 된다.
            //따라서 이벤트가 추가되었을 때 subscribe된 상태가 아니라면 안 된다.
        })
    
    subject.on(.next("1")) //선언 시 문자열로 했으므로 문자열만 넣을 수 있다.
    //on() 연산자로 모든 subscriber 에게 next() 이벤트를 알린다.
    //subscribe 이후 이벤트가 일어났으므로 출력된다.
    subject.onNext("2") //on(.next("2"))의 축약형
    
    //Subject는 observable과 observer의 역할을 동시에 수행한다.
    //위에서 subject가 next를 전달받아 subscribers에게 전달한다.
    //Suject에는 4가지 유형이 있다.
    //• PublishSubject : 빈 상태로 시작하고, 새로운 요소만 구독자에게 알린다.
    //• BehaviorSubject : 초기값이 있고, 가장 최신의 요소만 구독자에게 알린다.
    //• ReplaySubject : 버퍼 크기로 초기화 된다. 버퍼의 크기 만큼 최신 요소만 구독자에게 알린다.
    //• Variable : BehaviorSubject를 래핑. 현재값을 상태로 유지하고
    //  최신/초기 값만 구독자에게 알린다. BehaviorSubject를 더 쉽게 사용한다.
    
    //PublishSubject는 .completed, .error 이벤트로 끝날 때까지
    //구독 시점부터 새 이벤트를 알릴 때 유용하다 (새 이벤트만 전달해야 할 경우). p.70
    //subscribers는 subscribe 이후 일어난 이벤트에 대해서만 알림을 받는다.
    
    let subscriptionTwo = subject
        .subscribe { event in //구독
            print("2)", event.element ?? event)
            //event가 optional 이므로 바인딩 해준다.
            //subscribe 이후 이벤트가 일어나지 않으면 아무런 출력이 없다.
    }
    
    subject.onNext("3") //next 이벤트
    //subject를 구독한 subscriptionOne, subscriptionTwo 모두가 출력한다.
    subscriptionOne.dispose() //subscriptionOne 종료
    subject.onNext("4") //subscriptionTwo만 출력한다.
    
    //publish subject가 .completed, .error 이벤트를 받으면(정지 이벤트)
    //subscribers에게 정지 이벤트를 emit한 후, 더 이상 .next를 발생시키지 않는다.
    subject.onCompleted() //completed 이벤트 //subscribers에게 알림
    subject.onNext("5") //이 이벤트는 emit 되지 않는다.
    subscriptionTwo.dispose() //subscriptionTwo 종료
    //항상 끝나면 dispose 해 주는 것을 잊지 말아야 한다.
    
    let disposeBag = DisposeBag() //DisposeBag 생성
    subject
        .subscribe { //새로운 subscribe 생성 //이미 completed 된 시퀀스를 구독
            print("3)", $0.element ?? $0) //축약해 쓸 수 있다.
            //모든 subject는 종료되어도 이후에
            //subscribe한 구독자에게 중지 이벤트를 re-emit 한다. //따라서 출력 됨.
            //따라서 코드에 중지 이벤트에 대한 처리를 꼭 해주는 것이 좋다.
        }
        .disposed(by: disposeBag) //종료
    
    subject.onNext("?") //출력 되지 않는다.
    
    //PublishSubject는 시간에 민감한 데이터를 다를 때 유용하다.
    //하지만, 10시에 경매가 종료되었고, 9시59분에 "1분뒤 경매 종료" 알림을 줬을 때
    //10시 1분에 들어온 사용자는 이 정보에 대한 알림이 필요없다.
    //오히려 버그성 알림이 될 뿐이다.
}

enum MyError: Error { //에러 타입
    case anError
}

func print<T: CustomStringConvertible>(label: String, event: Event<T>) {
    print(label, event.element ?? event.error ?? event) //삼항 연산자
    //요소가 있는 경우 인쇄, 에러가 있는 경우 에러를 인쇄. 그것도 아니라면 이벤트 자체 인쇄
    //삼항 연산자로 간단히 줄일 수 있다.
}

example(of: "BehaviorSubject") {
    let subject = BehaviorSubject(value: "Initial value") //초기값 필요
    //BehaviorSubject는 PublishSubject와 비슷하지만, 최신의 이벤트를 전달.
    //즉, 구독 시, 구독 전에 일어났던 가장 최신의 next 이벤트를 받아온다. p.72
    //PublishSubject는 정지 이벤트에 한해서는 BehaviorSubject처럼 된다.
    //BehaviorSubject 구독 시 항상 최신 요소를 emit하기 때문에
    //이벤트 없는 Subject가 될 수 없다. 따라서 초기값이 반드시 필요하다.
    let disposeBag = DisposeBag()
    subject.onNext("X")
    subject
        .subscribe { //구독
            print(label: "1)", event: $0) //helper 메서드
            //구독 전 다른 next 이벤트가 없으면, 초기값을 제공한다.
            //구독 전 다른 next 이벤트가 있었다면, 해당 이벤트를 제공한다.
            //이후에는 PublishSubject와 같다.
        }
        .disposed(by: disposeBag) //종료
    
    subject.onError(MyError.anError) //에러 이벤트
    subject
        .subscribe { //구독
            print(label: "2)", event: $0)
            //구독 전에 최신 이벤트(erorr)를 받아온다.
            //최신 이벤트가 erorr 혹은 completed라면
            //BehaviorSubject와 PublishSubject의 구독 시 같은 결과를 얻을 것이다.
        }
        .disposed(by: disposeBag) //종료
    
    //BehaviorSubject는 가장 최근의 이벤트를 받아와야 하는 경우 유용하다.
    //ex. 프로필에 새로운 데이터를 업데이트 하기 전까진 최근의 데이터로 채워 넣을 수 있다.
    
    //검색 시 가장 최근 검색어 하나 표시 : BehaviorSubject
    //검색 시 가장 최근 검색어 x개 표시 : ReplaySubject
}

example(of: "ReplaySubject") {
    let subject = ReplaySubject<String>.create(bufferSize: 2) //버퍼 크기 설정
    //ReplaySubject는 특정 크기만큼 이벤트를 받아온다. 버퍼를 이용해 캐싱을 한다. p.75
    //ReplaySubject를 사용할 경우, 이미지와 같은 대용량 데이터를 캐싱하는 경우와
    //요소가 배열인 경우 메모리 사용량이 크게 증가하므로 조심해야 한다.
    //항상 ReplaySubject를 사용할 때는 메모리 관리를 염두에 두어야 한다.
    let disposeBag = DisposeBag()
    subject.onNext("1")
    subject.onNext("2")
    subject.onNext("3")
    
    subject
        .subscribe { //구독
            print(label: "1)", event: $0)
        }
        .disposed(by: disposeBag)
    
    subject
        .subscribe { //구독
            print(label: "2)", event: $0)
        }
        .disposed(by: disposeBag)
    
    //subscribe 시 버퍼 사이즈 내의 이벤트가 re-emit 된다.
    
    subject.onNext("4") //이미 구독중인 구독자에게 emit된다.
    subject.onError(MyError.anError) //이미 구독중이 구독자에게 emit된다.
    subject.dispose() //종료.
    //일반적으로 dispose()를 명시적으로 실행하는 경우는 별로 없다.
    //.disposed(by: disposeBag)는 dispose하는 것이 아니라
    //dispose 시의 핸들러를 정의한 것
    
    subject
        .subscribe{
            print(label: "3)", event: $0)
            //subscribe 시 버퍼 사이즈 내의 이벤트가 re-emit 된다.
            //종료되었더라도 버퍼에 남아 있는 이벤트들이 있으면 re-emit된다.
            //dispose() 되었다면 버퍼가 비어지기 때문에 이벤트를 받아오지 못한다.
        }
        .disposed(by: disposeBag)
    //.disposed(by: disposeBag)로 strong reference를 방지할 수 있다.
    
    //publish, behavior, replay subject로 대부분의 모델을 구현할 수 있다.
}

example(of: "Variable") {
    let variable = Variable("Initial value") //타입 추론
    //Variable은 BehaviorSubject를 래핑한다. 때문에 초기값이 필요하다.
    let disposeBag = DisposeBag()
    variable.value = "New initial value" //value로 요소 추가
    //현재 값을 가져오거나 설정한다. 새 값이 설정될 때 마다 subscriber에게 emit 된다.
    //새로 설정한 값이 이전 값과 같더라도 emit 된다.
    //value 속성으로 현재 값에 접근할 수 있다.
    //일반 subject와 달리 onNext()대신 value로 요소를 설정한다.
    variable.asObservable() //asObservable()로 BehaviorSubject에 접근 가능하다.
        .subscribe { //구독
            print(label: "1)", event: $0)
            //BehaviorSubject처럼 최신의 event를 받는다.
        }
        .disposed(by: disposeBag)
    
    variable.value = "1" //추가
    variable.asObservable()
        .subscribe { //구독
            print(label: "2)", event: $0)
            //BehaviorSubject처럼 최신의 event를 받는다.
        }
        .disposed(by: disposeBag)
    variable.value = "2" //구독중인 모든 variable에게 영향 준다.
    
    //variable은 .error와 .completed를 수신할 수 없다. //수신 시도 시 컴파일 오류
    //variable 할당이 해제될 때 (메모리 해제 시)
    //자동으로 완료되므로 completed 이벤트를 추가하지 않는다.
    //밑의 코드들은 모두 오류
    //    variable.value.onError(MyError.anError)
    //    variable.asObservable().onError(MyError.anError)
    //    variable.value = MyError.anError
    //    variable.value.onCompleted()
    //    variable.asObservable().onCompleted()
}
