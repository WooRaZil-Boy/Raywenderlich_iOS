/// Copyright (c) 2018 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit
import AVFoundation

class AudioViewController: UIViewController {
  
  @IBOutlet var songLabel: UILabel!
  @IBOutlet var timeLabel: UILabel!
  lazy var player: AVQueuePlayer = self.makePlayer()
  
  private lazy var songs: [AVPlayerItem] = {
    let songNames = ["FeelinGood", "IronBacon", "WhatYouWant"]
    return songNames.map {
      let url = Bundle.main.url(forResource: $0, withExtension: "mp3")!
      return AVPlayerItem(url: url)
    }
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    do {
      try AVAudioSession.sharedInstance().setCategory(
        AVAudioSession.Category.playAndRecord,
        mode: .default,
        options: [])
    } catch {
      print("Failed to set audio session category.  Error: \(error)")
    }
    
    player.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 100), queue: DispatchQueue.main) {
      [weak self] time in
      guard let strongSelf = self else { return }
      let timeString = String(format: "%02.2f", CMTimeGetSeconds(time))
      
      if UIApplication.shared.applicationState == .active {
        strongSelf.timeLabel.text = timeString
      } else {
        print("Background: \(timeString)")
      }
    }
  }
  
  private func makePlayer() -> AVQueuePlayer {
    let player = AVQueuePlayer(items: songs)
    player.actionAtItemEnd = .advance
    player.addObserver(self, forKeyPath: "currentItem", options: [.new, .initial] , context: nil)
    return player
  }
  
  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    if keyPath == "currentItem", let player = object as? AVPlayer,
      let currentItem = player.currentItem?.asset as? AVURLAsset {
      songLabel.text = currentItem.url.lastPathComponent
    }
  }
  
  @IBAction func playPauseAction(_ sender: UIButton) {
    sender.isSelected = !sender.isSelected
    if sender.isSelected {
      player.play()
    } else {
      player.pause()
    }
  }
}

//2010년, iOS 4부터 멀티 태스킹(background mode)가 지원되었다.
//배터리와 리소스 소모를 줄이기 위해 제한이 있으며, Capabilities에서 체크하지 않은 다른 기능을 background로 실행하는 경우 reject 될 수 있다.




//Xcode Project에서 Capabilities 탭 - Background mode에서 활성화할 기능(Audio, AirPlay, and Picture in Picture)을 선택하면 된다.
