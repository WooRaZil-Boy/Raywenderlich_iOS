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

let SURFACE_LENGTH: CGFloat = 3.0
let SURFACE_HEIGHT: CGFloat = 0.2
let SURFACE_WIDTH: CGFloat = 3.0
//포탈 바닥과 천장에 대한 상수 정의

let SCALEX: Float = 2.0
let SCALEY: Float = 2.0
//표면(surfaces)에 텍스처를 스케일링하고 반복하는 상수 정의

let WALL_WIDTH:CGFloat = 0.2
let WALL_HEIGHT:CGFloat = 3.0
let WALL_LENGTH:CGFloat = 3.0
//벽의 너비, 높이, 길이 상수 정의

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

func repeatTextures(geometry: SCNGeometry, scaleX: Float, scaleY: Float) {
  //SCNGeometry 객체와 스케일 배율 X, Y를 인자로 사용한다.
  
  geometry.firstMaterial?.diffuse.wrapS = SCNWrapMode.repeat
  geometry.firstMaterial?.selfIllumination.wrapS = SCNWrapMode.repeat
  geometry.firstMaterial?.normal.wrapS = SCNWrapMode.repeat
  geometry.firstMaterial?.specular.wrapS = SCNWrapMode.repeat
  geometry.firstMaterial?.emission.wrapS = SCNWrapMode.repeat
  geometry.firstMaterial?.roughness.wrapS = SCNWrapMode.repeat
  //텍스처 매핑은 S와 T 좌표계를 사용한다. 여기서 S는 X, T는 Y에 해당한다.
  //SCNWrapMode.repeat으로 해당 텍스처를 S좌표에 맞춰 반복해 래핑한다.
  
  geometry.firstMaterial?.diffuse.wrapT = SCNWrapMode.repeat
  geometry.firstMaterial?.selfIllumination.wrapT = SCNWrapMode.repeat
  geometry.firstMaterial?.normal.wrapT = SCNWrapMode.repeat
  geometry.firstMaterial?.specular.wrapT = SCNWrapMode.repeat
  geometry.firstMaterial?.emission.wrapT = SCNWrapMode.repeat
  geometry.firstMaterial?.roughness.wrapT = SCNWrapMode.repeat
  //텍스처 매핑은 S와 T 좌표계를 사용한다. 여기서 S는 X, T는 Y에 해당한다.
  //SCNWrapMode.repeat으로 해당 텍스처를 T좌표에 맞춰 반복해 래핑한다.
  
  geometry.firstMaterial?.diffuse.contentsTransform =
    SCNMatrix4MakeScale(scaleX, scaleY, 0)
  geometry.firstMaterial?.selfIllumination.contentsTransform =
    SCNMatrix4MakeScale(scaleX, scaleY, 0)
  geometry.firstMaterial?.normal.contentsTransform =
    SCNMatrix4MakeScale(scaleX, scaleY, 0)
  geometry.firstMaterial?.specular.contentsTransform =
    SCNMatrix4MakeScale(scaleX, scaleY, 0)
  geometry.firstMaterial?.emission.contentsTransform =
    SCNMatrix4MakeScale(scaleX, scaleY, 0)
  geometry.firstMaterial?.roughness.contentsTransform =
    SCNMatrix4MakeScale(scaleX, scaleY, 0)
  //각 텍스처를 인자로 들어온 스케일 비율로 설정한다.
}

func makeOuterSurfaceNode(width: CGFloat,
                          height: CGFloat,
                          length: CGFloat) -> SCNNode {
  //??? 파라미터 인자가 안 쓰임
  
  let outerSurface = SCNBox(width: SURFACE_WIDTH,
                            height: SURFACE_HEIGHT,
                            length: SURFACE_LENGTH,
                            chamferRadius: 0)
  //바닥과 천장 치수 상수를 사용하여, 박스형태의 surface 지오메트리 작성
  outerSurface.firstMaterial?.diffuse.contents = UIColor.white
  outerSurface.firstMaterial?.transparency = 0.000001
  //투명도 매우 낮게 설정해 객체가 보이지 않도록 설정한다.
  
  let outerSurfaceNode = SCNNode(geometry: outerSurface) //지오메트리로 SCNNode 생성
  outerSurfaceNode.renderingOrder = 10 //렌더링 순서
  //렌더링 순서가 클수록 마지막에 렌더링 된다.
  
  return outerSurfaceNode
}

func makeFloorNode() -> SCNNode {
  let outerFloorNode = makeOuterSurfaceNode(width: SURFACE_WIDTH,
                                            height: SURFACE_HEIGHT,
                                            length: SURFACE_LENGTH)
  //바닥 치수(천장 치수와 같다) 상수를 사용하여 floor 노드의 아래 쪽을 만든다.
  outerFloorNode.position = SCNVector3(SURFACE_HEIGHT * 0.5,
                                       -SURFACE_HEIGHT, 0)
  //위치를 지정해 준다. floor 노드의 아래에 배치
  
  let floorNode = SCNNode() //floor의 inner와 outer surface를 모두 보유하는 노드
  floorNode.addChildNode(outerFloorNode) //outerFloorNode를 자식노드로 추가한다.
  
  let innerFloor = SCNBox(width: SURFACE_WIDTH,
                          height: SURFACE_HEIGHT,
                          length: SURFACE_LENGTH,
                          chamferRadius: 0)
  //바닥의 형상을 한 Box 지오메트리를 만든다.
  
  innerFloor.firstMaterial?.lightingModel = .physicallyBased
  innerFloor.firstMaterial?.diffuse.contents =
    UIImage(named: "Assets.scnassets/floor/textures/Floor_Diffuse.png")
  innerFloor.firstMaterial?.normal.contents =
    UIImage(named: "Assets.scnassets/floor/textures/Floor_Normal.png")
  innerFloor.firstMaterial?.roughness.contents =
    UIImage(named: "Assets.scnassets/floor/textures/Floor_Roughness.png")
  innerFloor.firstMaterial?.specular.contents =
    UIImage(named: "Assets.scnassets/floor/textures/Floor_Specular.png")
  innerFloor.firstMaterial?.selfIllumination.contents =
    UIImage(named: "Assets.scnassets/floor/textures/Floor_Gloss.png")
  //해당 텍스처를 설정해 준다.
  
  repeatTextures(geometry: innerFloor, scaleX: SCALEX, scaleY: SCALEY)
  //텍스처 반복하는 helper
  
  let innerFloorNode = SCNNode(geometry: innerFloor) //지오메트리 사용하여 노드 생성
  innerFloorNode.renderingOrder = 100 //렌더링 순서를 outerFloorNode보다 높게 설정한다.
  //이렇게 하면, 사용자가 포탈 외부에 있을 때 innerFloorNode가 보이지 않게 된다.
  innerFloorNode.position = SCNVector3(SURFACE_HEIGHT * 0.5, 0, 0)
  //위치 지정
  floorNode.addChildNode(innerFloorNode) //자식 노드로 추가
  
  return floorNode
}

func makeCeilingNode() -> SCNNode {
  //makeFloorNode와 로직이 거의 비슷하다.
  let outerCeilingNode = makeOuterSurfaceNode(width: SURFACE_WIDTH,
                                              height: SURFACE_HEIGHT,
                                              length: SURFACE_LENGTH)
  outerCeilingNode.position = SCNVector3(SURFACE_HEIGHT * 0.5,
                                         SURFACE_HEIGHT, 0)
  let ceilingNode = SCNNode()
  ceilingNode.addChildNode(outerCeilingNode)
  
  let innerCeiling = SCNBox(width: SURFACE_WIDTH,
                            height: SURFACE_HEIGHT,
                            length: SURFACE_LENGTH,
                            chamferRadius: 0)
  
  innerCeiling.firstMaterial?.lightingModel = .physicallyBased
  innerCeiling.firstMaterial?.diffuse.contents =
    UIImage(named: "Assets.scnassets/ceiling/textures/Ceiling_Diffuse.png")
  innerCeiling.firstMaterial?.emission.contents =
    UIImage(named: "Assets.scnassets/ceiling/textures/Ceiling_Emis.png")
  innerCeiling.firstMaterial?.normal.contents =
    UIImage(named: "Assets.scnassets/ceiling/textures/Ceiling_Normal.png")
  innerCeiling.firstMaterial?.specular.contents =
    UIImage(named: "Assets.scnassets/ceiling/textures/Ceiling_Specular.png")
  innerCeiling.firstMaterial?.selfIllumination.contents =
    UIImage(named: "Assets.scnassets/ceiling/textures/Ceiling_Gloss.png")
  
  repeatTextures(geometry: innerCeiling, scaleX: SCALEX, scaleY: SCALEY)
  
  let innerCeilingNode = SCNNode(geometry: innerCeiling)
  innerCeilingNode.renderingOrder = 100
  innerCeilingNode.position = SCNVector3(SURFACE_HEIGHT * 0.5, 0, 0)
  ceilingNode.addChildNode(innerCeilingNode)
  
  return ceilingNode
}

func makeWallNode(length: CGFloat = WALL_LENGTH,
                  height: CGFloat = WALL_HEIGHT,
                  maskLowerSide:Bool = false) -> SCNNode {
  //벽 노드를 만든다. makeFloorNode, makeCeilingNode과 로직이 비슷하다.
  
  let outerWall = SCNBox(width: WALL_WIDTH,
                         height: height,
                         length: length,
                         chamferRadius: 0)
  //Box 지오메트리를 생성한다.
  
  outerWall.firstMaterial?.diffuse.contents = UIColor.white //흰 색상
  outerWall.firstMaterial?.transparency = 0.000001 //투명도
  //이렇게 흰 색상에 투명도를 낮추면 시스루 효과를 얻을 수 있다.
  
  let outerWallNode = SCNNode(geometry: outerWall) //지오메트리로 노드 생성
  let multiplier: CGFloat = maskLowerSide ? -1 : 1
  //maskLowerSide가 true이면, 외벽이 벽 노드의 좌표계에서 내벽 아래에 배치된다. 그렇지 않으면 위에 놓인다.
  outerWallNode.position = SCNVector3(WALL_WIDTH*multiplier,0,0)
  //외벽 X 치수의 벽 너비 만큼 위치 설정
  outerWallNode.renderingOrder = 10 //렌더 순서를 낮은 순서로 설정하면 먼저 렌더링한다.
  //이렇게 하면 outer에서 inner가 보이지 않게 된다.
  
  let wallNode = SCNNode() //벽 노드 생성하고
  wallNode.addChildNode(outerWallNode) //자식 노드로 추가
  
  let innerWall = SCNBox(width: WALL_WIDTH,
                         height: height,
                         length: length,
                         chamferRadius: 0)
  //inner wall 생성
  
  innerWall.firstMaterial?.lightingModel = .physicallyBased
  innerWall.firstMaterial?.diffuse.contents =
    UIImage(named: "Assets.scnassets/wall/textures/Walls_Diffuse.png")
  innerWall.firstMaterial?.metalness.contents =
    UIImage(named: "Assets.scnassets/wall/textures/Walls_Metalness.png")
  innerWall.firstMaterial?.roughness.contents =
    UIImage(named: "Assets.scnassets/wall/textures/Walls_Roughness.png")
  innerWall.firstMaterial?.normal.contents =
    UIImage(named: "Assets.scnassets/wall/textures/Walls_Normal.png")
  innerWall.firstMaterial?.specular.contents =
    UIImage(named: "Assets.scnassets/wall/textures/Walls_Spec.png")
  innerWall.firstMaterial?.selfIllumination.contents =
    UIImage(named: "Assets.scnassets/wall/textures/Walls_Gloss.png")
  //텍스처를 입힌다.
  
  let innerWallNode = SCNNode(geometry: innerWall) //노드 생성
  innerWallNode.renderingOrder = 100 //렌더 순서를 높은 순서로 설정하면 나중에 렌더링 된다.
  wallNode.addChildNode(innerWallNode)
  
  return wallNode
}


