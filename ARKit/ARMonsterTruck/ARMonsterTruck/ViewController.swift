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
import CoreMotion //모션을 통해 트럭에 움직임을 준다. //모션 및 환경 관련 데이터 액세스
//가속도, 자이로 스코프, 만보계, 자력계, 기압계 등의 정보를 포함한다.

// MARK: - Game State
enum GameState: Int16 {
  case detectSurface //ARKit이 시작되고 수평면을 감지하는 동안의 상태
  case hitStartToPlay //ARKit이 수평면을 감지하고 초점 커서가 교차
  //이 시점에서 초점 커서가 보이고 플레이어에게 적합한 표면이 감지되었음을 알려 게임 시작이 준비되었음을 알려준다.
  case playGame //게임이 시작된 상태. 플레이어가 적당한 표면을 선택했고, 트럭이 커서 위치에 나타난다.
  //트럭을 움직이거나 조종할 수 있다. 게임을 재설정하면 .detectSurface로 돌아간다.
}

class ViewController: UIViewController {
  
  // MARK: - Properties
  var trackingStatus: String = ""
  var statusMessage: String = ""
  var gameState: GameState = .detectSurface
  var focusPoint: CGPoint!
  var focusNode: SCNNode!
  var groundNode: SCNNode! //무한 지면
  
  //트럭 노드들
  var truckNode: SCNNode!
  var wheelFLNode: SCNNode!
  var wheelFRNode: SCNNode!
  var wheelRLNode: SCNNode!
  var wheelRRNode: SCNNode!
  
  //Wheel physics type
  let wheelRadius: CGFloat = 0.04 //바퀴의 외형 반경
  let wheelFrictionSlip: CGFloat = 0.9 //마찰. 바퀴와 접촉하는 다른 표면과의 트랙션
  let suspensionMaxTravel: CGFloat = 4.0
  //바퀴가 연결 지점 기준으로 위 아래로 움직일 수 있는 최대 거리. 단위는 cm
  let suspensionMaxForce: CGFloat = 100 //바쿼와 차량 사이의 서스펜션 최대 힘. 단위는 N
  let suspensionRestLength: CGFloat = 0.08 //서스펜션의 Rest 길이. 단위는 m
  let suspensionDamping: CGFloat = 2.0 //서스펜션 진동을 제한하는 비율
  let suspensionStiffness: CGFloat = 2.0 //바쿼와 차량 사이의 스프링 계수
  let suspensionCompression: CGFloat = 4.0
  //서스펜션이 압축 된 후 정지 길이로 돌아갈 때 속도의 제한 계수
    
  var physicsVehicle: SCNPhysicsVehicle! //Body와 Wheel을 합칠 차량 물리 객체
  
  var isThrottling = false //터치 입력을 사용해 플레이어가 트럭을 조정 중임을 나타내는 변수
  var engineForce: CGFloat = 0 //조정 시에 엔진에 가해지는 힘의 양
  let defaultEngineForce: CGFloat = 10.0 //조정 시 적용할 엔진 힘의 기본 값
    
  var brakingForce: CGFloat = 0 //브레이크
  let defaultBrakingForce: CGFloat = 0.01 //트럭이 조정되지 않을 때 바퀴에 적용될 브레이크의 기본양
    
  let motionManager = CMMotionManager() //CoreMotion의 인스턴스. 모션 데이터를 얻는 데 사용한다.
  let steeringClamp: CGFloat = 0.6 //차량을 제어하기 위해 앞 바퀴에 적용되는 각도
  var steeringAngle: CGFloat = 0 //각도를 조정하여 값이 오버되는 것을 방지한다.
    
  var maximumSpeed: CGFloat = 2.0 //속도 제한 //단위는 시속 km
  
  // MARK: Outlets
  @IBOutlet var sceneView: ARSCNView!
  @IBOutlet var statusLabel: UILabel!
  @IBOutlet var startButton: UIButton!
  @IBOutlet var resetButton: UIButton!
  
  // MARK: Actions
  @IBAction func startButtonPressed(_ sender: Any) {
    self.startGame()
  }
  
  @IBAction func resetButtonPressed(_ sender: Any) {
    self.resetGame()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.initSceneView()
    self.initScene()
    self.initARSession()
    self.loadModels()
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
  
  override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    return .landscapeRight
  }
  
  // MARK: Init Functions
  
  func initSceneView() {
    sceneView.delegate = self
    sceneView.automaticallyUpdatesLighting = false
    //sceneView.showsStatistics = true
    //sceneView.preferredFramesPerSecond = 60
    //sceneView.antialiasingMode = .multisampling2X
    sceneView.debugOptions = [
      //ARSCNDebugOptions.showFeaturePoints,
      //ARSCNDebugOptions.showWorldOrigin,
      //SCNDebugOptions.showPhysicsShapes,
      //SCNDebugOptions.showBoundingBoxes
    ]
    
    focusPoint = CGPoint(x: view.center.x, y: view.center.y + view.center.y * 0.25)
  }
  
  func initScene() {
    let scene = SCNScene()
    scene.lightingEnvironment.contents = "MonsterTruck.scnassets/Textures/Environment_CUBE.jpg"
    scene.lightingEnvironment.intensity = 4
    //scene의 조명 설정. 여기서 설정하는 조명은 최종 장면에서 플레이어가 볼 것이다.
    //모든 PBR 기반 텍스처 모델에서 중요한 설정이다.
    scene.physicsWorld.speed = 1
    scene.isPaused = false
    sceneView.scene = scene
  }
  
  func initARSession() {
    
    guard ARWorldTrackingConfiguration.isSupported else {
      print("*** ARConfig: AR World Tracking Not Supported")
      return
    }
    
    let config = ARWorldTrackingConfiguration()
    config.isLightEstimationEnabled = true
    config.planeDetection = .horizontal
    config.worldAlignment = .gravity
    config.providesAudioData = false
    sceneView.session.run(config)
  }
  
  func resetARSession() {
    let config = sceneView.session.configuration as! ARWorldTrackingConfiguration
    config.planeDetection = .horizontal
    sceneView.session.run(config,
                          options: [.resetTracking,
                                    .removeExistingAnchors])
  }
  
  func suspendARPlaneDetection() {
    let config = sceneView.session.configuration as! ARWorldTrackingConfiguration
    config.planeDetection = []
    sceneView.session.run(config)
  }
  
  
  // MARK: Helper Functions
  
  func createARPlaneNode(planeAnchor: ARPlaneAnchor, color: UIColor) -> SCNNode {
    
    // 1 - Create plane geometry using anchor extents
    let planeGeometry = SCNPlane(width: CGFloat(planeAnchor.extent.x),
                                 height: CGFloat(planeAnchor.extent.z))
    
    // 2 - Create meterial with just a diffuse color
    let planeMaterial = SCNMaterial()
    planeMaterial.diffuse.contents = color
    planeGeometry.materials = [planeMaterial]
    
    // 3 - Create plane node
    let planeNode = SCNNode(geometry: planeGeometry)
    planeNode.position = SCNVector3Make(planeAnchor.center.x, 0, planeAnchor.center.z)
    planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2, 1, 0, 0)
    
    return planeNode
  }
  
  func updateARPlaneNode(planeNode: SCNNode, planeAchor: ARPlaneAnchor) {
    
    // 1 - Update plane geometry with planeAnchor details
    let planeGeometry = planeNode.geometry as! SCNPlane
    planeGeometry.width = CGFloat(planeAchor.extent.x)
    planeGeometry.height = CGFloat(planeAchor.extent.z)
    
    // 2 - Update plane position
    planeNode.position = SCNVector3Make(planeAchor.center.x, 0, planeAchor.center.z)
  }
  
  func removeARPlaneNode(node: SCNNode) {
    for childNode in node.childNodes {
      childNode.removeFromParentNode()
    }
  }
  
  func createPhysicsVehicleWheel(wheelNode: SCNNode, position: SCNVector3) -> SCNPhysicsVehicleWheel {
    let wheel = SCNPhysicsVehicleWheel(node: wheelNode)
    //바퀴 형의 물리 모델 적용
    wheel.connectionPosition = position
    wheel.axle = SCNVector3(x: -1.0, y: 0, z: 0)
    wheel.maximumSuspensionTravel = suspensionMaxTravel
    wheel.maximumSuspensionForce = suspensionMaxForce
    wheel.suspensionRestLength = suspensionRestLength
    wheel.suspensionDamping = suspensionDamping
    wheel.suspensionStiffness = suspensionStiffness
    wheel.suspensionCompression = suspensionCompression
    wheel.radius = wheelRadius
    wheel.frictionSlip = wheelFrictionSlip
    //Properties에서 미리 설정한 속성들을 적용
    
    return wheel
  }
  
  func createVehiclePhysics() {
    if physicsVehicle != nil { //이전에 차량 물리 모델을 만들었다면 삭제 후 다시 만든다.
      sceneView.scene.physicsWorld.removeBehavior(physicsVehicle)
    }
    let wheelFL = createPhysicsVehicleWheel(
      wheelNode: wheelFLNode!,
      position: SCNVector3(x: -0.07, y: 0.04, z: 0.06))
    let wheelFR = createPhysicsVehicleWheel(
      wheelNode: wheelFRNode!,
      position: SCNVector3(x: 0.07, y: 0.04, z: 0.06))
    let wheelRL = createPhysicsVehicleWheel(
      wheelNode: wheelRLNode!,
      position: SCNVector3(x: -0.07, y: 0.04, z: -0.06))
    let wheelRR = createPhysicsVehicleWheel(
      wheelNode: wheelRRNode!,
      position: SCNVector3(x: 0.07, y: 0.04, z: -0.06))
    //Helper 메서드를 사용해 바퀴 위치를 매개변수로 각각의 Wheel 객체를 만들어 준다.
    physicsVehicle = SCNPhysicsVehicle(
      chassisBody: truckNode.physicsBody!,
      wheels: [wheelFL, wheelFR, wheelRL, wheelRR]) //차량 물리 모델로 객체 생성
    sceneView.scene.physicsWorld.addBehavior(physicsVehicle)
    //해당 객체를 SceneView에 추가한다.
  }
  
  func createFloorNode() -> SCNNode {
    //Creating an infinite ground plane
    //감지된 평면에 할당된 물리 객체가 없으므로, 트럭을 생성해도 평면에 걸리지 않고 밑으로 떨어지게 된다.
    //또 다른 문제는 감지된 면이 매우 작아 트럭이 움직일 공간이 적은 경우이다.
    //이에 대한 해결책은 무한한 지면을 만드는 것이다. ScenenKit의 SCNFloor 노드를 활용한다.
    let floorGeometry = SCNFloor()
    floorGeometry.reflectivity = 0.25
    //Floor 노드를 생성한 후 바닥을 완전히 반사로 만든다. 0.0이면 완전 비 반사
    
    let floorMaterial = SCNMaterial()
    floorMaterial.diffuse.contents = UIColor.white //평면 백색 소재
    floorMaterial.blendMode = .multiply //multiply로 설정하면, 바닥을 숨기고 반사와 그림자를 유지할 수 있다.
    floorGeometry.materials = [floorMaterial]
    
    let floorNode = SCNNode(geometry: floorGeometry) //지오메트리 생성
    floorNode.position = SCNVector3Zero
    floorNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
    floorNode.physicsBody?.restitution = 0.5
    floorNode.physicsBody?.friction = 4.0
    floorNode.physicsBody?.rollingFriction = 0.0
    //물리적 특성을 설정해 준다.
    
    return floorNode
  }
  
  func startAccelerometer() {
    // 1
    guard motionManager.isAccelerometerAvailable else { return }
    //디바이스가 해당 기능을 사용할 수 있는지 항상 확인하는 것이 좋다.
    // 2
    motionManager.accelerometerUpdateInterval = 1/60.0
    //가속도계가 초당 60번 업데이트 된다. 따라서 동일한 속도로 업데이트
    // 3
    motionManager.startAccelerometerUpdates( //가속도계를 업데이트 한다.
      to: OperationQueue.main,
      withHandler: { (accelerometerData: CMAccelerometerData?,
        error: Error?) in
        //가속도계가 업데이트 될 때마다 콜백 핸들러가 실행된다.
        self.updateSteeringAngle(acceleration:
          accelerometerData!.acceleration)
    })
  }
  
  func stopAccelerometer() { //가속도계는 리소스를 많이 사용한다. 실제로 사용하지 않는다면, 멈춰주는 것이 좋다.
    motionManager.stopAccelerometerUpdates()
  }
  
  // MARK: Update Functions
  
  func updateStatus() {
    switch gameState {
    case .detectSurface: statusMessage = "Detecting surfaces..."
    case .hitStartToPlay: statusMessage = "Hit START to play!"
    case .playGame: statusMessage = "Touch to Throttle, Tilt to Steer!"
    }
    
    self.statusLabel.text = trackingStatus != "" ?
      "\(trackingStatus)" : "\(statusMessage)"
  }
  
  func updateFocusNode() {
    
    // Hide Focus Node
    if gameState == .playGame {
      self.focusNode.isHidden = true
      return
    }
    
    // Show Focus Node
    self.focusNode.isHidden = false
    
    let results = self.sceneView.hitTest(self.focusPoint, types: [.existingPlaneUsingExtent])
    
    if results.count >= 1 {
      if let match = results.first {
        let t = match.worldTransform
        self.focusNode.position = SCNVector3(x: t.columns.3.x, y: t.columns.3.y, z: t.columns.3.z)
        self.gameState = .hitStartToPlay
      }
    } else {
      self.gameState = .detectSurface
    }
  }
  
  func updatePositions() {
    // Update Truck Node //트럭 노드의 위치를 포커스 노드와 동일한 위치로 업데이트 한다.
    self.truckNode.position = self.focusNode.position
    self.truckNode.position.y += 0.20
    //트럭의 위치를 포커스 위치와 같게 하되, 지면보다 살짝 위(20cm)로 위치 시킨다.
    
    self.truckNode.physicsBody?.velocity = SCNVector3Zero
    self.truckNode.physicsBody?.angularVelocity = SCNVector4Zero
    //트럭에 작용하는 물리 속성(속도, 각 속도)를 0으로 해 작용하는 힘이 없도록 초기화한다.
    //이 값이 들어가 있다면, 트럭이 생성됨과 동시에 움직이게 된다.
    self.truckNode.physicsBody?.resetTransform()
    //트럭 노드의 위치를 업데이트 했기 때문에, 물리 시뮬레이션을 트럭의 새 위치로 업데이트해야 한다.
    //물리 객체에 resetTransform()를 호출하면 된다.
    
    // Update Ground Node
    self.groundNode.position = self.focusNode.position
    //트럭처럼 지면 노드를 보여주기 전에 초점 노드를 고려해야 한다. 지면 노드는 포커스 노드와 동일한 평면에 있어야 한다.
    self.groundNode.physicsBody?.resetTransform() //물리 시뮬레이션 업데이트
  }
  
  override func touchesBegan(_ touches: Set<UITouch>,
                             with event: UIEvent?) {
    isThrottling = true
  }
  override func touchesEnded(_ touches: Set<UITouch>,
                             with event: UIEvent?) {
    isThrottling = false
  }
  //플레이어가 스크린에 닿았을 때 isThrottling는 true, 아니면 false
  
  func updateVehiclePhysics() {
    guard self.gameState == .playGame else { return } //플레이 중에만 물리 속성 업데이트
    
    if isThrottling { //조정 중이라면
      engineForce = defaultEngineForce //엔진 힘을 기본 값으로
      brakingForce = CGFloat(0) //브레이크 값을 0으로
    } else {
      engineForce = CGFloat(0)
      brakingForce = defaultBrakingForce //브레이크
    }
    
    // Apply Engine Force
    physicsVehicle.applyEngineForce(engineForce, forWheelAt: 0)
    physicsVehicle.applyEngineForce(engineForce, forWheelAt: 1)
    physicsVehicle.applyEngineForce(engineForce, forWheelAt: 2)
    physicsVehicle.applyEngineForce(engineForce, forWheelAt: 3)
    //applyEngineForce 메서드로 바퀴에 적용된다. 힘이 가해지는 바쿼 번호와 엔진 힘의 양을 적용
    //적용되는 바퀴를 조절해 전륜, 후륜 구동 등으로 바꿔 줄 수 있다.
    
    // Apply Braking Force
    physicsVehicle.applyBrakingForce(brakingForce, forWheelAt: 0)
    physicsVehicle.applyBrakingForce(brakingForce, forWheelAt: 1)
    physicsVehicle.applyBrakingForce(brakingForce, forWheelAt: 2)
    physicsVehicle.applyBrakingForce(brakingForce, forWheelAt: 3)
    //엔진 힘과 마찬가지로, 브레이크가 바퀴에 적용된다.
    
    // Apply Steering
    physicsVehicle.setSteeringAngle(steeringAngle, forWheelAt: 0)
    physicsVehicle.setSteeringAngle(steeringAngle, forWheelAt: 1)
    //바퀴의 각도 조정 //앞 두 바퀴만 업데이트 //디바이스를 기울이면 각도에 따라 바퀴가 꺽이며 회전한다.
    
    // Limit Speed
    if self.physicsVehicle.speedInKilometersPerHour >
      CGFloat(maximumSpeed) {
      //속도 제한을 초과하면 해당 업데이트에 대한 엔진힘이 취소된다.
      //제한을 초과하면 엔진 힘이 다시 적용되고 트럭이 일정한 속도로 유지된다.
      engineForce = CGFloat(0.0)
    }
  }
  
  func updateSteeringAngle(acceleration: CMAcceleration) {
    steeringAngle = (CGFloat)(acceleration.y) //가속도 데이터의 y축 각도를 가져온다.
    
    if steeringAngle < -steeringClamp {
      steeringAngle = -steeringClamp;
    } else if steeringAngle > steeringClamp { //각도의 최대치
      steeringAngle = steeringClamp;
    }
  }
  
  // MARK: Game Management
  
  func startGame() {
    guard self.gameState == .hitStartToPlay else { return }
    //트럭이 Scene에 스폰되기 전에 hitStartToPlayState 상태여야 한다.
    
    DispatchQueue.main.async { //그래픽과 관련된 모든 작업은 메인 스레드에서 진행되어야 한다.
      self.createVehiclePhysics() //물리 객체 생성
      self.updatePositions() //포커스 노드와 동일한 위치로 업데이트
      self.startAccelerometer() //가속도계 업데이트
      self.groundNode.isHidden = false //지면 노드를 보이게 한다.
      self.truckNode.isHidden = false //트럭 노드를 보이게 한다.
      self.gameState = .playGame //게임 상태 전환
    }
  }
  
  func resetGame(){
    guard self.gameState == .playGame else { return }
    //게임이 진행 중인 상태에서만 리셋을 할 수 있다.

    DispatchQueue.main.async { //그래픽 업데이트는 항상 메인 스레드에서 진행해야 한다.
      self.truckNode.isHidden = true
      self.groundNode.isHidden = true
      self.stopAccelerometer()
      self.gameState = .detectSurface
      //reset에 필요한 설정들을 한다.
    }
  }
  
  func loadModels() {
    
    // Load Focus Node
    let focusScene = SCNScene(named: "MonsterTruck.scnassets/Models/Focus.scn")!
    focusNode = focusScene.rootNode.childNode(withName: "Focus", recursively: false)
    focusNode.isHidden = true
    sceneView.scene.rootNode.addChildNode(focusNode)
    
    // Load Truck Node
    let truckScene = SCNScene(named: "MonsterTruck.scnassets/Models/MonsterTruck.scn")!
    //Scenen 불러오기
    truckNode = truckScene.rootNode.childNode(withName: "Truck", recursively: true)
    wheelFLNode = truckScene.rootNode.childNode(withName: "Wheel_FL", recursively: true)
    wheelFRNode = truckScene.rootNode.childNode(withName: "Wheel_FR", recursively: true)
    wheelRLNode = truckScene.rootNode.childNode(withName: "Wheel_RL", recursively: true)
    wheelRRNode = truckScene.rootNode.childNode(withName: "Wheel_RR", recursively: true)
    //바퀴 노드들을 가져온다. 바퀴의 회전과 방향을 따로 설정해야 하므로 각각 가져온다.
    
    truckNode.addChildNode(wheelFLNode!)
    truckNode.addChildNode(wheelFRNode!)
    truckNode.addChildNode(wheelRLNode!)
    truckNode.addChildNode(wheelRRNode!)
    //바퀴의 물리적 특성을 트럭 자체와 별도로 구성해야 한다.
    
    truckNode.isHidden = true //트럭 노드를 숨겨 볼수 없도록 한다.
    sceneView.scene.rootNode.addChildNode(truckNode)
    
    // Load Ground Node
    groundNode = self.createFloorNode() //지면 생성
    groundNode.isHidden = true
    sceneView.scene.rootNode.addChildNode(groundNode)
  }
}




extension ViewController : ARSCNViewDelegate {
  
  // MARK: - SceneKit Management
  
  func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
    DispatchQueue.main.async {
      self.updateStatus()
      self.updateFocusNode()
      self.updateVehiclePhysics() //물리 엔진 업데이트
    }
  }
  
  // MARK: - AR Session State Management
  
  func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
    switch camera.trackingState {
    case .notAvailable:
      self.trackingStatus = "Tacking:  Not available!"
      break
    case .normal:
      self.trackingStatus = "" // Tracking Normal
      break
    case .limited(let reason):
      switch reason {
      case .excessiveMotion:
        self.trackingStatus = "Tracking: Limited due to excessive motion!"
        break
      case .insufficientFeatures:
        self.trackingStatus = "Tracking: Limited due to insufficient features!"
        break
      case .relocalizing:
        self.trackingStatus = "Tracking: Resuming..."
        break
      case .initializing:
        self.trackingStatus = "Tracking: Initializing..."
        break
      }
    }
  }
  
  // MARK: - AR Session Error Managent
  
  func session(_ session: ARSession, didFailWithError error: Error) {
    // Present an error message to the user
    self.trackingStatus = "AR Session Failure: \(error)"
  }
  
  func sessionWasInterrupted(_ session: ARSession) {
    // Inform the user that the session has been interrupted, for example, by presenting an overlay
    self.trackingStatus = "AR Session Was Interrupted!"
  }
  
  func sessionInterruptionEnded(_ session: ARSession) {
    // Reset tracking and/or remove existing anchors if consistent tracking is required
    self.trackingStatus = "AR Session Interruption Ended"
    self.resetGame()
  }
  
  // MARK: - Plane Management
  
  func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
    guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
    DispatchQueue.main.async {
      let planeNode = self.createARPlaneNode(
        planeAnchor: planeAnchor,
        color: UIColor.blue.withAlphaComponent(0))
      node.addChildNode(planeNode)
    }
  }
  
  func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
    guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
    DispatchQueue.main.async {
      self.updateARPlaneNode(
        planeNode: node.childNodes[0],
        planeAchor: planeAnchor)
    }
  }
  
  func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
    guard anchor is ARPlaneAnchor else { return }
    DispatchQueue.main.async {
      self.removeARPlaneNode(node: node)
    }
  }
}

//SceneKit에는 시뮬레이션을 위한 물리학이 내장되어 있다.
//레고 처럼 각 파트의 모델을 조립하여 하나의 트럭 모델을 완성한다.
//새 SceneKit(MonsterTruck.scn) 파일을 MonsterTruck.scnassets/Models 위치에 추가한다.



//Setting up the lighting environment
//PBR 기반 텍스처를 사용하면 어둡기 때문에 조명 환경이 필요하다.
//해당 노드를 SceneEditor에서 선택한 후, Scene Inspector에서 environment 텍스처를 설정한다.

//Adding the wheels
//바퀴는 빈 노드를 추가해서 비벗 포인트로 사용하는 것이 좋다. 이 포인트를 중심으로 바퀴가 회전 할 것이다.




//Adding vehicle physics
//SceneKit은 물리적인 차량 모델을 쉽게 만들 수 있다. 이 때 기본 구성 요소가 세 가지 있다.
//• SCNPhysicsVehicle : 표준 물리학 Body가 차량처럼 작동하도록 해준다.
//• SCNPhysicsBody : SCNPhysicsVehicle을 적용할 기본적인 물리학 Body
//• SCNPhysicsVehicleWheel : 바퀴의 동작과 외형, 물리적 특성을 시뮬레이트하는 유형
//  SCNPhysicsVehicle와 연계되어 사용될 것이다.
//이 외에 다양한 물리학 모델을 만들 수 있다.




//Creating the wheel physics
//바퀴 물리 type이 SceneKit에서 지원하지 않기 때문에 코드로 지정해 줘야 한다.
//바쿼 물리 type은 바퀴 자체에 대한 세부 사항뿐만 아니라 특정 바퀴에 연결된 서스펜션도 정의한다.



//Challenge
//MonsterTruck.scn에 광원을 추가해 부드러운 그림자를 생성해 줄 수 있다.
//• Directional Light : 트럭 노드의 자식인 MonsterTruck.scn에 추가된 지향성 라이트는 그림자를 생성한다.
//  트럭 노드의 자식 노드이므로 광원을 자동으로 로드한다. 광원은 트럭을 따라 가며 그림자를 만들 수 있다.
//  보다 근본적이고 영구적인 해결책은 트럭 노드와 분리된 광원을 만들어야 하며, 트럭 주변을 따라 X, Z 위치를 업데이트한다.
//• The floor node : SceneKit의 바닥 노드는 반사율을 조정할 수 있다. 0.25(25%) 정도면 사실적인 결과를 얻는다.
