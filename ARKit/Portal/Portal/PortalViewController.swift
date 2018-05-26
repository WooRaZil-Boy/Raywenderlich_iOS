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
import ARKit

class PortalViewController: UIViewController {

  @IBOutlet var sceneView: ARSCNView?
  //3D SceneKit 객체를 사용하여 카메라 뷰를 AR하는 데 사용한다.
  @IBOutlet weak var messageLabel: UILabel?
  //사용자에게 메시지 표시. ex.앱과 상호작용하는 방법 알려준다.
  @IBOutlet weak var sessionStateLabel: UILabel?
  //세션 중단을 사용자에게 알린다(오류 시에만 보인다). ex.앱이 백그라운드로 갈 때 또는 주변 조명이 부족한 경우
  
  override func viewDidLoad() {
    super.viewDidLoad()
    resetLabels()
    runSession()
  }
  
  func resetLabels() {
    messageLabel?.alpha = 1.0
    messageLabel?.text =
      "Move the phone around and allow the app to find a plane." +
      "You will see a yellow horizontal plane."
    sessionStateLabel?.alpha = 0.0
    sessionStateLabel?.text = ""
  }
  
  func runSession() {
    let configuration = ARWorldTrackingConfiguration.init()
    //ARWorldTrackingConfiguration 객체 생성 //ARWorldTrackingConfiguration()와 같다.
    //ARSession에서 사용할 수있는 구성에는 ARSessionConfiguration과 ARWorldTrackingConfiguration이 있다.
    //AROrientationTrackingConfiguration(3DOF), ARWorldTrackingConfiguration(6DOF)
    //ARSessionConfiguration은 위치가 아닌 장치의 회전만을 고려하기 때문에 사용하지 않는 것이 좋다.
    //A9 프로세서를 사용하는 디바이스의 경우 ARWorldTrackingSessionConfiguration이 최상의 구성이다.
    configuration.planeDetection = .horizontal //수평면 탐지
    //Plane의 범위는 변경될 수 있으며 카메라가 움직이며 여러 Plane이 하나로 합쳐질 수 있다.
    //ARPlaneAnchors가 ARSession 앵커 배열에 자동으로 추가되고,
    //ARSCNView는 ARPlaneAnchor 객체를 SCNNode로 자동 변환한다.
    configuration.isLightEstimationEnabled = true //조명 추적 계산 사용
    //가상 콘텐츠를 더 사실적으로 보이게 한다.
    sceneView?.session.run(configuration) //해당 구성으로 세션 시작
    //sceneView에 표시되는 카메라에서 ARKit세션과 비디오 캡쳐가 시작된다.
    
    #if DEBUG //디버그 빌드의 경우 옵션을 추가한다.
      sceneView?.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
    #endif
    
    sceneView?.delegate = self //delegate 설정 //스토리보드에서 설정해 줄 수도 있다.
  }
}

extension PortalViewController: ARSCNViewDelegate {
  //세션의 planeDetection을 .horizontal로 설정했는데, 이는 앱이 수평면을 감지할 수 있음을 의미한다.
  //캠쳐된 plane 정보는 ARSCNViewDelegate 프로토콜의 delegate에서 콜백 메서드를 받을 수 있다.
  func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
    //새로운 plane을 감지하면 호출된다. ARSCNView는 plane의 ARPlaneAnchor를 자동으로 추가한다(planeDetection).
    DispatchQueue.main.async { //콜백은 백그라운드 스레드에서 발생한다. UI업데이트는 메인 스레드에서 실행해야 한다.
      if let planeAnchor = anchor as? ARPlaneAnchor { //트리거를 발생시킨 앵커가 ARPlaneAnchor인지 확인

        #if DEBUG //디버그 모드에서만 실행
          let debugPlaneNode = createPlaneNode(center: planeAnchor.center, extent: planeAnchor.extent)
          //ARKit에 의해 감지된 planeAnchor의 중심 좌표와 범위 좌표를 전달하여 SCNNode 객체를 생성한다.
          node.addChildNode(debugPlaneNode)
          //노드 객체는 ARSCNView에서 Scene에 자동으로 추가되는 빈 SCNNode이다(좌표는 앵커와 동일).
          //debugPlaneNode를 자식 노드로 추가한다.
        #endif

        self.messageLabel?.alpha = 1.0
        self.messageLabel?.text = "Tap on the detected horizontal plane to place the portal"
        //메시지 업데이트
      }
    }
  }
  
  func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
    //ARKit은 새로운 특징 지점을 기반으로 plane의 위치와 범위를 지속적으로 업데이트 한다.
    //해당 ARAnchor가 업데이트 될 때 delegate에서 콜백 메서드를 받는다.
    DispatchQueue.main.async { //UI업데이트는 메인 스레드에서 실행되야 한다.
      if let planeAnchor = anchor as? ARPlaneAnchor, node.childNodes.count > 0 {
        //ARAnchor가 ARPlaneAnchor인지 확인하고, Plane의 SCNNode에 해당하는 하나 이상의 하위 노드가 있는 지 확인
        updatePlaneNode(node.childNodes[0], center: planeAnchor.center, extent: planeAnchor.extent)
        //Plane의 좌표와 크기를 ARPlaneAnchor의 새 값으로 업데이트
      }
    }
  }
}

//ARKit은 모든 센서 및 카메라 데이터를 처리하지만, 가상 콘텐츠는 실제로 렌더링하지 않는다.
//Scene에 콘텐츠를 렌더링하려면, ARKit과 함께 사용하는 다양한 렌더러(SceneKit, SpriteKit)을 사용해야 한다.

//Helpers 폴더에 여러 유용한 유틸리티 클래스가 있다.
