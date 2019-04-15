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
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import XCTest

class BullsEyeUITests: XCTestCase {
  var app: XCUIApplication!

  override func setUp() {
    continueAfterFailure = false
    
    app = XCUIApplication()
    app.launch()
  }

  //UI Testing in Xcode
  func testGameStyleSwitch() {
    //UI 테스트로 사용자 인터페이스와 상호작용을 테스트할 수 있다.
    //UI 테스트는 쿼리로 앱의 UI 객체를 찾고 이벤트를 합성한 다음 해당 객체에 이벤트를 보내 작동한다.
    //API를 사용하면 UI 객체의 속성과 상태를 검사하고 예상 상태와 비교할 수 있다.
    
    // 1. Given : 필요한 모든 값들을 설정한다.
    let slideButton = app/*@START_MENU_TOKEN@*/.segmentedControls.buttons["Slide"]/*[[".segmentedControls.buttons[\"Slide\"]",".buttons[\"Slide\"]"],[[[-1,1],[-1,0]]],[1]]@END_MENU_TOKEN@*/
    //menu를 열어 segmentedControls의 button으로 선택한다.
    let typeButton = app.segmentedControls.buttons["Type"]
    let slideLabel = app.staticTexts["Get as close as you can to: "]
    let typeLabel = app.staticTexts["Guess where the slider is: "]
    //테스트 하려는 UI의 메서드를 생성해, 커서를 위치하도록 하고 콘솔창 좌측의 빨간 녹음 단추를 클릭한다.
    //그러면 상호작용을 기록하는 모드로 앱이 시작된다. 테스트를 하고자하는 UI를 선택하거나 제스처 한 다음 중단 버튼을 누른다.
    //완료가 되면, 해당 UI 요소들을 상호작용을 테스트하는 코드가 만들어 진다.
    //만들어진 코드에서 불필요한 부분(tap()이나 메뉴로 선택해야 하는 다른 UI)을 삭제하거나 선택해 준다.
    
    // 3. Then : 테스트가 실패할 경우 메시지를 출력하고 assert 함수를 사용해 종료시킨다.
    if slideButton.isSelected {
      XCTAssertTrue(slideLabel.exists)
      XCTAssertFalse(typeLabel.exists)
      
      typeButton.tap()
      XCTAssertTrue(typeLabel.exists)
      XCTAssertFalse(slideLabel.exists)
    } else if typeButton.isSelected {
      XCTAssertTrue(typeLabel.exists)
      XCTAssertFalse(slideLabel.exists)
      
      slideButton.tap()
      XCTAssertTrue(slideLabel.exists)
      XCTAssertFalse(typeLabel.exists)
    }
  }
  //각각의 세그먼트를 tap 했을 때 레이블이 올바르게 적용되는지 확인한다.
  
}

//UI Testing in Xcode
//UI 테스트로 사용자 인터페이스와 상호작용을 테스트할 수 있다.
//UI 테스트는 쿼리로 앱의 UI 객체를 찾고 이벤트를 합성한 다음 해당 객체에 이벤트를 보내 작동한다.
//API를 사용하면 UI 객체의 속성과 상태를 검사하고 예상 상태와 비교할 수 있다.
//Test navigator 탭(⌘-6)을 열고, 왼쪽 하단의 + 버튼을 눌러 New UI Test Class... 을 선택한다.
