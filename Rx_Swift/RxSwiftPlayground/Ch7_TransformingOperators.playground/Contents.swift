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

//********** Chapter 7: Transforming Operators **********

//변형(Transforming) 연산자는 observable의 데이터를 구독자가 사용할 수 있도록 해 준다.
//Observables는 요소를 개별적으로 emit 하지만, collection에 바인딩해 사용할 수 있다.

example(of: "toArray")   {
    let disposeBag = DisposeBag()
    
    Observable.of("A", "B", "C")
        .toArray()
        //toArray로 모든 요소를 배열로 변환할 수 있다. 다이어그램은 p.143
        //시퀀스의 요소를 배열로 변환하고 그 배열을 포함해 .next() 이벤트를 내보낸다.
        .subscribe(onNext: { //구독
            print($0)
        })
        .disposed(by: disposeBag)
}

example(of: "map")   {
    let disposeBag = DisposeBag()
    
    let formatter = NumberFormatter() //숫자의 형식을 만들어 준다.
    formatter.numberStyle = .spellOut //숫자를 영어로 읽는 형식
    //ex. 110 = "one hundred ten"
    
    Observable<NSNumber>.of(123, 4, 56)
        //정수 변환을 할 필요 없도록 NSNumber 타입으로 Observable 생성
        .map { //map 연산자는 Swift 기본 라이브러리의 map과 비슷하다. p.144
            //각 요소에 대해 map의 코드를 적용해 준다.
            formatter.string(from: $0) ?? "" //문자열로 변환 //변환 못하면 ""
        }
        .subscribe(onNext: { //구독
            print($0)
        })
        .disposed(by: disposeBag)
}

example(of: "enumerated and map") {
    let disposeBag = DisposeBag()
    
    Observable.of(1, 2, 3, 4, 5, 6)
        .enumerated() //시퀀스를 enumerate 한다. //튜플 (index, value)
        .map { index, integer in
            //map 연산자는 Swift 기본 라이브러리의 map과 비슷하다. p.144
            //각 요소에 대해 map의 코드를 적용해 준다.
            index > 2 ? integer * 2 : integer
            //index가 2보다 크면 2를 곱하고, 그렇지 않으면 그대로
        }
        .subscribe(onNext: { //구독
            print($0)
        })
        .disposed(by: disposeBag)
}

struct Student {
    var score: BehaviorSubject<Int>
    //초기값이 있고, 가장 최신의 요소만 구독자에게 알린다.
}

example(of: "flatMap") {
    let disposeBag = DisposeBag()
    
    let ryan = Student(score: BehaviorSubject(value: 80))
    let charlotte = Student(score: BehaviorSubject(value: 90))
    
    let student = PublishSubject<Student>()
    //PublishSubject : 빈 상태로 시작하고, 새로운 요소만 구독자에게 알린다.
    
    student
        .flatMap {
        //observable의 각 요소를 투영해 변형하고 그 결과로 각각의 시퀀스를 생성한다.
        //그 후 각 시퀀스를 마지막까지 진행하면서 하나로 병합한다. p.147
        //(값이 바뀌면 그 바뀐 값도 최종 시퀀스로 투영 된다.)
        //observable의 값을 변환한 후(map), 평탄화해 병합한다.
            $0.score //각 인스턴스(학생)의 변수(점수)에 접근
        }
        .subscribe(onNext: { //구독
            print($0)
        })
        .disposed(by: disposeBag)
    
    student.onNext(ryan) //onNext() 이벤트가 일어나야 해당 부분이 출력된다.
    ryan.score.onNext(85)
    student.onNext(charlotte)
    ryan.score.onNext(95)
    charlotte.score.onNext(100)
    //flatMap이 각 요소별로 observable을 유지한다.
    //각 observable의 변경사항을 투영한다.
}

example(of: "flatMapLatest") {
    let disposeBag = DisposeBag()
    
    let ryan = Student(score: BehaviorSubject(value: 80))
    let charlotte = Student(score: BehaviorSubject(value: 90))
    
    let student = PublishSubject<Student>()
    //PublishSubject : 빈 상태로 시작하고, 새로운 요소만 구독자에게 알린다.
    
    student
        .flatMapLatest {
            //flatMapLatest는 flatMap의 최신 요소를 emit 한다.
            //flatMapLatest는 map 및 switchLatest의 조합이다.
            //switchLatest는 가장 최근의 observable에서 값을 가져오고,
            //이전의 observable에서는 수신하지 않는다.
            //따라서 flatMapLatest는 observable의 각 요소를 새로운 시퀀스에 투영해 하나로
            //변환한 다음 가장 최근의 시퀀스 값을 emit한다. p.150
            $0.score
        }
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)
    
    student.onNext(ryan) //onNext() 이벤트가 일어나야 해당 부분이 출력된다.
    ryan.score.onNext(85)
    student.onNext(charlotte) //charlotte의 observable이 최신이 된다.

    ryan.score.onNext(95)
    charlotte.score.onNext(100)
    
    //flatMapLatest은 네트워크 작업에서 사용할 수 있다.
    //ex. 사용자가 문자를 입력하면, 새 검색을 실행하고, 이전 검색 결과를 무시할 수 있다.
}

example(of: "materialize") {
    //observable을 이벤트의 observable으로 변환해야 할 경우가 있다.
    //ex. observable 외부 순서 종료 방지를 위한 오류 이벤트 처리
    
    enum MyError: Error {
        case anError
    }
    
    let disposeBag = DisposeBag()
    
    let ryan = Student(score: BehaviorSubject(value: 80))
    let charlotte = Student(score: BehaviorSubject(value: 100))
    
    let student = BehaviorSubject(value: ryan) //ryan으로 초기화
    //초기값이 있고, 가장 최신의 요소만 구독자에게 알린다.
    
    let studentScore = student
        .flatMapLatest {
            //flatMapLatest는 flatMap의 최신 요소를 emit 한다.
            //flatMapLatest는 map 및 switchLatest의 조합이다.
            //switchLatest는 가장 최근의 observable에서 값을 가져오고,
            //이전의 observable에서는 수신하지 않는다.
            //따라서 flatMapLatest는 observable의 각 요소를 새로운 시퀀스에 투영해 하나로
            //변환한 다음 가장 최근의 시퀀스 값을 emit한다. p.150
            $0.score.materialize()
            //materialize로 observable에 의해 생성된 각 이벤트를 래핑한다. p.153
            //요소를 이벤트로 전환한다. //ex. 1 -> .next(1)
        }
    
    studentScore
        .subscribe(onNext: { //구독
            print($0)
        })
        .disposed(by: disposeBag)
    
    ryan.score.onNext(85)
    ryan.score.onError(MyError.anError) //시퀀스 종료 //에러는 따로 처리하지 않았다.
    //이후의 이벤트들은 일어나지 않는다.
    ryan.score.onNext(90)
    
    student.onNext(charlotte) //새로운 observable에서 .next 발생
    //materialize이 없을 경우 위의 이벤트가 일어나기 전에
    //이미 모든 시퀀스가 종료되었기 때문에 이벤트가 일어나지 않는다.
    //하지만, materialize연산자를 사용한 경우
    //오류로 studentScore가 종료 되어도, 외부의 다른 시퀀스가 알 수 없기 때문에
    //외부의 새 객체(charlotte)로 전환된다.
}

example(of: "dematerialize") {
    //observable을 이벤트의 observable으로 변환해야 할 경우가 있다.
    //ex. observable 외부 순서 종료 방지를 위한 오류 이벤트 처리
    
    enum MyError: Error {
        case anError
    }
    
    let disposeBag = DisposeBag()
    
    let ryan = Student(score: BehaviorSubject(value: 80))
    let charlotte = Student(score: BehaviorSubject(value: 100))
    
    let student = BehaviorSubject(value: ryan) //ryan으로 초기화
    //초기값이 있고, 가장 최신의 요소만 구독자에게 알린다.
    
    let studentScore = student
        .flatMapLatest {
            //flatMapLatest는 flatMap의 최신 요소를 emit 한다.
            //flatMapLatest는 map 및 switchLatest의 조합이다.
            //switchLatest는 가장 최근의 observable에서 값을 가져오고,
            //이전의 observable에서는 수신하지 않는다.
            //따라서 flatMapLatest는 observable의 각 요소를 새로운 시퀀스에 투영해 하나로
            //변환한 다음 가장 최근의 시퀀스 값을 emit한다. p.150
            $0.score.materialize()
            //materialize로 observable에 의해 생성된 각 이벤트를 래핑한다. p.153
    }
    
    studentScore
        .filter {
            guard $0.error == nil else { //오류 필터링
                print($0.error!)
                
                return false
            }
            
            return true //오류가 아닌 이상 모두 통과된다.
        }
        .dematerialize() //dematerialize로 원래의 형태로 변환한다. p.154
        //이벤트를 요소로 다시 바꾼다. ex. next(80)가 80으로 변환된다.
        .subscribe(onNext: { //구독
            print($0)
        })
        .disposed(by: disposeBag)
    
    ryan.score.onNext(85)
    ryan.score.onError(MyError.anError) //시퀀스 종료 //에러는 따로 처리하지 않았다.
    //이후의 이벤트들은 일어나지 않는다.
    ryan.score.onNext(90)
    
    student.onNext(charlotte) //인쇄 된다.
}








