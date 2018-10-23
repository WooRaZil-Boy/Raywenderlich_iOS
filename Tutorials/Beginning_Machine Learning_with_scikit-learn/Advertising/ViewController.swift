/// Copyright (c) 2017 Razeware LLC
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

final class ViewController: UIViewController {
  @IBOutlet private var tvSlider: UISlider!
  @IBOutlet private var radioSlider: UISlider!
  @IBOutlet private var newspaperSlider: UISlider!
  @IBOutlet private var tvLabel: UILabel!
  @IBOutlet private var radioLabel: UILabel!
  @IBOutlet private var newspaperLabel: UILabel!
  @IBOutlet private var salesLabel: UILabel!
  private let numberFormatter = NumberFormatter()
  private let advertising = Advertising() //Core ML 모델
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    numberFormatter.numberStyle = .decimal
    numberFormatter.maximumFractionDigits = 1
    
    sliderValueChanged()
  }
  
  @IBAction func sliderValueChanged(_ sender: UISlider? = nil) {
    let tv = Double(tvSlider.value)
    let radio = Double(radioSlider.value)
    let newspaper = Double(newspaperSlider.value)
    
    let input = AdvertisingInput(tv: tv, radio: radio, newspaper: newspaper) //Core ML의 input을 생성한다.
    
    guard let output = try? advertising.prediction(input: input) else { //Core ML에서 결과를 예측한다.
      return
    }
    
    let sales = output.sales
    
    tvLabel.text = numberFormatter.string(from: tv as NSNumber)
    radioLabel.text = numberFormatter.string(from: radio as NSNumber)
    newspaperLabel.text = numberFormatter.string(from: newspaper as NSNumber)
    salesLabel.text = numberFormatter.string(from: sales as NSNumber)
  }
}

//iOS 11에서 Apple은 기계 학습 모델을 앱에 통합할 수 있는 Core ML 프레임 워크를 출시했다. 여러 가지 tool로 mlmodel 형식으로 변환할 수 있다.
//이 프로젝트에서는 scikit-learn으로 Python으로 기계 학습 모델을 만들고 Core ML 프레임 워크로 iOS 앱에 통합한다.
//이 앱은 TV, Radio, 신문 광고의 예산을 표시하는 3개의 slider가 있다. 다양한 시나리오를 기반으로 판매 결과를 예측하는 모델을 작성하는 것이 목표이다.




//Integrating the Core ML Model into Your App
//Core ML 모델을 단순히 Drag-and-Drop 해서 프로젝트로 옮길 수 있다.

//올바른 모델을 선택하는 순서도 링크 http://scikit-learn.org/stable/tutorial/machine_learning_map/index.html
//PythonDataScienceHandbook https://jakevdp.github.io/PythonDataScienceHandbook/
