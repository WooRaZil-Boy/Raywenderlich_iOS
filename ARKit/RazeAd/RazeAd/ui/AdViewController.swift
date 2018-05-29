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

class AdViewController: UIViewController {
  @IBOutlet var sceneView: ARSCNView!
  weak var targetView: TargetView!

  private var billboard: BillboardContainer?

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

    // Run the view's session
    sceneView.session.run(configuration)
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)

    // Pause the view's session
    sceneView.session.pause()
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
        guard let billboard = billboard else { return nil } //빌보드가 없다면 종료
        var node: SCNNode? = nil
        
//        DispatchQueue.main.async { //이 메서드는 일반적으로 메인 스레드에서 호출되지 않는다.
        //따라서 UI업데이트를 할때는 메인 스레드에서 호출해야 한다. 여기서는 UI관련 처리가 없으므로 없어도 된다.
            switch anchor {
            case billboard.billboardAnchor: //앵커가 빌보드 앵커인지 확인
                let billboardNode = addBillboardNode() //SCNNode 반환
                node = billboardNode
            default:
                break
            }
//        }
        
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
}

extension AdViewController {
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let currentFrame = sceneView.session.currentFrame else {
        //가장 최근 세션에서 캡쳐된 AR scene 정보를 가지고 있는 비디오 프레임이 없다면 반환
        //비디오 피드의 단일 캡쳐로, ARKit은 이를 분석하고 디바이스의 모션 감지 기능과 결합하여 AR을 만든다.
        return
    }
    
    DispatchQueue.global(qos: .background).async {
        //이미지 처리는 CPU의 자원을 많이 소모하므로 백그라운드에서 실행하는 것이 자원관리에 좋다.
        do {
            let request = VNDetectRectanglesRequest { request, error in
                //Vison 프레임워크로 사각형을 감지한 후, VNDetectRectanglesRequest를 사용해
                //해당 사각형을 ARKit 객체로 변환할 수 있다.
                //사각형 영역을 찾는 이미지 분석이 완료되면 클로저가 호출된다.
                guard let results = request.results?.compactMap({ $0 as? VNRectangleObservation }),
                    //결과는 반환되는 request의 results에서 가져올 수 있다(Any 타입).
                    //감지된 각 사각형을 VNRectangleObservation 타입으로 변환하여 배열에 저장한다.
                    let result = results.first else {
                        //감지된 결과가 하나도 없다면 반환
                        //VNDetectRectanglesRequest의 maximumObservations 속성은 default가 1이다.
                        //따라서 따로 설정하지 않으면 가장 사각형에 가깝다고 판단하는 하나의 형태만 감지한다.
                        print("[Vision] VNRequest produced no result")
                        return
                }
                
                let coordinates: [matrix_float4x4] = [result.topLeft, result.topRight, result.bottomRight, result.bottomLeft].compactMap {
                    //VNRectangleObservation로 감지된 사각형의 네 꼭지점을 식별할 수 있다.
                    //Vison Framework는 2D 이미지에서 작동하므로, 결과는 항상 비트맵 이미지 내의 2D좌표이다.
                    //이 4개의 좌표를 배열로 처리하면 순차적으로 처리하기 쉬워진다.
                    guard let hitFeature = currentFrame.hitTest($0, types: .featurePoint).first else {
                        //map의 각 배열의 요소(4개의 좌표)로 currentFrame의 hiTest를 진행한다.
                        //Vison 으로 찾은 2D의 좌표를 공간 상의 3D 좌표로 가져올 수 있다.
                        
                        //hitTest에서 사용하는 type에는 4가지가 있다.
                        //• featurePoint : surfac의 점 이지만 앵커는 없다.
                        //• estimatedHorizontalPlane : 검색에 의해 감지되었지만 앵커가 없는 plane 평면
                        //• existingPlane : plane의 크기를 고려하지 않는 연관된 앵커가 있는 plane
                        //• existingPlaneUsingExtent : plane의 크기를 고려한 연관된 앵커가 있는 평면
                        //나머지 3개가 평면을 감지해 내는 것이므로 점을 감지하는 것은 하나밖에 없다.
                        return nil
                    }
                    
                    return hitFeature.worldTransform //hitTest에서 나온 결과를 Transform으로 저장
                }
                
                guard coordinates.count == 4 else { return }
                //map을 거친 후, coordinate은 worldTransform 속성에서 가져온 4x4 행렬의 배열이 된다.
                //사각형을 다루기 때문에 반드시 4개의 좌표가 있어야 한다.
                //ARKit에서 Vison에서 찾은 2D 좌표를 3D로 변환이 하나라도 실패한다면 종료된다.
                
                DispatchQueue.main.async { //UI요소를 추가하고 제거하므로 메인 스레드에서 진행해야 한다.
                    self.removeBillboard() //이전 빌보드가 표시된 경우 제거한다.
                    let (topLeft, topRight, bottomRight, bottomLeft) = (coordinates[0], coordinates[1], coordinates[2], coordinates[3])
                    
                    self.createBillboard(topLeft: topLeft, topRight: topRight, bottomRight: bottomRight, bottomLeft: bottomLeft)
                    //새로운 빌보드를 작성한다. 파라미터로 이전 단계에서 찾은 네 개의 좌표를 전달한다.
                    
                    //디버깅 위한 Dummy
//                    for coordinate in coordinates {
//                        let box = SCNBox(width: 0.01, height: 0.01, length: 0.001, chamferRadius: 0.0)
//                        //10 x 10 x 1 mm 크기의 지오메트리 상자 생성
//                        let node = SCNNode(geometry: box) //지오메트리 상자로 SceneKit 노드 생성
//                        node.transform = SCNMatrix4(coordinate) //SCNMatrix4로 변환한 새 노드 설정
//
//                        self.sceneView.scene.rootNode.addChildNode(node)
//                    }
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
        } catch (let error) {
            //오류 처리
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
        let plane = RectangularPlane(topLeft: topLeft, topRight: topRight, bottomLeft: bottomRight, bottomRight: bottomLeft)
        //사각형 크기와 중심을 계산하는 RectangularPlane 컨테이너에 4개의 행렬 값을 전달한다.
        let anchor = ARAnchor(transform: plane.center)
        //사각형 중심에 위치한 plane에 대한 앵커를 생성한다.
        billboard = BillboardContainer(billboardAnchor: anchor, plane: plane)
        //앵커와 plane으로 BillboardContainer를 생성한다.
        //BillboardContainer는 빌보드에 대한 데이터를 저장하는데 사용하는 자료구조. 액세스할 수 있도록 저장해 둔다.
        sceneView.session.add(anchor: anchor) //앵커 추가
        
        print("New billboard created")
    }
    
    func addBillboardNode() -> SCNNode? {
        guard let billboard = billboard else { return nil }
        
        let rectangle = SCNPlane(width: billboard.plane.width, height: billboard.plane.height)
        //createBillboard에서 저장한 RectangularPlane 구조체 값으로 SCNPlane(지오메트리) 생성
        let rectangleNode = SCNNode(geometry: rectangle) //지오메트리로 SCNNode 생성
        self.billboard?.billboardNode = rectangleNode //컨테이너에 노드 추가
        
        return rectangleNode
    }
    
    func removeBillboard() {
        if let anchor = billboard?.billboardAnchor {
            //guard로 billboard 속성이 nil인지 아닌지 확인할 수도 있지만, 앵커만 확인하면 되므로 간단히 구현
            sceneView.session.remove(anchor: anchor) //앵커 있는 경우 ARKit 세션에서 앵커 제거
            billboard?.billboardNode?.removeFromParentNode()
            billboard = nil
            //노드 삭제
        }
    }
}

//Plane detection vs. object detection
//평면 탐지와 객체 탐지는 다르다. ARKit은 처음에는 평면의 일부만 탐지한다. 디바이스가 움직이면 평면이 실시간으로 업데이트되고
//ARKit은 평면을 확장한다. 평면은 전체 표면의 경계를 감지하도록 설계되었다. 객체 탐지는 Vision Framework를 사용해
//특정 모양을 감지한 후 ARKit의 평면 위에 표현할 수 있다.
