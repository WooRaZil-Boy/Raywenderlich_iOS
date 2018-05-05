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

@testable import FlashCards

class CardsViewModelTests: XCTestCase {
  private func testSet(_ setName: String = "") -> FlashCardSet {
    //여기서 테스트할 View Model을 생성하기 위해FlashCardSet 객체가 필요하다.
    //이 작업을 자동화하기 위해, 필요할 때마다 dummy FlashCardSet 객체를 만드는 메서드를 추가하는 것이 편하다.
    return FlashCardSet(setName, cards: [FlashCard("face", "back")])
    //앞면(face), 뒷면(back)이라는 텍스트가 있는 단일 FlashCard 사용
  }

  func test_storesSet_whenInitialized() {
    let setName = "testSet"
    let vm = CardsViewModel(set: testSet(setName)) //testSet 이름의 새로운 Set 생성
    //View Model 생성
    
    XCTAssertEqual(vm.set.name, setName) //테스트
    //View Model의 set name과 setName이 같아야 한다.
    //위에서 setName으로 새로 생성했으므로 제대로 저장되었는지 확인
    
    //Realm 객체는 유지되지 않을 때(in memory 에서 테스트 시) 일반 Swift 객체처럼 작동하므로
    //쉽게 생성하고 전달해 테스트 할 수 있다.
  }

  func test_hasInitialCardState_whenInitialized() {
    let vm = CardsViewModel(set: testSet()) //위에서 만든 테스트 셋으로 테스트
    //단순히 View Model이 초기화 시, 카드의 앞, 뒷면의 값을 올바르게 반환하는 지 테스트 하므로 테스틑 셋으로 충분하다.
    
    XCTAssertEqual(vm.text, "face")
    XCTAssertEqual(vm.details, "1 of 1")
  }

  func test_updatesState_whenPositionChanges() {

  }

  func test_updatesState_whenToggled() {

  }
}

//Command + U 로 테스트 진행할 수 있다.
//Realm의 알림 매커니즘에 의존하는 테스트가 단위 테스트인지 통합 테스트인지 여부는 논쟁의 여지가 있다.




//Dependency injection
//의존성 주입을 테스트 하려면, 코드를 약간 변경해야 한다.
//테스트에서 테스트 provider를 생성해 View Model로 전달하고, View Model을 Model에 넘겨준다. p.182
//이렇게 하면 View Model과 Model 클래스는 DB에 어떤 종류의 Realm을 사용하고 있는지 알 수 없다
//단순히 provider를 받아 사용하고 필요에 따라 소유한 클래스에 전달 한다(추상화 되어 어떤 Realm 객체가 오든 상관없다).
//앱이 실행 중일 때, View Model과 Model은 다른 객체에서 필요한 provider를 계속해서 수신한다.
//테스트 중인 경우 테스트 provider를 주입하는 동안 앱 실행에 기본 provider를 사용할 수도 있다.

