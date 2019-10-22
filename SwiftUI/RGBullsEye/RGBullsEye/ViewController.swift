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
import SwiftUI //추가

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
}




struct ViewControllerRepresentation: UIViewControllerRepresentable {
    //UIViewControllerRepresentable 프로토콜은 make와 update 메서드를 구현해야 한다.
    
    func makeUIViewController(context: UIViewControllerRepresentableContext <ViewControllerRepresentation>) -> ViewController {
        UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController") as! ViewController
        //Storyboard에서 ViewController를 인스턴스화 한다(StoryBoard ID 사용).
        //ViewController가 Storyboard를 사용하지 않거나, 빈 ViewController를 사용하는 경우에는
        //기본 생성자를 사용해 인스턴스화 할 수 있다.
    }
    
    func updateUIViewController(_ uiViewController: ViewController, context: UIViewControllerRepresentableContext<ViewControllerRepresentation>) {
        //해당 ViewController가 SwiftUI View의 데이터에 의존적이지 않으므로 update는 비워둔다.
        
    }
}




struct ViewControllerPreviews: PreviewProvider {
    //Previewing UIKit views
    //SwiftUI 앱에서 Viewcontroller를 Hosting 하지 않더라도, UIViewControllerRepresentable을
    //구현하면, Xcode에서 preview를 할 수 있다.
    
    static var previews: some View {
        ViewControllerRepresentation()
    }
    
    //SwiftUI View 아래에 추가되는 preview 코드와 같다(ContentView.swift 참고).
}

