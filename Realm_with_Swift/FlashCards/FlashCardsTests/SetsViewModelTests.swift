/// Copyright (c) 2018 Razeware LLC
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
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import XCTest
import RealmSwift

@testable import FlashCards

private func indicesToString(string: String, indices: [Int]) -> String {
  return "\(string)[" + indices.map(String.init)
    .joined(separator: ",") + "]"
}

class SetsViewModelTests: XCTestCase {

  func test_loadsSets_whenInitialized() {
    let testCards = RealmProvider.cards.copyForTesting() //testCards 복사본. 메모리 영역에서 생성된다.
    let setName = "testSet"
    
    testCards.realm.addForTesting(objects: [FlashCardSet(setName, cards: [FlashCard("face", "back")])]) //sample data
    //write 트랜잭션으로 카드 세트를 추가한다.
    
    let vm = SetsViewModel(cards: testCards, api: CardsAPI())
    //test Realm을 사용하는 View Model 인스턴스 생성
    
    XCTAssertEqual(vm.sets.count, 1) //test Realm 집합을 포함하고 있는 지 여부
    XCTAssertEqual(vm.sets.first?.name, setName) //사용한 이름이 일치하는 지 여부
  }

  func test_propagadesChanges_whenSetsUpdated() {
    //새로운 Cards 세트가 다운로드 될 때마다 View Model이 콜 백하는 지 테스트.
    //Realm의 비동기 알림을 받아야 하기 때문에 이전 테스트보다 조금 복잡하다.
    let testCards = RealmProvider.cards.copyForTesting()
    let setName = "testSet"
    
    testCards.realm.addForTesting(objects: [FlashCardSet(setName, cards: [FlashCard("face", "back")])])
    
    let vm = SetsViewModel(cards: testCards, api: CardsAPI())
    //여기까지는 test_loadsSets_whenInitialized와 동일
    
    var results = [String]()
    //비동기 테스트로 시간이 지남에 따라 이벤트를 모니터링하므로 테스트 실행하는 동안 결과를 저장해야 한다.
    
    let expectation = XCTestExpectation()
    //XCTestExpectation을 이용해, 특정 조건이 충족될 때까지 기다렸다가 테스트를 진행할 수 있다.
    expectation.expectedFulfillmentCount = 3 //default는 1
    //3개의 이벤트까지 기다렸다가 트리거 한다.
    
    vm.didUpdate = { del, ins, upd in
      
      //View Model에서 카드 세트가 변경될 때마다 didUpdate 클로저가 호출된다.
      //여기서 테스트 코드를 추가하여 업데이트를 기록하고, 각 업데이트에 대한 세부 정보를 기록한다.
      let result = [del, ins, upd].reduce("", indicesToString)
      //indicesToString로 세 개의 배열을 가져와 단일 문자열로 줄인다.
      
      results.append(result)
      expectation.fulfill() //이벤트 호출
      //expectedFulfillmentCount를 3으로 설정했기에, 세 번까지 호출되어야 테스트가 진행된다.
      //expectedFulfillmentCount가 1이 된다.
    }

    DispatchQueue.main.async { //메인 스레드에서 작업 예약
      testCards.realm.addForTesting(objects: [FlashCardSet(setName + "New", cards: [FlashCard("face", "back")])])
      //FlashCardSet 객체 테스트 Realm에 추가 //expectedFulfillmentCount가 2가 된다.
      
      try! testCards.realm.write {
        testCards.realm.deleteAll()
        //expectedFulfillmentCount가 3이 된다.
      }
    }
    
    let waitResult = XCTWaiter().wait(for: [expectation], timeout: 1.0)
    //expectedFulfillmentCount, 1초 wait
    //조건이 충족될 때까지 테스트 실행을 유지시킨다(hold).
    //XCTWaiter는 현재 스레드를 차단하지 않고, 현재 코드의 실행을 일시적으로 중단한다.
    //XCTWaiter는 예상 상태를 주기적으로 확인하므로 비동기 코드의 expectedFulfillmentCount가 3이 되면 다시 시작한다.
    //expectedFulfillmentCount이 3이 되지 않아도, 1초 이상의 시간이 지나면 timeout으로 종료된다.
    
    XCTAssertNotEqual(waitResult, .timedOut)
    //XCTWaiter의 결과 확인. 3개의 이벤트가 기록되지 않았으면, .timeout 결과를 출력한다.
    XCTAssertEqual(results[0], "[][][]") //처음 기록된 변경 세트가 비어 있는지 확인 //초기 상태
    XCTAssertEqual(results[1], "[][1][]") //삽입된 세트가 [][1][]로 업데이트 되었는지 확인
    XCTAssertEqual(results[2], "[0,1][][]") //모든 세틑를 삭제하면서, index 0, 1이 삭제가 된다.
    //업데이트, 삽입은 비어 있다.
  }
}
