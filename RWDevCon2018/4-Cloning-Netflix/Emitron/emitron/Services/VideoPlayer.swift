/*
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
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import Foundation
import AVFoundation
import AVKit

class VideoPlayer: NSObject {
  typealias DependencyProvider = StoreProvider & NavigationProvider
  private let provider: DependencyProvider
  
  private lazy var store = provider.store

  private weak var avPlayerViewController: AVPlayerViewController?
  private var timeObservationToken: Any?
  
  init(dependencyProvider: DependencyProvider) {
    self.provider = dependencyProvider
  }
  
  func play(video: Video) {
    store.getStreamForVideo(id: video.id) { (result) in
      switch result {
      case .success(let streamUrl):
        self.playStream(streamUrl, with: video.viewing)
      case .error(let error):
        self.handle(error: error)
      }
    }
  }
  
  private func playStream(_ url: URL, with viewing: Viewing) {
    let controller = getPlayerVC()
    
    if let player = controller.player,
      let currentItem = player.currentItem,
      let asset = currentItem.asset as? AVURLAsset,
      asset.url == url {
      // We're currently playing the correct stream—do nothing
      player.play()
      return
    }
    
    var player: AVPlayer
    
    if let existingPlayer = controller.player {
      // Already have a player—just need to update its item, and time callback
      player = existingPlayer
      if let timeObservationToken = timeObservationToken {
        // TODO: Remove observer
        player.removeTimeObserver(timeObservationToken)
        self.timeObservationToken = .none
        //비디오 스트림이 변경될 때마다 옵저버 제거
      }
      // Create an item with the new URL
      let avPlayerItem = AVPlayerItem(url: url)
      // Hot-swap it
      player.replaceCurrentItem(with: avPlayerItem)
    } else {
      //  Create an AVPlayer, passing it the HTTP Live Streaming URL.
      player = AVPlayer(url: url)
    }
    
    // TODO: Add an time observer
    let interval = CMTime(seconds: 5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
    timeObservationToken = player.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main) { [weak self] time in
      self?.store.updateProgressFor(viewing: viewing, time: Int(time.seconds))
    }
    //프로그레스 바를 실시간으로 업데이트 하진 않는다. 옵저버를 추가해 주기적으로 업데이트한다.
    
    // TODO: Jump to the correct start point
    let startPoint = CMTime(seconds: Double(viewing.time), preferredTimescale: CMTimeScale(NSEC_PER_SEC))
    player.seek(to: startPoint)
    //최근 시간에서 비디오 이어서 재생
  
    // Pass the player over to the view controller
    controller.player = player
    
    if controller == avPlayerViewController {
      // Don't need to present it—it's already there
      player.play()
    } else {
      avPlayerViewController = controller
      // Modally present the player and call the player's play() method when complete.
      provider.present(controller, animated: true) {
        player.play()
      }
    }
  }
  
  private func getPlayerVC() -> AVPlayerViewController {
    if let controller = avPlayerViewController {
      return controller
    }

    let controller = AVPlayerViewController()
    controller.delegate = self
    return controller
  }
  
  private func handle(error: Error) {
    if let error = error as? BetamaxError {
      provider.showError(title: error.title, description: error.message)
    } else {
      provider.showError(title: "Unknwon Error", description: "An unknown error has occurred. If this persists, please contact support.")
    }
  }
}

extension VideoPlayer: AVPlayerViewControllerDelegate {
  func playerViewController(_ playerViewController: AVPlayerViewController, restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void) {
    provider.present(playerViewController, animated: true) {
      completionHandler(true)
    }
  }
}
