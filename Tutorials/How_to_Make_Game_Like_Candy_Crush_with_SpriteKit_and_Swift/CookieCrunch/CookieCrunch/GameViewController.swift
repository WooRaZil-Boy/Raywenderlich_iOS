/**
 * GameViewController.swift
 * CookieCrunch
 * Copyright (c) 2017 Razeware LLC
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

class GameViewController: UIViewController {
  
  // MARK: Properties
  
  // The scene draws the tiles and cookie sprites, and handles swipes.
  var scene: GameScene! //scene에 대한 참조
  
  var movesLeft = 0
  var score = 0
  
  var level: Level!
  
  lazy var backgroundMusic: AVAudioPlayer? = { //배경 음악. lazy로 선언되었기에 처음 액세스할 때까지 실행되지 않는다.
    guard let url = Bundle.main.url(forResource: "Mining by Moonlight", withExtension: "mp3") else {
      return nil
    }
    do {
      let player = try AVAudioPlayer(contentsOf: url)
      player.numberOfLoops = -1 //루프. 반복한다.
      return player
    } catch {
      return nil
    }
  }()
  
  // MARK: IBOutlets
  @IBOutlet weak var gameOverPanel: UIImageView!
  @IBOutlet weak var targetLabel: UILabel!
  @IBOutlet weak var movesLabel: UILabel!
  @IBOutlet weak var scoreLabel: UILabel!
  @IBOutlet weak var shuffleButton: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Configure the view
    let skView = view as! SKView
    skView.isMultipleTouchEnabled = false
    
    // Create and configure the scene.
    scene = GameScene(size: skView.bounds.size)
    scene.scaleMode = .aspectFill
    
    // Present the scene.
    skView.presentScene(scene)
    
//    level = Level() //level 인스턴스 생성
    level = Level(filename: "Level_1") //JSON 파일로 인스턴스 생성
    scene.level = level //추가
    
    beginGame()
    scene.addTiles()
  }
  
  // MARK: IBActions
  @IBAction func shuffleButtonPressed(_: AnyObject) {
    
  }
  
  // MARK: View Controller Functions
  override var prefersStatusBarHidden: Bool {
    return true
  }
  
  override var shouldAutorotate: Bool {
    return true
  }
  
  override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    return [.portrait, .portraitUpsideDown]
  }
}

//해당 프로젝트는 MVC 패턴과 매우 유사한 아키텍처를 사용한다.
//Data Model : 모델에는 데이터가 포하모디어 있으며 대부분의 게임 플레이 논리를 처리한다.
//View : 객체를 표시하고 움직인다.
//View Controller : 일반적인 MVC 앱에서와 같은 역할을 수행한다. Model과 View 를 조율한다.
//이렇게 아키텍처를 분리하면, 각 객체에 수행할 수 있는 작업이 명확해지고 코드 관리가 쉬워진다.




//Assets
//이미지는 global assets catalog(Assets.xcassets) 또는 texture atlas(.atlas)에 있다.
//이는 Xcode가 게임을 빌드할 때 이미지를 텍스처 맵에 패킹하여 성능을 획기적으로 향상시킨다(SpriteKit).




extension GameViewController {
  func beginGame() { //게임을 시작한다.
    shuffle()
  }
  
  func shuffle() {
    let newCookies = level.shuffle()
    scene.addSprites(for: newCookies) //GameScene에 쿠키 스프라이트를 추가해야 화면에 표시된다.
  }
}
