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

import XCTest //테스팅 프레임워크 import
@testable import BullsEye //테스트 할 프로젝트 import
//이렇게 import를 해야 BullsEye의 internal 변수와 메서드를 사용할 수 있다.

//Fake Update to Mock Object
class MockUserDefaults: UserDefaults {
  //이전의 테스트에서는 가짜 객체의 입력을 제공하기 위해 stub을 사용했다.
  //다음으로 mock 객체를 사용해 코드가 UserDefaults를 올바르게 업데이트 되는 지 테스트한다.
  //Test navigator 탭(⌘-6)을 열고, 왼쪽 하단의 + 버튼을 눌러 New Unit Test Class... 을 선택한다.
  var gameStyleChanged = 0
  
  override func set(_ value: Int, forKey defaultName: String) { //gameStyleChanged를 증가 시킨다.
    //Int 대신 Bool로 설정할 수도 있지만, Int로 하는 것이 유연하다.
    //ex. 테스트에서 메서드가 한 번만 호출되는지 확인할 수 있다.
    if defaultName == "gameStyle" {
      gameStyleChanged += 1
    }
  }
}

class BullsEyeMockTests: XCTestCase {
  var sut: ViewController! //System Under Test
  var mockUserDefaults: MockUserDefaults!
  
  override func setUp() {
    super.setUp()
    
    sut = UIStoryboard(name: "Main", bundle: nil)
      .instantiateInitialViewController() as? ViewController //객체 생성
    mockUserDefaults = MockUserDefaults(suiteName: "testing")
    sut.defaults = mockUserDefaults //UserDefaults 객체 DI
  }

  override func tearDown() {
    sut = nil
    mockUserDefaults = nil
    
    super.tearDown()
  }
  
  func testGameStyleCanBeChanged() {
    // 1. given : 여기서 필요한 모든 값들을 설정해 준다.
    let segmentedControl = UISegmentedControl()
    
    // 2. when : 테스트 코드를 작성한다.
    XCTAssertEqual(mockUserDefaults.gameStyleChanged, 0, "gameStyleChanged should be 0 before sendActions")
    //gameStyleChanged는 테스트 하기 전에는 0 이어야 한다(default).
    //0이 아닐 시, "gameStyleChanged should be 0 before sendActions" 메시지를 출력한다.
    segmentedControl.addTarget(sut, action: #selector(ViewController.chooseGameStyle(_:)), for: .valueChanged)
    //Action 추가
    segmentedControl.sendActions(for: .valueChanged)
    //Action 실행
    
    // 3. then : 테스트가 실패할 경우 메시지를 출력하고 assert 함수를 사용해 종료시킨다.
    XCTAssertEqual(mockUserDefaults.gameStyleChanged, 1, "gameStyle user default wasn't changed")
    //Action을 실행한 결과가 반영되어 gameStyleChanged가 1이 되어야 한다.
    //같지 않을 시 "gameStyle user default wasn't changed" 메시지를 출력한다.
  }
}

//Fake Update to Mock Object
//이전의 테스트에서는 가짜 객체의 입력을 제공하기 위해 stub을 사용했다.
//다음으로 mock 객체를 사용해 코드가 UserDefaults를 올바르게 업데이트 되는 지 테스트한다.
//Test navigator 탭(⌘-6)을 열고, 왼쪽 하단의 + 버튼을 눌러 New Unit Test Class... 을 선택한다.
