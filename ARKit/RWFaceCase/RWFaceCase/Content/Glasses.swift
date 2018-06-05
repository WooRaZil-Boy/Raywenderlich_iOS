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

import ARKit
import SceneKit

class Glasses: SCNNode {
  let occlusionNode: SCNNode

  init(geometry: ARSCNFaceGeometry) {
    //얼굴형상 지오메트리를 매개변수로 사용
    geometry.firstMaterial!.colorBufferWriteMask = []
    //색상을 렌더링하지 않고, 깊이를 렌더링하도록 한다.
    occlusionNode = SCNNode(geometry: geometry) //지오메트리로 노드 생성
    occlusionNode.renderingOrder = -1 //렌더링 순서가 클수록 마지막에 렌더링된다.
    //occlusionNode는 얼굴 형상을 가져오므로, 안경 보다 먼저 렌더링 되어야 한다.

    super.init()

    addChildNode(occlusionNode) //얼굴 노드를 자식 노드로 추가한다.

    guard let url = Bundle.main.url(forResource: "glasses",
                                    withExtension: "scn",
                                    subdirectory: "Models.scnassets")
      else {
        fatalError("Missing resource")
    }
    //glasses.scn이 메인 번들에 있는 지 확인한다.

    let node = SCNReferenceNode(url: url)!
    //별도의 Scene 파일을 로드하는 참조 노드 생성
    node.load() //참조된 별도의 Scene 파일에서 노드로 내용을 로드한다.

    addChildNode(node) //안경 노드를 자식 노드로 추가한다.
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("\(#function) has not been implemented")
  }

  // - Tag: ARFaceAnchor Update
  func update(withFaceAnchor anchor: ARFaceAnchor) {
    //마스크를 추가할 때 사용한 update와 유사하다.
    let faceGeometry = occlusionNode.geometry as! ARSCNFaceGeometry
    //업데이트된 얼굴 추적 지오메트리(occlusionNode.geometry)를 가져온다.
    faceGeometry.update(from: anchor.geometry)
  }
}
