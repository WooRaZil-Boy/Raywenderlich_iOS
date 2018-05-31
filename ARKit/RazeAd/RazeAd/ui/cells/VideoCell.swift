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
import SpriteKit
import AVFoundation
import ARKit

class VideoCell: UICollectionViewCell {
  var isPlaying = false //비디오가 현재 재생중인지 여부
  var videoNode: SKVideoNode! //비디오 셀을 생성할 때 ARKit node를 videoNode에 저장한다.
  var spriteScene: SKScene! //비디오 셀을 생성할 때 SpriteKit scene을 spriteScene에 저장한다.
  var videoUrl: String! //대상 비디오의 URL
  var player: AVPlayer? //해당 비디오를 재상하는 플레이어
  weak var billboard: BillboardContainer? //빌보드 컨테이너에 대한 참조
  weak var sceneView: ARSCNView? //ARKit scene View에 대한 참조
  @IBOutlet weak var playButton: UIButton!
  @IBOutlet weak var playerContainer: UIView!

  func configure(videoUrl: String, sceneView: ARSCNView, billboard: BillboardContainer) {
    self.videoUrl = videoUrl
    self.billboard = billboard
    self.sceneView = sceneView
    billboard.videoNodeHandler = self //비디오 플레이어의 SceneKit 노드를 만들고 제거하기 위한 delegate
  }

  func createVideoPlayerAnchor() {
    guard let billboard = billboard else { return }
    guard let sceneView = sceneView else { return }

    let center = billboard.plane.center * matrix_float4x4(SCNMatrix4MakeRotation(Float.pi / 2.0, 0.0, 0.0, 1.0))
    //빌보드 중앙에 회전 적용
    let anchor = ARAnchor(transform: center) //앵커 생성
    sceneView.session.add(anchor: anchor) //새 앵커를 ARKit scene에 추가한다.
    billboard.videoAnchor = anchor //앵커에 대한 참조를 유지한다.
  }

  func createVideoPlayerView() {
    if player == nil {
      guard let url = URL(string: videoUrl) else { return }
      player = AVPlayer(url: url)
      let layer = AVPlayerLayer(player: player)
      layer.frame = playerContainer.bounds
      playerContainer.layer.addSublayer(layer)
      //플레이어 생성하고 재생
    }

    player?.play()
  }

  func stopVideo() {
    player?.pause()
  }

  @IBAction func play() {
    //비디오 재생
    guard let billboard = billboard else { return }

    if billboard.isFullScreen {
      if isPlaying == false { //비디오가 재생되고 있지 않다면
        createVideoPlayerView() //비디오 플레이어 뷰 생성
        playButton.setImage(#imageLiteral(resourceName: "arKit-pause"), for: .normal)
      } else { //비디오가 재생 중이라면
        stopVideo() //비디오 재생 중단
        playButton.setImage(#imageLiteral(resourceName: "arKit-play"), for: .normal)
      }
      isPlaying = !isPlaying //토글
    } else {
      createVideoPlayerAnchor() //비디오 플레이어 앵커 생성
      billboard.videoPlayerDelegate?.didStartPlay() //비디오가 재생되기 시작했다고 delegate에게 알린다.
      playButton.isEnabled = false //재생 버튼 비활성화(두번 눌러 다시 트리거 되지 않도록)
    }
  }
}

extension VideoCell: VideoNodeHandler {
    //VideoNodeHandler의 구현은 이전 장에서의 로직과 거의 비슷하다.
  func createNode() -> SCNNode? {
    guard let billboard = billboard else { return nil }

    let frameSize = CGSize(width: 1024, height: 1024)
    let url = URL(string: videoUrl)!

    let player = AVPlayer(url: url)
    videoNode = SKVideoNode(avPlayer: player)
    videoNode.size = frameSize
    videoNode.position = CGPoint(x: frameSize.width / 2, y: frameSize.height / 2)
    videoNode.zRotation = CGFloat.pi

    spriteScene = SKScene(size: frameSize)
    spriteScene.scaleMode = .aspectFit
    spriteScene.backgroundColor = UIColor(white: 33/255, alpha: 1.0)
    spriteScene.addChild(videoNode)

    let billboardSize = CGSize(width: billboard.plane.width, height: billboard.plane.height / 2)
    let plane = SCNPlane(width: billboardSize.width, height: billboardSize.height)
    plane.firstMaterial!.isDoubleSided = true
    plane.firstMaterial!.diffuse.contents = spriteScene
    let node = SCNNode(geometry: plane)

    billboard.videoNode = node

    billboard.videoNodeHandler = self

    videoNode.play()
    return node
  }

  func removeNode() {
    videoNode?.pause()

    spriteScene?.removeAllChildren()
    spriteScene = nil

    if let videoAnchor = billboard?.videoAnchor {
      sceneView?.session.remove(anchor: videoAnchor)
    }

    billboard?.videoPlayerDelegate?.didEndPlay()

    billboard?.videoNode?.removeFromParentNode()
    billboard?.videoAnchor = nil
    billboard?.videoNode = nil

    playButton.isEnabled = true
  }
}
