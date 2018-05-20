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

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?
}

//MARK: - Demo 1
//Command-Shift-O를 눌러 Xcode 내 검색 창을 열 수 있다.




//Ensure a consistent board
//Equal Widths and Equal Heights
//두 가지의 같은 제약 조건을 만들고, 주 제약 조건과 보조 제약 조건으로 설정할 수 있다(priority).
//주 제약 조건을 충족시킬 수 없을 때 보조 제약 조건이 적용된다.

//Missing Constraints
//누락된 제약 조건은 인터페이스 빌더의 왼쪽 창 오른쪽 상단의 빨간 화살표 버튼을 클릭해 확인할 수 있다.




//Add Progress Squares
//연속 적인 UI를 나타낼 때는 StackView를 적극적으로 홯용하는 것이 오토 레이아웃 관리하기 편하다.




//Dynamic Type
//Settings > General > Accessibility > Larger Text 설정
//레이블의 폰트를 Headline 등 Dynamic Type으로 표현되는 것을 고른다.
//Automatically Adjusts Font checkbox에 체크 해서 설정을 적용시킨다.

//인스턴스들을 여러 개 선택하고, Embed 버튼으로 StackView를 만들 수 있다.



//MARK: - Demo2
//Finder의 폴더를 Terminal에 Drag & Drop해서 해당 폴더로 바로 이동할 수 있다.

//일반적으로 인터페이스 빌더 이외의 방법으로 오토레이 아웃을 관리하는 4가지 방법이 있다. p.9 예시 참조
//1. NSLayoutConstraint : 매우 세밀하게 레이아웃을 설정할 수 있지만 거의 사용하지 않는다.
//2. Visual Format Language : 상관 관계가 있는 간단한 뷰 사이에서 사용한다.
//3. NSLayoutAnchor : 다른 뷰에 대한 기본적인 정렬을 할 때 사용한다(top, bottom, center, right).
//4. Third Party (e.g. SnapKit, PureLayout) : 큰 프로젝트나 레이아웃 기반 코드가 광범위할 때 사용한다.



