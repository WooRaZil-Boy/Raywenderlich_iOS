/**
 * Copyright (c) 2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
 * distribute, sublicense, create a derivative work, and/or sell copies of the
 * Software in any work that is designed, intended, or marketed for pedagogical or
 * instructional purposes related to programming, coding, application development,
 * or information technology.  Permission for such use, copying, modification,
 * merger, publication, distribution, sublicensing, creation of derivative works,
 * or sale is expressly withheld.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import CoreML
import Vision

class ViewController: UIViewController {

  // MARK: - IBOutlets
  @IBOutlet weak var scene: UIImageView!
  @IBOutlet weak var answerLabel: UILabel!

  // MARK: - Properties
  let vowels: [Character] = ["a", "e", "i", "o", "u"]

  // MARK: - View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()

    guard let image = UIImage(named: "train_night") else {
      fatalError("no starting image")
    }

    scene.image = image
    
    guard let ciImage = CIImage(image: image) else {
      fatalError("couldn't convert UIImage to CIImage")
    }
    
    detectScene(image: ciImage)
  }
}

// MARK: - IBActions
extension ViewController {

  @IBAction func pickImage(_ sender: Any) {
    let pickerController = UIImagePickerController()
    pickerController.delegate = self
    pickerController.sourceType = .savedPhotosAlbum
    present(pickerController, animated: true)
  }
}

// MARK: - UIImagePickerControllerDelegate
extension ViewController: UIImagePickerControllerDelegate {

  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    dismiss(animated: true)

    guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
      fatalError("couldn't load image from Photos")
    }

    scene.image = image
    
    guard let ciImage = CIImage(image: image) else {
      fatalError("couldn't convert UIImage to CIImage")
    }
    
    detectScene(image: ciImage)
  }
}

// MARK: - UINavigationControllerDelegate
extension ViewController: UINavigationControllerDelegate {
}

// MARK: - Methods
//Wrapping the Core ML Model in a Vision Model
extension ViewController {
  func detectScene(image: CIImage) {
    answerLabel.text = "detecting scene..."
    
    // 1. Load the ML model through its generated class
    guard let model = try? VNCoreMLModel(for: GoogLeNetPlaces().model) else {
      //VNCoreMLModel는 Vision request에 사용되는 Core ML model의 모델 컨테이너 이다.
      fatalError("can't load Places ML model")
    }
    
    // 2. Create a Vision request with completion handler
    let request = VNCoreMLRequest(model: model) { [weak self] request, error in
      //VNCoreMLRequest는 Core ML에서 사용하는 image analysis request이다.
      //클로저는 completion handler로 request와 error 객체를 받는다.
      guard let results = request.results as? [VNClassificationObservation], let topResult = results.first else {
        //request.results이 VNClassificationObservation 배열인지 확인한다.
        //VNClassificationObservation는 Core ML model이 분류 모델일 때 Vision Framework가 반환하는 객체이다.
        //GoogLeNetPlaces는 어떤 이미지인지를 카테고리로 판단하므로 분류 모델이다(205 개의 카테고리가 있다).
        //VNClassificationObservation는 두 개의 속성이 있다.
        // • identifier : category의 String
        // • confidence : 0과 1사이의 확률 값
        //가장 확률이 높은 카테고리가 처음으로 온다. 따라서 results.first로 해당 카테고리를 가져올 수 있다.
        fatalError("unexpected result type from VNCoreMLRequest")
      }
      
      // Update UI on main queue
      let article = (self?.vowels.contains(topResult.identifier.first!))! ? "an" : "a" //모음에 따라 관사 선택
      DispatchQueue.main.async { [weak self] in //모델이 결과를 도출하는 데 시간이 걸리므로 메인 스레드에서 업데이트 하는 것이 좋다.
        self?.answerLabel.text = "\(Int(topResult.confidence * 100))% it's \(article) \(topResult.identifier)"
      }
    }
    //request를 생성할 뿐, 실제로 실행하지는 않는다(네트워크에서 Session 처럼). 실제 실행은 VNImageRequestHandler로 perform 해 줘야 한다.
    
    // 3. Run the Core ML GoogLeNetPlaces classifier on global dispatch queue
    let handler = VNImageRequestHandler(ciImage: image) //detectScene(image:)의 인자로 image 를 받아 온다.
    //VNImageRequestHandler는 Vision Framework의 request handler이다. 이것은 Core ML 모델에만 국한 되는 것이 아니다.
    DispatchQueue.global(qos: .userInteractive).async {
      do {
        try handler.perform([request]) //해당 메서드를 호출한다.
      } catch {
        print(error)
      }
    }
    
    //표준적인 Vision의 workflow는 model을 만들고 하나 이상의 request를 생성한 후, request handler를 실행하는 것이다.
  }
}

//Core ML과 Vison은 iOS 11에서 새로 추가된 Framework 이다.
//여기서는 이 프로엠워크들과 Places205-GoogLeNet 모델을 사용해 이미지의 scene 분석을 한다.




//iOS Machine Learning
//기계 학습은 명시적으로 프로그래밍되지 않아도 컴퓨터가 학습하는 인공 지능의 한 유형이다.
//알고리즘을 코딩하는 대신 기계 학습 도구를 사용하면 컴퓨터가 방대한 양의 데이터 패턴을 찾아 알고리즘을 개발하고 수정한다.

//Deep Learning
//Apple의 Core ML 프레임워크는 neural networks, tree ensembles, support vector machines,
//generalized linear models, feature engineering, pipeline models 등을 지원한다.
//neural network는 최근에 많은 성공 사례를 만들어 내고 있는 인공지능 모델이다. Siri와 Alexa 같은 앱 또한 neural network를 사용한다.
//neural network는 서로 다른 방식으로 연결되어 있는 노드 계층으로 인간의 두뇌를 모방한다. 기본적으로 추가 계층이 누적될 수록 성능이 향상된다.
//계산은 행렬 곱으로 이루어지며, GPU가 이를 효율적으로 처리할 수 있다. neural network는 많은 양의 training 데이터를 필요한다.
//학습은 neural network에 데이터를 제공해 적합한 매개 변수 값을 계산하는 것이다.
//deep neural network는 완벽하지 않다. 학습을 위한 데이터 세트를 만드는 것이 어렵고 오버피팅도 잘 일어난다.

//What Does Apple Provide?
//NSLinguisticTagger은 iOS 5에서 natural language 를 분석하기 위해 도입했다.
//Metal은 iOS 8부터 포함된 GPU에 대한 low-level access 를 제공한다.
//2016년에 Apple은 Accelerate framework에 Basic Neural Network Subroutines(BNNS)를 추가하여,
//training이 아닌 inferencing을 위한 네트워크를 구축할 수 있도록 했다.
//그리고 2017년, Core ML과 Vision을 추가했다.
// • Core ML을 사용해 훈련된 모델을 앱에서 쉽게 사용할 수 있다.
// • Vision을 사용해, 얼굴, 얼굴 요소, 텍스트, 사각형, 바코드, 객체를 감지하는 Apple 모델에 쉽게 액세스할 수 있다.
//Vision 모델에서 image-analysis Core ML 모델을 래핑할 수 도 있다.
//이 두 framework는 Metal을 기반으로 하므로, 디바이스에서 효율적으로 실행된다(서버로 데이터를 보낼 필요 없다).




//Integrating a Core ML Model Into Your App
//이 프로젝트는 Places205-GoogLeNet 모델을 사용한다.
//Cafe, Keras, scikikit-learn 과 같은 기계 학습 도구를 사용해 모델을 만든 경우 Core ML 로 변환 할 수도 있다.
//https://developer.apple.com/documentation/coreml/converting_trained_models_to_core_ml

//Adding a Model to Your Project
//추가한 mlmodel 모델을 코드로도 볼 수 있다.
//GoogLeNetPlaces는 model 프로퍼티와 두 개의 prediction 메서드를 가지고 있다.
//GoogLeNetPlacesInput는 CVPixelBuffer type의 sceneImage 속성을 가지고 있다.
//Vision framework로 CVPixelBuffer type을 익숙한 type으로 변환할 수 있다.
//또, Vision frmaework는 GoogLeNetPlacesOutput 속성을 results type으로 변환하고, prediction 메서드를 관리한다.
//이렇게 Vision framework에서 다른 속성과 메서드를 관리하므로, 개발자는 model 속성만 사용해 모델을 사용할 수 있다.

