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
import SwiftUI

class ViewController: UIViewController {
  @IBOutlet weak var slider: UISlider!
  @IBOutlet weak var targetLabel: UILabel!
  
  var currentValue = 50
  var targetValue = Int.random(in: 1...100)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    targetLabel.text = String(targetValue)
  }
  
  @IBAction func showAlert() {
    let difference = abs(targetValue - currentValue)
    let points = 100 - difference
    
    let alert = UIAlertController(title: "Your Score",
      message: String(points), preferredStyle: .alert)
    
    let action = UIAlertAction(title: "OK",
      style: .default, handler: nil)
    
    alert.addAction(action)
    
    present(alert, animated: true, completion: nil)
  }
  
  @IBAction func sliderMoved(_ slider: UISlider) {
    currentValue = lroundf(slider.value)
  }
    
    //StoryBoard의 segue에서 Control-drag 해서 SegueAction 생성
    @IBSegueAction func openRGBullsEye(_ coder: NSCoder) -> UIViewController? {
         UIHostingController(coder: coder, rootView: ContentView(rGuess: 0.5, gGuess: 0.5, bGuess: 0.5))
        //Swift 5.1 이후 부터, 한 줄 코드인 경우에는 return 키워드가 필요 없다.
    }
    
}

//Chapter 4: Integrating SwiftUI
//기존의 UIKit에 SwiftUI를 추가할 수 있고, 반대로 SwiftUI 앱에서 UIKit을 추가할 수 도 있다.
//또한, SwiftUI와 데이터를 교환하는 UIKit도 작성할 수 있다.
//이를 "호스팅(Hosting)이라 한다. UIKit 앱은 SwiftUI View를 호스팅 할 수 있고,
//SwiftUI 앱은 UIKit View를 호스팅 할 수 있다.




//Getting started
//UIKit으로 작성된 프로젝트가 있다. 여기에 SwiftUI View를 통합하려 한다.

//Targeting iOS 13
//SwiftUI는 iOS 13 이상 부터 지원되므로 UIKit 앱의 배포 대상이 iOS 13인지 확인해야 한다.




//Hosting a SwiftUI view in a UIKit project
//가장 쉬운 통합 방법은 기존 UIKit앱에서 SwiftUI View를 호스팅하는 것이다.
// 1. SwiftUI View 파일을 프로젝트에 추가한다.
// 2. RGBullsEye를 실행하는 Button을 추가한다.
// 3. Hosting Controller를 StoryBoard로 끌어서 Segue를 만든다.
// 4. Segue를 ViewController 코드의 @IBSegueAction에 연결하고 Hosting Controller의
//  rootView를 SwiftUI View의 인스턴스로 설정한다.
//ContentView.swift를 BullsEye 프로젝트로 drag-and-drop 한다. Copy items if needed 체크한다.
//StoryBoard에서 Library를 열고 Button을 추가하고 제약 조건을 설정한다.
//Library에서 Hosting Controller를 StoryBoard로 끌어와 생성한다.
//이후, 이전에 생성한 Button에서 Control-drag 해서 Hosting Controller에 drop하고 Show를 선택한다.
//UIHostingController는 콘텐츠가 SwiftUI인 UIViewController이다.
//SwiftUI로 새 프로젝트를 시작한 경우, SceneDelegate에서 ContentView를 생성할 때 사용하기도 한다.
//StoryBoard에서 ViewController를 선택하고,
//Assistant Editor(Control-Option-Command-Return)를 연다. SwiftUI를 import 하고
//StoryBoard의 segue에서 ViewController로 Control-drag 해서 @IBSegueAction를 만든다.
//@IBSegueAction는 UIKit에서 prepare(for:sender:)을 대신하는 Xcode 11의 새 기능이다.
//대상 ViewController를 생성할 때 속성을 설정하는 경우 유용하다.
//또한, segue에 직접 연결되어 있기 때문에 식별자가 따로 필요하지 않다.

