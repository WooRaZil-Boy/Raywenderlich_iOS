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

class BullsEyeTests: XCTestCase {
  var sut: BullsEyeGame! //placeholder //System Under Test
  
  //Using XCTAssert to Test Models
  override func setUp() {
    super.setUp()
      
    sut = BullsEyeGame() //객체 생성
    //이 테스트 클래스의 모든 테스트는 sut 객체의 속성과 메서드에 액세스할 수 있게 된다.
    sut.startNewGame()
  }

  override func tearDown() {
    sut = nil
    
    super.tearDown()
  }
  
  //모든 테스트가 깨끗히 초기화된 상태에서 시작하도록 sut 객체를 setUp()에서 생성하고, tearDown()에서 해제하는 것이 좋다.
  //http://qualitycoding.org/teardown/
  
  //Writing Your First Test
  func testScoreIsComputed() { //테스트 메서드는 항상 test라는 이름으로 시작하고, 테스트할 내용을 뒤에 이어 써준다.
    //테스트는 항상 given, when, then 세션으로 나누는 것이 좋다.
    
    // 1. given : 여기서 필요한 모든 값들을 설정해 준다.
    let guess = sut.targetValue + 5 //targetValue와 얼마나 다른지 나타내는 변수
    
    // 2. when : 테스트 코드를 작성한다.
    sut.check(guess: guess) //BullsEyeGame에서 예측값과 실제값의 차이를 계산하는 함수
    
    // 3. then : 테스트가 실패할 경우 메시지를 출력하고 assert 함수를 사용해 종료시킨다.
    XCTAssertEqual(sut.scoreRound, 95, "Score computed from guess is wrong")
    //sut.scoreRound가 95와 같아야 한다. 같지 않을 시 "Score computed from guess is wrong" 메시지를 출력한다.
  }
  
  //Debugging a Test
  func testScoreIsComputedWhenGuessLTTarget() {
    //테스트가 실패하면 버그 혹은 잘못 작성된 코드가 있다는 의미가 된다.
    //이 프로젝트에는 테스트를 위해 의도적으로 잘못 작성한 코드가 있다. 이를 체크하고 디버깅한다.
    
    // 1. given
    let guess = sut.targetValue - 5
    
    // 2. when
    sut.check(guess: guess)
    
    // 3. then
    XCTAssertEqual(sut.scoreRound, 95, "Score computed from guess is wrong")
    //Test Failure Breakpoint를 추가하고 테스트를 진행하면, 이곳에서 멈추게 된다.
    //debug console에서 sut과 guess를 확인해 본다.
  }
}

//다음과 같은 목표가 있다.
//Xcode Test navigator를 사용해 앱의 모델 및 비동기 메서드를 테스트
//stub 및 mock를 사용하여 라이브러리 또는 시스템 객체와의 상호 작용을 가짜로 만들어 테스트 하는 방법
//UI 및 performance 테스트 방법
//code coverage tool 사용 방법




//Figuring Out What to Test
//기존 앱을 확장하는 것이라면, 변경하는 구성 요소에 대한 테스트를 먼저 작성해야 한다.
//일반적으로 테스트는 다음을 포함해야 한다.
// • 핵심기능 : 모델 클래스, 메서드, 컨트롤러의 상호 작용
// • 가장 일반적인 UI workflow
// • 경계 조건(Boundary conditions)
// • 버그 수정




//Best Practices for Testing
//FIRST 약어로 효과적인 단위 테스트를 위한 간결한 기준을 설명할 수 있다.
// • Fast : 테스트는 빠르게 실행되어야 한다.
// • Independent/Isolated : 각 테스트는 서로의 상태를 공유하지 않아야 한다.
// • Repeatable : 테스트를 실행할 때마다 동일한 결과를 얻어야 한다.
//  외부 데이터 공급자 혹인 동시성 문제로 일시적인 오류가 발생할 수는 있다.
// • Self-validating : 테스트는 완전히 자동화되어야 한다. 로그파일을 보고 프로그래머가 해석하기 보다
//  "통과" 혹은 "실패"의 출력이 나와야 한다.
// • Timely : 테스트 코드는 실제 코드를 작성하기 전에 작성하는 것이 이상적이다(TDD: Test-Driven Development).




//Getting Started

//Unit Testing in Xcode
//Test navigator에서 테스트 타겟을 만들고 테스트를 진행한다.

//Creating a Unit Test Target
//Test navigator 탭(⌘-6)을 열고, 왼쪽 하단의 + 버튼을 눌러 New Unit Test Target... 을 선택한다.
//default template 은 testing framework(XCTest)를 import 하고 있다.
//또한 XCTestCase를 선언하고 setUp(), tearDown() 메서드를 override 해 두었다.
//테스트를 실행하는 방법에는 세 가지가 있다.
// 1. Product ▸ Test (⌘-U). 모든 테스트 클래스를 실행한다.
// 2. Test navigator에서 화살표 버튼을 클릭한다. 개별 테스트 메서드를 실행한다.
// 3. cutter에서 다이아몬드 버튼을 클릭한다. 개별 테스트 메서드를 실행한다.
//테스트를 실행하고 실행이 완료되면, cutter의 마지막 부분에서
//회색 다이아몬드 버튼(testPerformanceExample의 measure)을 클릭해 결과를 확인해 볼 수 있다.
//현재 tutorial에서는 필요하지 않으므로, testPerformanceExample()와 testExample()를 삭제한다.

//Using XCTAssert to Test Models
//XCTAssert 함수를 사용해, 프로젝트의 핵심 모델 함수를 테스트 한다.




//Writing Your First Test
//테스트 메서드는 항상 test라는 이름으로 시작하고, 테스트할 내용을 뒤에 이어 써준다.
//테스트는 항상 given, when, then 세션으로 나누는 것이 좋다.
// 1. Given : 필요한 모든 값들을 설정한다.
// 2. When : 테스트 코드를 작성한다.
// 3. Then : 테스트가 실패할 경우 메시지를 출력하고 assert 함수를 사용해 종료시킨다.




//Debugging a Test
//테스트가 실패하면 버그 혹은 잘못 작성된 코드가 있다는 의미가 된다. 따라서 이를 체크하고 디버깅할 수 있다.
//Breakpoint navigator에서 Test Failure Breakpoint를 추가한다.
//이 breakpoint는 테스트 메서드가 실패해 Assert 함수가 작동하면 테스트 실행을 중지시킨다.
//이후 중단점에서 debub 콘솔의 변수들을 확인해 어느 부분이 잘못 작동하는지 체크해 볼 수 있다.
//테스트가 성공하지 않으면, 해당 부분의 코드에 breakpoint를 걸어 일반적인 디버깅방법으로 버그를 해결한다.
