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
import CoreML //패키지 추가
import Vision //패키지 추가

class ViewController: UIViewController {
  
  @IBOutlet var imageView: UIImageView!
  @IBOutlet var cameraButton: UIButton!
  @IBOutlet var photoLibraryButton: UIButton!
  @IBOutlet var resultsView: UIView!
  @IBOutlet var resultsLabel: UILabel!
  @IBOutlet var resultsConstraint: NSLayoutConstraint!
    
    lazy var classificationRequest: VNCoreMLRequest = {
        do { //.mlmodel 파일에 오류가 있는 경우 VNCoreMLModel 객체 불러오기가 실패할 수 있으므로 코드가 do catch로 래핑된다.
            let healthySnacks = HealthySnacks()
            //HealthySnacks 객체를 인스턴스화한다. .mlmodel 파일로 자동 생성된 코드의 클래스이다.
            //이 클래스는 직접 사용하지 않으며, Vision에 MLModel 객체 인스턴스를 전달한다.
            let visionModel = try VNCoreMLModel(for: healthySnacks.model)
            //VNCoreMLModel 객체를 생성한다. VNCoreMLModel은 Core ML 프레임 워크의 MLModel 인스턴스를 Vision과 연결하는 래퍼(wrapper) 객체이다.
            let request = VNCoreMLRequest(model: visionModel, completionHandler: {
                [weak self] request, error in
                //Vision의 request는 비동기로 실행되므로, 결과를 수신하는 completion handler를 사용할 수 있다.
                self?.processObservations(for: request, error: error)
            })
            //VNCoreMLRequest 객체를 생성한다. VNCoreMLRequest 객체는 입력 이미지를 CVPixelBuffer로 변환, 크기를 227x227로 재조정, Core ML 모델을 실행, 결과를 해석 등의 실제 작업을 수행한다.
            
            request.imageCropAndScaleOption = .centerCrop
            //model에서 사용하는 227x227로 사진의 크기를 조정할 때, 조정 방식을 지정한다.
            
            return request
        } catch { //VNCoreMLModel 객체 불러오기 실패 시
            fatalError("Failed to create VNCoreMLModel: \(error)") //앱 중단
        }
    }()

  var firstTime = true

  override func viewDidLoad() {
    super.viewDidLoad()
    cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
    resultsView.alpha = 0
    resultsLabel.text = "choose or take a photo"
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    // Show the "choose or take a photo" hint when the app is opened.
    if firstTime {
      showResultsView(delay: 0.5)
      firstTime = false
    }
  }
  
  @IBAction func takePicture() {
    presentPhotoPicker(sourceType: .camera)
  }

  @IBAction func choosePhoto() {
    presentPhotoPicker(sourceType: .photoLibrary)
  }

  func presentPhotoPicker(sourceType: UIImagePickerController.SourceType) {
    let picker = UIImagePickerController()
    picker.delegate = self
    picker.sourceType = sourceType
    present(picker, animated: true)
    hideResultsView()
  }

  func showResultsView(delay: TimeInterval = 0.1) {
    resultsConstraint.constant = 100
    view.layoutIfNeeded()

    UIView.animate(withDuration: 0.5,
                   delay: delay,
                   usingSpringWithDamping: 0.6,
                   initialSpringVelocity: 0.6,
                   options: .beginFromCurrentState,
                   animations: {
      self.resultsView.alpha = 1
      self.resultsConstraint.constant = -10
      self.view.layoutIfNeeded()
    },
    completion: nil)
  }

  func hideResultsView() {
    UIView.animate(withDuration: 0.3) {
      self.resultsView.alpha = 0
    }
  }

  func classify(image: UIImage) {
    //classify(image :)를 구현해 이미지 분류(image classification)를 추가한다.
    //여기에 Vision을 사용하여 Core ML 모델(model)을 실행하고 결과를 해석한다.
    guard let ciImage = CIImage(image: image) else {
        //UIImage를 CIImage 객체로 변환한다.
        //CIImage를 사용해 고급 이미지 처리를 할 수 있다.
        print("Unable to create CIImage")
        
        return
    }
    
    let orientation = CGImagePropertyOrientation(image.imageOrientation)
    //UIImage의 imageOrientation 속성으로 이미지의 방향을 가져올 수 있다.
    //예를 들어, 방향(orientation)이 "down"인 경우, 이미지를 180도 회전 시켜야 한다.
    //Core ML은 이미지가 정방향일 것으로 예상하므로, 필요한 경우 이미지를 회전할 수 있도록 Vision에 orientation를 전달해 준다.
    
    DispatchQueue.global(qos: .userInitiated).async {
        //Core ML에서 계산하는 이미지 분류가 시간이 오래 걸릴 수 있으므로, 메인 스레드를 차단하지 않고 백그라운드 queue를 사용하는 것이 좋다.
        //SqueezeNet은 한 이미지 당 3.9 억개의 계산을 해야한다.
        let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation)
        //이미지와 방향정보로 VNImageRequestHandler를 생성한다.
        
        do {
            try handler.perform([self.classificationRequest])
            //VNImageRequestHandler의 perform으로 request를 실행한다.
            //VNRequest 객체의 배열로 perform을 실행하므로, 원하는 경우 동일한 이미지에 대해 다중의 Vision request를 수행할 수도 있다.
        } catch {
            print("Failed to perform classification: \(error)")
        }
    }
  }
    
    func processObservations(for request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            //request의 completion handler는 request를 시작한 background queue에서 호출된다.
            //main queue에서만 UIKit 메서드를 호출할 수 있기 때문에 해당 메서드의 나머지 코드는 main queue에서 실행된다.
            if let results = request.results as? [VNClassificationObservation] {
                //request 매개변수는 VNCoreMLRequest의 기본 클래스인 VNRequest 유형이다.
                //오류 없이 진행되면, request의 결과(result) 배열(array)에는 하나 이상의 VNClassificationObservation 객체가 포함되어 있다.
                //request가 실패할 때는, 오류가 발생하여 result가 nil이거나 배열에 다른 유형의 observation 객체가 포함되어 있기 때문인데
                //이는 해당 모델이 classifier가 아니거나, Vision request 객체가 Core ML과 일치하지 않는 경우이다.
                if results.isEmpty { //결과가 비어 있는 경우
                    self.resultsLabel.text = "nothing found"
                } else if results[0].confidence < 0.8 { //불확실한 경우
                    self.resultsLabel.text = "not sure"
                } else {
                    //results가 비어 있지 않다면 해당 범주에 대한 VNClassificationObservation 객체가 포함되어 있다.
                    self.resultsLabel.text = String(format: "%@ %.1f%%", results[0].identifier, results[0].confidence * 100)
                    //VNClassificationObservation 객체에는 각 범주의 식별자(healthy/unhealthy)와 모델이 해당 범주일 것으로 생각하는 확률인 신뢰도 점수가 있다.
                    //Vision은 결과를 신뢰도에 따라 자동 정렬하므로, results[0]에는 신뢰도가 가장 높은 범주가 온다. 범주의 이름과 신뢰도를 가져와 label에 표기한다.
                } //결과를 label에 출력한다.
            } else if let error = error { //request에 오류가 있는 경우
                self.resultsLabel.text = "error: \(error.localizedDescription)"
                //오류 메시지를 표시한다.
                //이런 경우가 아예 일어나지 않는 것이 바람직하지만, 모든 경우에 대비해 두는 것이 좋다.
            } else {
                self.resultsLabel.text = "???"
            }
            
            self.showResultsView()
            //결과 label을 화면에 표시한다.
        }
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    picker.dismiss(animated: true)

	let image = info[.originalImage] as! UIImage
    imageView.image = image

    classify(image: image)
  }
}





//Bonus: Using Core ML without Vision
//let healthySnacks = HealthySnacks()

//func pixelBuffer(for image: UIImage)-> CVPixelBuffer? {
//    let model = healthySnacks.model
//    let imageConstraint = model.modelDescription
//        .inputDescriptionsByName["image"]!
//        .imageConstraint!
//    //constraint는 모델의 input 이미지를 설명하는 MLImageConstrint 객체이다.
//    let imageOptions: [MLFeatureValue.ImageOption: Any] = [
//        .cropAndScale: VNImageCropAndScaleOption.scaleFill.rawValue
//    ]
//    //options dictionary로 이미지의 크기를 조정하고 잘라내는 방법을 지정할 수 있다.
//    //Vision과 동일한 옵션을 사용했지만, CGRect를 사용해 커스텀하게 자를 수도 있다.
//    //MLFeatureValue 생성자(constructor)를 사용할 수도 있으며, 이 경우 이미지의 방향이 upright가 아니라면 이미지에 대한 방향 값을 전달할 수 있도록 한다.
//
//    return try? MLFeatureValue(cgImage: image.cgImage!, constraint: imageConstraint, options: imageOptions).imageBufferValue
//}

//func classify(image: UIImage) {
//    DispatchQueue.global(qos: .userInitiated).async {
//        //MLModel의 예측(prediction) 메서드(method)는 동기식(synchronous)이므로, 완료될 때까지 현재 스레드(thread)를 차단한다.
//        //해당 이미지 분류기(image classifier)는 간단하기 때문에 속도가 상당히 빨라 큰 문제가 아닐 수도 있지만, 백그라운드 큐(background queue)에서 예측을 진행하는 것이 좋다.
//        if let pixelBuffer = self.pixelBuffer(for: image) {
//            //helper 메서드를 사용해서, UIImage를 CVPixelBuffer로 변환한다.
//            //이미지를 227x227로 변환하고, 방향을 올바르게 고정시킨다.
//            if let prediction = try? self.healthySnacks.prediction(image: pixelBuffer) {
//                //prediction(image:)를 호출하여 예측을 진행한다. 잠정적으로 오류가 발생할 수 있으므로, if let과 try?를 사용한다.
//                //예를 들어 image buffer가 227x227이 아닌 경우 오류가 발생한다.
//                let results = self.top(1, prediction.labelProbability)
//                //예측 객체는 HealthySnacksOutput이다. 간단히 확률이 가장 높은 클래스의 label을 가져올 수도 있지만, 확률도 확인하기 위해 help 메서드를 사용한다.
//                self.processObservations(results: results) //helper method
//            } else {
//                self.processObservations(results: []) //helper method
//            }
//        }
//    }
//}

//func top(_ k: Int, _ prob: [String: Double]) -> [(String, Double)] {
//    //prob 매개변수로 prediction.labelProbability를 가져와 dictionary를 확인하고, k개의 예측을 (String, Double) 쌍의 배열로 반환한다.
//    //String은 레이블의 이름이고, Double은 해당 클래스의 확률이다.
//    return Array(prob.sorted { $0.value > $1.value }
//        .prefix(min(k, prob.count)))
//}

//func processObservations(results: [(identifier: String, confidence: Double)]) {
//    DispatchQueue.main.async {
//        if results.isEmpty {
//            self.resultsLabel.text = "nothing found"
//        } else if results[0].confidence < 0.8 {
//            self.resultsLabel.text = "not sure"
//        } else {
//            self.resultsLabel.text = String(format: "%@ %.1f%%", results[0].identifier, results[0].confidence * 100)
//        }
//        self.showResultsView() //결과 레이블에 표시
//    }
//}


