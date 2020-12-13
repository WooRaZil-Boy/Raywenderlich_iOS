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

class AboutViewController: UIViewController {
  private var contactButtonConstraints: [NSLayoutConstraint] = []
  lazy var contactUsButton: UIButton = {
    let button =  UIButton()
    button.backgroundColor = .white
    button.setTitleColor(.blue, for: .normal)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.layer.cornerRadius = 20.0
    button.layer.borderWidth = 1.0
    button.layer.borderColor = UIColor.blue.cgColor
    button.setImage(UIImage(named:"info"), for: .normal)
    button.imageView?.contentMode = .scaleAspectFit
    button.setBackgroundImage(UIImage(named: "button-background"), for: .normal)
    return button
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.addSubview(contactUsButton) //뷰에 추가
    setupContactUsButton(verticalSizeClass: traitCollection.verticalSizeClass)
    //처음 view가 호출될 때, 올바르게 설정되도록 호출한다.
  }
  
  private func setupContactUsButton(verticalSizeClass: UIUserInterfaceSizeClass) {
    NSLayoutConstraint.deactivate(contactButtonConstraints) //제약조건 비활성화
    
    if verticalSizeClass == .compact { //세로가 .compact 이면
      contactUsButton.setTitle("Contact Us", for: .normal) //타이틀 변경
      contactButtonConstraints = [
        contactUsButton.widthAnchor.constraint(equalToConstant: 160),
        contactUsButton.heightAnchor.constraint(equalToConstant: 40),
        contactUsButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
        contactUsButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
      ] //제약조건 설정
    } else { //compact가 아닌 경우. .regular
      contactUsButton.setTitle("", for: .normal) //타이틀 변경
      contactButtonConstraints = [
        contactUsButton.widthAnchor.constraint(equalToConstant: 40),
        contactUsButton.heightAnchor.constraint(equalToConstant: 40),
        contactUsButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        contactUsButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
      ] //제약조건 설정
    }
    
    NSLayoutConstraint.activate(contactButtonConstraints) //제약조건 활성화
  }
  
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) { //화면이 회전될 때 호출된다.
    super.traitCollectionDidChange(previousTraitCollection)
    
    if traitCollection.verticalSizeClass != previousTraitCollection?.verticalSizeClass { //현재 verticalSizeClass가 이전과 다른지 확인한다.
      setupContactUsButton(verticalSizeClass: traitCollection.verticalSizeClass)
      //다르다면, 제약조건을 새로 적용한다.
    }
  }
}

//One storyboard to run them all
//앱의 복잡성에 따라 다른 전략을 사용하여 적절한 제약조건을 사용함으로써, 다른 화면 크기와 방향에 모두 적용되는 앱을 만들 수 있다.
//현재 앱은 가로모드에서 제대로 작동하지 않는다.
//Profile.storyboard에서 Profile Scene의 Main Stack View를 선택한다.
//Size inspector에서 제약 조건을 추가한다.

//Setting up the storyboard
//Main.storyboard에서 Command-Option-1을 눌러, File inspector를 선택한다.
//Use Trait Variations과 Use Safe Area Layout Guides를 체크한다.
//Xcode 최신 버전에서는 기본적으로 체크가 되어 있다.
// • Use Trait Variations : 둘 이상의 디바이스에 대한 데이터를 저장할 수 있다.
//  adaptive layouts을 적용하려면 이 옵션을 선택해야 한다.
// • Use Safe Area Layout Guides : 최신 아이폰 max 등의 notch에 가려지지 않는 레이아웃을 사용한다.

//Previewing layouts
//스토리 보드의 View as: <iOS Device>에서 각 디바이스를 선택할 수 있다.




//Size classes
//여러 장치의 각 방향에서 제대로 레이아웃을 적용 시키려면, Size classes을 사용한다.
//Size class는 기기와 앱이 실행되고 있는 환경을 고려해 사용가능한 공간이 얼마나 되는지 알 수 있게 해준다.
//Size classes는 horizontalSizeClass와 verticalSizeClass가 있다. 이를 조합하면 4가지가 있다.
//p.188

//Working with size classes
//Main.storyboard의 About Scene을 선택한다.
//Vary for Traits을 선택하고, 영향받는 제약조건을 설정할 수 있다.




//Changing properties
//제약조건 외에도 size classes를 사용하여 일부 속성의 값을 변경할 수도 있다.
//스토리 보드의 Attributes inspector에서 각 옵션의 + 버튼을 사용해 해당 size classes에 속성 값을 준다.

//Trait environment and trait collections
//기기의 방향이 바뀔때 마다 새로운 구성이 화면에 적용된다.
//traitCollectionDidChange(_:)를 사용하여 이러한 코드 변경에 응답할 수 있다.




//Adaptive images
//Image assets도 적응형으로 만들 수 있다. size class에 따른 다른 이미지를 제공할 수 있다.

//Images and traits
//Assets.xcassets에서 이미지를 선택하고, Width Class와 Height Class를 설정해 줄 수 있다.

//Alignment insets and slicing
//Asset Catalog를 사용하여, 이미지에 alignment insets와 slicing을 지정해 줄 수 있다.
//alignment을 사용하면, 여백을 지정하여 이미지의 일부만 가져올 수 있다.
//slicing은 원하는 부분만 이미지를 늘려, 사이즈가 잘 맞게 할 수 있다.
//Assets.xcassets에서 slicing메뉴를 사용해 적용한다.
//중앙 하단의 Show Slicing 버튼을 눌러보면 미리보기를 확인할 수 있다.
