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

class Pig: SCNNode { //Glasses와 유사하다.
  let occlusionNode: SCNNode

  // Set up brow
  private var neutralBrowY: Float = 0 //안면 요소를 애니메이션화 할 때는 중립적인 위치를 기록해야 한다. 시작위치
  private lazy var browNode = childNode(withName: "brow",
                                        recursively: true)! //노드 참조
  //Pig의 자식노드에서 brow 이름의 노드를 가져온다.

  // Set up right eye
  private var neutralRightEyeX: Float = 0 //오른쪽 눈의 시작 위치
  private var neutralRightEyeY: Float = 0 //오른쪽 눈의 시작 위치
  private lazy var eyeRightNode = childNode(withName: "eyeRight",
                                            recursively: true)!
  //Pig의 자식노드에서 eyeRight(눈) 이름의 노드를 가져온다.
  private lazy var pupilRightNode = childNode(withName: "pupilRight",
                                              recursively: true)!
  //Pig의 자식노드에서 pupilRight(눈동자) 이름의 노드를 가져온다.

  // Set up left eye
  private var neutralLeftEyeX: Float = 0
  private var neutralLeftEyeY: Float = 0
  private lazy var eyeLeftNode = childNode(withName: "eyeLeft",
                                           recursively: true)!
  private lazy var pupilLeftNode = childNode(withName: "pupilLeft",
                                             recursively: true)!
  //right eye와 같다.
  //왼쪽 눈동자가 오른쪽 눈동자와 크기가 같기 때문에 별도의 변수가 필요하지 않다.

  // Get size of pupils
  private lazy var pupilWidth: Float = { //눈동자의 너비
    let (min, max) = pupilRightNode.boundingBox
    return max.x - min.x
  }()
  private lazy var pupilHeight: Float = { //눈동자의 높이
    let (min, max) = pupilRightNode.boundingBox
    return max.y - min.y
  }()

  // Set up mouth
  private var neutralMouthY: Float = 0
  private lazy var mouthNode = childNode(withName: "mouth",
                                         recursively: true)!
  //Pig의 자식노드에서 mouth(입) 이름의 노드를 가져온다.

  // Get size of mouth
  private lazy var mouthHeight: Float = { //입 높이
    let (min, max) = mouthNode.boundingBox
    return max.y - min.y
  }()


  init(geometry: ARSCNFaceGeometry) {
    //얼굴형상 지오메트리를 매개변수로 사용
    //색상을 렌더링하지 않고, 깊이를 렌더링하도록 한다.
    occlusionNode = SCNNode(geometry: geometry) //지오메트리로 노드 생성
    occlusionNode.renderingOrder = -1 //렌더링 순서가 클수록 마지막에 렌더링된다.
    //occlusionNode는 얼굴 형상을 가져오므로, 안경 보다 먼저 렌더링 되어야 한다.

    super.init()
    self.geometry = geometry

    guard let url = Bundle.main.url(forResource: "pig",
                                    withExtension: "scn",
                                    subdirectory: "Models.scnassets")
      else {
        fatalError("Missing resource")
    }
    //pig.scn이 메인 번들에 있는 지 확인한다.

    let node = SCNReferenceNode(url: url)!
    //별도의 Scene 파일을 로드하는 참조 노드 생성
    node.load() //참조된 별도의 Scene 파일에서 노드로 내용을 로드한다.

    addChildNode(node) //돼지 노드를 자식 노드로 추가한다.

    // Set Baselines
    neutralBrowY = browNode.position.y
    neutralRightEyeX = pupilRightNode.position.x
    neutralRightEyeY = pupilRightNode.position.y
    neutralLeftEyeX = pupilLeftNode.position.x
    neutralLeftEyeY = pupilLeftNode.position.y
    neutralMouthY = mouthNode.position.y
    //중립적인 기본 위치 설정해 준다.
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("\(#function) has not been implemented")
  }

  // - Tag: ARFaceAnchor Update
  func update(withFaceAnchor anchor: ARFaceAnchor) {
//    //마스크를 추가할 때 사용한 update와 유사하다.
//    let faceGeometry = occlusionNode.geometry as! ARSCNFaceGeometry
//    //업데이트된 얼굴 추적 지오메트리를 가져온다.
//    faceGeometry.update(from: anchor.geometry)
    
    blendShapes = anchor.blendShapes
    //특정 표정을 매핑하기 위해서는 지오메트리 대신 blendShapes를 사용해야 한다.
    //ARKit에게 face anchor에서 blendShapes dictionary를 읽고 그에 따라 업데이트 하도록 한다.
  }

  // - Tag: BlendShapeAnimation
  var blendShapes: [ARFaceAnchor.BlendShapeLocation: Any] = [:] { //dictionary
    //추적할 blend 모양을 결정한다.
    didSet {
      guard

        // Brow
        let browInnerUp = blendShapes[.browInnerUp] as? Float,
    
        // Right eye
        let eyeLookInRight = blendShapes[.eyeLookInRight] as? Float,
        let eyeLookOutRight = blendShapes[.eyeLookOutRight] as? Float,
        let eyeLookUpRight = blendShapes[.eyeLookUpRight] as? Float,
        let eyeLookDownRight = blendShapes[.eyeLookDownRight] as? Float,
        let eyeBlinkRight = blendShapes[.eyeBlinkRight] as? Float,

        // Left eye blink
        let eyeBlinkLeft = blendShapes[.eyeBlinkLeft] as? Float,

        // Left eye
        let eyeLookInLeft = blendShapes[.eyeLookInLeft] as? Float,
        let eyeLookOutLeft = blendShapes[.eyeLookOutLeft] as? Float,
        let eyeLookUpLeft = blendShapes[.eyeLookUpLeft] as? Float,
        let eyeLookDownLeft = blendShapes[.eyeLookDownLeft] as? Float,

        // Mouth
        let mouthOpen = blendShapes[.jawOpen] as? Float
        
        //ARFaceAnchor.BlendShapeLocation 값을 보유하고 있을 변수들. 0 ~ 1 사이의 값을 가진다.

        else { return }

      // Brow
      let browHeight = (browNode.boundingBox.max.y - browNode.boundingBox.min.y)
      //경계의 최대 값에서 최소 값을 빼서 높이를 구한다.
      browNode.position.y = neutralBrowY + browHeight * browInnerUp
      //browNode를 배치할 위치를 결정한다. //기본 위치 값에서 높이와 현재 값을 곱한 값을 더한다.

      // Right eye look
      let rightPupilPos = SCNVector3(x: (neutralRightEyeX - pupilWidth) * (eyeLookInRight - eyeLookOutRight), y: (neutralRightEyeY - pupilHeight) * (eyeLookUpRight - eyeLookDownRight), z: pupilRightNode.position.z)
      pupilRightNode.position = rightPupilPos

      // Right eye blink
      eyeRightNode.scale.y = 1 - eyeBlinkRight //눈을 얼마나 감을 지.

      // Left Eye
      let leftPupilPos = SCNVector3(x: (neutralLeftEyeX - pupilWidth) * (eyeLookOutLeft - eyeLookInLeft), y: (neutralLeftEyeY - pupilHeight) * (eyeLookUpLeft - eyeLookDownLeft), z: pupilLeftNode.position.z)
      pupilLeftNode.position = leftPupilPos

      // Left eye blink
      eyeLeftNode.scale.y = 1 - eyeBlinkLeft

      // Mouth
      mouthNode.position.y = neutralMouthY - mouthHeight * mouthOpen
        
      //눈썹과 입은 스케일 변화 없이 단순히 움직이는 것이므로 노드의 position.y로 값을 설정해 주면 된다.
      //눈은 스케일 변화(찡그릴 때)가 있으므로 scale.y도 설정해 줘야 한다.
    }
  }
}

//ARKit은 얼굴의 기본 동작을 추적하기 위해 face mesh를 제공한다.
//눈을 깜박이거나 눈썹을 치켜뜨는 것과 같은 특정 표정을 매핑하기 위해서는 blendShapes Dictionary를 사용한다.
//blendShapes 딕셔너리에는 ARFaceAnchor.BlendShapeLocation 형식의 키가 들어 있다.
//각 키는 중립 위치를 기준으로 해당 지형의 현재 위치를 나타내는 값이다. 0.0(중립) ~ 1.0(최대 이동). p.333
//총 52개의 BlendShape가 있다. 좌우의 기준은 해당 객체로 한다.
//https://developer.apple.com/documentation/arkit/arfaceanchor.blendshapelocation
