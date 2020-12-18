///// Copyright (c) 2019 Razeware LLC
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

class mZone_Poker_UITests: XCTestCase {
  func testExample() {
    let app = XCUIApplication()
    setupSnapshot(app)
    app.launch()
    //snapshots을 생성하고, 앱을 실행하도록 test를 설정한다.
  
    let chipCountTextField = app.textFields["chip count"]
    chipCountTextField.tap()
    chipCountTextField.typeText("10")
    //Chip Count 텍스트 필드(Storyboard에서 "chip count"로 설정된 accessibility identifier)를 tap하고 10을 입력한다.
    
    let bigBlindTextField = app.textFields["big blind"]
    bigBlindTextField.tap()
    bigBlindTextField.typeText("100")
    //Big Blind 텍스트 필드를 tap하고 100을 입력한다.
    
    snapshot("01UserEntries")
    //app이 어떻게 보이는지 보여주는 snapshot을 01UserEntries 이름으로 생성한다.
    
    app.buttons["what should i do"].tap()
    snapshot("02Suggestion")
    //What Should I Do? 버튼을 tap하고 screenshot을 02Suggestion 이름으로 생성하여, resulting alert을 캡쳐한다.
  }
}
