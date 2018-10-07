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
import CoreML
import Vision

class ViewController: UIViewController {

  @IBOutlet weak var drawView: DrawView!
  @IBOutlet weak var predictLabel: UILabel!

  // TODO: Define lazy var classificationRequest
  lazy var classificationRequest: VNCoreMLRequest = {
  //request 객체는 모든 이미지에서 작동하므로 한 번만 정의해 주면 된다. 따라서 lazy var로 선언한다.
    do {
      let model = try VNCoreMLModel(for: MNISTClassifier().model) //mlmodel에서 model을 가져온다.
      return VNCoreMLRequest(model: model, completionHandler: handleClassification)
      //Core ML 모델을 사용해 이미지를 처리하는 이미지 분석 request
    } catch {
      fatalError("Can't load Vision ML model: \(error).")
    }
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    predictLabel.isHidden = true
  }

  @IBAction func clearTapped() {
    drawView.lines = []
    drawView.setNeedsDisplay()
    predictLabel.isHidden = true
  }

  @IBAction func predictTapped() {
    guard let context = drawView.getViewContext(),
      let inputImage = context.makeImage()
      else { fatalError("Get context or make image failed.") }
    // TODO: Perform request on model
    print("Get context and make image succeeded.")
    
    let ciImage = CIImage(cgImage: inputImage)
    let handler = VNImageRequestHandler(ciImage: ciImage) //이미지 분석 요청
    do {
        try handler.perform([classificationRequest]) //Vison의 request를 수행한다. //handler로 전달된다.
    } catch {
        print(error)
    }
  }

}

extension ViewController {
  func handleClassification(request: VNRequest, error: Error?) { //VNCoreMLRequest handler
    //request와 error 객체를 수신한다.
    guard let observations = request.results as? [VNClassificationObservation] else {
      //VNClassificationObservation은 이미지 분석 요청으로 생성된 class 정보. Core ML model이 분류했을 때 Vison Framework 가 반환한다.
      //VNClassificationObservation은 identifier와 confidence 두 가지 속성을 가진다.
      // identifier : 해당 값의 String
      // confidence : 0 ~ 1 사이의 각 분류별 확률
      fatalError("Unexpected result type from VNCoreMLRequest.")
    }
    
    guard let best = observations.first else { //가장 높은 확률을 가진 첫 번째 값을 가져온다.
      fatalError("Can't get best result.")
    }
    
    DispatchQueue.main.async { //분류 작업이 느려질 수 있으므로 메인 스레드에서 업데이트 해 준다.
      self.predictLabel.text = best.identifier
      self.predictLabel.isHidden = false
    }
  }
}
