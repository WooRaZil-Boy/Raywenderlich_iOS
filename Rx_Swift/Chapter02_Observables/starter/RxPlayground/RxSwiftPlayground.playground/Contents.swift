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

example(of: "just, of, from") {
    let one = 1
    let two = 2
    let three = 3
    //예제에서 사용할 정수 상수를 정의한다.
    
    let observable = Observable<Int>.just(one)
    //one 상수와 just메서드를 사용하여, Int 유형의 observable 시퀀스를 생성한다.
    
    let observable2 = Observable.of(one, two, three) //Observable<Int>
    let observable3 = Observable.of([one, two, three]) //Observable<[Int]>
    //배열 자체가 하나의 요소
    let observable4 = Observable.from([one, two, three]) //Observable<Int>
    //배열의 개별 요소를 내보낸다.
}

example(of: "subscribe") {
    let one = 1
    let two = 2
    let three = 3

    let observable = Observable.of(one, two, three)
    
//    observable.subscribe { event in
//        print(event)
//    }

//    observable.subscribe { event in //구독
//        if let element = event.element {
//            print(event)
//        }
//    }
    
    observable.subscribe(onNext: { element in
        print(element)
    })
}

example(of: "empty") { //즉시 종료된다.
    let observable = Observable<Void>.empty()
    
    observable.subscribe(
        onNext: { element in //next 이벤트를 처리한다.
            print(element)
        },
        onCompleted: { //completed 이벤트에는 요소가 없다.
            print("Completed")
        }
    )
}

example(of: "never") { //결코 종료되지 않는다.
    let observable = Observable<Void>.never()
    
    observable.subscribe(
        onNext: { element in
            print(element)
        },
        onCompleted: {
            print("Completed")
        }
    )
}

example(of: "range") {
    let observable = Observable<Int>.range(start: 1, count: 10)
    //시작값과 개수를 사용하는 range 연산자를 사용하여 Observable을 생성한다.
    
    observable
        .subscribe(onNext: { i in
            //방출된 각 원소에 대해 n 번째 피보나치 수를 계산하고 출력한다.
            let n = Double(i)
            
            let fibonacci = Int(
                ((pow(1.61803, n) - pow(0.61803, n)) / 2.23606).rounded()
            )
            
            print(fibonacci)
        })
}

example(of: "dispose") {
    let observable = Observable.of("A", "B", "C")
    //문자열 Observable를 생성한다.
    
    let subscription = observable.subscribe { event in
        //반환된 데이터를 상수로 저장한다.
        print(event)
        //방출된 각 이벤트를 출력한다.
    }
    
    subscription.dispose() //구독을 폐기한다.
}

example(of: "DisposeBag") {
    let disposeBag = DisposeBag()
    //DisposeBag을 생성한다.
    
    Observable.of("A", "B", "C") //Observable을 생성한다.
        .subscribe {
            //Observable을 구독하고, 기본 인수 $0를 사용하여 내보낸 이벤트를 출력한다.
            print($0)
        }
        .disposed(by: disposeBag)
        //구독에서 반환된 Disposable을 dispose bag에 추가한다.
}

example(of: "create") {
    enum MyError: Error { //오류 추가
        case anError
    }
    
    let disposeBag = DisposeBag()
    
    Observable<String>.create { observer in
        observer.onNext("1")
        //observer에 next 이벤트를 추가한다.
        //onNext(_:)는 on(.next(_:))의 convenience method 이다.
        
        observer.onError(MyError.anError) //오류 발생
        
        observer.onCompleted()
        //observer에 completed 이벤트를 추가한다.
        //onCompleted()는 on(.completed)의 convenience method 이다.
        
        observer.onNext("?")
        //observer에 next 이벤트를 추가한다.
        
        return Disposables.create()
        //observable이 종료(terminated)되거나 폐기(disposed)될 때 발생하는 상황을 정의하는 disposable을 반환한다.
        //이 경우에는 따로 정리할 필요가 없으므로 빈 disposable를 반환한다.
    }
    .subscribe(onNext: { print($0) },
               onError: { print($0) },
               onCompleted: { print("Completed") },
               onDisposed: { print("Disposed") })
    .disposed(by: disposeBag)
}

example(of: "deferred") {
    let disposeBag = DisposeBag()
    
    var flip = false
    //반환할 Observable을 뒤집을 수 있는 Bool 플래그를 생성한다.
    
    let factory: Observable<Int> = Observable.deferred {
        //deferred 연산자를 사용하여 Int 타입의 factory Observable를 생성한다.
        flip.toggle()
        //factory가 구독될 때마다, flip을 토글한다.
        
        if flip { //flip의 Bool 값에 따라 다른 observables을 반환한다.
            return Observable.of(1, 2, 3)
        } else {
            return Observable.of(4, 5, 6)
        }
    }
    
    for _ in 0...3 {
        factory.subscribe(onNext: {
            print($0, terminator: "")
        })
        .disposed(by: disposeBag)
        
        print()
    }
}

example(of: "Single") {
    let disposeBag = DisposeBag()
    //나중에 사용할 dispose bag을 생성한다.
    
    enum FileReadError: Error {
        //디스크에서 파일을 읽을 때 발생할 수 있는 error를 열거형으로 정의한다.
        case fileNotFound, unreadable, encodingFailed
    }
    
    func loadText(from name: String) -> Single<String> {
        //디스크의 파일에서 텍스트를 로드하여 single을 반환하는 함수를 구현한다.
        return Single.create { single in
            //single을 반환한다.
            let disposable = Disposables.create()
            //create의 subscribe 클로저의 반환 유형이 Disposable이므로 이를 생성한다.
            
            guard let path = Bundle.main.path(forResource: name, ofType: "txt") else {
                //파일 이름으로 경로를 가져오고, 찾을 수 없는 파일인 경우 Single에 오류를 추가하고 disposable을 반환한다.
                single(.error(FileReadError.fileNotFound))
                return disposable
            }
            
            guard let data = FileManager.default.contents(atPath: path) else {
                //해당 경로에서 데이터를 가져오고, 가져올 수 없는 경우 Single에 오류를 추가하고 disposable을 반환한다.
                single(.error(FileReadError.unreadable))
                return disposable
            }
            
            guard let contents = String(data: data, encoding: .utf8) else {
                //데이터를 문자열로 변환하고, 실패할 경우 Single에 오류를 추가하고 disposable을 반환한다.
                single(.error(FileReadError.encodingFailed))
                return disposable
            }
            
            single(.success(contents)) //성공적으로 가져온 문자열을 Single에 추가한다.
            return disposable //disposable을 반환한다.
        }
    }
    
    loadText(from: "Copyright")
        //loadText(from:)를 호출하고 텍스트 파일의 이름을 전달한다.
        .subscribe { //loadText(from:)이 반환하는 Single을 구독한다.
            switch $0 {
            case .success(let string): //성공
                print(string)
            case .error(let error): //오류
                print(error)
            }
        }
        .disposed(by: disposeBag)
}



















