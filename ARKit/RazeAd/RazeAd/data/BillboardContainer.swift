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

protocol VideoNodeHandler: class {
  func createNode() -> SCNNode? //비디오 플레이어에 새로운 SCNNode가 필요할 때 adViewController에 의해 호출된다.
  func removeNode() //노드를 제거해야 할 때 호출된다.
}

protocol VideoPlayerDelegate: class { //비디오 플레이어 delegate
  func didStartPlay() //시작
  func didEndPlay() //종료
}

class BillboardContainer {
  var billboardAnchor: ARAnchor
  var billboardNode: SCNNode?
  var videoAnchor: ARAnchor?
  var videoNode: SCNNode?
  var plane: RectangularPlane
  var isFullScreen = false
  var viewController: BillboardViewController?

  var hasBillboardNode: Bool { return billboardNode != nil }
  var hasVideoNode: Bool { return videoNode != nil }

  weak var videoNodeHandler: VideoNodeHandler?
  weak var videoPlayerDelegate: VideoPlayerDelegate? //비디오 플레이어 delegate

  init(billboardAnchor: ARAnchor, plane: RectangularPlane) {
    self.billboardAnchor = billboardAnchor
    self.plane = plane
    self.billboardNode = nil
    self.videoAnchor = nil
    self.videoNode = nil
  }
}
