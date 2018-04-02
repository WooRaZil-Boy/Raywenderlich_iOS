//: Please build the scheme 'RxSwiftPlayground' first

import RxSwift
import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true




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

//********** Chapter 9: Combining Operators **********

example(of: "startWith") {
    let numbers = Observable.of(2, 3, 4)
    
    let observable = numbers.startWith(1)
    //startWith로 접두사처럼 맨 앞에 요소를 넣어 줄 수 있다. p.180
    //startWith는 observable에 init 값으로 쓸 수 있다. 요소와 같은 자료형이어야 한다.
    //옵저버는 즉시 초기값을 얻고, 이후의 모든 업데이트를 받을 수 있다.
    //concat의 한 종류라 생각하면 편하다.
    //현재 상태가 먼저 필요한 상황에 쓸 수 있다. //ex. 현재 위치와 네트워크 연결 상태
    
    observable.subscribe(onNext: { value in
        print(value)
    })
}

example(of: "Observable.concat") {
    let first = Observable.of(1, 2, 3)
    let second = Observable.of(4, 5, 6)
    
    let observable = Observable.concat([first, second])
    //concat 연산자는 시퀀스를 연결할 수 있다. p.181
    //첫 번째 시퀀스의 모든 요소가 완료된 후 다음 시퀀스로 넘어간다.
    //만일 오류가 발생하면 거기서 종료된다.
    
    observable.subscribe(onNext: { value in
        print(value)
    })
}

example(of: "concat") {
    let germanCities = Observable.of("Berlin", "Münich", "Frankfurt")
    let spanishCities = Observable.of("Madrid", "Barcelona", "Valencia")
    
    let observable = germanCities.concat(spanishCities)
    //Observable.concat과 같다. 해당 시퀀스가 완료 된 후, 다음 시퀀스로 넘어간다.
    //concat은 요소의 자료형이 같은 시퀀스만 연결할 수 있다.
    
    observable.subscribe(onNext: { value in
        print(value)
    })
}

example(of: "concatMap") {
    let sequences = [
        "Germany": Observable.of("Berlin", "Münich", "Frankfurt"),
        "Spain": Observable.of("Madrid", "Barcelona", "Valencia")
    ]

    let observable = Observable.of("Germany", "Spain")
        .concatMap { country in sequences[country] ?? .empty()
        //concatMap은 flatMap과 관련이 있다. 각 요소를 투영해 하나의 시퀀스로 연결한다.
        //flatMap은 emit된 Observable을 병합한다.
        //concatMap는 다음 구독이 되기 전에 각 시퀀스가 실행되어 완료된다.
        //따라서 concatMap은 순차적인 시퀀스의 진행을 보장한다.
    }
    
    _ = observable.subscribe(onNext: { string in
        print(string)
    })
}

example(of: "merge") {
    let left = PublishSubject<String>()
    let right = PublishSubject<String>()
    //PublishSubject : 빈 상태로 시작하고, 새로운 요소만 구독자에게 알린다.
    
    let source = Observable.of(left.asObservable(), right.asObservable())
    //Subject는 Observable하고 observer인 객체
    //asObservable()로 Subject의 Observable을 가져올 수 있다.
    
    let observable = source.merge()
    //merge 연산자는 말 그대로 합친다. p.184
    //각 시퀀스를 구독하고, 이벤트가 일어나자 마자 emit한다. 미리 정의된 순서는 없다.
    //모든 시퀀스가 완료된 후 완료된다. //시퀀스 중 하나라도 오류가 발생하면 오류를 내고 종료.
    
    //수 많은 시퀀스를 동시에 merge할 수 있다. 그 수를 제한하려면
    //merge(maxConcurrent :)를 쓰면 된다.
    //그 수를 넘어가면 이전 시퀀스에서 하나가 종료될 때 대기 중인 다음 시퀀스를 구독한다.
    
    let disposable = observable.subscribe(onNext: { value in
        print(value)
    })
    
    var leftValues = ["Berlin", "Munich", "Frankfurt"]
    var rightValues = ["Madrid", "Barcelona", "Valencia"]
    
    repeat {
        if arc4random_uniform(2) == 0 { //랜덤인 수를 반환한다. (0 ~ 1)
            if !leftValues.isEmpty {
                left.onNext("Left: " + leftValues.removeFirst())
            }
        } else if !rightValues.isEmpty {
            right.onNext("Right: " + rightValues.removeFirst())
        }
    } while !leftValues.isEmpty || !rightValues.isEmpty
    //repeat while 반복문. 한 번 이상은 반드시 실행된다.
    
    disposable.dispose() //메모리 누수 되지 않도록 직접 호출
}

example(of: "combineLatest") {
    let left = PublishSubject<String>()
    let right = PublishSubject<String>()
    
    let observable = Observable.combineLatest(left, right, resultSelector: { lastLeft, lastRight in
        //combineLatest는 결합된 시퀀스 중 하나가 값을 emit할 때 마다 클로저가 호출된다.
        //각 시퀀스의 최신값이 클로저의 파라미터로 들어온다.
        //ex. 여러 텍스트 필드를 한 번에 관찰해 값을 결합하거나 여러 소스의 상태 볼 때 p.186
        "\(lastLeft) \(lastRight)"
        //각 시퀀스의 최신값을 받아 결합 //결합된 시퀀스 중 하나에서 값을 emit해야 작동한다.
        //따라서 업데이트에 시간이 걸리므로 startWith(_:)로 초기값을 주는 것이 좋다.
        
        //strings in strings.joined(separator: " ")
        //으로 표현해 줄 수도 있다.
        
        //combineLatest은 map과 같이 반환의 Observable 객체를 만든다.
        //따라서 체이닝을 통해 연산자를 붙여 전환할 수 있다.
        //ex. let observable = Observable
        //          .combineLatest(left, right) { ($0, $1) }
        //          .filter { !$0.0.isEmpty }
        //위의 예는 튜플로 결합 해 필터링 한다.
    })
    
    let disposable = observable.subscribe(onNext: { value in
        print(value)
    })
    
    print("> Sending a value to Left")
    left.onNext("Hello,")
    
    print("> Sending a value to Right")
    right.onNext("world")
    
    print("> Sending another value to Right")
    right.onNext("RxSwift")
    
    print("> Sending another value to Left")
    left.onNext("Have a good day,")
    
    disposable.dispose()
}

example(of: "combine user choice and value") {
    let choice: Observable<DateFormatter.Style> = Observable.of(.short, .long)
    let dates = Observable.of(Date())
    
    let observable = Observable.combineLatest(choice, dates) { (format, when) -> String in
        //combineLatest 연산자는 여러가지 변형이 있다.
        //매개 변수로는 2 ~ 8 사이의 observable을 사용하고, 동일한 타입이 아니어도 된다.
        //combineLatest는 내부 시퀀스의 마지막이 완료되어야 최종 완료된다.
        //그 전에는 결합된 값을 계속 전송한다. 일부 시퀀스가 종료되면 마지막 시퀀스의 값을
        //다른 시퀀스의 새 값과 결합한다. p.186
        let formatter = DateFormatter()
        formatter.dateStyle = format
        
        return formatter.string(from: when)
    } //이런 식으로 다른 코드의 추가 없이 화면의 값을 자동 업데이트 할 수 있다.
    
    observable.subscribe(onNext: { value in //구독
        print(value)
    })
}

example(of: "zip") {
    enum Weather {
        case cloudy
        case sunny
    }
    
    let left: Observable<Weather> = Observable.of(.sunny, .cloudy, .cloudy,
                                                  .sunny)
    let right = Observable.of("Lisbon", "Copenhagen", "London", "Madrid",
                              "Vienna")
    
    let observable = Observable.zip(left, right) { weather, city in
        //zip으로 각 시퀀스의 요소를 결합한다. p.189
        //각각 내부의 observables가 새로운 값을 emit해 결합하고,
        //어느 한 시퀀스가 완료되면, zip연산자도 종료된다.
        //다른 시퀀스가 종료될 때까지 기다리지 않는다. (indexed sequencing)
        return "It's \(weather) in \(city)"
    }
    
    observable.subscribe(onNext: { value in //구독
        print(value)
    })
}

example(of: "withLatestFrom") {
    let button = PublishSubject<Void>()
    let textField = PublishSubject<String>()
    
    let observable = button.withLatestFrom(textField)
    //앱은 한 번에 여러 observables의 입력을 받는다.
    //withLatestFrom로 코드에서 액션을 트리거할 수 있다. p.191
    //해당 요소가 emit될 때마다 두 번째 시퀀스의 최신 요소를 사용할 수 있다.
    //RxCocoa와 함께 사용되어 액션을 트리거 하는 데 사용될 수 있다.
    //withLatestFrom는 observable한 데이터를 파라미터로 사용한다.
    
    _ = observable.subscribe(onNext: { value in //구독
        print(value)
    })
    
    textField.onNext("Par")
    textField.onNext("Pari")
    textField.onNext("Paris")
    
    button.onNext(())
    button.onNext(())
}

example(of: "sample") {
    let button = PublishSubject<Void>()
    let textField = PublishSubject<String>()
    
    let observable = textField.sample(button)
    //앱은 한 번에 여러 observables의 입력을 받는다.
    //sample로 코드에서 액션을 트리거할 수 있다. p.192
    //해당 요소가 emit될 때마다 두 번째 시퀀스의 최신 요소를 사용할 수 있다.
    //RxCocoa와 함께 사용되어 액션을 트리거 하는 데 사용될 수 있다.
    //새로운 값이 emit 되지 않았기 때문에 sample에서는 withLatestFrom과 달리
    //같은 요소는 한 번만 출력된다. //샘플링 간격의 최신 요소만 emit
    //sample은 observable한 트리거를 파라미터로 사용한다.
    
    _ = observable.subscribe(onNext: { value in //구독
        print(value)
    })
    
    textField.onNext("Par")
    textField.onNext("Pari")
    textField.onNext("Paris")
    
    button.onNext(())
    button.onNext(())
    
    //트리거는 UI 작업을 할 때 주로 사용할 수 있다.
}

example(of: "amb") {
    let left = PublishSubject<String>()
    let right = PublishSubject<String>()
    
    let observable = left.amb(right)
    //amb(ambiguous)은 먼저 반응하는 observable만 전파한다. p.193
    //처음에는 이벤트를 emit할 observable를 특정하지 않지만, 이벤트가 발생할 때 결정된다.
    
    let disposable = observable.subscribe(onNext: { value in //구독
        print(value)
    })
    
    left.onNext("Lisbon")
    right.onNext("Copenhagen")
    left.onNext("London")
    left.onNext("Madrid")
    right.onNext("Vienna")
    //두 시퀀스가 모두 이벤트를 emit하지만, 먼저 emit된 하나의 시퀀스만 작동한다.
    
    disposable.dispose()
}

example(of: "switchLatest") {
    let one = PublishSubject<String>()
    let two = PublishSubject<String>()
    let three = PublishSubject<String>()
    
    let source = PublishSubject<Observable<String>>()
    
    let observable = source.switchLatest()
    //최근의 observable에서만 값을 생성한다. //p.194
    //switchLatest가 amb보다 좀 더 보편적으로 널리 쓰인다.
    //소스 시퀀스에서 이벤트가 일어난 하위 시퀀스에서만 이벤트가 emit 된다.
    //소스 시퀀스에서 이벤트를 발생해 이벤트가 일어난 하위 시퀀스를 바꿀 수 있다.
    
    let disposable = observable.subscribe(onNext: { value in //구독
        print(value)
    })
    
    source.onNext(one)
    one.onNext("Some text from sequence one")
    two.onNext("Some text from sequence two")
    
    source.onNext(two)
    two.onNext("More text from sequence two")
    one.onNext("and also from sequence one")
    
    source.onNext(three)
    two.onNext("Why don't you see me?")
    one.onNext("I'm alone, help me")
    three.onNext("Hey it's three. I win.")
    
    source.onNext(one)
    one.onNext("Nope. It's me, one!")
    
    disposable.dispose()
}

example(of: "reduce") {
    let source = Observable.of(1, 3, 5, 7, 9)
    
    let observable = source.reduce(0, accumulator: +)
    //reduce로 시퀀스 내의 요소를 결합해 줄 수 있다(초기값, 연산자). p.196
    //기본 라이브러리의 reduce와 비슷하다.
    //recude 연산자는 observable이 완료될 때에만 값을 생성한다.
    //완료되지 않은 시퀀스에는 적용해도 아무런 일도 일어나지 않는다. //이 부분을 자주 착각한다.
    
    //let observable = source.reduce(0, accumulator: { summary, newValue in
    //    return summary + newValue
    //})
    //풀어 쓰면 위와 같이 된다.
    observable.subscribe(onNext: { value in
        print(value)
    })
}

example(of: "scan") {
    let source = Observable.of(1, 3, 5, 7, 9)
    
    let observable = source.scan(0, accumulator: +)
    //scan 연산자는 reduce와 비슷하게 사용된다. p.197
    //하지만, reduce와 달리 결합된 하나의 값을 emit 하는 것이 아니라,
    //중간의 값들을 emit한다. //입력 당 하나의 출력값을 얻는다.
    
    //누적 합계, 통계, 상태 등을 계산하는 데 사용할 수 있다.
    //로컬 변수를 사용할 필요가 없으며, 소스 시퀀스가 완료되면 사라진다.
    observable.subscribe(onNext: { value in
        print(value)
    })
}
