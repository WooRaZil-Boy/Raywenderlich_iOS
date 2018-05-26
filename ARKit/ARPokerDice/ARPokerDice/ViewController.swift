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

// MARK: - Game State

enum GameState: Int16 { //게임 상태의 열거형
    case detectSurface  // Scan playable surface (Plane Detection On)
    //ARKit은 주변을 파악하고 표면 감지하는 데 시간이 걸린다. 게임이 이 상태에 있는 동안, 플레이어는 테이블 같은 적당한
    //수평 표면을 스캔해야 한다. 제대로 감지됐다면 Start 버튼을 눌러 게임을 할 수 있고 상태가 변경된다. p.98
    case pointToSurface // Point to surface to see focus point (Plane Detection Off)
    //감지된 표면에서 포커스 커서를 볼 수 있다. 주사위가 던져질 목표지점을 표시한다. p.98
    case swipeToPlay    // Focus point visible on surface, swipe up to play
    //위쪽으로 스와이프하여 주사위를 던진다. p.99
}

class ViewController: UIViewController {
  
  // MARK: - Properties
  
  var trackingStatus: String = "" //상태를 알려주기 위한 문자열
  var statusMessage: String = ""
  var gameState: GameState = .detectSurface //게임의 상태 속성. default 상태
    var focusPoint:CGPoint! //레이 캐스팅에 사용할 화면상 위치.
  var focusNode: SCNNode! //포커스 노드
  var diceNodes: [SCNNode] = [] //주사위 노드들의 배열
  var diceCount: Int = 5 //주사위의 수를 나타내는 카운터
  var diceStyle: Int = 0 //스타일 전환에 사용할 index
  var diceOffset: [SCNVector3] = [SCNVector3(0.0,0.0,0.0),
                                  SCNVector3(-0.05, 0.00, 0.0),
                                  SCNVector3(0.05, 0.00, 0.0),
                                  SCNVector3(-0.05, 0.05, 0.02),
                                  SCNVector3(0.05, 0.05, 0.02)]
  //주사위의 위치 offset. AR로 주사위를 던질 때, 정확히 ARCamera 상의 위치에 생성하지 않는다.
  //위치를 현실적으로 보정해준다.
  
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
    diceStyle = diceStyle >= 4 ? 0 : diceStyle + 1
    //5가지 스타일을 반복한다.
  }
  
  @IBAction func resetButtonPressed(_ sender: Any) {
  }
  
  @IBAction func swipeUpGestureHandler(_ sender: Any) {
    guard let frame = sceneView.session.currentFrame else { return }
    //currentFrame은 ARScene의 캡쳐된 이미지, AR 카메라, 조명, 앵커, 특징점과 같은 정보를 가지고 있다.
    //세션의 가장 최근 ARScene 정보가 포함된 비디오 프레임 이미지
    
    for count in 0..<diceCount {
      throwDiceNode(transform: SCNMatrix4(frame.camera.transform),
                    offset: diceOffset[count])
      //카메라의 위치와 회전 정보를 행렬로 변환하여 주사위를 던진다.
    }
  }
  
  // MARK: - View Management
  
  override func viewDidLoad() {
    super.viewDidLoad()
    initSceneView()
    initScene()
    initARSession()
    loadModels()
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
  }
    
    @objc func orientationChanged() { //화면이 회전하면 focusPoint를 업데이트 해 줘야 한다.
        focusPoint = CGPoint(x: view.center.x, y: view.center.y + view.center.y * 0.25)
        //뷰의 y중심보다 25% 낮은 위치
    }
  
  // 치ARK: - Initialization
  
  func initSceneView() {
    sceneView.delegate = self
    sceneView.showsStatistics = true
    sceneView.debugOptions = [
      //ARSCNDebugOptions.showFeaturePoints,
      //ARSCNDebugOptions.showWorldOrigin,
      //SCNDebugOptions.showBoundingBoxes,
      //SCNDebugOptions.showWireframe
    ] //디버깅 옵션
    //• Feature points : Scene 전체에 보이는 작은 점들을 추가한다.
    //  디바이스의 위치와 방향을 정확하게 추적하는 데 사용된다.
    //• World origin : 세션을 시작한 곳의 R(X)G(Y)B(Z) 교차선을 나타낸다.
    //• Bounding boxes : 모든 3D 객체 주위에 상자 모양의 윤곽선을 보여 준다.
    //  SceneKit 객체 도형의 범위를 보여준다.
    //• Wireframe : Scene의 geometry를 표시한다. AR Scene에서 각 3D 객체의 표면에 있는 폴리곤 윤곽을 볼 수 있다.
    //  기하학적 모양이 얼마나 자세히 표시되는 지 확인할 수 있다.
    
    focusPoint = CGPoint(x: view.center.x, y: view.center.y + view.center.y * 0.25)
    //뷰의 y중심보다 25% 낮은 위치
    //레이 캐스팅에 사용할 화면 상의 위치를 정의한다. 일반적으로 화면의 중심이다.
    //하지만 여기에서 포커스 노드는 애니메이션이 추가되므로 중심보다 약간 아래의 위치에 추가해 준다.
    
    NotificationCenter.default.addObserver(self, selector: #selector(ViewController.orientationChanged), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    //화면 회전 시 알림을 트리거
  }
  
  func initScene() {
    let scene = SCNScene() //빈 Scene 생성
    scene.isPaused = false
    sceneView.scene = scene
    scene.lightingEnvironment.contents = "PokerDice.scnassets/Textures/Environment_CUBE.jpg"
    //전체적인 Scene의 조명을 Environment_CUBE.jpg로 설정
    scene.lightingEnvironment.intensity = 2
    //강도 2
  }
  
  func initARSession() {
    guard ARWorldTrackingConfiguration.isSupported else {
      //디바이스가 ARWorldTrackingConfiguration(6DOF)를 지원하는 지 여부
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
    config.planeDetection = .horizontal //표면을 탐지하기 위해 ARConfiguration에서 활성화해야 한다. 수평
    //감지된 모든 표면(여기서는 수평)에 대해 ARPlaneAnchor 인스턴스를 자동으로 생성한다.
    //renderer(_:didAdd:for) delegate가 호출되어 새로 추가된 앵커에 대해 알려준다.
    
    //Anchors
    //앵커는 움직이는 물위에서 선박의 위치를 유지한다. 마찬가지로 ARKit은 3D 콘텐츠에 첨부된 가상 앵커를 사용한다.
    //주요 목적은 플레이어가 주변을 움직일 때 관련된 실제 세계에 3D 콘텐츠의 위치를 유지하는 것이다.
    //ARAnchor 객체는 위치와 방향을 유지하는 변환을 포함하고 있다. 앵커는 보이는 요소가 아닌 ARKit에서 유지되는 객체이다.
    //기본적으로 ARKit은 ARAnchor와 SCNNode를 연결한다. 3D 콘텐츠를 해당 노드의 하위 노드로 추가하면 작업이 완료된다.
    //ARPlaneAnchor는 중심점, 방향, 표면 범위를 포함하는 추가 평면 정보와 함께 실제 변환(위치, 방향)을 포함한다.
    //이 정보를 사용하여 SCeneKit Plane 노드를 생성할 수 있다. p.101
    //cf. ARFaceAnchor도 있다.
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
  
  // MARK: - Load Models
  
  func loadModels() {
    let diceScene = SCNScene(
      named: "PokerDice.scnassets/Models/DiceScene.scn")! //Scene 로드하여 저장

    for count in 0..<5 { //주사위 수가 총 5개
      diceNodes.append(diceScene.rootNode.childNode(
        withName: "dice\(count)",
        recursively: false)!) //배열에 저장
        //Scene의 rootNode scene를 검색하여, dice0 부터 dice4까지 모든 노드를 찾는다.
        //해당 노드를 발견하면 diceNodes 배열에 추가한다.
        //recursively 매개변수를 true로 하면, 자식 노드의 하위 트리까지 검색한다.
        //false로 하면 해당 노드의 직접적인 자식만 검색
    }
    
    let focusScene = SCNScene(
      named: "PokerDice.scnassets/Models/FocusScene.scn")! //Scene 로드하여 저장
    focusNode = focusScene.rootNode.childNode(
      withName: "focus", recursively: false)! //포커스 노드 발견해서
    
    sceneView.scene.rootNode.addChildNode(focusNode) //SceneView에 자식노드로 추가한다.
  }
  
  // MARK: - Helper Functions
  
  func throwDiceNode(transform: SCNMatrix4, offset: SCNVector3) {
    //선택된 주사위 노드를 AR Scene로 복제하는 메서드
    let position = SCNVector3(transform.m41 + offset.x,
                              transform.m42 + offset.y,
                              transform.m43 + offset.z)
    //transform의 위치데이터를 벡터와 결합해 offset 위치를 만든다.
    
    let diceNode = diceNodes[diceStyle].clone() //선택된 주사위 노드의 복제 생성
    diceNode.name = "dice" //이름
    diceNode.position = position //위치 설정
    sceneView.scene.rootNode.addChildNode(diceNode)
    //복제된 주사위 노드가 AR Scene에 배치된다.
    diceCount -= 1 //diceCount 감소 시켜 주사위가 굴려졌을음 나타낸다.
  }
    
    func createARPlaneNode(planeAnchor: ARPlaneAnchor, color: UIColor) -> SCNNode {
        //앵커를 받아 Plane 요소를 추가한다.
        let planeGeometry = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        //extent로 검출된 평면의 너비와 길이를 가져올 수 있다.
        //앵커의 범위에 대한 지오메트리 평면(Editor에서 초록색으로 추가하던 객체)이 생성된다.
        
        let planeMaterial = SCNMaterial() //Material 생성
        planeMaterial.diffuse.contents = "PokerDice.scnassets/Textures/Surface_DIFFUSE.png"
        //Scene Editor로 설정하던 것을 코드로. 텍스처를 가져온다.
        planeGeometry.materials = [planeMaterial] //지오메트리에 텍스처를 입힌다.
        
        let planeNode = SCNNode(geometry: planeGeometry) //지오메트리로 plane 노드 생성
        planeNode.position = SCNVector3Make(planeAnchor.center.x, 0, planeAnchor.center.z)
        //앵커의 중심점을 기준으로 평면 노드의 위치 설정
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2, 1, 0, 0)
        //SCNPlane으로 생성된 지오메트리(Editor의 초록색 Plane)는 기본적으로 수직이다.
        //따라서 평면으로 배치하려면 x축을 기준으로 시계 방향으로 90도 회전해야 한다.
        //수직 앵커를 사용할 때는 이 줄을 생략할 수 있다.
        
        return planeNode
    }
    
    func updateARPlaneNode(planeNode: SCNNode, planeAchor: ARPlaneAnchor) {
        //기존의 plane 노드를 새로운 위치, 방향, 크기로 업데이트 하는 메서드
        let planeGeometry = planeNode.geometry as! SCNPlane //여기서는 수평 plane만 사용하므로
        planeGeometry.width = CGFloat(planeAchor.extent.x) //앵커 너비로 가로 업데이트
        planeGeometry.height = CGFloat(planeAchor.extent.z) //앵커 길이로 세로 업데이트
        
        planeNode.position = SCNVector3Make(planeAchor.center.x, 0, planeAchor.center.z)
        //앵커 중앙의 위치로 plane 노드의 위치를 업데이트한다.
    }
    
    func removeARPlaneNode(node: SCNNode) {
        //여러 Plane이 겹치는 경우가 있다.
        //이런 경우, ARKit은 감지된 여러 Plane을 여러 평면으로 병합할 수 있다.
        for childNode in node.childNodes { //해당 노드의 자식 노드들을 loop로 돌아서
            childNode.removeFromParentNode()
            //자식 노드들을 삭제한다.
        }
    }
    
    func updateFocusNode() {
        let results = self.sceneView.hitTest(self.focusPoint, types: [.existingPlaneUsingExtent])
        //해당 지점의 해당 타입의 실제 객체 또는 AR 앵커를 검색한다.
        //hitTest는 레이 캐스트를 수행한다. 매개변수로 광선을 발사할 곳의 스크린 위치와 찾고자하는 대상 유형을 입력한다.
        //.existingPlaneUsingExtent으로 plane 기반의 객체만 가져온다.
        //.featurePoints, .estimatedHorizontalPlane, .existingPlane 등을 사용할 수 있다.
        
        if results.count == 1 { //검색된 결과가 하나라면
            if let match = results.first { //해당 결과를 가져온다.
                let t = match.worldTransform //위치, 방향, 크기 정보가 포함된 worldTransform를 사용한다.
                
                self.focusNode.position = SCNVector3(x: t.columns.3.x, y: t.columns.3.y, z: t.columns.3.z)
                //변환 행렬을 기반으로 포커스 노드의 위치를 업데이트한다.
                //위치정보는 변환 행렬의 세 번째 열에서 찾을 수 있다.
                self.gameState = .swipeToPlay
            }
        } else { //검색 결과가 없다면
            self.gameState = .pointToSurface
            //표면을 감지하도록 gameState를 설정해 준다.
        }
    }
}

extension ViewController : ARSCNViewDelegate {
  //프로토콜 자체를 extension으로 관리해 주는 것이 좋다.
  //관련 기능을 유지하면서 깨끗하게 분리해 낸다. 가독성을 높여준다.
  
  // MARK: - SceneKit Management
  
  func renderer(_ renderer: SCNSceneRenderer,
                updateAtTime time: TimeInterval) {
    DispatchQueue.main.async {
//      self.statusLabel.text = self.trackingStatus
        self.updateStatus() //위의 코드 대체
        self.updateFocusNode() //포커스 노드 업데이트
    }
  }
    
  func updateStatus() {
    switch gameState { //현재 게임 상태
    case .detectSurface:
        statusMessage = "Scan entire table surface...\nHit START when ready!"
    case .pointToSurface:
        statusMessage = "Point at designated surface first!"
    case .swipeToPlay:
        statusMessage = "Swipe UP to throw!\nTap on dice to collect it again."
    }
    
    self.statusLabel.text = trackingStatus != "" ? "\(trackingStatus)" : "\(statusMessage)"
    //statusLabel에 상태를 표기한다. 필요한 경우 기존 메시지에 추가.
  }
  
  
  // MARK: - Session State Management
  
  func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
    //세션이 실행되는 동안 외부 상태 및 이벤트에 따라 트래킹 상태를 변경될 수 있다.
    //세션 상태가 변경될 때 마다 해당 메서드가 트리거 된다. 따라서 상태를 모니터링하기 좋은 장소이다.
    switch camera.trackingState { //ARCamera의 상태로 Switch
    case .notAvailable: //ARSession을 추적할 수 없는 경우
      trackingStatus = "Tacking:  Not available!"
    case .normal: //정상적인 상태
      trackingStatus = "Tracking: All Good!"
    case .limited(let reason): //ARSession을 추적할 수는 있지만, 제한적인 경우
      switch reason {
      case .excessiveMotion: //디바이스가 너무 빨리 움직여 정확한 정확한 이미지 위치를 트래킹 할 수 없는 경우
        trackingStatus = "Tracking: Limited due to excessive motion!"
      case .insufficientFeatures: //이미지 위치를 트래킹할 feature들이 충분하지 않은 경우
        trackingStatus = "Tracking: Limited due to insufficient features!"
      case .initializing: //세션이 트래킹 정보를 제공할 충분한 데이터를 아직 수집하지 못한 경우
        //새로 세션 시작하거나 구성 변경 시 일시적으로 발생한다.
        trackingStatus = "Tracking: Initializing..."
      case .relocalizing: //세션이 중단된 이후 재개하려고 시도 중인 경우
        trackingStatus = "Tracking: Relocalizing..."
      }
    }
  }
  
  // MARK: - Session Error Management
  
  func session(_ session: ARSession,
               didFailWithError error: Error) {
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
  
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        //감지된 모든 표면(여기서는 수평)에 대한 AR anchor가 자동으로 추가될 때 호출된다.
        //파라미터의 node는 세로운 SceneKit 노드로, ARAnchor 노드와 쌍을 이룬다.
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        //여기서는 ARPlaneAnchor 노드만 사용하므로 이외의 타입에 대해서는 그대로 반환한다.
        
        DispatchQueue.main.async { //메인 스레드에서만 UI 업데이트 등의 시각적 요소를 만들 수 있다.
            let planeNode = self.createARPlaneNode(planeAnchor: planeAnchor, color: UIColor.yellow.withAlphaComponent(0.5))
            //앵커의 정보를 색상과 함께 전달해 plane 노드를 생성한다.
            node.addChildNode(planeNode)
            //해당 노드를 ARKit 노드의 하위 노드로 추가된다.
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        //SceneKit 노드의 속성이 해당 앵커의 현제 상태와 일치하도록 업데이트해야 하는 경우 호출된다.
        //이전에 감지된 표면을 새 정보로 업데이트해야 할 경우 트리거 된다.
        //여기서 node는 이전에 추가한 기존 plane 노드이다.
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        //여기서는 ARPlaneAnchor 노드만 사용하므로 이외의 타입에 대해서는 그대로 반환한다.
        
        DispatchQueue.main.async { //메인 스레드에서만 UI 업데이트 등의 시각적 요소를 만들 수 있다.
            self.updateARPlaneNode(planeNode: node.childNodes[0], planeAchor: planeAnchor)
            //앵커 정보를 첫 번째 자식 노드와 함께 전달한다.
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        //노드가 제거되었을 때 트리거 된다.
        guard anchor is ARPlaneAnchor else { return }
        
        DispatchQueue.main.async {
            self.removeARPlaneNode(node: node) //노드를 삭제한다.
        }
    }
}

//A9 이상의 프로세서가 있는 실제 장치를 사용해야 한다.
//• iPhone SE
//• iPhone 6s 및 6s Plus
//• iPhone 7 및 7 Plus
//• iPad Pro (모든 크기의 1 세대 및 2 세대 : 9.7", 10.5" 및 12.9")
//• iPad (2017+ 모델)
//• iPhone 8 및 8 Plus
//• iPhone X




//ARKit을 사용하는 앱은 카메라에 대한 액세스가 반드시 있어야 한다.
//Info.plist의 Find Privacy - Camera Usage Description에서 설정할 수 있다.
//ARKit 템플릿으로 프로젝트를 생성하면, 자동으로 설정되어 있다.
//이 메시지는 카메라에 액세스 요청할 때 사용자에게 표시되는 문자열이다.

//SceneKit Asset Catalog는 .scnassets 확장자로 생성해 주면 된다.
//ARPokerDice group에서 right-click, Add Files to "ARPokerDice"... 선택

//SceneKit Scene File을 생성할 때, Group을 제대로 지정해 줘야 한다. .scnassets 확장자 내의 그룹인지 확인




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




//Adding 3D objects
//COLLADA등의 다른 3D 파일도 SceneKit으로 변환해서 사용할 수 있다.
//Editor ▸ Enable default lighting 으로 기본 조명을 활성화 한다.
//Editor ▸ Convert to SceneKit scene file format(.scn) 으로 변환한다.




//Shaders, materials and textures

//Lighting models (shaders)
//조명 모델에 따라 다양한 질감및 재료 효과를 생성한다. p.76
//• Constant : 주변 조명만 통합하는 평면 조명 모델
//• Lambert : 주변 및 확산 조명 통합
//• Blinn : 주변, 확산, 반사 조명 정보를 통합. Jim Blinn 공식 사용. 더 크고 부드러면 반사를 만든다.
//• Phong : 주변, 확산, 반사 조명 정보를 통합. Bui Tuong Phong 공식으로 반사 하이라이트 개선
//• Physical Based : 실제 조명 및 재료의 현실적인 추상화와 확산을 통합한다. 가장 최근에 추가된 모델이며 사실적이다.

//Materials
//물, 가죽, 나무, 암석 등의 물질을 구성한다.
//각 Material은 서로 다른 질감 레이어로 구성되며 각 레이어는 특정 색상, 질감, 효과를 생성하는 데 사용된다.

//Textures
//3D 객체에 저장된 좌표 정보를 사용하여 해당 객체를 감싸는 2D 이미지.
//텍스처는 서로 다른 레이어에 적용되며 각 레이어는 색상, 반사, 광택, 거칠기, 투명도 등 특정 속성을 정의하는 데에도 사용한다.
//결합시 다양한 속성이 실제와 같은 재질과 질감을 정의하는 데 사용된다.




//Physically based rendering (PBR)
//PBR은 가장 사실적인 3D 객체를 구현한다.

//Environment map
//Environment map 전에 Cube map을 이해하는 것이 좋다. 큐브 맵은 큐브와 마찬가지로 여섯 면으로 구성된다.
//일반적으로 큐브 맵은 반사 표면과 "스카이 박스"를 만드는데 사용한다. 스카이 박스는 3D 가상 환경에서 하늘과 다른 먼 배경을
//만드는 데 사용한다. p.78. SceneKit는 큐브 맵에 대한 다양한 패턴을 지원한다. 가장 일반적인 horizontal strip 패턴은
//6개의 동일한 크기의 텍스처 집합을 1:6 비율 이미지로 구성한다. p.79. 환경 맵은 반사도가 높은 곳에서는 reflection map과
//비슷하게 구현된다. 또한 PBR 객체에 조명 정보를 제공하여 사실적인 조명 환경을 제공한다.

//Diffuse map
//확산 맵은 3D 객체에 기본 색상을 제공한다. 조명과 기타 특수 효과에 관계없이 일반적으로 객체가 무엇인지를 정의한다.
//ex. 구를 지구로 정의. 알파 채널로 투명도를 지정할 수 있다. p.79

//Normal map
//조명 계산 중 물체 표면에 각 픽셀이 빛을 어떻게 휘게 하여 모양을 시뮬레이션 하는지 설명한다.
//간단히 말해 노멀 맵은 표면에 더 많은 폴리곤을 추가하지 않고도 표면을 더 울퉁불퉁하게 만들어 사실적인 구현을 한다.
//ex. 지구의 산맥, 해구, 평야등을 표현. p.80

//Height map
//높이 지도는 PBR 조명 모델의 일부는 아니다. 높이 정보를 정의하는 흑백 이미지로, 흰 색상은 객체에서 가장 높은 점으로
//렌더링 되고, 검정색은 가장 낮은 점으로 렌더링 된다. 높이 맵을 정의한 후, 노멀 맵으로 변환할 수 있다.
//http://bit.ly/1ELCePX 에서 높이 맵을 노멀 맵으로 변환할 수 있다.

//Occlusion map
//빛이 객체의 갈라진 틈 사이와 같은 좁은 구석까지 도달하는 것을 방지한다. 자연광의 특성을 모방한다. p.82

//Emission map
//모든 조명 및 음영 정보를 무시하여 발광 효과를 만든다. p.82
//빛을 어둡게 해야 효과가 뚜렷해 진다.

//Self-illumina1on map
//다른 모든 효과 후에 적용된다. 최종 결과를 색칠하거나 밝게 또는 어둡게 한다. p.83

//Displacement map
//노멀 맵이 픽셀 강도를 사용하여 매끄러운 표면에서 다양한 높이를 생성하는 경우,
//Displacement map은 픽셀 강도를 사용하여 실제 표면을 변경한다. p.83

//Metalness and roughness maps
//PBR의 주요 특징은 Metalness와 Roughness이다. p.84
//• Metalness : 금속적인 느낌. 반사도
//• Roughness : 거칠기. 무광. 광택

//Metalness map
//금속성을 나타낸다. 검은 색은 완전한 비금속 특성이고, 흰색은 완전한 금속 특성을 나타낸다. p.84

//Roughness map
//거칠기는 실제 표면의 미세한 디테일을 대략적으로 나타낸다. 검색은은 매우 거친 표면, 흰색은 매우 매끄러운 표면이다. p.85




//Applying environment textures
//Scene Graph에서 노드들의 계층정보를 볼 수 있고, Scene inspector에서 배경과 조명 설정을 해 준다.

//Applying 3D model textures
//Material inspector에서 여러 맵들과 재질 등을 설정해 줄 수 있다.
//노드를 복사 붙여 넣기한 경우, Unshare를 해줘야 설정이 공유 되지 않는다.




//Ray casting
//레이 캐스팅은 3D 물체와의 교차점을 찾고 있는 동안, 화면 중심(초점)에서 가상 Scene로 광선을 만들어 낸다. p.107
//광성이 평면과 교차하면 해당 교차 위치에 포커스 노드를 배치하면 된다.


