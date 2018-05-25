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

class ViewController: UIViewController {
  
  // MARK: - Properties
    var trackingStatus: String = "" //상태를 알려주기 위한 문자열
  
  // MARK: - Outlets
  
  @IBOutlet var sceneView: ARSCNView!
    //ARSCNView는 카메라의 라이브 배경 이미지 위에 3D scene 을 오버레이할 수 있다.
    //ARKit과 SceneKit 간의 완벽한 통합을 제공한다.
    
    //ARSCNView는 기본적으로 SceneKit 뷰이다. 여기에는 ARKit의 모션 추적 및 이미지 처리를 담당하는 ARSession
    //객체가 포함된다. 이것은 세션 기반으로 ARSession을 생성 한 다음 실행하여 AR Tracking 프로세스를 시작해야 한다.
    
    //SpriteKit과 ARKit을 통합한 ARSKView도 있다. 2D SpriteKit 컨텐츠를 사용하는 경우 사용한다.
  @IBOutlet weak var statusLabel: UILabel!
  @IBOutlet weak var startButton: UIButton!
  @IBOutlet weak var styleButton: UIButton!
  @IBOutlet weak var resetButton: UIButton!
  
  // MARK: - Actions
  
  @IBAction func startButtonPressed(_ sender: Any) {
  }
  
  @IBAction func styleButtonPressed(_ sender: Any) {
  }
  
  @IBAction func resetButtonPressed(_ sender: Any) {
  }
  
  // MARK: - View Management
  
  override func viewDidLoad() {
    super.viewDidLoad()
    initSceneView()
    initScene()
    initARSession()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    print("*** ViewWillAppear()")
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    print("*** ViewWillDisappear()")
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    print("*** DidReceiveMemoryWarning()")
  }
  
  override var prefersStatusBarHidden: Bool {
    return true
    //true로 하면, statusBar를 가린다.
  }
  
  // MARK: - Initialization
  
  func initSceneView() {
    sceneView.delegate = self
    sceneView.showsStatistics = true
    sceneView.debugOptions = [ ARSCNDebugOptions.showFeaturePoints,
                               ARSCNDebugOptions.showWorldOrigin,
                               SCNDebugOptions.showBoundingBoxes,
                               SCNDebugOptions.showWireframe ] //디버깅 옵션
    //• Feature points : Scene 전체에 보이는 작은 점들을 추가한다.
    //  디바이스의 위치와 방향을 정확하게 추적하는 데 사용된다.
    //• World origin : 세션을 시작한 곳의 R(X)G(Y)B(Z) 교차선을 나타낸다.
    //• Bounding boxes : 모든 3D 객체 주위에 상자 모양의 윤곽선을 보여 준다.
    //  SceneKit 객체 도형의 범위를 보여준다.
    //• Wireframe : Scene의 geometry를 표시한다. AR Scene에서 각 3D 객체의 표면에 있는 폴리곤 윤곽을 볼 수 있다.
    //  기하학적 모양이 얼마나 자세히 표시되는 지 확인할 수 있다.
  }
  
  func initScene() {
//    let scene = SCNScene(named: "art.scnassets/ship.scn")! //default 비행기
    let scene = SCNScene(named: "PokerDice.scnassets/SimpleScene.scn")! //지구
    scene.isPaused = false

    sceneView.scene = scene
  }
  
  func initARSession() {
    guard ARWorldTrackingConfiguration.isSupported else {
        //디바이스가 ARWorldTrackingConfiguration(6DOF)를 지원하는 지 여부.
        print("*** ARConfig: AR World Tracking Not Supported")
        
        return
    }
    
    let config = ARWorldTrackingConfiguration() //ARWorldTrackingConfiguration 인스턴스 생성
    //AR session을 시작하기 전에 AR session configuration을 먼저 만들어야 한다.
    //AR session configuration은 장치가 있는 실제 세계와 가상 콘텐츠가 있는 3D 세계 사이의 연결을 설정한다.
    config.worldAlignment = .gravity //worldAlignment 속성은 가상 콘텐츠를 매핑하는 방법을 결정한다.
    //1. gravity : 콘텐츠를 중력에 평행한 y좌표 축에 설정한다. y축은 항상 실제 공간에서 위쪽을 향하게 된다.
    //  또한 장치의 초기 위치를 좌표의 원점으로 사용한다. AR Sessio이 시작되는 순간 실제 공간에서의 장치 위치이다.
    //2. gravityAndHeading : gravity와 같이 콘텐츠를 중력에 평행한 y좌표 축에 설정한다. 또한,
    //  x축이 서쪽에서 동쪽으로, z축이 북쪽에서 남쪽으로 지정된다. p.62
    //  장치의 초기 위치를 원점으로 사용한다. ex. 나침반
    //3. camera : 디바이스의 방향과 위치를 원점으로 사용한다.
    config.providesAudioData = false
    //AR Session이 오디오를 캡쳐할지 여부.
    //다른 속성인 isLightEstimationEnabled(조명)도 있다.
    
    sceneView.session.run(config) //AR Session 시작
    //6DOF로 트래킹 데이터를 수집을 시작한다.
    
    
    
    
    //Controlling an AR session
    //AR Session을 제어하는 방법
    //• Pausing : ARSession.pause()으로 AR Session 트래킹을 일시 중지한다. ex. 다른 앱으로 전환 시
    //• Resuming : ARSession.run()으로 일시 중지된 세션을 다시 시작한다. 이전의 Config를 그대로 사용한다.
    //• Updating : ARSession.run(ARSessionConfig)으로 Config를 업데이트한다.
    //  ex. 버튼을 누를 때에만 오디오 샘플링 활성화
    //• Resetting : ARSession.run(_ : options :)으로 세션을 재시작한다. 이전 세션의 정보가 삭제된다.
  }
}

extension ViewController : ARSCNViewDelegate {
    //프로토콜 자체를 extension으로 관리해 주는 것이 좋다.
    //관련 기능을 유지하면서 깨끗하게 분리해 낸다. 가독성을 높여준다.
  
  // MARK: - SceneKit Management
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        //delegate에게 actions, animations, physics 전에 해야 하는 업데이트를 실행하도록 한다.
        DispatchQueue.main.async { //UI 업데이트 시에는 메인 스레드에서 처리해야 한다.
            self.statusLabel.text = self.trackingStatus
        }
    }
  
  // MARK: - Session State Management
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        //세션이 실행되는 동안 외부 상태 및 이벤트에 따라 트래킹 상태를 변경될 수 있다.
        //세션 상태가 변경될 때 마다 해당 메서드가 트리거 된다. 따라서 상태를 모니터링하기 좋은 장소이다.
        switch camera.trackingState {
            //ARCamera의 상태로 Switch
        case .notAvailable:
            //ARSession을 추적할 수 없는 경우
            trackingStatus = "Tracking:  Not available!"
        case .normal:
            //정상적인 상태
            trackingStatus = "Tracking: All good!"
        case .limited(let reason):
            //ARSession을 추적할 수는 있지만, 제한적인 경우.
            switch reason {
            case .excessiveMotion:
                //디바이스가 너무 빨리 움직여 정확한 정확한 이미지 위치를 트래킹 할 수 없는 경우
                trackingStatus = "Tracking: Limited due to excessive motion!"
            case .insufficientFeatures:
                //이미지 위치를 트래킹할 feature들이 충분하지 않다.
                trackingStatus = "Tracking: Limited due to insufficient features!"
            case .initializing:
                //세션이 트래킹 정보를 제공할 충분한 데이터를 아직 수집하지 못한 경우
                //새로 세션 시작하거나 구성 변경 시 일시적으로 발생한다.
                trackingStatus = "Tracking: Initializing..."
            case .relocalizing:
                //세션이 중단된 이후 재개하려고 시도 중이다.
                trackingStatus = "Tracking: Relocalizing..."
            }
        }
    }
  
  // MARK: - Session Error Managent
    func session(_ session: ARSession, didFailWithError error: Error) {
        //delegate에게 오류로 세션이 중지될 때 알려 준다.
        trackingStatus = "AR Session Failure: \(error)"
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        //세션이 중단 되기 전에 이 메서드가 먼저 트리거 된다. 여기서 필요한 일부 설정을 저장하고 오류 처리할 수 있다.
        //주로 앱이 백그라운드로 가거나, 많은 앱들이 실행 중인 경우 세션이 중단되는 경우가 발생한다.
        trackingStatus = "AR Session Was Interrupted!"
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        //세션 재시작. 이전 interruption이 종료될 때 트리거 된다.
        //세션 트래킹을 재설정하여 모든 것이 정상적으로 다시 작동하는 지 확인하는 것이 좋다.
        trackingStatus = "AR Session Interruption Ended"
    }
  
  // MARK: - Plane Management
  
}

//앱이 시작되면 ARKit은 공간에서의 디바이스의 현재 위치를 앵커로 사용한다.
//그 후, SceneKit을 로드하고 해당 scene 을 증강현실 공간에 배치한다.

//SceneKit은 앱의 모든 그래픽 및 오디오 콘텐츠를 만들고 관리할 수 있는 그래픽 프레임워크이다.
//art.scnassets에는 Scene, Texture, 3D Model, Animation, Sound effect 같은 다양한 Asset을 저장할 수 있다.

//Xcode의 AR 템플릿은 UI요소를 지원하지 않기 때문에 스토리보드에서 추가해 줘야 한다.
//스토리보드에서 ARSCNView 위에 UI객체를 삽입하면, 해당 UI로 대체되어 버린다.
//따라서 UIView가 자식으로 ARSCNView를 가지도록 계층 구조를 정리해 주는 것이 좋다.

//Auto Layout를 설정할 때 아이폰 X의 notch를 고려해야 한다. Safe Area로 맞춰주는 것이 좋다.




//Creating the configuration
//AR session을 시작하기 전에 AR session configuration을 먼저 만들어야 한다.
//AR session configuration은 장치가 있는 실제 세계와 가상 콘텐츠가 있는 3D 세계 사이의 연결을 설정한다.
//두 가지 유형의 configuration이 있다.
//• AROrientationTrackingConfiguration : for three degrees. 3DOF라 한다.
//• ARWorldTrackingConfiguration : for six degrees. 6DOF라 한다.

//3DOF
//3DOF는 각각 X, Y, Z 축으로 회전하는 Pitch, Roll, Yaw를 트래킹한다. p.60
//AROrientationTrackingConfiguration에서 사용한다.

//6DOF
//6DOF는 3DOF와 같이 Pitch, Roll, Yaw를 트래킹한다.
//또한, 각각 X, Y, Z 축에 평행하게 이동하는 Sway, Heave, Surge를 사용해 3D 공간의 장치 이동을 추적한다.

