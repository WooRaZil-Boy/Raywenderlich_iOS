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

import UIKit

@IBDesignable final class ContactPreviewView: UIView {
  @IBOutlet var photoImageView: ProfileImageView!
  @IBOutlet var nameLabel: UILabel!
  @IBOutlet var contentView: UIView!
  @IBOutlet var callButton: UIButton!
  
  let nibName = "ContactPreviewView"
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    loadView()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    loadView()
  }
  
  func loadView() {
    let bundle = Bundle(for: ContactPreviewView.self)
    let nib = UINib(nibName: nibName, bundle: bundle)
    let view = nib.instantiate(withOwner: self).first as! UIView

    view.frame = bounds
    view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    
    setupLayoutInView(view) //추가
    addSubview(view)
  }
  
  private func setupLayoutInView(_ view: UIView) {
    let layoutGuide = UILayoutGuide()
    //새 레이아웃 가이드를 인스턴스화 한다.
    view.addLayoutGuide(layoutGuide)
    //ContactPreview의 현재 view에 새 레이아웃 가이드를 추가한다.
    
    nameLabel.translatesAutoresizingMaskIntoConstraints = false
    callButton.translatesAutoresizingMaskIntoConstraints = false
    //false로 설정해야 코드로 제약조건을 적용할 수 있다.
    
    NSLayoutConstraint.activate([
      nameLabel.topAnchor.constraint(equalTo: layoutGuide.topAnchor),
      nameLabel.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor),
      nameLabel.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor),
      //nameLabel을 layoutGuide에 대해 제약조건을 추가한다.
      
      callButton.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor),
      callButton.centerXAnchor.constraint(equalTo: nameLabel.centerXAnchor)
    ])
    
    let margins = view.layoutMarginsGuide //view의 Layout Margin guide를 할당한다.
    //view에 고정된 제약조건을 만들 수 있다.
    NSLayoutConstraint.activate([
      layoutGuide.topAnchor.constraint(equalTo: photoImageView.bottomAnchor, constant: 5),
      layoutGuide.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
      layoutGuide.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
      layoutGuide.bottomAnchor.constraint(equalTo: margins.bottomAnchor)
      //layoutGuide에 대한 제약조건을 추가한다.
    ])
    
    //layoutGuide는 nameLabel과 callButton의 컨테이너 역할을 한다.
    //따라서 layoutGuide에 영향을 미치는 제약조건은 view의 위치에 직접 영향을 준다.
  }
}

//Layout Guide는 View 사이에 공백을 만드는 데 사용할 수 있는 직사각형 영역이다.
//과거에서 해당 역할을 하는 더미 뷰를 만들어야 했다.
//Auto Layout과 Layout Guide를 사용하면, 더미 뷰가 더 이상 필요하지 않다.

//Available Layout Guides
//디바이스마다 크기가 다르기 때문에, 적절한 인터페이스를 구성할 수 있는 Layout Guide가 있다.
//Layout Guide는 Safe Area, Layout Margin, Readable Content이 있다.

//Safe Area layout guide
//iOS SDK에는 몇가지 레이아웃 가이드가 있지만, 가장 많이 사용되는 것은 Safe Area 레이아웃 가이드이다.
//Safe Area는 navigation bars, tab bars, toolbars에서 다루지 않는 화면 부분을 나타낸다. //p.155

//Layout Margin guides and Readable Content guides
//다음으로 확인해야 할 레이아웃 가이드는 Layout Margin과 Readable Content이다.
//Layout Margin은 View의 여백을 나타낸다. View 자체 대신 View의 여백에 대한 제약 조건을 만드는 데 사용할 수 있다. //p.156
//Readable Content guide는 앱 내에서  text views로 작업할 때 사용할 수 있는 권장 영역을 나타낸다. //p.157

//Creating layout guides
//다음 단계를 거쳐 코드로 layout guides를 생성한다.
// 1. 새 레이아웃 가이드를 인스턴스화한다.
// 2. addLayoutGuide(_:)를 호출하여 컨테이너 뷰에 추가한다.
// 3. layout guide의 제약조건을 정의한다.
//layout guide를 뷰 사이 공백을 만드는 것 외에도 다른 뷰를 포함하게 사용할 수 있다.
//이는 view 중앙에 있는 컨테이너를 만들 때 유용하다.

//Creating custom layout guides
//이전에 구축한 modal view의 버튼과 텍스트가 잘려 있다. 레이아웃 가이드를 이용해 이를 해결할 수 있다.

//Contacts.storyboard의 About Scene에서 Size Inspector를 선택한다.
//Layout margins에서 Follow Readable Width 옵션을 체크한다.
//Readable Content guide를 사용해 화면의 텍스트가 가운데 정렬되고, 가독성을 위해 여백이 추가된다.
