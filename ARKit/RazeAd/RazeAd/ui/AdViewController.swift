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
import Vision //Vison Framework
//Vision Framework는 실제 객체를 식별하고 분류하기 위한 이미지 분석 및 컴퓨터 비전 프레임워크이다.
//apple.co/2CGWZgy
import CoreLocation

class AdViewController: UIViewController {
  @IBOutlet weak var sceneView: ARSCNView!
  @IBOutlet weak var autoscanButton: UIButton!
  @IBOutlet weak var removeBillboardButton: UIButton!
  @IBOutlet weak var toggleLocationTrackingButton: UIButton!
  @IBOutlet weak var beaconStatusImage: UIImageView!
  @IBOutlet weak var beaconStatusLabel: UILabel!
  weak var targetView: TargetView!

  private var billboard: BillboardContainer?
  private var autoscanTimer: Timer?
    
  private var locationManager = LocationManager()

  // Flag indicating if timer is on when the view is hidden
  private var wasTimerActive = false

  // Flag indicating if location tracking is active
  private var isLocationTrackingActive = false
  override func viewDidLoad() {
    super.viewDidLoad()

    // Set the view's delegate
    sceneView.delegate = self

    // Set the session's delegate
    sceneView.session.delegate = self

    // Show statistics such as fps and timing information
    sceneView.showsStatistics = true

    // Create a new scene
    let scene = SCNScene()

    // Set the scene to the view
    sceneView.scene = scene
    
    // Initialize core location
    locationManager.initialize()
    locationManager.delegate = self
    //Core Location을 사용하려면, Info.plist을 업데이트 해야 한다. Core Location을 사용하는 방법에는 두 가지가 있다.
    //• when in use : Core Location은 앱이 foreground에 있을 때만 업데이트한다.
    //• always : foreground 혹은 background에 관계 없이 언제든지 업데이트한다.
    //iOS 10 이전에서는 NSLocationAlwaysUsageDescription 키를 Info.plist에 추가해야 했다.
    //iOS 11부터는 NSLocationAlwaysAndWhenInUseUsageDescription와
    //NSLocationWhenInUseUsageDescription 키 두 개를 추가해야 한다. p.258

    // Setup the target view
    let targetView = TargetView(frame: view.bounds)
    view.addSubview(targetView)
    self.targetView = targetView
    targetView.show()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    // Create a session configuration
    let configuration = ARWorldTrackingConfiguration()
    configuration.worldAlignment = .camera
    //worldAlignment은 세션이 디바이스 모션을 3D scene 좌표계로 매핑하는 방법을 정의한다.
    //worldAlignment는 열거형으로 세 가지 값이 정의되어 있다.
    //• gravity : y축은 중력과 평행이고, 원점과 x-z 축은 디바이스의 초기 위치와 방향이다.
    //    현재 카메라 위치에 따라 중력 방향으로 수직으로 향한 객체 배치 시에 유용하다. p.203
    //• gravityAndHeading : 동쪽의 x 축, 남쪽의 z축이 추가되는 것을 제외하면 gravity와 같다. p.203
    //    세션이 시작될 때 카메라 방향과 관계없이 방향은 항상 고정된다. 실제 세계의 참조점을 사용해야 할 때 유용하다.
    //• camera : 좌표계가 카메라 위치와 일치하도록 고정된다. 카메라를 움직이면 따라 움직인다. p.204
    //gravity와 gravityAndHeading에서 원점은 중력과 평행한 y축을 가진다. world origin을 향한 노드는
    //항상 지면에 수직인 방향이다. camera 옵션은 world origin이 항상 카메라에 고정되어 카메라와 함께 이동하고
    //회전한다. 카메라가 움직이면, world의 모든 객체의 위치와 방향이 업데이트 된다(위치가 상대적).
    
    //여기서는 감지하려는 사각형이 수직인 방향일 경우가 많기 때문에 camera 옵션을 사용하는 것이 좋다.
    //camera로 설정을하면, 생성된 plane이 항상 카메라를 향하게 된다.
    //카메라에서 생성된 plane 사각형의 중심까지을 잇는 선은 수직이다. p.205

    var triggerImages = ARReferenceImage.referenceImages(inGroupNamed: "RMK-ARKit-triggers", bundle: nil)
    //감지 가능한 이미지는 ARReferenceImage의 인스턴스에 번들로 제공된다.
    //RMK-ARKit-triggers 그룹에 추가한 이미지를 로드한다.
    //해당 이미지를 감지한다.

    //Asset에 있는 지정해 둔 이미지 외에 코드로 추가할 때
    let image = UIImage(named: "logo_2")! //이미지 생성
    let referenceImage = ARReferenceImage(image.cgImage!, orientation: .up, physicalWidth: 0.2)
    //실제 너비 0.2미터의 참조 이미지 생성. 물리적 높이는 시스템에 의해 계산된다.
    triggerImages?.insert(referenceImage) //새로 작성된 참조 이미지를 triggerImages의 그룹에 추가한다.
    
    //참조 이미지 감지는 QR코드 감지를 대체하지 않는다(둘 다 작동한다).

    configuration.detectionImages = triggerImages //배열이 아닌 Set
    //detectionImages 속성으로 ARKit에서 인식할 이미지 세트를 지정해 줄 수 있다.
    
    //Detec1ng predefined images
    //ARKit 1.5에는 사용자 지정 이미지를 감지하는 기능이 추가되었다.
    //흰색 직사각형이나 QR코드를 감지하는 대신 앱에서 하나 이상의 미리 정의된 이미지를 인식할 수 있다.
    //Xcode 9.3 이상, iOS 11.3 이상에서만 작동하며, 하나 이상의 참조 이미지가 있어야 한다.
    //Assets.xcassets에서 New AR Resource Group으로 그룹을 만들고 New AR Reference Image으로 이미지를 추가해야 한다. p.246
    //warning이 뜨기도 하지만, 완전히 조건에 맞춘 이미지가 아니더라도 대부분 작동은 한다.
    
    //참조 이미지가 인식되면 앱에 알리기 위해 ARKit이 필요하다. 인식되면, ARKit은 세션에 앵커를 자동으로 추가한다.
    //앵커가 추가될 때 알림을 받을 수 있는 세 가지 방법이 있다.
    //• ARSessionDelegate의 session(_:didAdd:)
    //• ARSKViewDelegate의 view(_:didAdd:for:)
    //• ARSCNViewDelegate의 rendered(_:didAdd:for:)

    // Run the view's session
    sceneView.session.run(configuration)

    if wasTimerActive {
      // Start the timer
      startAutoscanTimer()
      wasTimerActive = false
    }
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)

    // Pause the view's session
    sceneView.session.pause()

    if isTimerRunning {
      wasTimerActive = true
      stopAutoscanTimer()
    }
  }

  @IBAction func didTapRemoveBillboard() {
    removeBillboard()
  }

  @IBAction func didTapToggleAutoScan() {
    if isTimerRunning {
      stopAutoscanTimer()
    } else {
      startAutoscanTimer()
    }
  }

  @IBAction func toggleLocationTracking() {
    //Geofencing은 사용자가 대상으로부터 특정 거리 내에 있는 것을 알아내는 기능이다. 특정 위치 주변, 특히 디바이스가 해당 영역의 경계를 넘을 때 모니터링된다.
    isLocationTrackingActive = !isLocationTrackingActive
    //isLocationTrackingActive는 위치 추적이 현재 활성화되어 있는지 여부를 나타내는 플래그이다.
    
    if isLocationTrackingActive { //사용자가 지오펜싱 버튼을 탭하고 위치 추적이 활성화되었을 때
        self.toggleLocationTrackingButton.setImage(#imageLiteral(resourceName: "arKit-fence-on"), for: .normal) //버튼 이미지 업데이트
        let rmkLocation = Constants.razewareMobileKioskLocation //목표 지점
        let rmkCoordinates = rmkLocation.location //목표지점의 좌표
        
        print("")
        print("=========================================================================================================")
        print("WARNING: ensure that the Razeware Mobile Kiosk is at a location near you,")
        print("otherwise geofencing and beacon detection won't work")
        print("The current location is: \(rmkLocation.name) (\(rmkLocation.location.latitude), \(rmkLocation.location.longitude))")
        print("=========================================================================================================")
        
        do {
            try locationManager.startMonitoring(location: rmkCoordinates,
                                                radius: Constants.geofencingRadius,
                                                identifier: Constants.razewareMobileKioskIdentifier) //모니터링 시작
            //rmkCoordinates의 Constants.geofencingRadius 반경(300 미터) 모니터링
        } catch (let error as LocationManager.GeofencingError) {
            print("An error occurred while monitoring a region: \(error)")
        } catch (let error) {
            print("Tracking location error: \(error.localizedDescription)")
        }
    } else { //위치 추적 중단
        self.toggleLocationTrackingButton.setImage(#imageLiteral(resourceName: "arKit-fence-off"), for: .normal) //버튼 이미지 업데이트
        locationManager.stopMonitoringRegions() //위치 추적 중단
        
        locationManager.stopMonitoring(beacons: Constants.razeadBeacons) //비콘 모니터링 중단
        beaconStatusImage.isHidden = true
        beaconStatusLabel.isHidden = true
        stopAutoscanTimer() //타이머 중단
    }
  }
}

// MARK: - ARSCNViewDelegate
extension AdViewController: ARSCNViewDelegate {
  func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
    //createBillboard에서 ARKit 앵커를 만들어 ARKit 세션에 추가했다.
    //다음 단계는 ARKit 앵커를 SceneKit 노드로 변환하는 것이다.
    //새 앵커를 ARKit 세션에 수동으로 추가하면, ARKit은 이 메서드를 호출하여 메서드 끝에서
    //앵커를 반환하여 새로 만든 앵커에 대한 SceneKit 노드를 제공한다.
    //노드를 추가하지 않도록 ARKit에 알릴 수도 있다. 이 경우에는 단순히 nil을 반환하면 된다.
    guard let billboard = billboard else { return nil }
    var node: SCNNode? = nil
    
    DispatchQueue.main.sync { //이 메서드는 일반적으로 메인 스레드에서 호출되지 않는다.
      //UI업데이트를 할때는 메인 스레드에서 호출해야 한다.
      switch anchor {
      case billboard.billboardAnchor: //앵커가 빌보드 앵커인지 확인
        let billboardNode = addBillboardNode() //SCNNode 반환
        //touchesBegun(_:with)에서 생성된 ARKit 앵커와 연결된 이 노드는 SceneKit 노드로 지오메트리를 가지고 있다.
        //SceneKit의 모든 지오메트리는 SCNGeometry를 상속한다.
        self.createBillboardController()
        //이전 구현에서는 addBillboardNode() 내부에서 BillboardViewController를 만들었다.
        //새로운 구현(Ch12)에서는 스토리보드 기반의 billboard를 새로 만든다. 복잡하기 때문에 아예 새로운 메서드로 떼어낸다.
        node = billboardNode
        
//      let image = UIImage(named: "logo_1")!
//      setBillboardImage(image: image) //빌보드에 이미지 생성

      case (let videoAnchor) where videoAnchor == billboard.videoAnchor: //비디오 앵커인 경우
//      node = addVideoPlayerNode() //이전 구현
        node = billboard.videoNodeHandler?.createNode()

      default:
        break
      }
    }

    return node
  }
}

extension AdViewController: ARSessionDelegate {
  func session(_ session: ARSession, didFailWithError error: Error) {
  }

  func sessionWasInterrupted(_ session: ARSession) {
    //ARKit 세션이 interruptede되면(백 그라운드 등) 위치 및 방향을 찾던 센서도 중단된다.
    //백그라운드 처리를 사용할 수도 있다. 하지만, 정기적으로 수행하면 리소스가 많이 낭비된다.
    //단순히 사용자가 앱을 다시 시작하면 이전 감지 프로세스를 새로 시작하는 것이 좋다.
    //따라서 세션이 중단될때 빌보드를 제거하는 것으로 간단히 구현 가능하다.
    removeBillboard()
  }

  func sessionInterruptionEnded(_ session: ARSession) {
  }
  
  func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
    //ARKit은 앵커가 세션에 추가될 때 이 메서드를 호출한다.
    //참조 이미지가 인식되면 새로운 앵커가 생성되기 때문에 이 메서드가 트리거 된다.
    if let imageAnchor = anchors.compactMap({ $0 as? ARImageAnchor }).first {
      //유형별로 필터링하고 ARImageAnchor인스턴스만 유지한다. 그 중 첫 번째 요소만 가져온다
      self.createBillboard(center: imageAnchor.transform, size: imageAnchor.referenceImage.physicalSize)
      //해당 앵커를 사용해 빌보드를 생성한다.
    }
  }
}

extension AdViewController {
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    if billboard?.hasVideoNode == true { //비디오 노드가 있는 지 확인
      billboard?.billboardNode?.isHidden = false //빌보드 노드 숨기고
//      removeVideo() //비디오 제거
      billboard?.videoNodeHandler?.removeNode() //비디오 노드 제거
      return //추가 적인 처리 없이 메서드를 종료시킨다. 비디오가 재생되는 동안 터치하면 QR코드 스캔을 트리거하지 않는다.
    }
  }
    
    private func scanQRCode() {
        //이전과 달리 비콘 감지가 되면 자동으로 QR 스캔 모드를 트리거 하도록 구현한다.
        //따라서 화면 터치 시 QR 코드를 스캔하는 부분을 따로 떼어낸다.
        
        guard let currentFrame = sceneView.session.currentFrame else { return }
        //가장 최근 세션에서 캡쳐된 AR scene 정보를 가지고 있는 비디오 프레임이 없다면 반환
        //비디오 피드의 단일 캡쳐로, ARKit은 이를 분석하고 디바이스의 모션 감지 기능과 결합하여 AR을 만든다.
        
        DispatchQueue.global(qos: .background).async {
            //이미지 처리는 CPU의 자원을 많이 소모하므로 백그라운드에서 실행하는 것이 자원관리에 좋다.
            do {
                //        let request = VNDetectRectanglesRequest { (request, error) in
                //Vison 프레임워크로 사각형을 감지한 후, VNDetectRectanglesRequest를 사용해
                //해당 사각형을 ARKit 객체로 변환할 수 있다.
                //사각형 영역을 찾는 이미지 분석이 완료되면 클로저가 호출된다.
                
                let request = VNDetectBarcodesRequest { (request, error) in
                    //VNDetectBarcodesRequest로 QR코드를 읽을 수 있다.
                    //VNDetectRectanglesRequest을 VNDetectBarcodesRequest로
                    //VNRectangleObservation를 VNBarcodeObservation로 대체해 준다.
                    
                    //Vision은 다른 유형을 탐지할 수도 있다.
                    //• Horizon : VNDetectHorizonRequest 사용. 이미지의 수평 각을 결정한다.
                    //• Faces : VNDetectFaceRectanglesRequest, VNDetectFaceLandmarksRequest 사용
                    //  얼굴과 얼굴 특징을 포함하는 직사각형을 감지한다.
                    //• Text : VNDetectTextRectanglesRequest 사용. 식별 가능한 텍스트가 포함된 영역을 감지한다.
                    //• Rectangle, object 트래킹 : VNTrackRectangleRequest, VNTrackObjectRequest 사용.
                    //  이전에 감지한 모든 직사각형과 객체를 추적한다.
                    
                    // Access the first result in the array,
                    // after converting to an array
                    // of VNBarcodeObservation
                    
                    //          guard let results = request.results?.compactMap({ $0 as? VNRectangleObservation }),
                    //결과는 반환되는 request의 results에서 가져올 수 있다(Any 타입).
                    //감지된 각 사각형을 VNRectangleObservation 타입으로 변환하여 배열에 저장한다.
                    
                    guard let results = request.results?.compactMap({ $0 as? VNBarcodeObservation }),
                        //VNDetectBarcodesRequest로 QR코드를 읽을 수 있다.
                        //VNDetectRectanglesRequest을 VNDetectBarcodesRequest로
                        //VNRectangleObservation를 VNBarcodeObservation로 대체해 준다.
                        let result = results.first else {
                            //감지된 결과가 하나도 없다면 반환
                            //VNDetectRectanglesRequest의 maximumObservations 속성은 default가 1이다.
                            //따라서 따로 설정하지 않으면 가장 사각형에 가깝다고 판단하는 하나의 형태만 감지한다.
                            
                            //결과가 있는지 확인하고 첫 번째 결과를 가져온다.
                            print ("[Vision] VNRequest produced no result")
                            return
                    }
                    
                    let coordinates: [matrix_float4x4] = [result.topLeft, result.topRight, result.bottomRight, result.bottomLeft].compactMap {
                        //VNRectangleObservation로 감지된 사각형의 네 꼭지점을 식별할 수 있다.
                        //Vison Framework는 2D 이미지에서 작동하므로, 결과는 항상 비트맵 이미지 내의 2D좌표이다.
                        //이 4개의 좌표를 배열로 처리하면 순차적으로 처리하기 쉬워진다.
                        guard let hitFeature = currentFrame.hitTest($0, types: .featurePoint).first else { return nil }
                        //map의 각 배열의 요소(4개의 좌표)로 currentFrame의 hiTest를 진행한다.
                        //Vison 으로 찾은 2D의 좌표를 공간 상으로 투영하여(Hit Test) 3D 좌표로 가져올 수 있다.
                        
                        //hitTest에서 사용하는 type에는 4가지가 있다.
                        //• featurePoint : surfac의 점 이지만 앵커는 없다.
                        //• estimatedHorizontalPlane : 검색에 의해 감지되었지만 앵커가 없는 plane 평면
                        //• existingPlane : plane의 크기를 고려하지 않는 연관된 앵커가 있는 plane
                        //• existingPlaneUsingExtent : plane의 크기를 고려한 연관된 앵커가 있는 평면
                        //나머지 3개가 평면을 감지해 내는 것이므로 점을 감지하는 것은 하나밖에 없다.
                        
                        return hitFeature.worldTransform //hitTest에서 나온 결과를 Transform으로 저장
                        //worldTransform 속성은 world coordinate system을 기준으로 한 위치와 방향 정보를 가지고 있다.
                        //3D의 모든 객체에는 world coordinate system 기준의 위치와 방향이 있다.
                        //world coordinate system은 세션이 시작될 때마다 ARKit에 의해 설정되며
                        //디바이스의 위치와 방향에 따라 달라진다.
                    }
                    
                    guard coordinates.count == 4 else { return }
                    //map을 거친 후, coordinate은 worldTransform 속성에서 가져온 4x4 행렬의 배열이 된다.
                    //사각형을 다루기 때문에 반드시 4개의 좌표가 있어야 한다.
                    //ARKit에서 Vison에서 찾은 2D 좌표를 3D로 변환이 하나라도 실패한다면 종료된다.
                    
                    /*
                     simd_float4x4([
                     [1.0, 0.0, 0.0, 0.0)],
                     [0.0, 1.0, 0.0, 0.0)],
                     [0.0, 0.0, 1.0, 0.0)],
                     [-0.0293431, -0.238044, -0.290515, 1.0)]
                     ])
                     */
                    //coordinates의 각 요소(matrix_float4x4 타입)은 위와 같이 4x4 행렬로 출력된다.
                    //마지막 열은 위치(position)를 지정하고, 앞의 세 열은 크기 조정(scale) 및 방향(orientation)을 지정한다.
                    
                    DispatchQueue.main.async { //UI요소를 추가하고 제거하므로 메인 스레드에서 진행해야 한다.
                        self.removeBillboard() //이전 빌보드가 표시된 경우 제거한다.
                        
                        // Stop the timer
                        self.stopAutoscanTimer()
                        
                        // Remove the target
                        self.targetView.hide()
                        
                        let (topLeft, topRight, bottomRight, bottomLeft) = (coordinates[0], coordinates[1], coordinates[2], coordinates[3])
                        self.createBillboard(topLeft: topLeft, topRight: topRight, bottomRight: bottomRight, bottomLeft: bottomLeft)
                        //새로운 빌보드를 작성한다. 파라미터로 이전 단계에서 찾은 네 개의 좌표를 전달한다.
                        
                        // Uncomment to show four small placeholders in correspondence of the plane vertices
                        /*
                         for coordinate in coordinates {
                         let box = SCNBox(width: 0.01, height: 0.01, length: 0.001, chamferRadius: 0.0)
                         let node = SCNNode(geometry: box)
                         node.transform = SCNMatrix4(coordinate)
                         self.sceneView.scene.rootNode.addChildNode(node)
                         }
                         */
                        //디버깅 위한 Dummy
                    }
                }
                
                let handler = VNImageRequestHandler(cvPixelBuffer: currentFrame.capturedImage)
                //VNDetectRectanglesRequest를 실행하는 방법은 실제 이미지 처리를 담당하는 핸들러를 작성하는 것이다.
                //cvPixelBuffer 매개변수로 분석할 이미지를 전달한다.
                //단일 이미지에서 Vison request를 실행하려면, 핸들러를 인스턴스화해야 한다.
                //이 핸들러는 이미지 분석을 요청한다.
                
                //핸들러 인스턴스가 단일 프레임에 대해 정의되어 있다.
                //텍스트 인식, 바코드 감지 등 동일한 프레임에서 여러 요청을 수행할 수도 있다.
                //그 경우에는 하나의 요청당 하나의 핸들러를 생성해야 한다.
                
                try handler.perform([request]) //핸들러를 실행한다.
            } catch(let error) { //오류 처리
                print("An error occurred during rectangle detection: \(error)")
            }
        }
    }
}

private extension AdViewController {
  func createBillboard(topLeft: matrix_float4x4, topRight: matrix_float4x4, bottomRight: matrix_float4x4, bottomLeft: matrix_float4x4) {
    //4개의 직사각형 꼭지점 마다 위치와 방향을 결정하는 4개의 행렬을 가지고 있다(world transform).
    //world transform에는 2D 점을 카메라의 반대 방향으로 투영하고, 그 방향의 교차점을 포함한다.
    //orientation은 카메라의 가상선과 사각형 꼭지점을 잇는 선분(빨간색 선)과
    //평면에 수직인 선(녹색선)사이의 각도로 결정된다. p.191
    autoscanButton.isEnabled = false
    removeBillboardButton.isEnabled = true

    let plane = RectangularPlane(topLeft: topLeft, topRight: topRight, bottomLeft: bottomLeft, bottomRight: bottomRight)
    //사각형 크기와 중심을 계산하는 RectangularPlane 컨테이너에 4개의 행렬 값을 전달한다.
    
//    let anchor = ARAnchor(transform: plane.center)
    //사각형 중심에 위치한 plane에 대한 앵커를 생성한다.
    
    let rotation =
      SCNMatrix4MakeRotation(Float.pi / 2.0, 0.0, 0.0, 1.0)
    //z축을 중심으로 시계 방향으로 90도 회전한 행렬 //카메라 world alignment를 사용하면 반대편에서 평면을 본 방향으로
    let rotatedCenter =
      plane.center * matrix_float4x4(rotation) //회전을 평면 중심에 적용
    let anchor = ARAnchor(transform: rotatedCenter) //앵커 transform에 적용
    billboard = BillboardContainer(billboardAnchor: anchor, plane: plane)
    //앵커와 plane으로 BillboardContainer를 생성한다.
    //BillboardContainer는 빌보드에 대한 데이터를 저장하는데 사용하는 자료구조. 액세스할 수 있도록 저장해 둔다.
    billboard?.videoPlayerDelegate = self //delegate를 설정해 준다.
    sceneView.session.add(anchor: anchor) //앵커 추가

    print("New billboard created")
  }

  func createBillboard(center: matrix_float4x4, size: CGSize) {
    //위의 createBillboard와 구현이 거의 동일하다.
    let plane = RectangularPlane(center: center, size: size)
    //네 개의 직사각형 꼭지점 대신 참조 이미지의 중심점으로 plane을 생성한다.
    let rotation =
      SCNMatrix4MakeRotation(Float.pi / 2, -1.0, 0.0, 0.0)
    let rotatedCenter =
      plane.center * matrix_float4x4(rotation)
    //회전 행렬이 이전 createBillboard메서드와 다르다.
    //위의 메서드는 z축 시계 방향으로 90도 회전 했지만, 여기서는 x축 시계 반대 방향으로 90도 회전한다.
    //이것은 SceneKit 노드의 일반적인 조정이다.

    //이후 나머지는 위의 createBillboard 메서드와 같다.
    let anchor = ARAnchor(transform: rotatedCenter)
    billboard = BillboardContainer(billboardAnchor: anchor, plane: plane)
    billboard?.videoPlayerDelegate = self
    sceneView.session.add(anchor: anchor)
    
    print("New billboard created")
  }
    
//  func createVideo() {
//    guard let billboard = billboard else { return }
//
//    let rotation =
//      SCNMatrix4MakeRotation(Float.pi / 2.0, 0.0, 0.0, 1.0)
//    let rotatedCenter =
//      billboard.plane.center * matrix_float4x4(rotation)
//    //빌보드와 같은 위치 중앙
//    let anchor = ARAnchor(transform: rotatedCenter) //새 앵커 생성
//
//    sceneView.session.add(anchor: anchor) //앵커 추가
//    self.billboard?.videoAnchor = anchor //나중에 액세스 할 수 있도록 앵커 저장
//  }

  func addBillboardNode() -> SCNNode? {
    guard let billboard = billboard else { return nil }

    let rectangle = SCNPlane(width: billboard.plane.width, height: billboard.plane.height)
    //createBillboard에서 저장한 RectangularPlane 구조체 값으로 SCNPlane(지오메트리) 생성
    let rectangleNode = SCNNode(geometry: rectangle) //지오메트리로 SCNNode 생성

    self.billboard?.billboardNode = rectangleNode //컨테이너에 노드 추가
    
//    let images = [
//      "logo_1", "logo_2", "logo_3", "logo_4", "logo_5"
//      ].map { UIImage(named: $0)! }
//    //map으로 해당 이름의 이미지 객체를 생성해 배열로 저장
//
//    setBillboardImages(images)
    
    return rectangleNode
  }

//  func addVideoPlayerNode() -> SCNNode? {
//    //AVPlayerViewController가 있지만, ARKit과 함께 작동하지 않는다.
//    //따라서 AVPlayer를 직접 사용해서 비디오를 재생시켜야 한다.
//    guard let billboard = billboard else { return nil }
//
//    let billboardSize = CGSize(
//      width: billboard.plane.width,
//      height: billboard.plane.height / 2
//    )
//    let frameSize = CGSize(width: 1024, height: 512)
//    let videoUrl = URL(string:
//      "https://www.rmp-streaming.com/media/bbb-360p.mp4")!
//    //필요한 변수 초기화
//
//    let player = AVPlayer(url: videoUrl) //비디오 플레이어 생성
//    let videoPlayerNode = SKVideoNode(avPlayer: player) //SpriteKit의 비디오 노드
//    videoPlayerNode.size = frameSize
//    videoPlayerNode.position = CGPoint(
//      x: frameSize.width / 2,
//      y: frameSize.height / 2
//    )
//    videoPlayerNode.zRotation = CGFloat.pi
//
//    let spritekitScene = SKScene(size: frameSize) //SpriteKit Scene 생성
//    spritekitScene.addChild(videoPlayerNode) //비디오 노드 추가
//
//    let plane = SCNPlane(
//      width: billboardSize.width,
//      height: billboardSize.height
//    ) //Plane (SceneKit)을 설정한다.
//    plane.firstMaterial!.isDoubleSided = true
//    plane.firstMaterial!.diffuse.contents = spritekitScene
//    //SpriteKit Scene로 생성한 비디오 노드를 사용한다.
//    let node = SCNNode(geometry: plane) //노드 생성
//
//    self.billboard?.videoNode = node //나중에 참조할 수 있도록 새로 작성된 노드를 저장한다.
//
//    self.billboard?.billboardNode?.isHidden = true //빌보드 노드를 숨기고
//    videoPlayerNode.play() //비디오를 재생한다.
//
//    return node
//  }

  func removeBillboard() {
    if let anchor = billboard?.billboardAnchor {
      //guard로 billboard 속성이 nil인지 아닌지 확인할 수도 있지만, 앵커만 확인하면 되므로 간단히 구현
      if let viewController = billboard?.viewController {
        viewController.willMove(toParentViewController: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParentViewController()
      }

      sceneView.session.remove(anchor: anchor) //앵커 있는 경우 ARKit 세션에서 앵커 제거
      billboard?.billboardNode?.removeFromParentNode()

      billboard?.videoNodeHandler = nil

      billboard = nil
      //노드 삭제
    }
  }

  func createBillboardController() {
    DispatchQueue.main.async { //UI 업데이트 이므로 메인 스레드에서 진행해야 한다.
      let navController = UIStoryboard(name: "Billboard", bundle: nil).instantiateInitialViewController() as! UINavigationController
      //스토리 보드 기반의 Billboard 생성. instantiateInitialViewController()로 인스턴스화 한다.
      let billboardViewController = navController.visibleViewController as! BillboardViewController
      //네비게이션 컨트롤러에서 현재 보이는 뷰 컨트롤러를 가져온다(첫 번째 뷰 컨트롤러(root)가 된다).
      billboardViewController.sceneView = self.sceneView
      billboardViewController.billboard = self.billboard
      //속성 할당

      billboardViewController.willMove(toParentViewController: self)
      //willMove는 뷰 컨트롤러가 컨테이너 뷰 컨트롤러에 추가 되거나 제거되기 바로 전에 호출된다.
      //새로운 뷰 컨트롤러(billboardViewController)에게 부모 뷰 컨트롤러 self(AdViewController)로
      //이동할 것이라 알려준다.
      self.addChildViewController(billboardViewController)
      //AdViewController에 billboardViewController를 자식으로 추가한다.
      self.view.addSubview(billboardViewController.view)
      //AdViewController 뷰에 billboardViewController의 뷰를 하위 뷰로 추가한다.

      self.show(viewController: billboardViewController)
      //billboardViewController를 보이게 한다.
    }
  }

  private func show(viewController: BillboardViewController) {
    //이전 장의 setBillboardImages()에서의 로직과 거의 유사하다.
    let material = SCNMaterial()
    material.isDoubleSided = true
    material.cullMode = .front //어떤 면이 SceneKit를 렌더링할지 결정

    material.diffuse.contents = viewController.view

    billboard?.viewController = viewController
    billboard?.billboardNode?.geometry?.materials = [material]
  }
    
//  func removeVideo() {
//    if let videoAnchor = billboard?.videoAnchor {
//      sceneView.session.remove(anchor: videoAnchor) //앵커 제거
//    }
//
//    billboard?.videoNode?.removeFromParentNode() //비디오 노드 제거
//    billboard?.videoAnchor = nil
//    billboard?.videoNode = nil
//  }

//  func setBillboardImages(_ images: [UIImage]) {
//    let material = SCNMaterial() //SCNMaterial 생성
//    material.isDoubleSided = true
//    //isDoubleSided를 true로 설정하면, 재질이 양면에 적용된다.
//    //false로 설정하면, 카메라가 뒤쪽에서 객체를 보고 있을 때 보이지 않게 된다.
//
//    DispatchQueue.main.async { //UI 작업 처리를 위해 메인 스레드에서 진행
//      // https://forums.developer.apple.com/thread/89423
//      // A UIView can be assigned to a material
//      let billboardViewController = BillboardViewController(
//        nibName: "BillboardViewController", bundle: nil) //billboardViewController 인스턴스 생성
//      billboardViewController.delegate = self //delegate 설정
//      billboardViewController.images = images
//
//      material.diffuse.contents = billboardViewController.view
//
////            let imageView = UIImageView(image: image) //매개변수로 전달된 이미지로 뷰 생성
////            material.diffuse.contents = imageView //material의 diffuse 속성에 추가한다.
////            material.diffuse.contents = image
//      //ImageView에 boxing하는 대신 UIImage 자체를 지정할 수도 있다.
//      //경우에 따라 투명도가 있는 이미지를 사용할 때나 UIView 상속 클래스를 사용하는 경우 UIImageView가
//      //제대로 표현되지 않기 때문에 더 좋은 옵션이 될 수도 있다.
//
//      self.billboard?.viewController = billboardViewController
//      //새로 인스턴스화된 뷰 컨트롤러를 추적하기 위해 BillboardContainer 구조체에 저장한다.
//
//      self.billboard?.billboardNode?.geometry?.materials = [material]
//      //새 재질을 해당 지오메트리에 설정한다.
//      //billboardNode는 touchesBegun(_:with)에서 생성된 ARKit 앵커와 연결된 SceneKit 노드로
//      //지오메트리를 가지고 있다. SceneKit의 모든 지오메트리는 SCNGeometry를 상속한다.
//    }
//  }
}

//extension AdViewController: BillboardViewDelegate {
//  func billboardViewDidSelectPlayVideo(
//    _ view: BillboardView) {
//
//    createVideo()
//  }
//}

extension AdViewController: VideoPlayerDelegate {
  func didStartPlay() {
    //비디오 재생 시작
    billboard?.billboardNode?.isHidden = true //빌보드를 숨긴다.
    //새 노드가 만들어진다.
  }

  func didEndPlay() {
    //비디오 재생 종료
    billboard?.billboardNode?.isHidden = false //빌보드를 다시 보인다.
  }
}

//Plane detection vs. object detection
//평면 탐지와 객체 탐지는 다르다. ARKit은 처음에는 평면의 일부만 탐지한다. 디바이스가 움직이면 평면이 실시간으로 업데이트되고
//ARKit은 평면을 확장한다. 평면은 전체 표면의 경계를 감지하도록 설계되었다. 객체 탐지는 Vision Framework를 사용해
//특정 모양을 감지한 후 ARKit의 평면 위에 표현할 수 있다.

// MARK: - Timer
extension AdViewController {
  func startAutoscanTimer() {
    guard isTimerRunning == false else { return }

    targetView.show()

    autoscanTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(didFireTimer(timer:)), userInfo: nil, repeats: true)
    autoscanButton.setImage(#imageLiteral(resourceName: "arKit-radar-on"), for: .normal)
  }

  func stopAutoscanTimer() {
    targetView.hide()

    // Stops the timer
    autoscanTimer?.invalidate()
    autoscanTimer = nil
    autoscanButton.setImage(#imageLiteral(resourceName: "arKit-radar-off"), for: .normal)
  }

  var isTimerRunning: Bool {
    guard let timer = autoscanTimer else { return false }
    return timer.isValid
  }

  @objc func didFireTimer(timer: Timer) {
    scanQRCode() //QR 코드 스캔 
  }
}

// MARK: - LocationManagerDelegate
extension AdViewController: LocationManagerDelegate {
    //CLLocationManager의 delegate와 유사하지만, 해당 앱에 맞춘 사용자 정의 delegate
    //LocationManager 클래스에서 사용하는 CLLocationManagerDelegate를 감싸는 래퍼
    //이렇게 래퍼를 만들어 추상화하면서 필요한 기능만 제공해 줄 수 있다.
    
    //디바이스가 모니터링된 영역을 통과할 때 LocationManager에 알린다. LocationManager는 LocationManagerDelegate의 두 가지 메서드를 사용한다.
    
    // MARK: Location
    func locationManager(_ locationManager: LocationManager, didEnterRegionId regionId: String) {
        //영역 안으로 들어왔을 때 알린다.
        
        // Notify the user that he’s entered the geofenced zone
        let distance = String(format: "%0.0f", Constants.geofencingRadius)
        let message = "\(regionId) is less than \(distance) meters. " + "Come say hi and interact with our e-billboard"
        let title = regionId
        
        showAlert(with: "geofencing-notification", title: title, message: message)
        
        locationManager.startMonitoring(beacons: Constants.razeadBeacons) //정의된 비컨 모니털링을 시작한다.
    }
    
    func locationManager(_ locationManager: LocationManager, didExitRegionId regionId: String) {
        // In case the autoscan timer is still active, disables it because there's nothing to scan
        locationManager.stopMonitoring(beacons: Constants.razeadBeacons) //비콘 모니터링 종료
        
        stopAutoscanTimer()
        //타이머를 멈춘다. QR 코드 자동 감지를 멈춘다.
        
        beaconStatusImage.isHidden = true
        beaconStatusLabel.isHidden = true
        //비콘 상태를 나타내는 UI들을 감춘다.
    }
    
    // MARK: Beacons
    func locationManager(_ locationManager: LocationManager, didRangeBeacon beacon: CLBeacon) {
        beaconStatusImage.isHidden = false
        beaconStatusLabel.isHidden = false
        //비콘의 상태를 알려주는 UI들을 보이게 한다.
        
        switch beacon.proximity {
        //proximity로 비콘의 거리를 알 수 있다.
        //비콘은 저 에너지 장치이다. 365일 24시간 끊임없이 신호를 보내면서 배터리 소모는 매우 적다.
        //디바이스는 비콘과의 거리를 계산할 수 있다. 이는 세 개의 범위로 분류 된다.
        //• Far: 10미터 이상 떨어져 있다.
        //• Near: 몇 미터 이내에 있다.
        //• Immediate: 몇 센티미터 이내에 있다.
        case .immediate: //몇 센티미터 이내에 있다.
            beaconStatusImage.image = #imageLiteral(resourceName: "arKit-marker-1")
        case .near: //몇 미터 이내에 있다.
            beaconStatusImage.image = #imageLiteral(resourceName: "arKit-marker-2")
        case .far: //10미터 이상 떨어져 있다.
            beaconStatusImage.image = #imageLiteral(resourceName: "arKit-marker-3")
        case .unknown:
            beaconStatusImage.image = #imageLiteral(resourceName: "arKit-marker-4")
        }
        
        // Start auto scan, but only if the app is in the foreground
        // and there is no active billboard
        if UIApplication.shared.applicationState == .active && (billboard == nil || billboard?.hasBillboardNode == false) {
            //앱이 foreground에 있고, 현재 표시되는 빌보드가 없는 경우
            startAutoscanTimer()
            //QR 코드 감지를 활성화하는 타이머 시작
        }
    }
    
    func locationManager(_ locationManager: LocationManager, didLeaveBeacon beacon: CLBeacon) {
        stopAutoscanTimer()
        //타이머를 멈춘다. QR 코드 자동 감지를 멈춘다.
        
        beaconStatusImage.isHidden = true
        beaconStatusLabel.isHidden = true
        //비콘 상태를 나타내는 UI들을 감춘다.
    }
}

//Time for testing
//출발지, 목적지, 출발지로 되돌아가는 3개의 웨이 포인트 경로가 있다. 최초의 default 웨이 포인트 중에
//초기 위치는 목적지에서 약 1000m 거리를 갖도록 설정되어 있다.
//좌표와 이름 외에도 각 웨이 포인트에는 시간이 있다. 상대적으로 다음 위치로 이동하는 데 걸리는 시간을 알 수 있다. 첫 설정은 30초 씩

//Xcode 시뮬레이터를 실행하고 .gpx 파일에서 정의된 경로를 위치로 선택할 수 있다. p.270


