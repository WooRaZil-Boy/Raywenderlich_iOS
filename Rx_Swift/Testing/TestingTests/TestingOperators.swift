/*
 * Copyright (c) 2014-2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import XCTest
import RxSwift
import RxTest
import RxBlocking

class TestingOperators : XCTestCase {

  var scheduler: TestScheduler! //테스트에서 사용할 TestScheduler
  var subscription: Disposable! //각 테스트에서 구독을 hold

  override func setUp() { //setUp은 각 테스트 케이스가 시작되기 전에 호출된다.
    //테스트 전 초기 설정을 완료하는 장소
    super.setUp()
    
    scheduler = TestScheduler(initialClock: 0) //initialClock 값이 0인 스케줄러로 처기화
  }

  override func tearDown() { //tearDown은 각 테스트가 완료될 때 호출된다.
    scheduler.scheduleAt(1000) { //1000(milliseconds)초에
        self.subscription.dispose() //구독을 해제한다.
        //각 테스트는 1초 미만 동안 실행되므로, 구독을 1초 내에 해제하는 것이 안전하다.
    }

    super.tearDown()
  }
    
    func testAmb() { //XCTest를 사용하는 모든 테스트 메서드 이름은 test로 시작해야 한다.
        //RxTest도 마찬가지로 test로 시작해야 한다.
        let observer = scheduler.createObserver(String.self)
        //스케줄러에서 string 타입의 observer 생성
        //observer는 수신한 이벤트를 기록하고, timestamp 처리한다.
        
        let observableA = scheduler.createHotObservable([ //hot observable 생성
            next(100, "a"), //지정된 시간에 해당 값을 추가하는 이벤트
            next(200, "b"),
            next(300, "c")
            ])
        
        let observableB = scheduler.createHotObservable([ //hot observable 생성
            next(90, "1"), //지정된 시간에 해당 값을 추가하는 이벤트
            next(200, "2"),
            next(300, "3")
            ])
        
        let ambObservable = observableA.amb(observableB) //Observable<String>
        //amb 연산자는 두 observable간에 사용되며, 먼저 이벤트를 emit하는 observable이 전파된다.
        
        scheduler.scheduleAt(0) { //지정된 시간에 실행하도록 스케줄러에 지정
            self.subscription = ambObservable.subscribe(observer) //구독
            //tearDown에서 1000 밀리초에 구독을 해제한다.
        }
        
        scheduler.start() //스케줄러 시작
        
        let results = observer.events.map { //결과 수집
            $0.value.element! //map으로 각 이벤트들의 요소에 접근
        }
        
        XCTAssertEqual(results, ["1", "2", "3"]) //결과가 ["1", "2", "3"] 으로 나와야 정답
        //amb 연산자는 먼저 이벤트를 발생시킨 observable을 전달하므로 observableB의 요소가 수신되어야 한다.
//        XCTAssertEqual(results, ["1", "2", "No you didn't!"])
    }
    
    func testFilter() { //testAmb()와 유사하게 구현된다.
        let observer = scheduler.createObserver(Int.self)
        //스케줄러에서 Int 타입의 observer 생성
        //observer는 수신한 이벤트를 기록하고, timestamp 처리한다.
        
        let observable = scheduler.createHotObservable([ //hot observable 생성
            next(100, 1), //지정된 시간에 해당 값을 추가하는 이벤트
            next(200, 2),
            next(300, 3),
            next(400, 2),
            next(500, 1)
            ])
        
        let filterObservable = observable.filter { //필터링 테스트
            $0 < 3 //3보다 작은 값만 와야 한다.
        }
        
        scheduler.scheduleAt(0) { //지정된 시간에 실행하도록 스케줄러에 지정
            self.subscription = filterObservable.subscribe(observer) //구독
            //tearDown에서 1000 밀리초에 구독을 해제한다.
        }
        
        scheduler.start() //스케줄러 시작
        
        let results = observer.events.map { //결과 수집
            $0.value.element! //map으로 각 이벤트들의 요소에 접근
        }
        
        XCTAssertEqual(results, [1, 2, 2, 1]) //결과가 [1, 2, 2, 1] 으로 나와야 정답
    }
    
    //위의 testAmb, testFilter는 동기식(synchronous) 테스트이다.
    
    //비동기식 테스트를 위해서는 몇 가지 방법이 있지만, 가장 쉬운 방법은 RxBlocking을 사용하는 것이다.
    //RxBlocking은 또 다른 라이브러리이다. 주 목적은 observable을 toBlocking(timeout:) 메서드를 통해
    //BlockingObservable로 변환하는 것이다.
    //BlockingObservable은 observable이 종료될 때까지 현재 스레드를 차단하고,
    //지정된 시간을 초과하면 RxError.timeout 오류를 발생시킨다.
    //기본적으로 비동기 작업을 동기 작업으로 변환하여 테스트를 훨씬 쉽게 만든다.
    
    func testToArray() { //비동기 테스트
        let scheduler = ConcurrentDispatchQueueScheduler(qos: .default)
        //비동기로 스케줄링하는 concurrent scheduler를 생성한다.
        let toArrayObservable = Observable.of(1, 2).subscribeOn(scheduler)
        //1, 2 두 문자를 등록한 observable을 생성하고 구독한다.
        
        XCTAssertEqual(try! toArrayObservable.toBlocking().toArray(), [1, 2])
        //toBlocking()은 toArrayObservable을 blocking observable로 변환하고
        //종료될떄까지 스케줄러에 의해 생성된 스레드를 차단한다.
    }
    
    func testToArrayMaterialized() {
        //RxBlocking은 작업의 결과를 검사하는데 사용하는 materialize 연산자가 있다.
        //enum인 MaterializedSequenceResult(completed, failed)가 반환된다.
        //case completed(elements: [T]) :: 성공. Observable에서 emit된 요소의 배열
        //case failed(elements: [T], error: Error) :: 오류. 요소 배열과 오류
        let scheduler = ConcurrentDispatchQueueScheduler(qos: .default)
        //비동기로 스케줄링하는 concurrent scheduler를 생성한다.
        let toArrayObservable = Observable.of(1, 2).subscribeOn(scheduler)
        //1, 2 두 문자를 등록한 observable을 생성하고 구독한다.
        
        let result = toArrayObservable
            .toBlocking()
            //toBlocking()은 toArrayObservable을 blocking observable로 변환하고
            //종료될떄까지 스케줄러에 의해 생성된 스레드를 차단한다.
            .materialize()
            //시퀀스가 종료할 때까지 현재 스레드 차단. 완료되면, 요소 목록 반환. 오류 발생 시 오류 자체와 요소 목록 반환
        
        switch result { //materialize를 통해 results의 내용을 검사해 볼 수 있다.
        case .completed(elements: let elements): //성공
            XCTAssertEqual(elements,  [1, 2])
        case .failed(_, error: let error): //실패
            XCTFail(error.localizedDescription)
        }
    }
}
