/// Copyright (c) 2020 Razeware LLC
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

final class ProfileHeaderView: UIView {
  override init(frame: CGRect) { //초기화 코드를 추가한다.
    super.init(frame: frame)
    backgroundColor = .groupTableViewBackground
  }
  
  required init?(coder: NSCoder) { //Interface Builder를 위한 초기화 메서드
    //스토리 보드의 .xib로 객체를 초기화할 때 사용한다.
    super.init(coder: coder)
  }
  
  //일반적으로 view가 코드로 생성되면 init(frame:)을, 스토리보드나 .xib에서 뷰가 생성되면 init(coder:)를 사용한다.
}


//Building out a view controller’s user interface in code

//이전 장에서 Interface Builder로 작성한 UI를 코드로 구현한다.

//Layout anchors
//Layout anchors 도입 이전에는 NSLayoutConstraint를 사용하여 코드로 조약조건을 만들었다.
//NSLayoutConstraint는 두 UI 객체 간의 관계를 설명하며, Auto Layout을 충족해야 한다.
//이러한 구현을 여전히 사용할 수 있지만, 가독성에 문제가 생길 수 있다.
//Apple은 이를 보완한 layout anchors를 도입했다.
//ViewController의 중심에 위치하는 사각 view를 만들 때, NSLayoutConstraint를 사용하면 다음과 같다.
//NSLayoutConstraint(
//  item: squareView,
//  attribute: .centerX,
//  relatedBy: .equal,
//  toItem: view,
//  attribute: .centerX,
//  multiplier: 1,
//  constant: 0).isActive = true
//NSLayoutConstraint(
//  item: squareView,
//  attribute: .centerY,
//  relatedBy: .equal,
//  toItem: view,
//  attribute: .centerY,
//  multiplier: 1,
//  constant: 0).isActive = true
//NSLayoutConstraint(
//  item: squareView,
//  attribute: .width,
//  relatedBy: .equal,
//  toItem: nil,
//  attribute: .notAnAttribute,
//  multiplier: 0,
//  constant: 100).isActive = true
//NSLayoutConstraint(
//  item: squareView,
//  attribute: .width,
//  relatedBy: .equal,
//  toItem: squareView,
//  attribute: .height,
//  multiplier: 1,
//  constant: 0).isActive = true

//layout anchors를 사용하면 다음과 같다.
//squareView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
//squareView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
//squareView.widthAnchor.constraint(equalToConstant: 100).isActive = true
//squareView.widthAnchor.constraint(equalTo: squareView.heightAnchor).isActive = true

//layout anchors가 간결하며 가독성이 좋다. layout anchors를 사용하는 또 다른 장점은 유형 확인이다.
//따라서 잘못된 제약조건이 추가될 가능성을 줄일 수 있다.
//아래와 같은 코드를 컴파일한다고 하면
//view.leadingAnchor.constraint(equalTo: squareView.topAnchor)
//NSLayoutXAxisAnchor와 NSLayoutYAxisAnchor 사이의 제약조건을 생성하려 하므로, 컴파일되지 않는다.
//컴파일러는 제약조건이 유효하지 않다는 것을 인식하고, layout anchor의 유형을 확인해 build-time errors가 발생한다.





