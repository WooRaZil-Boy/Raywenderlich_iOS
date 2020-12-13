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

class SettingsTableViewController: UITableViewController {
  override func awakeFromNib() { //awakeFromNib 재정의
    //viewController가 로드되기 전에 코드가 실행된다.
    super.awakeFromNib()
    
    navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissModal))
    modalPresentationStyle = .popover //기본 프레젠테이션 스타일
    popoverPresentationController!.delegate = self //delegate 설정
  }
  
   @objc private func dismissModal() { //네비게이션 바의 버튼을 누르면 호출된다.
    dismiss(animated: true)
  }
}

extension SettingsTableViewController: UIPopoverPresentationControllerDelegate {
  func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
    //size classes에 따른 modal presentation style을 선택한다.
    switch(traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass) {
      //가로와 세로 vertical size classes를 나누는 switch
    case (.compact, .compact): //가로, 세로가 모두 compact이면 .fullScreen으로 반환한다.
      return .fullScreen
    default:
      return .none
    }
  }
  
  func presentationController(_ controller: UIPresentationController, viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle ) -> UIViewController? {
    //표시되는 뷰 컨트롤러와 다른 뷰 컨트롤러를 반환할 수 있다.
    return UINavigationController(rootViewController: controller.presentedViewController)
    //네비게이션 바가 있어 UIBarButtonItem으로 뷰 컨트롤러를 종료할 수 있다.
  }
}

//Adaptive presentation
//뷰 컨트롤러는 환경에 따라 다른 방식으로 제시될 수 있다.
//Messages탭의 Options을 선택하면, sheet를 아래로 끌어 숨길 수 있다.
//하지만, 가로모드에서는 같은 방식으로 sheet를 숨길수 없다.
//SettingsTableViewController를 생성한다.




//UIKit and adaptive interfaces
//UIKit는 adaptive interfaces를 위한 도구를 제공한다. 그 중 일부는 다음과 같다.
// • Split view controller
// • Layout guides
// • UIAppearance proxy




