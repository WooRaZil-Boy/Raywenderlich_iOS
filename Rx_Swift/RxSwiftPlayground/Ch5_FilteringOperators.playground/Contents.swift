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

//********** Chapter 5: Filtering Operators **********

example(of: "ignoreElements") {
    let strikes = PublishSubject<String>()
    //Subject는 observable과 observer의 역할을 동시에 수행한다.
    //PublishSubject : 빈 상태로 시작하고, 새로운 요소만 구독자에게 알린다.
    let disposeBag = DisposeBag()
    
    strikes
        .ignoreElements()
        //ignoreElements를 사용해서 이벤트를 무시할 수 있다.
        //.next는 무시 되나, completed와 error는 허용한다. 다이어그램 p.104
        //.completed 또는 .error 이벤트를 통해 종료 되었을 때만 알리고 싶을 때 유용
        .subscribe { _ in //구독
            print("You're out!")
        }
        .disposed(by: disposeBag)
    
    strikes.onNext("X")
    strikes.onNext("X")
    strikes.onNext("X")
    //ignoreElements 했으므로 next 이벤트가 일어나지 않는다.
    
    strikes.onCompleted() // 이 이벤트는 일어난다.
}

example(of: "elementAt") {
    let strikes = PublishSubject<String>()
    let disposeBag = DisposeBag()
    
    strikes
        .elementAt(2)
        //무시하되, n번 째 요소만 처리할 경우에는 elementAt()을 사용할 수 있다.
        //나머지 특징은 ignoreElements()와 같다. p.106
        .subscribe(onNext: { _ in //구독
            print("You're out!")
        })
        .disposed(by: disposeBag)
    
    strikes.onNext("X")
    strikes.onNext("X")
    strikes.onNext("X")
}

example(of: "filter") {
    let disposeBag = DisposeBag()
    
    Observable.of(1, 2, 3, 4, 5, 6)
        .filter { integer in
        //ignoreElements, elementAt는 Observable에서 생성된 필터링 요소
        //필터 할 조건이 다중이 된다면, filter를 이용해 해당 요소만 통과하도록 할 수 있다.
            integer % 2 == 0 //필터 조건을 클로저로 정의해 준다. //짝수만 통과 p.107
        }
        .subscribe(onNext: { //구독
            //위에서 필터링을 만족하는 경우에만 next 이벤트가 일어난다.
            print($0)
        })
        .disposed(by: disposeBag)
}

example(of: "skip") {
    let disposeBag = DisposeBag()
    
    Observable.of("A", "B", "C", "D", "E", "F")
        .skip(3) //skip을 사용하면, 매개변수로 전달한 숫자까지 무시한다.
        //skip은 1부터 시작한다. 따라서 여기선, A, B, C가 무시된다. p.108
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)
}

example(of: "skipWhile") {
    let disposeBag = DisposeBag()
    
    Observable.of(2, 2, 3, 4, 4)
        .skipWhile{ integer in
        //skipWhile은 filter처럼 필터링 할 수 있다.
        //필터와 달리 지정된 조건이 true인 경우 패싱한고,
        //처음 false가 나올 때까지 skip된다. p.109
            integer % 2 == 0
        }
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)
    
    //ex. 연속해서 돈을 인출하는 프로그램에서, 잔고가 0이 되기 전까지 인출
}

//지금까지는 이미 정해진 값이 있는 정적 필터링이었다. 동적으로 필터링 하는 방법도 있다.

example(of: "skipUtil") {
    let disposeBag = DisposeBag()
    let subject = PublishSubject<String>()
    let trigger = PublishSubject<String>() //subject를 트리거
    
    subject
        .skipUntil(trigger)
        //skipUtil은 다른 Observable이 emit될 때까지 요소를 건너 뛴다. p.110
        //전달된 Observable(trigger)가 emit되기 전까지 이벤트를 건너 뛰고 이후에 받는다.
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)
    
    subject.onNext("A")
    subject.onNext("B") //두 next 이벤트는 skip된다.
    
    trigger.onNext("X")
    //트리거에서 next 이벤트가 emit 되었으므로 이 후의 이벤트는 받게 된다. skip을 멈춘다.
    
    subject.onNext("C") //이 후 이벤트를 받는다.
}



example(of: "take") {
    let disposeBag = DisposeBag()
    
    Observable.of(1, 2, 3, 4, 5, 6)
        .take(3)
        //take는 skip과 반대이다. 요소를 가져온다. p.112
        //skip과 같이 1부터 count가 시작한다. 여기서는 3개의 요소를 가져온다.
        .subscribe(onNext: { //구독
            print($0)
        })
        .disposed(by: disposeBag)
}

example(of: "takeWhile") {
    let disposeBag = DisposeBag()
    
    Observable.of(2, 2, 4, 4, 6, 6)
        .enumerated() //시퀀스를 enumerate 한다. //튜플 (index, value)
        .takeWhile { index, integer in
        //takeWhile은 skipWhile의 반대이다. p.113
        //지정된 조건이 true인 경우 이벤트가 발생하고,
        //처음 false가 나오면 그 때부터 skip 된다.
            integer % 2 == 0 && index < 3
            //조건이 실패할 때까지 이벤트를 받는다.
        }
        .map { $0.element } //기본 라이브러리 map과 같지만, observable이다.
        //요소만 가져온다.
        .subscribe(onNext: { //구독
            print($0)
        })
        .disposed(by: disposeBag)
}

example(of: "takeUntil") {
    let disposeBag = DisposeBag()
    let subject = PublishSubject<String>()
    let trigger = PublishSubject<String>() //subject를 트리거
    
    subject
        .takeUntil(trigger)
        //takeUntil은 skipUntil의 반대이다. p.114
        //다른 Observable이 emit될 때까지 요소를 받는다.
        //전달된 Observable(trigger)가 emit되기 전까지 이벤트를 받고, 이후에 건너 뛴다.
        .subscribe(onNext: { //구독
            print($0)
        })
        .disposed(by: disposeBag)
    
    subject.onNext("1")
    subject.onNext("2")
    
    trigger.onNext("X") //트리거에서 emite되었으므로 이 이벤트 이후 부터는 skip 된다.
    
    subject.onNext("3") //이 이벤트는 출력되지 않는다.
    
    //RxCocoa 라이브러리의 API와 함께 takeUtil을 사용하면, DisposeBag를 사용하지 않고도
    //subscribe를 처분해 메모리를 회수 받을 수 있다.
    //대부분의 경우에는 DisposeBag을 사용하는 것이 편하다.
}


example(of: "distinctUntilChanged") {
    let disposeBag = DisposeBag()
    
    Observable.of("A", "A", "B", "B", "A")
        .distinctUntilChanged()
        //distinctUntilChanged는 연속되는 중복 항목을 필터링 하는 경우에 쓸 수 있다.
        //중복이 아닌 연속되는 중복만 걸러낸다.
        .subscribe(onNext: { //구독
            print($0)
        })
        .disposed(by: disposeBag)
}

example(of: "distinctUntilChanged(_:)") {
    let disposeBag = DisposeBag()
    
    let formatter = NumberFormatter() //숫자 형식을 만들어주는 클래스
    formatter.numberStyle = .spellOut //숫자를 영어로 읽는 형식
    //ex. 110 = "one hundred ten"
    
    Observable<NSNumber>.of(10, 110, 20, 200, 210, 310)
        .distinctUntilChanged { a, b in
        //distinctUntilChanged는 Equatable으로 판단한다.
        //따라서 Equatable을 구현한 객체들의 비교 논리를 통해 커스텀하게 구현해 줄 수 있다.
        //또한, Equatable을 준수하지 않는 유형에 대해 중복을 방지하려는 경우에도 유용하다.
            guard let aWords = formatter.string(from: a)?.components(separatedBy: " "),
                let bWords = formatter.string(from: b)?.components(separatedBy: " ") else {
                    //string(from: ) : string으로 변환
                    //components(separatedBy: ) : split
                    return false
            }
            
            var containsMatch = false
            for aWord in aWords {
                for bWord in bWords {
                    if aWord == bWord {
                        containsMatch = true
                        //연속해서 중복된 요소가 나오면 true를 반환해서 필터링
                        break
                    }
                }
            }
            
            return containsMatch
        }
        .subscribe(onNext: { //구독
            print($0)
        })
        .disposed(by: disposeBag)
}





