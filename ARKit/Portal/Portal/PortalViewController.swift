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

  @IBOutlet weak var crosshair: UIView!
  @IBOutlet var sceneView: ARSCNView?
  //3D SceneKit 객체를 사용하여 카메라 뷰를 AR하는 데 사용한다.
  @IBOutlet weak var messageLabel: UILabel?
  //사용자에게 메시지 표시. ex.앱과 상호작용하는 방법 알려준다.
  @IBOutlet weak var sessionStateLabel: UILabel?
  //세션 중단을 사용자에게 알린다(오류 시에만 보인다). ex.앱이 백그라운드로 갈 때 또는 주변 조명이 부족한 경우
  
  var portalNode: SCNNode? = nil //포탈
  var isPortalPlaced = false //포탈이 Scene에서 렌더링되고 있는지 여부
  var debugPlanes: [SCNNode] = [] //디버그 모드에서 렌더링된 모든 plane을 저장하는 배열
  var viewCenter: CGPoint { //뷰의 가운데 지점
    let viewBounds = view.bounds
    
    return CGPoint(x: viewBounds.width / 2.0, y: viewBounds.height / 2.0)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    resetLabels()
    runSession()
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

    sceneView?.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    //해당 구성과 옵션으로 세션 시작
    //sceneView에 표시되는 카메라에서 ARKit세션과 비디오 캡쳐가 시작된다.
    
    //.resetTracking : 트래킹을 리셋해, 세션이 이전 구성의 디바이스 위치 및 동작 추적을 계속 사용하지 않게 한다.
    //.removeExistingAnchors : 이전 구성에서 세션과 연관된 모든 앵커 객체가 제거 된다.

    #if DEBUG //디버그 빌드의 경우 옵션을 추가한다.
      sceneView?.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
    #endif

    sceneView?.delegate = self //delegate 설정 //스토리보드에서 설정해 줄 수도 있다.
  }
  
  func resetLabels() {
    messageLabel?.alpha = 1.0
    messageLabel?.text = "Move the phone around and allow the app to find a plane. You will see a yellow horizontal plane."
    sessionStateLabel?.alpha = 0.0
    sessionStateLabel?.text = ""
  }
  
  func showMessage(_ message: String, label: UILabel, seconds: Double) {
    //지정한 시간 동안 지정된 레이블에 문자열 메시지 출력하는 helper
    label.text = message
    label.alpha = 1
    
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
      if label.text == message { //지정된 시간 후 label 숨기기
        label.text = ""
        label.alpha = 0
      }
    }
  }
  
  func removeAllNodes() { //Scene에 추가된 기존 SCNNode 객체 모두 제거
    removeDebugPlanes() //렌더링된 모든 plane 객체 삭제
    self.portalNode?.removeFromParentNode() //상위노드에서 포탈 제거
    self.isPortalPlaced = false //포탈 생성 flag를 false로 변경
  }
  
  func removeDebugPlanes() {
    //debugPlanes에 저장하고 있던 plane 객체 모두 삭제
    for debugPlaneNode in self.debugPlanes {
      debugPlaneNode.removeFromParentNode()
    }
    
    self.debugPlanes = []
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    //ARSCNView에 터치가 활성화되어 있다. 사용자가 뷰를 탭하면 해당 메서드가 호출된다.
    if let hit = sceneView?.hitTest(viewCenter, types: [.existingPlaneUsingExtent]).first {
      //ARSCNView의 히트 테스팅을 사용하여, 사용자가 손가락으로 터치한 곳을 감지해, 가상 공간의 위치를 확인할 수 있다.
      //hitTest 메서드는 해당 좌표(중심)를 향해 광선을 쏴서 그 선상에 있는 해당 객체들을 검출하는 것으로 생각하면 된다.
      //.existingPlaneUsingExtent로 해당 선상에서 plane 기반의 객체만 가져온다.
      //광선이 직진하면서 선상의 모든 해당 타입과 교차하는 점을 가져온다. first로 이 중 가장 처음 일치하는 점만 가져온다.
      //결국 여기서는 뷰의 중심을 향해 광선을 쏴서, 해당 선상에서 교차하는 plane 객체 위의 첫번째 점을 hit로 가져온다.
      
      //.featurePoints, .estimatedHorizontalPlane, .existingPlane 등을 사용할 수 있다.
      sceneView?.session.add(anchor: ARAnchor.init(transform: hit.worldTransform))
      //앵커를 찾은 점 위에 추가한다.
      //앵커가 추가되면, delegate의 renderer(_:didAdd:for:)가 호출된다. 거기에 해당 로직을 추가해 준다.
    }
  }
  
  func makePortal() -> SCNNode {
    let portal = SCNNode() //SCNNode 생성
    let box = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0)
    //SCNBox로 큐브 지오메트리(Scene Editor 에서 녹색 객체) 생성
    let boxNode = SCNNode(geometry: box) //지오메트리로 객체 생성
    
    portal.addChildNode(boxNode) //포탈의 하위 노드에 큐브 박스 추가
    
    return portal
  }
}

extension PortalViewController: ARSCNViewDelegate {
  //세션의 planeDetection을 .horizontal로 설정했는데, 이는 앱이 수평면을 감지할 수 있음을 의미한다.
  //캡쳐된 plane 정보는 ARSCNViewDelegate 프로토콜의 delegate에서 콜백 메서드를 받을 수 있다.
  
  //중단이 있는 경우(background로 이동, 여러 응용 프로그램이 foreground에 있을 때 등), 세션을 상태를 재설정 해야 한다.
  //중단 되면, 비디오 캡쳐가 실패하고, ARSession이 데이터를 받지 않으므로 트래킹할 수 없다.
  //앱이 background에서 foreground로 다시 들어오게 되면, 이전에 감지한 렌더링된 수평 plane이 여전히 보인다.
  //그러나 디바이스의 위치나 회전이 변경되면 ARSession이 더 이상 작동하지 않는데 이런 경우 세션을 재 시작해야 한다.
  //ARSCNViewDelegate(ARSessionObserver 프로토콜)을 구현하여 ARSession의 인터럽트나 오류를 감지할 수 있다.
  
  func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
    //새로운 plane을 감지하면 호출된다. ARSCNView는 plane의 ARPlaneAnchor를 자동으로 추가한다(planeDetection).
    DispatchQueue.main.async { //콜백은 백그라운드 스레드에서 발생한다. UI업데이트는 메인 스레드에서 실행해야 한다.
      if let planeAnchor = anchor as? ARPlaneAnchor, !self.isPortalPlaced {
        //트리거를 발생시킨 앵커가 ARPlaneAnchor인지 확인 //포탈이 아직 없을 때에만 감지된 plane을 표시한다.
        #if DEBUG //디버그 모드에서만 실행
          let debugPlaneNode = createPlaneNode(
            center: planeAnchor.center,
            extent: planeAnchor.extent)
          //ARKit에 의해 감지된 planeAnchor의 중심 좌표와 범위 좌표를 전달하여 SCNNode 객체를 생성한다.
          node.addChildNode(debugPlaneNode)
          //노드 객체는 ARSCNView에서 Scene에 자동으로 추가되는 빈 SCNNode이다(좌표는 앵커와 동일).
          //debugPlaneNode를 자식 노드로 추가한다.
          self.debugPlanes.append(debugPlaneNode) //새롭게 감지한 plane을 해당 배열에 추가한다.
        #endif
        self.messageLabel?.alpha = 1.0
        self.messageLabel?.text = """
        Tap on the detected \
        horizontal plane to place the portal
        """
        //메시지 업데이트
      } else if !self.isPortalPlaced {
        //추가된 앵커가 ARPlaneAnchor가 아니고 포털 노드가 아직 배치되지 않은 경우
        //사용자가 포털을 생성하기 위해 화면을 터치하는 경우이다.
        self.portalNode = self.makePortal() //포탈 생성
        
        if let portal = self.portalNode {
          node.addChildNode(portal) //포탈을 해당 노드의 자식 노드로 추가하고
          self.isPortalPlaced = true //포탈 생생 flag를 true로 바꾼다.
          
          self.removeDebugPlanes() //포탈이 생성 되었으므로, plane이 더 이상 필요하지 않다. 제거
          self.sceneView?.debugOptions = [] //디버그 옵션도 빈 배열로 해, 노란 점들을 제거해 준다.
          
          DispatchQueue.main.async { //메인 스레드에서 UI 업데이트
            //레이블들을 재설정하고 숨긴다.
            self.messageLabel?.text = ""
            self.messageLabel?.alpha = 0
          }
        }
      }
    }
  }
 
  func renderer(_ renderer: SCNSceneRenderer,
                didUpdate node: SCNNode,
                for anchor: ARAnchor) {
    //ARKit은 새로운 특징 지점을 기반으로 plane의 위치와 범위를 지속적으로 업데이트 한다.
    //해당 ARAnchor가 업데이트 될 때 delegate에서 콜백 메서드를 받는다.
    DispatchQueue.main.async { //UI업데이트는 메인 스레드에서 실행되야 한다.
      if let planeAnchor = anchor as? ARPlaneAnchor,
        node.childNodes.count > 0, !self.isPortalPlaced  {
        //ARAnchor가 ARPlaneAnchor인지 확인하고, Plane의 SCNNode에 해당하는 하나 이상의 하위 노드가 있는 지 확인
        //포탈이 생성되지 않은 경우에만 plane을 업데이트 한다.
        updatePlaneNode(node.childNodes[0],
                        center: planeAnchor.center,
                        extent: planeAnchor.extent)
        //Plane의 좌표와 크기를 ARPlaneAnchor의 새 값으로 업데이트
      }
    }
  }
  
  func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
    //렌더링 동안 다양한 시간에 작업을 수행하는데 사용한다.
    //이 메서드는 프레임 당 정확히 한 번 호출되며 모든 프레임 별 논리를 수행하는 데 사용한다.
    DispatchQueue.main.async { //메인 스레드에서 UI업데이트를 수행해야 한다.
      if let _ = self.sceneView?.hitTest(self.viewCenter, types: [.existingPlaneUsingExtent]).first {
        //뷰 중심에서 히트 테스트를 수행해 선상에 겹치는 plane의 좌표를 추출한다.
        self.crosshair.backgroundColor = UIColor.green //감지한 결과가 있다면 녹색으로 표기
      } else {
        self.crosshair.backgroundColor = UIColor.lightGray //없다면 회색으로 설정
      }
    }
    
    //이 메서드는 프레임마다 호출되기 때문에, 이전에 해당 plane을 찾아 crosshair가 녹색이 되었더라도
    //움직이면서 히트 테스트의 광선이 앵커 plane을 벗어나게 되면 곧바로 crosshair가 회색이 된다.
  }
  
  func session(_ session: ARSession, didFailWithError error: Error) {
    //세션이 실패할 때 호출된다. 실패 시 세션이 일시 중지되고, 센서 데이터를 수신하지 않는다.
    guard let label = self.sessionStateLabel else { return } //sessionStateLabel 존재 여부 확인
    
    showMessage(error.localizedDescription, label: label, seconds: 3)
    //해당 시간만큼 메시지 출력
  }
  
  func sessionWasInterrupted(_ session: ARSession) {
    //세션이 인터럽트될 때 호출. 즉, 앱이 백그라운드로 이동하여 비디오 캡쳐가 중단될 때 호출된다.
    //인터럽트 상태가 끝날 때까지 추가 프레임 업데이트가 전달되지 않는다.
    guard let label = self.sessionStateLabel else { return }
    
    showMessage("Session interrupted", label: label, seconds: 3)
  }
  
  func sessionInterruptionEnded(_ session: ARSession) {
    //세션 인터럽트가 종료된 후 호출. 인터럽트가 종료되면, 세션은 마지막으로 알려진 상태에서 계속 실행된다.
    //따라서 앵커가 제대로 업데이트 되지 않는데, 그렇기 때문에 세션을 다시 시작해 줘야 한다.
    guard let label = self.sessionStateLabel else { return }
    
    showMessage("Session resumed", label: label, seconds: 3)
    
    DispatchQueue.main.async { //UI관련 업데이트는 메인 스레드에서 호출되어야 한다.
      self.removeAllNodes() //이전에 렌더링된 객체를 제거
      self.resetLabels() //레이블 재 설정
    }
    
    runSession() //세션 다시 시작. 구성을 재설정하고 새로운 구성으로 트래킹을 다시 시작한다.
    //즉, 이전 세션에서 감지한 앵커와 plane 객체가 모두 삭제되면서 새 세션을 실행한다.
  }
}

//ARKit은 모든 센서 및 카메라 데이터를 처리하지만, 가상 콘텐츠는 실제로 렌더링하지 않는다.
//Scene에 콘텐츠를 렌더링하려면, ARKit과 함께 사용하는 다양한 렌더러(SceneKit, SpriteKit)을 사용해야 한다.

//Helpers 폴더에 여러 유용한 유틸리티 클래스가 있다.







