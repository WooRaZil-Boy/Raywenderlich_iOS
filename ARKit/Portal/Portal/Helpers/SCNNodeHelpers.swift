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

import SceneKit

func createPlaneNode(center: vector_float3,
                     extent: vector_float3) -> SCNNode {
  //렌더링할 plane의 중심과 범위를 나타내는 vector_float3 타입의 매개변수

  let plane = SCNPlane(width: CGFloat(extent.x), height: CGFloat(extent.z))
  //Geometry 생성(Editor의 녹색 객체). 평면의 너비와 높이를 지정하여 SCNPlane을 인스턴스화
  
  let planeMaterial = SCNMaterial() //material 초기화
  planeMaterial.diffuse.contents = UIColor.yellow.withAlphaComponent(0.4) //40%의 노란색
  plane.materials = [planeMaterial] //plane의 material에 추가. plane의 텍스처와 색상 정의

  let planeNode = SCNNode(geometry: plane) //plane 구조의 SCNNode 생성
  //SCNPlane은 SCNGeometry를 상속 한다. SCNGeometry는 SceneKit에서 렌더링되어 보이는 객체의 형태만 제공한다.
  //이를 SCNNode 객체에 연결하여 위치와 방향을 지정해 준다.
  //여러 노드가 동일한 SCNGeometry를 참조할 수 있으므로 Scene의 다른 위치에 나타날 수 있다.
  planeNode.position = SCNVector3Make(center.x, 0, center.z) //노드의 위치 설정
  planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2, 1, 0, 0)
  //SceneKit의 plane은 수직이 default이다. 따라서 90도 회전 시켜 평면으로 만든다.
  
  return planeNode
}

func updatePlaneNode(_ node: SCNNode,
                     center: vector_float3,
                     extent: vector_float3) {

  let geometry = node.geometry as? SCNPlane //SCNPlane의 Geometry가 있는지 확인한다.
  geometry?.width = CGFloat(extent.x) //높이
  geometry?.height = CGFloat(extent.z) //너비
  //전달된 ARPlaneAnchor의 새 값으로 geometry를 업데이트 한다.

  node.position = SCNVector3Make(center.x, 0, center.z) //Plane 노드의 위치를 새 위치로 업데이트
}

