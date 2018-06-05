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

enum MaskType: Int { //마스크 유형 열거형. 쉽게 참조하기 위해 열거형을 사용하는 것이 좋다.
  case basic
  case painted
  case zombie
}

class Mask: SCNNode {

  init(geometry: ARSCNFaceGeometry, maskType: MaskType) {
    //ARKit에서 제공한 얼굴의 지오메트리를 인자로 인스턴스를 생성한다.
    //ARKit은 사용자 얼굴의 크기, 모양, 위상 및 현재 표정과 일치하는 3D 메쉬 형상을 제공한다.
    super.init()
    self.geometry = geometry
    self.swapMaterials(maskType: maskType)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("\(#function) has not been implemented")
  }

  // MARK: Materials Setup
  func swapMaterials(maskType: MaskType) {
    guard let material = geometry?.firstMaterial! else { return }
    material.lightingModel = .physicallyBased //조명 모드 물리적으로 생성

    // Reset materials
    material.diffuse.contents = nil
    material.normal.contents = nil
    material.transparent.contents = nil

    switch maskType {
    case .basic: //기본 마스크
      material.lightingModel = .physicallyBased
      material.diffuse.contents = UIColor(red: 0.0,
                                          green: 0.68,
                                          blue: 0.37,alpha: 1)
      //텍스처 설정. //Ray Wenderlich Green
        
    case .painted: //페인팅 마스크
      material.diffuse.contents =
      "Models.scnassets/Masks/Painted/Diffuse.png"
      material.normal.contents =
      "Models.scnassets/Masks/Painted/Normal_v1.png"
      material.transparent.contents =
      "Models.scnassets/Masks/Painted/Transparency.png"

    case .zombie: //좀비 마스크
      material.diffuse.contents =
      "Models.scnassets/Masks/Zombie/Diffuse.png"
      material.normal.contents =
      "Models.scnassets/Masks/Zombie/Normal_v1.png"

    }
  }

  // Tag: ARFaceAnchor Update
  func update(withFaceAnchor anchor: ARFaceAnchor) {
    let faceGeometry = geometry as! ARSCNFaceGeometry
    //업데이트된 얼굴 추적 지오메트리를 가져온다.
    faceGeometry.update(from: anchor.geometry)
  }
}
