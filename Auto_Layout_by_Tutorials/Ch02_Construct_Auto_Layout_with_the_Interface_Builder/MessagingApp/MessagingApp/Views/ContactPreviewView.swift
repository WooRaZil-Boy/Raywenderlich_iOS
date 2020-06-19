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

class ContactPreviewView: UIView {
  @IBOutlet var photoImageView: UIImageView!
  @IBOutlet var nameLabel: UILabel!
  @IBOutlet var contentView: UIView!
  //xib의 class를 ContactPreviewView로 지정해 주고 File’s Owner에서 연결한다.
  
  override init(frame: CGRect) { //init(frame:)를 재정의해 loadView()를 호출한다.
    //프로그래밍 방식 초기화
    super.init(frame: frame)
    loadView()
  }
  
  required init?(coder: NSCoder) { //init(coder:)를 재정의해 loadView()를 호출한다.
    //스토리 보드 로드
    super.init(coder: coder)
    loadView()
  }
  
  func loadView() {
    let bundle = Bundle(for: ContactPreviewView.self)
    //번들을 가져온다.
    let nib = UINib(nibName: "ContactPreviewView", bundle: bundle)
    //xib 인스턴스 생성
    let view = nib.instantiate(withOwner: self).first as! UIView
    //view를 인스턴스화 하고, 현재 클래스를 할당한다.
    view.frame = bounds //view.frame을 bounds로 설정한다.
    addSubview(view) //현재 view에 추가
  }
}
//ContactPreviewView를 프로젝트 어디에서나 사용할 수 있다.




//Chapter 2: Construct Auto Layout with the Interface Builder

//Setting up the launch screen layout using a storyboard

//Previewing layouts on multiple screen sizes
//Adjust Editor Options의 Preview를 선택해서, 앱을 실행 시키지 않고도 다양한 디바이스에서 실행화면을 확인해 볼 수 있다.
//스토리 보드는 기본으로 Safe Area를 기준으로 되어 있는데, 이 경우 Max 등의 아이폰에서는 상하단을 꽉 채워지지 않는다.
//오토 레이아웃에서 Safe Area를 Superview로 변경해주면, Max에서도 모두 채워지게 된다.

//Constraint inequalities
//상황에 따라, 다른 제약조건을 사용해야 할 때도 있다. ex. 가로모드
//aspect ratio 제약조건을 추가하면, 비율로 View를 조정할 수 있다.
//Greater Than or Equal을 사용해 크기의 최소값을 지정해 주면, 상황에 따라 크기를 조절할 수 있다.

//Pros/cons and who is it for?
//스토리보드가 항상 장점만 있는 것은 아니다. 쉽게 이해하기 쉽지만, 코드 병합시 충돌나는 경우가 많고, 컴파일 시간을 증가시킨다.




//Using Xibs
//.nib 와 xib는 비슷하지만 다르다. .nibs는 배포 가능한 파일이다.
//최종 컴파일된 앱에서 .xib 파일을 사용하려면 .nib로 컴파일해야 한다.

//How to achieve modularity with .xib
//The .xib object life cycle
// 1. 리소스 파일을 메모리에 로드한다.
// 2. .xib 파일 내 모든 객체를 인스턴스화 한다. init(coder:)
// 3. 모든 Outlet과 Action을 재설정한다.
// 4. awakeFromNib() 호출
// 5. view를 표시한다.

//Practical use case
//ContactPreview 폴더에서 New File....을 선택해서 User Interface 세션의 View를 선택한다.
//이름을 ContactPreviewView로 지정하고 Create를 선택하면, ContactPreviewView.xib가 생성된다.
//Attributes inspector에서 size를 Freeform으로 설정하면, 크기를 임의로 조절할 수 있다.
//xib를 연결할 View를 생성한다.
//Cocoa Touch Class를 선택해, UIView의 subview로 ContactPreviewView를 생성한다.
