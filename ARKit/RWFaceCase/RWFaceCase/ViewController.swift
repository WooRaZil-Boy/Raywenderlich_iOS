/**
 * Copyright (c) 2018 Razeware LLC
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
import SceneKit
import ARKit
import ReplayKit

enum ContentType: Int {
  case none
  case mask
  case glasses
  case pig
}

class ViewController: UIViewController {

  // MARK: - Properties

  @IBOutlet var sceneView: ARSCNView!
  @IBOutlet weak var messageLabel: UILabel!
  
  @IBOutlet weak var recordButton: UIButton!

  var session: ARSession {
    return sceneView.session
  }

  var contentTypeSelected: ContentType = .none

  var anchorNode: SCNNode?
  var mask: Mask?
  var maskType = MaskType.zombie
  var glasses: Glasses?
  var pig: Pig?
    
  let sharedRecorder = RPScreenRecorder.shared()
  //ReplayKit에서 녹화/녹음을 담당하는 싱글톤 객체
  private var isRecording = false

  // MARK: - View Management

  override func viewDidLoad() {
    super.viewDidLoad()
    setupScene()
    createFaceGeometry()
    
    sharedRecorder.delegate = self //delegate 설정
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    UIApplication.shared.isIdleTimerDisabled = true
    //true로 해두면, 디바이스가 절전모드로 전환되지 않는다.
    resetTracking() //트래킹 재 시작
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)

    UIApplication.shared.isIdleTimerDisabled = false
    //iOS는 일정 시간 동안 사용자의 터치가 없으면 디바이스 화면을 끈다.
    //이 시간을 판단하는 것이 IdleTimer로, 화면을 터치할 때마다 초기화되고 지정된 시간이 되면 화면을 끈다.
    //항상 화면이 켜진 상태로 두려면 IdleTimer를 꺼야 한다(그때는 true로 설정하면 된다: viewDidAppear).
    sceneView.session.pause() //앱이 background로 전환될 때 세션을 중지시킨다.
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }

  override var prefersStatusBarHidden: Bool {
    return true
  }

  // MARK: - Button Actions

  @IBAction func didTapReset(_ sender: Any) {
    print("didTapReset") //사용자가 세션을 재설정하고자 할 때마다 버튼을 눌러 재설정할 수 있다.
    contentTypeSelected = .none //콘텐츠 타입 none으로 초기화
    resetTracking() //트래킹 재시작
  }

  @IBAction func didTapMask(_ sender: Any) {
    print("didTapMask")

    switch maskType { //마스크 타입을 바꿔준다.
    case .basic:
      maskType = .zombie
    case .painted:
      maskType = .basic
    case .zombie:
      maskType = .painted
    }

    mask?.swapMaterials(maskType: maskType) //바꾼 마스크 타입으로 마스크 재 생성

    contentTypeSelected = .mask//콘텐츠 타입 mask로 설정
    resetTracking() //트래킹 재시작
  }

  @IBAction func didTapGlasses(_ sender: Any) {
    print("didTapGlasses")
    contentTypeSelected = .glasses //콘텐츠 타입 glasses로 설정
    resetTracking() //트래킹 재시작
  }

  @IBAction func didTapPig(_ sender: Any) {
    print("didTapPig")
    contentTypeSelected = .pig //콘텐츠 타입 pig로 설정
    resetTracking() //트래킹 재시작
  }

  @IBAction func didTapRecord(_ sender: Any) {
    print("didTapRecord")
    
    guard sharedRecorder.isAvailable else {
        //ReplayKit 사용할 수 있는 지 여부 확인
        print("Recording is not available.")
        return
    }
    
    if !isRecording {
        startRecording()
    } else {
        stopRecording()
    }
  }
}

// MARK: - ARSCNViewDelegate

extension ViewController: ARSCNViewDelegate {

  // Tag: SceneKit Renderer
  func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
    //액션, 애니메이션, 물리 측정 등이 되기 전에 발생해야 하는 모든 업데이트를 수행하도록 한다.
    //SceneKit은 SCNView 객체가 일시 중지되지 않는 한 한 프레임당 여러 번 이 메서드를 호출한다.
    //여기에 렌더링 루프를 추가하면 계속해서 Scene에 반영된다(게임에서도!).
    //즉, Scene를 렌더링하는 데 사용하는 표현 노드의 계층 구조를 즉시 업데이트 한다.
    guard let estimate = session.currentFrame?.lightEstimate else {
        //configuration에서 isLightEstimationEnabled 속성을 true로 하면,
        //캡쳐하는 모든 객체에 대해 Scene 조명 정보를 제공한다. 이 정보는 각 ARFrame의 lightEstimate에 저장된다.
        //이 데이터를 사용하면, 환경 조명을 일치시켜 마스크를 더욱 사실적으로 보이게 할 수 있다.
      return
    }

    let intensity = estimate.ambientIntensity / 1000.0
    //ambientIntensitysms Scene 전체에서 주변 조명의 예상 광도(루멘). 1000의 값은 중립적인 빛이다.
    sceneView.scene.lightingEnvironment.intensity = intensity //광도를 재 설정해 준다.

    let intensityStr = String(format: "%.2f", intensity)
    let sceneLighting = String(format: "%.2f",
                               sceneView.scene.lightingEnvironment.intensity)

    print("Intensity: \(intensityStr) - \(sceneLighting)")
  }

  // Tag: ARNodeTracking
  func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
    //Scene에 추가된 각 앵커에 대해 호출되고 해당 AR앵커에 대해 만들어진 SceneKit노드에서 전달된다.
    //SceneKit 노드(새 ARAnchor)가 Scene에 추가되면 트리거 된다.
    anchorNode = node //앵커 노드
    setupFaceNodeContent() //마스크 추가
  }

  // Tag: ARFaceGeometryUpdate
  func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
    //마스크를 anchorNode의 자식으로 추가하면, 앵커노드가 자동으로 사용자 얼굴의 위치와 방향을 추적한다.
    //하지만 얼굴 표정과 같은 업데이트는 이루어지지 않는데, face mesh geometry를 사용하여 쉽게 추적할 수 있다.
    //update(from:)에서 사용자의 표정을 추적할 수 있다. 이 메서드는 ScenenKit 지오메트리를 변형하여 face mesh와 일치하도록 한다.
    //하지만 여기에서는 앵커 업데이트 될때마다 마스크를 업데이트 한다.
    
    //앵커가 업데이트 될 때마다 뷰가 자동으로 이 메서드를 호출한다.
    guard let faceAnchor = anchor as? ARFaceAnchor else { return }
    updateMessage(text: "Tracking your face.")

    switch contentTypeSelected {
    case .none: break
    case .mask:
      mask?.update(withFaceAnchor: faceAnchor)
    case .glasses:
      glasses?.update(withFaceAnchor: faceAnchor)
    case .pig:
      pig?.update(withFaceAnchor: faceAnchor)
    }
  }

  // Tag: ARSession Handling
  func session(_ session: ARSession, didFailWithError error: Error) {
    print("** didFailWithError")
    updateMessage(text: "Session failed.")
  }

  func sessionWasInterrupted(_ session: ARSession) {
    print("** sessionWasInterrupted")
    updateMessage(text: "Session interrupted.")
  }

  func sessionInterruptionEnded(_ session: ARSession) {
    print("** sessionInterruptionEnded")
    updateMessage(text: "Session interruption ended.")
  }
}

// MARK: - Private methods

private extension ViewController {

  // Tag: SceneKit Setup
  func setupScene() {
    // Set the view's delegate
    sceneView.delegate = self

    // Show statistics such as fps and timing information
    sceneView.showsStatistics = true

    // Setup environment
    sceneView.automaticallyUpdatesLighting = true /* default setting */
    sceneView.autoenablesDefaultLighting = false /* default setting */
    sceneView.scene.lightingEnvironment.intensity = 1.0 /* default setting */
    //이 기본값들을 변경하여, 마스크를 좀 더 사실적으로 보이게 할 수 있다.
  }

  // Tag: ARFaceTrackingConfiguration
  func resetTracking() {
    //얼굴 추적을 위해서는 ARFaceTrackingConfiguration을 사용해야 한다.
    //이전까지는 AROrientationTrackingConfiguration이나 ARWorldTrackingConfiguration를 사용했다.
    guard ARFaceTrackingConfiguration.isSupported else {
      updateMessage(text: "Face Tracking Not Supported.")
      return
    }

    updateMessage(text: "Looking for a face.")

    let configuration = ARFaceTrackingConfiguration() //기본 얼굴 인식 설정
    configuration.isLightEstimationEnabled = true /* default setting */ //조명 분석 여부
    //캡쳐하는 모든 객체에 대해 Scene 조명 정보를 제공한다. 이 정보는 각 ARFrame의 lightEstimate에 저장된다.
    //이 데이터를 사용하면, 환경 조명을 일치시켜 마스크를 더욱 사실적으로 보이게 할 수 있다.
    configuration.providesAudioData = false /* default setting */ //오디오 캡쳐 여부

    session.run(configuration, options: [.resetTracking, .removeExistingAnchors]) //세션 시작
    //해당 옵션은 세션이 시작될 때마다 트래킹을 재설정하고, 기존 앵커를 모두 제거한다.
  }

  // Tag: CreateARSCNFaceGeometry
  func createFaceGeometry() {
    updateMessage(text: "Creating face geometry.")

    let device = sceneView.device!  //Metal Device 사용
    //이게 원본 코드인데 오류 나는 경우도 있음
    
//        var device: MTLDevice!
//        device = MTLCreateSystemDefaultDevice()

    let maskGeometry = ARSCNFaceGeometry(device: device)! //ARSCNFaceGeometry 초기화
    mask = Mask(geometry: maskGeometry, maskType: maskType) //해당 마스크 타입으로 마스크 생성
    
    let glassesGeometry = ARSCNFaceGeometry(device: device)! //ARSCNFaceGeometry 초기화
    glasses = Glasses(geometry: glassesGeometry) //해당 지오메트리로 안경 생성
    
    let pigGeometry = ARSCNFaceGeometry(device: device)! //ARSCNFaceGeometry 초기화
    pig = Pig(geometry: pigGeometry) //해당 지오메트리로 돼지 생성
  }

  // Tag: Setup Face Content Nodes
  func setupFaceNodeContent() {
    //마스크 노드를 앵커 노드에 추가한다.
    guard let node = anchorNode else { return }

    node.childNodes.forEach { $0.removeFromParentNode() }
    //앵커 노드의 자식 노드 제거(이전 마스크 내용을 제거한다).

    switch contentTypeSelected {
    case .none: break
    case .mask:
      if let content = mask {
        node.addChildNode(content)
        //앵커에 해당 마스크 추가
        //앵커에 자식으로 추가하기 때문에 앵커노드로 표시되는 사용자의 얼굴을 자동으로 추적한다.
      }
    case .glasses:
      if let content = glasses {
        node.addChildNode(content)
        //앵커에 안경 추가
        //앵커에 자식으로 추가하기 때문에 앵커노드로 표시되는 사용자의 얼굴을 자동으로 추적한다.
      }
    case .pig:
      if let content = pig {
        node.addChildNode(content)
        //앵커에 돼지 추가
        //앵커에 자식으로 추가하기 때문에 앵커노드로 표시되는 사용자의 얼굴을 자동으로 추적한다.
      }
    }
  }

  // Tag: Update UI
  func updateMessage(text: String) {
    //UI를 업데이트하는 작업은 메인 스레드에서 실행되어야 한다.
    DispatchQueue.main.async {
      self.messageLabel.text = text
    }
  }
}

// MARK: - RPPreviewViewControllerDelegate (ReplayKit)
extension ViewController: RPPreviewViewControllerDelegate, RPScreenRecorderDelegate {
    //ReplayKit의 delegate
    
    // RPPreviewViewControllerDelegate methods
    func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
        print("previewControllerDidFinish")
        dismiss(animated: true) //편집 뷰를 닫는다.
    }
    
    // RPScreenRecorderDelegate methods
    func screenRecorder(_ screenRecorder: RPScreenRecorder, didStopRecordingWith previewViewController: RPPreviewViewController?, error: Error?) {
        //오류 혹은 사용불가로 recording이 중단 되면 이 메서드가 호출된다.
        guard error == nil else {
            print("There was an error recording: \(String(describing: error?.localizedDescription))")
            self.isRecording = false
            return
        }
    }
    
    func screenRecorderDidChangeAvailability(_ screenRecorder: RPScreenRecorder) {
        //recording 가능 / 불가능 상태가 변경되면 호출된다.
        recordButton.isEnabled = sharedRecorder.isAvailable
        //ReplayKit을 사용할 수 있으면 recordButton도 사용 가능하도록 설정한다.
        if !recordButton.isEnabled {
            self.isRecording = false
        }
        
        // Update the title in code
        if sharedRecorder.isAvailable { //상태에 따른 UI 업데이트
            DispatchQueue.main.async {
                self.recordButton.setTitle("[ RECORD ]", for: .normal)
                self.recordButton.backgroundColor = UIColor(red: 0.0039,
                                                            green: 0.5882,
                                                            blue: 1, alpha: 1.0)
            }
        } else {
            DispatchQueue.main.async {
                self.recordButton.setTitle("[ RECORDING DISABLED ]", for: .normal)
                self.recordButton.backgroundColor = UIColor.red
            }
        }
    }
    
    // Private functions
    private func startRecording() {
        self.sharedRecorder.isMicrophoneEnabled = true
        //true로 설정하면, 처음 사용 시에 마이크 사용 권한에 대한 alert을 띄운다.
        
        sharedRecorder.startRecording(handler: { error in
            //recording 시작 //startRecording은 RPPreviewViewController를 사용하여 데이터를 처리한다.
            //startCapture(handler:completionHandler:)을 사용할 수도 있다.
            guard error == nil else { //에러
                print("There was an error starting the recording: \(String(describing: error?.localizedDescription))")
                return
            }
            
            //정상작동
            print("Started Recording Successfully")
            self.isRecording = true //recording 중
            
            DispatchQueue.main.async { //UI 업데이트
                self.recordButton.setTitle("[ STOP RECORDING ]", for: .normal)
                self.recordButton.backgroundColor = UIColor.red
            }
        })
    }
    
    func stopRecording() {
        self.sharedRecorder.isMicrophoneEnabled = false
        //다시 false(기본 설정)으로 바꾼다.
        
        sharedRecorder.stopRecording(handler: { previewViewController, error in
            //recording 중단. //startRecording의 역이다.
            guard error == nil else { //에러
                print("There was an error stopping the recording: \(String(describing: error?.localizedDescription))")
                return
            }
            
            //정상작동
//            if let unwrappedPreview = previewViewController {
//                unwrappedPreview.previewControllerDelegate = self //delegate 설정
//                self.present(unwrappedPreview, animated: true, completion: {})
//            }
            
            //recording 후 바로 편집화면으로 가기 전에 사용자가 삭제할 것인지 편집화면으로 갈 것인지 선택하도록 변경
            let alert = UIAlertController(title: "Recording Complete", message: "Do you want to preview/edit your recording or delete it?", preferredStyle: .alert)
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: { (action: UIAlertAction) in
                self.sharedRecorder.discardRecording(handler: { () -> Void in
                    //삭제
                    print("Recording deleted.")
                })
            })
            let editAction = UIAlertAction(title: "Edit", style: .default, handler: { (action: UIAlertAction) -> Void in
                if let unwrappedPreview = previewViewController {
                    unwrappedPreview.previewControllerDelegate = self
                    self.present(unwrappedPreview, animated: true, completion: {})
                }
            })
            
            alert.addAction(editAction)
            alert.addAction(deleteAction)
            self.present(alert, animated: true, completion: nil)
        })
        
        //recording이 완료되었으므로 다시 기본 상태로 UI와 변수를 업데이트 한다.
        self.isRecording = false
        DispatchQueue.main.async {
            self.recordButton.setTitle("[ RECORD ]", for: .normal)
            self.recordButton.backgroundColor = UIColor(red: 0.0039, green: 0.5882, blue: 1, alpha: 1.0) /* #0196ff */
        }
    }
}

//ARKit for face-based AR
//ARKit은 TrueDepth 전면 카메라를 사용하여 얼굴 추적을 할 수 있다. 현재는 iPhoneX가 이 카메라가 장착된 유일한 장치이다.
//ARKit의 얼굴 추적은 사람 얼굴만 추적하며, 네 가지 기본 기능이 포함되어 있다.
//• Face detection and tracking(얼굴 탐지 및 추적) : 초당 60프레임 재생 빈도로 실시간 얼굴 탐지 및 추적
//• Real-time facial expression tracking(실시간 표정 추적) : 50개 이상의 특정 표정을 실시간으로 추적
//• Font color image, front depth image : 색상 픽셀 버퍼와 image의 depth를 캡쳐한다.
//• Light estimation : 얼굴 기반 AR 프로그램을 사용하여 감지된 얼굴의 방향과 조명을 측정할 수 있다.




//Detecting the user’s face
//얼굴 추적 세션이 실행 중이고, 카메라가 얼굴을 감지하면 ARFaceAnchor객체가 앵커 목록에 자동으로 추가된다.
//그 후 앵커를 사용하여 위치 및 방향과 같은 가상 콘텐츠에 대한 다양한 세부 정보를 얻을 수 있다.
//두 개 이상의 얼굴이 감지되면, 가장 확실한 하나의 얼굴을 사용한다. 좌표계는 오른손 기준이며 미터 단위이다. p.298
//이 좌표계는 x가 사용자의 오른쪽에 있음을 의미한다. 실제 세계에서 오른쪽은 사용자의 왼쪽이다.




//Getting started with ReplayKit
//iOS 9에서 처음 나온 ReplayKit은 앱에 화면 녹화 기능을 제공한다.
//ReplayKit을 사용하면 두 개의 ReplayKit API를 사용해 앱에서 오디오, 비디오, 마이크 녹화 및 녹음을 할 수 있다.
//• RPScreenRecorder : 직접 recording을 하는 싱글톤. 모든 앱은 이 클래스의 shared instance에 액세스할 수 있다.
//• RPPreviewViewController : recoding 완료 후 편집하거나 공유하는 데 사용하는 뷰 컨트롤러
//2017년 발표된 ReplayKit 2에서는 다음과 같은 기능이 추가되었다.
//• iOS screen record and broadcast : iOS 화면을 recoding한다. 시스템 UI를 제외한 모든 화면을 가져올 수 있다.
//  디바이스에서 바로 broadcasting도 가능하다.
//• Broadcast pairing : 라이브 스트리밍을 앱에 통합할 수 있다.
//• Fast camera switching : 전 / 후면 카메라 사이에서 피드를 전환할 수 있다.
//• In-app screen capture : 앱에서 직접 스크린을 캡쳐. 오디오, 비디오, 마이크에 직접 액세스할 수 있다.




//How does ReplayKit work?
//ReplayKit의 전체적인 로직은 p.344. 앱에서 RPScreenRecorder로 replay daemon과 통신하고
//하위 수준의 비디오 및 오디오 서비스와 통신을 한다. 거기서 상황이 인코딩되고 ReplayKit에서만 액세스 할 수 있는
//동영상 파일로 전송된다. 이 후, RPPreviewViewController 인스턴스에서 편집, 미리보기, 공유 등을 할 수 있다.



//How does ReplayKit 2 work?
//ReplayKit과 거의 비슷하며 전체적인 로직은 p.345. 가장 큰 차이점은 녹화한 오디오/비디오 샘플이
//RPPreviewViewController를 통하지 않고 우회하여 앱으로 직접 전송된다.


