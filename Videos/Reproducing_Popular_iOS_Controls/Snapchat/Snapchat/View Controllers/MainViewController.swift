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

protocol ColoredView {
  var controllerColor: UIColor { get set }
}

class MainViewController: UIViewController {
  
  // MARK: - Properties
  var scrollViewController: ScrollViewController!
  
  lazy var chatViewController: UIViewController! = {
    return self.storyboard?.instantiateViewController(withIdentifier: "ChatViewController")
  }()
  
  lazy var discoverViewController: UIViewController! = {
    return self.storyboard?.instantiateViewController(withIdentifier: "DiscoverViewController")
  }()
  
  lazy var lensViewController: UIViewController! = {
    return self.storyboard?.instantiateViewController(withIdentifier: "LensViewController")
  }()
  
  var cameraViewController: CameraViewController!
  
  // MARK: - IBOutlets
  @IBOutlet var navigationView: NavigationView!
  
  override var prefersStatusBarHidden: Bool {
    return true
  }
  
  // MARK: - Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    //밑의 두 컨트롤러(CameraViewController, ScrollViewController)는 embeded 되어 있다.
    if let controller = segue.destination as? CameraViewController {
      cameraViewController = controller
    } else if let controller = segue.destination as? ScrollViewController {
      scrollViewController = controller
      scrollViewController.delegate = self
    }
  }
}

// MARK: - IBActions
extension MainViewController {
  
  @IBAction func handleChatIconTap(_ sender: UITapGestureRecognizer) {
    scrollViewController.setController(to: chatViewController, animated: true)
  }
  
  @IBAction func handleDiscoverIconTap(_ sender: UITapGestureRecognizer) {
    scrollViewController.setController(to: discoverViewController, animated: true)
  }
  
  @IBAction func handleCameraButton(_ sender: UITapGestureRecognizer) {
    scrollViewController.setController(to: lensViewController, animated: true)
  }
}

// MARK: ScrollViewControllerDelegate
extension MainViewController: ScrollViewControllerDelegate {
  
  var viewControllers: [UIViewController?] {
    return [chatViewController, lensViewController, discoverViewController]
  }
  
  var initialViewController: UIViewController {
    return lensViewController
  }
  
  func scrollViewDidScroll() {
    //interactive interpolation
    //특정 범위를 이동하면서 회전을 준다고 할 때,
    //UIView dot animate를 사용하면, iOS가 필요한 해당 이동과 회전을 자동으로 계산한다.
    //그러나 interactive한 드래깅이라면, 개발자가 스스로 계산해서 적용해 줘야 한다.
    //nomalization fomula를 사용해서 적용해 줄 수 있다(0% ~ 100%).
    
    // calculate percentage for animation
    let min: CGFloat = 0
    let max: CGFloat = scrollViewController.pageSize.width
    let x = scrollViewController.scrollView.contentOffset.x
    let result = ((x - min) / (max - min)) - 1
    
    // check which controller is in the foreground.
    // This is for animated controller-specific info
    // (eg. background color)
    var controller: UIViewController?
    if scrollViewController.isControllerVisible(chatViewController) {
      //현재 보여지고 있는 뷰 컨트롤러가 무엇인지 확인
      controller = chatViewController
    } else if scrollViewController.isControllerVisible(discoverViewController) {
      controller = discoverViewController
    }
    
    navigationView.animate(to: controller, percent: result) //애니메이션 적용한다.
  }
}

