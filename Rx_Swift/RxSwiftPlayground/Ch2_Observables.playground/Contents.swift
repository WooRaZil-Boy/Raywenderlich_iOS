//: Please build the scheme 'RxSwiftPlayground' first
import RxSwift

//

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
//********** Chapter 2: Observables **********

//observable, sequence, observable sequence, stream 모두 같은 것을 지칭한다.
//Rx에서 모든 것은 sequence(observable)이다.
//Observables는 '비동기'로 이벤트를 생성하고 emitting한다.
//이벤트는 값이 포함되거나 탭과 같은 동작으로 인식될 수 있다.

//다이어그램으로 나타내면 쉽게 이해할 수 있다.
//다이어그램에서 왼쪽에서 오른쪽으로 순차적으로 진행되며, 각각의 원은 시퀀스의 요소이다.

//Observables의 이벤트에는 3가지가 있다.
//• .next(Element) : 다이어그램에서 원으로 나타난다. observable이 요소를 emit하는 이벤트
//• .completed : 다이어그램에서 수직 막대로 나타난다. 종료이후엔 아무것도 emit할 수 없다.
//             시퀀스가 종료된다.
//• .error(Swift.Error) : 다이어그램에서 엑스표로 나타난다. 종료이벤트와 유사하게
//                      시퀀스가 종료되고 이후 emit할 수 없다.
//error든, completed이든 Observables(sequence)가 종료되면 이벤트를 emit할 수 없다.

//Rx에서 이벤트는 Enum인데 으로 세가지(next, completed, error)요소로 구성되어 있다.

example(of: "just, of, from") {
    //Sources에 선언된 example 출력. 단순히 코드를 나누고 클로저를 실행한다.
    //상수 선언
    let one = 1
    let two = 2
    let three = 3
    
    //Rx에서 메서드를 연산자라 한다. ex. just, of, from
    
    let observable: Observable<Int> = Observable<Int>.just(one)
    //just()로 하나의 요소로 된 Int 타입의 Observable 생성
    let observable2 = Observable.of(one, two, three)
    //of()로 다수의 요소로 된 Int 타입의 Observable 생성
    //유형을 지정하지 않아도 타입을 추론한다.
    //여러개의 요소를 입력했어도 반환형은 배열이 아닌 Observable<Int>이다.
    //연산자 of의 첫 번째 파라미터로 가변 매개변수(Int...)를 취하기 때문이다.
    let observable3 = Observable.of([one, two, three])
    //배열로 만들고 싶다면, 파라미터로 배열을 전달하면 된다.
    //observable3의 타입은 Observable<[Int]>이다.
    //just로도 배열을 받을 수 있다.
    //ex.) let observableTest = Observable.just([one, two, three])
    //이때 자료형은 Observable<[Int]>이다.
    let observable4 = Observable.from([one, two, three])
    //from()은 파라미터로 배열만을 받는다.
    //observable4의 자료형은 Observable<Int>
}

//iOS의 NotificationCenter와 RxSwift Observables과 Subscribing이 비슷하다.
//ex. NotificationCenter : 키보드 프레임 변화시
//let observer = NotificationCenter.default.addObserver(
//    forName: .UIKeyboardDidChangeFrame,
//    object: nil,
//    queue: nil
//) { notification in
//    // Handle receiving notification
//}
//RxSwift에서는 addObserver() 대신 subscribe()를 사용한다.
//NoticiationCenter는 거의 싱글톤의 default를 사용했지만,
//Rx는 각각의 Observables으로 구독하는 것이 일반적이다.
//Observables은 구독되지 않으면 이벤트를 전송하지 않는다.

//observable을 subscribing 하는 것은 표준 라이브러리의 Iterator의 next()와 비슷하다.
let sequence = 0..<3
var iterator = sequence.makeIterator() //반복자 생성
while let n = iterator.next() { //next()로 다음 요소로 넘어가 그 요소 반환
    print(n)
}

//observable는 더 간소화된다. subscribing하고 각 이벤트에 핸들러를 추가한다.
example(of: "subscribe") {
    let one = 1
    let two = 2
    let three = 3
    
    let observable = Observable.of(one, two, three)
    
    observable.subscribe { event in //구독
        //@escaping 클로저가 실행되고, Disposable을 반환한다.
        //Disposable를 반환함으로써, Rx를 최종 종료하고, 메모리 누수를 막는다.
        print(event)
    }
    //next 이벤트 3번과 최종적으로 completed 이벤트가 실행되며 끝이 난다.
    
    observable.subscribe { event in
        if let element = event.element { //element로 요소에 접근할 수 있다.
            //next 이벤트에만 element가 있기 때문에 optional이며 바인딩해야 한다.
            print(element)
        }
    }
    
    observable.subscribe(onNext: { element in //next 이벤트 처리 핸들러
        print(element)
    }) //나머지 completed, erorr 이벤트는 무시된다.
    //위의 바인딩해서 사용하는 것 보다 더 나은 구현이 된다.
}

example(of: "empty") {
    let observable = Observable<Void>.empty() //요소가 없는 빈 시퀀스 생성
    //empty()는 유형을 유추할 수 없으므로, Void를 명시해 줘야 한다.
    
    observable
        .subscribe( //구독
            onNext: { element in //next 이벤트 핸들러
                print(element)
        },
            onCompleted: { //completed 이벤트 핸들러
                print("Completed")
        })
    //빈 시퀀스이기 때문에 next 이벤트가 발생하지 않고 Completed만 출력된다.
    
    //빈 시퀀스는 Completed만 반환하기 때문에 즉시 종료되거나
    //의도적으로 제로 값을 주는 경우에 유용하다.
}

example(of: "never") {
    let observable = Observable<Any>.never()
    //never()로 아무것도 방출하지 않고 종료되지도 않는 observable를 생성한다.
    //지속 시간이 무한하다.
    observable
        .subscribe(
            onNext: { element in
                print(element)
        },
            onCompleted: {
                print("Completed")
        }
    )
    //never 시퀀스는 아무런 이벤트(Completed도)를 발생시키지 않는다.
    //시퀀스가 종료되지도 않는ㄴ다.
}

example(of: "range") {
    let observable = Observable<Int>.range(start: 1, count: 10)
    //range로 범위 값을 줄 수도 있다. //1에서 시작해서 10개
    observable
        .subscribe(onNext: { i in
            let n = Double(i)
            let fibonacci = Int(((pow(1.61803, n) - pow(0.61803, n)) /
                2.23606).rounded())
            print(fibonacci)
        })
}

//never를 제외하곤, 모두 오류가 없으면 알아서 completed 이벤트를 발생 시킨다.
//이를 통해 observable를 생성하고, subscribe하는 데에만 집중할 수 있다.

example(of: "dispose") {
    let observable = Observable.of("A", "B", "C")
    //observable은 구독을 받을 때 까지 아무런 작업을 하지 않는다.
    let subscription = observable.subscribe { event in
        print(event)
    } //로컬 상수로 저장
    
    subscription.dispose()
    //명시적으로 구독을 취소 //메모리 해제 //ARC라 생각
    //구독을 취소하면 더 이상 이벤트가 발생하지 않는다.
}

example(of: "DisposeBag") {
    let disposeBag = DisposeBag()
    //DisposeBag은 Disposable 타입들을 담아 dispose 시킬 수 있다.
    //1회용 ARC로 생각
    Observable.of("A", "B", "C").subscribe { //구독
        print($0) //명시적으로(event)로 받지 않고, $을 사용할 수도 있다.
    }
    .disposed(by: disposeBag) //구독의 반환값을 disposeBag에 추가
    //이 형식(Observable을 구독하고 바로 DisposeBag에 담음)을 가장 자주 사용한다.
    
    //Dispose로 메모리 누수를 막을 수 있다.
}

example(of: "create") {
    enum MyError: Error { //Error 정의
        case anError
    }
    
    let disposeBag = DisposeBag()
    Observable<String>
    .create { observer in
        //Observable이 event를 emit하게 하는 다른 방법으로 create가 있다.
        //create 연산자는 단일 매개 변수 subscribe를 받는다.
        //구독한 Observable에게 emitting될 모든 이벤트를 정의한다.
        observer.onNext("1") //.next 이벤트를 옵저버에 추가한다.
        observer.onError(MyError.anError) //에러 추가
        observer.onCompleted() //.complete 이벤트를 옵저버에 추가한다.
        observer.onNext("?") //.next 이벤트를 옵저버에 추가한다.
    
        return Disposables.create() //Disposables 타입 생성(해제 가능)
    }
    .subscribe(
        onNext: { print($0) }, //.next 시 해당 요소 출력
        onError: { print($0) }, //.erorr 시 해당 요소 출력
        onCompleted: { print("Completed") }, //.complete 시 출력
        onDisposed: { print("Disposed") }) //메모리 해제 될 때 출력
    .disposed(by: disposeBag)
    //1 이후 onCompleted 되었으므로 ? 이벤트는 출력 되지 않는다.
    
    //에러 발생 시에는 해당 Observable이 종료된다.
}

example(of: "create") {
    enum MyError: Error { //Error 정의
        case anError
    }
    
    let disposeBag = DisposeBag()
    Observable<String>
        .create { observer in
            //Observable이 event를 emit하게 하는 다른 방법으로 create가 있다.
            //create 연산자는 단일 매개 변수 subscribe를 받는다.
            //구독한 Observable에게 emitting될 모든 이벤트를 정의한다.
            observer.onNext("1") //.next 이벤트를 옵저버에 추가한다.
            observer.onNext("?") //.next 이벤트를 옵저버에 추가한다.
            
            return Disposables.create() //Disposables 타입 생성(해제 가능)
        }
        .subscribe(
            onNext: { print($0) }, //.next 시 해당 요소 출력
            onError: { print($0) }, //.erorr 시 해당 요소 출력
            onCompleted: { print("Completed") }, //.complete 시 출력
            onDisposed: { print("Disposed") }) //메모리 해제 될 때 출력
    
    //.complete나 .error 이벤트가 발생하지 않고, disposeBag에 구독을 추가하지 않았을 경우
    //즉 위의 코드와 같이 error, completed 이벤트 발생하지 않고, dispose도 하지 않은 경우
    //Observable이 종료되지 않고, Disposed되지 않으므로 메모리가 누수 된다.
    //Disposed()를 명시적으로 추가해 주지 않고, onComplted()로 정상적으로 종료만 되어도
    //메모리 누수는 일어나지 않는다. 정상 종료되면 ARC에서 처리하기 때문.
    //혹은 Disposed()를 명시적으로 추가해 줘도(.disposed(by: disposeBag)) 된다.
}

example(of: "deferred") {
    let disposeBag = DisposeBag() //만들고 시작해서 항상 마지막에 추가해 주는 것이 좋다.
    //메모리 누수를 막을 수 있다.
    var flip = false
    let factory: Observable<Int> = Observable.deferred {
        //구독을 기다리는 observable 대신 observable factories로 관찰 가능한 항목을 지정할 수 있다.
        //deferred는 지연된 Observable을 생성한다(lazy와 비슷).
        //subscribe 될 때 지정된 클로저가 호출된다.
        flip = !flip
        
        if flip {
            return Observable.of(1, 2, 3)
        } else {
            return Observable.of(4, 5, 6)
        }
    }
    
    for _ in 0...3 {
        factory
        .subscribe(onNext: { //loop를 돌면서 새로운 구독이 생성된다.
            print($0, terminator: "")
        })
        .disposed(by: disposeBag) //항상 마지막에 추가해 주는 것이 좋다.
        //메모리 누수를 막을 수 있다.
        
        print()
    }
}

//trait를 사용하여 더 직관적으로 코딩할 수 있다.
//RxSwift에는 Single, Maybe, Completable의 세 가지 trait이 있다.
//• Single : .success(value), .error 이벤트 중 하나를 emit한다.
//           .success(value)는 .next와 .complete 이벤트의 조합이다.
//           성공해 값을 산출하거나 실패하는 일회성 프로세스에 유용하다.
//• Maybe : Single과 Completable의 혼합이다.
//          .success(value), .completed, .error 세 가지 이벤트가 있다.
//          성공, 실패의 여부가 있고 선택적으로 성공한 값을 반환해야 할때 사용한다.
//• Completable : .completed, .error 이벤트가 있다. 성공, 실패의 여부만 중요한 경우

example(of: "Single") {
    let disposeBag = DisposeBag() //DisposeBag 생성
    //후에 메모리 누수를 막기 위해 사용한다.
    
    enum FileReadError: Error { //파일 로드 시 일어날 수 있는 오류
        case fileNotFound, unreadable, encodingFailed
    }
    
    func loadText(from name: String) -> Single<String> { //로드
        return Single.create { single in
            //create의 클로저는 disposable를 반환해야 한다.
            let disposable = Disposables.create() //disposable 생성
            
            guard let path = Bundle.main.path(forResource: name, ofType: "txt") else { //경로에서 파일 가져오지 못한 경우
                single(.error(FileReadError.fileNotFound)) //에러 추가
                return disposable
            }
            
            guard let data = FileManager.default.contents(atPath: path) else { //파일을 읽을 수 없는 경우
                single(.error(FileReadError.unreadable)) //에러 추가
                return disposable
            }
        
            guard let contents = String(data: data, encoding: .utf8) else {
                //파일을 인코딩할 수 없는 경우
                single(.error(FileReadError.encodingFailed)) //에러 추가
                return disposable
            }
            
            single(.success(contents)) //성공한 경우에는 해당 값을 추가
            
            return disposable
        }
    }
    
    loadText(from: "Copyright") //함수 실행
        .subscribe { //구독 //함수의 반환값이 Single 시퀀스 이므로, 그것을 구독
            switch $0 { //single엔 success와 error뿐이므로 default 필요없다.
                //반환된 값으로 결과를 출력한다.
            case .success(let string):
                print(string)
            case .error(let error):
                print(error)
            }
        }
        .disposed(by: disposeBag)
}
