/// Copyright (c) 2021 Razeware LLC
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

class SwiftCalcUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testPressMemoryPlusAtAppStartShowZeroInDisplay() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
      
      let memoryButton = app.buttons["M+"]
      memoryButton.tap()
      
      let display = app.staticTexts["display"]
      //추가한 accessibility(identifier:)를 사용하여 app에서 표시되는 element를 찾는다.
      let displayText = display.label
      //위의 결과는 UI test의 대부분 UI elements와 마찬가지로 XCUIElement이다.
      //label의 텍스트를 포함하는 element의 label property을 조사한다.
      XCTAssert(displayText == "0")
      //assertion을 사용하여 label이 예상 결과와 일치하는지 확인한다.
      //모든 테스트 assertions은 Objective-C 명명 규칙에 따른 접두사 XCT로 시작한다.
      //각 테스트에서는 통과 또는 실패 여부를 결정하는 하나 이상의 assertions을 수행한다.
    }
  
  func testAddingTwoDigits() {
    let app = XCUIApplication()
    app.launch()

    let threeButton = app.buttons["3"]
    threeButton.tap()

    let addButton = app.buttons["+"]
    addButton.tap()

    let fiveButton = app.buttons["5"]
    fiveButton.tap()

    let equalButton = app.buttons["="]
    equalButton.tap()

    let display = app.staticTexts["display"]
    let displayText = display.label
//    XCTAssert(displayText == "8")
//    XCTAssert(displayText == "8.0")
    XCTAssertEqual(displayText, "8.0")
  }
  
  #if !targetEnvironment(macCatalyst)
  func testSwipeToClearMemory() {
    let app = XCUIApplication()
    app.launch()

    let threeButton = app.buttons["3"]
    threeButton.tap()
    let fiveButton = app.buttons["5"]
    fiveButton.tap()

    let memoryButton = app.buttons["M+"]
    memoryButton.tap()

    let memoryDisplay = app.staticTexts["memoryDisplay"]
    XCTAssert(memoryDisplay.exists)
    //XCUIElement의 exists 속성은 element가 존재하는 경우 true이다.
    //memory display가 보이지 않으면, 이 assert이 실패한다.
    memoryDisplay.swipeLeft()
    //swipeLeft() method는 호출되는 element의 왼쪽에 swipe action을 생성한다.
    //swipeRight(), swipeUp(), swipeDown()의 추가 method가 있다.
    XCTAssertFalse(memoryDisplay.exists)
    //XCTAssertFalse() 테스트는 XCTAssert의 반대 역할을 한다.
    //checked value가 true가 아닌 false이면 성공한다.
    //swipe는 gesture 후 memory를 0으로 설정해야 하며, action은 memory display를 숨기고 존재하지 않게 해야한다.
  }
  #endif

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
