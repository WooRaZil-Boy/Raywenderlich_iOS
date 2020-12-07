/// Copyright (c) 2019 Razeware LLC
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
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACTa, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import XCTest
import Combine

class CombineOperatorsTests: XCTestCase {
    var subscriptions = Set<AnyCancellable>()
  
  override func tearDown() {
    subscriptions = []
  }
    
    func test_collect() {
        // Given
        let values = [0, 1, 2]
        let publisher = values.publisher
        
        // When
        publisher
            .collect()
            .sink(receiveValue: {
                // Then
                XCTAssert(
                    $0 == values,
                    "Result was expected to be \(values) but was \($0)"
                )
                
//                XCTAssert(
//                    $0 == values + [1],
//                    "Result was expected to be \(values + [1]) but was \($0)"
//                )
            })
            .store(in: &subscriptions)
    }
    
    func test_flatMapWithMax2Publishers() {
        // Given
        let intSubject1 = PassthroughSubject<Int, Never>()
        let intSubject2 = PassthroughSubject<Int, Never>()
        let intSubject3 = PassthroughSubject<Int, Never>()
        //Int를 Input으로 사용하는 세 개의 passthrough subject를 사용한다.
        
        let publisher = CurrentValueSubject<PassthroughSubject<Int, Never>, Never>(intSubject1)
        //current value subject는 int 형의 passthrough subjects을 받으며, intSubject1로 초기화된다.
        
        let expected = [1, 2, 4]
        var results = [Int]()
        //예상 결과와 실제 결과를 저장할 배열을 선언한다.
        
        publisher
            .flatMap(maxPublishers: .max(2)) { $0 }
            //최대 2개까지 flatMap한다.
            .sink(receiveValue: {
                results.append($0)
                //수신한 각 값을 results 배열에 추가한다.
            })
            .store(in: &subscriptions)
        
        // When
        intSubject1.send(1)
        //intSubject1에 새 값을 내보낸다.

        publisher.send(intSubject2)
        //current value subject인 publisher에 intSubject2를 내보낸다.
        intSubject2.send(2)
        //intSubject2에 새 값을 내보낸다.

        publisher.send(intSubject3)
        intSubject3.send(3)
        intSubject2.send(4)
        //intSubject3에 대해서도 반복하되, 이번에는 두 개의 값을 내보낸다.

        publisher.send(completion: .finished)
        //completion 이벤트를 내보낸다.
        
        // Then
        XCTAssert(
            results == expected,
            "Results expected to be \(expected) but were \(results)"
        )
    }
    
    func test_timerPublish() {
        // Given
        func normalized(_ ti: TimeInterval) -> TimeInterval {
            //소수점 첫째 자리에서 반올림하여 time interval을 정규화하는 helper function
            return Double(round(ti * 10) / 10)
        }
        
        let now = Date().timeIntervalSinceReferenceDate
        //현재 time interval을 저장한다.
        let expectation = self.expectation(description: #function)
        //비동기 작업이 완료될 때까지 기다리는데 사용할 기대치를 생성한다.
        let expected = [0.5, 1, 1.5]
        var results = [TimeInterval]()
        //기대 결과와 실제 결과를 저장할 array을 정의한다.
        
        let publisher = Timer
            .publish(every: 0.5, on: .main, in: .common)
            .autoconnect()
            .prefix(3) //첫 3개의 값만 가져온다.
        //auto-connects되는 timer publisher를 생성한다.
        //세부 사항에 대한 내용은 Chapter 11, “Timers”을 참조한다.
        
        // When
        publisher
            .sink(receiveCompletion: { _ in expectation.fulfill() },
                  receiveValue: {
                    results.append(normalized($0.timeIntervalSinceReferenceDate - now))
            
            })
            .store(in: &subscriptions)
        
        // Then
        waitForExpectations(timeout: 2, handler: nil)
        //최대 2초동안 기다린다.
        
        XCTAssert(
            results == expected,
            "Results expected to be \(expected) but were \(results)"
        )
        //실제 results와 예측된 expected가 동일하다고 assert한다.
    }
    
    func test_shareReplay() {
        // Given
        let subject = PassthroughSubject<Int, Never>()
        //새 정수 값을 내보낼 subject를 생성한다.
        let publisher = subject.shareReplay(capacity: 2)
        //capacity가 2인 shareReplay를 사용하여 해당 subject에서 publisher를 만든다.
        let expected = [0, 1, 2, 1, 2, 3, 3]
        var results = [Int]()
        //예상 결과를 정의하고, 실제 출력을 저장할 array를 만든다.
        
        // When
        publisher
            .sink(receiveValue: { results.append($0) })
            .store(in: &subscriptions)
        //publisher에 대한 구독을 만들고, 내보낸 값을 results에 저장한다.
        
        subject.send(0)
        subject.send(1)
        subject.send(2)
        //publisher가 share-replaying 중인 subject를 사용해 일부 값을 내보낸다.
        
        publisher
            .sink(receiveValue: { results.append($0) })
            .store(in: &subscriptions)
        //또 다른 구독을 생성하고, 여기서도 내보낸 값을 results에 저장한다.
        
        subject.send(3)
        //subject에서 값을 하나 더 내보낸다.
        
        // Then
        XCTAssert(
            results == expected,
            "Results expected to be \(expected) but were \(results)"
        )
    }
}





