//
//  ViewController.swift
//  Mr.Pig
//
//  Created by 근성가이 on 2018. 9. 20..
//  Copyright © 2018년 근성가이. All rights reserved.
//

import UIKit
import SceneKit //SceneKit은 3D 그래픽을 제어한다.
import SpriteKit //SpriteKit은 2D 그래픽을 제어한다. 여기서는, SpriteKit을 사용해 SceneKit의 전환(transition)을 만든다.

class ViewController: UIViewController {
    var scnView: SCNView! //SCNView는 SCNScene의 내용을 scene에 표시한다.
    
    var gameScene: SCNScene! //SCNScene 클래스는 scene를 나타낸다. SCNView의 인스턴스에 scene를 표시한다.
    var splashScene: SCNScene! //SCNScene 클래스는 scene를 나타낸다. SCNView의 인스턴스에 scene를 표시한다.
    
    let game = GameHelper.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupScenes()
        setupNodes()
        setupActions()
        setupTraffic()
        setupGestures()
        setupSounds()
        
        game.state = .tapToPlay //게임 초기 상태
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    override var shouldAutorotate : Bool {
        return false
    }
    
    func setupScenes() {
        scnView = SCNView(frame: view.frame)
        view.addSubview(scnView) //현재 view의 하위 view로 추가
        //storyboard에서 SCNView로 연결할 수도 있다.
        
        gameScene = SCNScene(named: "/MrPig.scnassets/GameScene.scn") //scn file로 scene 초기화
        splashScene = SCNScene(named: "/MrPig.scnassets/SplashScene.scn") //scn file로 scene 초기화
        
        scnView.scene = splashScene //scnView에서 사용할 scene 설정
        //splashScene 부터 시작한다.
    }
    
    func setupNodes() {
        
    }
    
    func setupActions() {
        
    }
    
    func setupTraffic() {
        
    }
    
    func setupGestures() {
        
    }
    
    func setupSounds() {
        
    }
}

//이전과 다르게 이번 게임은 SceneKit Game Template를 사용하지 않고 Single View Application으로 생성한다.
//ViewController를 두 개 만들어 scene를 전환한다.
//Crossy Road, Pacman 256, Shooty Skies와 비슷한 복셀 스타일 그래픽을 사용한다.
//복셀(Voxel)은 Volume + Pixel 의 합성어로 ㅈ차원인 픽셀을 3차원 형태로 구현한 것이다. 부피를 가진 픽셀이라 할 수 있다.




//Creating the game scene
//패턴을 반복해서 glass를 만든다.

//Create the splash scene
//노드를 Drag and drop 해서 scene에 reference를 만들 수 있다. 해당 노드를 선택하고 Scenen Inspector에서 Scene Background를 지정할 수 있다.
//이렇게 설정하면, 배경에 하나의 정사각형 이미지를 사용하기 때문에 SceneKit은 scene 전체를 항상 채울 수 있게 확장할 수 있다.
//Shading에서 모드를 Constant 로 바꿔주면, 조명이 객체에 영향을 미치지 않도록 한다.
//Settings 섹션에서 Blend Mode를 Subtract로 하면, 혼합 확산 맵을 사용해 어둡게 만들 수 있다.


//Setting up the camera and lights
//카메라가 올바르게 구성되었는지 확인하려면, scene 미리보기 왼쪽 하단의 카메라 메뉴에서 Drop-down으로 해당 카메라를 선택해 하면 된다.




//Transitions
extension ViewController {
    func startGame() {
        splashScene.isPaused = true //게임은 splashScene에서만 시작할 수 있다. splashScene의 모든 동작과 물리 시뮬레이션을 일시 중지시킨다.
        
        let transition = SKTransition.doorsOpenVertical(withDuration: 1.0) //전환 효과
        //새 scene를 보여주며, 1초 동안 애니메이션한다.
        
        scnView.present(gameScene, with: transition, incomingPointOfView: nil) { //전환효과를 사용한다.
            //incomingPointOfView로 전환에 사용할 시점을 지정할 수 있지만, 카메라가 하나만 있으므로 nil로 둔다.
            
            //전환이 완료되면
            self.game.state = .playing //게임 상태가 play가 되고
            self.setupSounds() //사운드 로드
            self.gameScene.isPaused = false //gameScene의 일시정지를 해제한다.
        }
    }
    
    func stopGame() {
        game.state = .gameOver //게임 상태를 gameOver로
        game.reset() //게임을 리셋
    }
    
    func startSplash() {
        gameScene.isPaused = true //gameScene의 모든 동작과 물리 시뮬레이션을 일시 중지시킨다.
        
        let transition = SKTransition.doorsOpenVertical(withDuration: 1.0)
        
        scnView.present(splashScene, with: transition, incomingPointOfView: nil) { //전환효과를 사용한다.
            //incomingPointOfView로 전환에 사용할 시점을 지정할 수 있지만, 카메라가 하나만 있으므로 nil로 둔다.
            
            //전환이 완료되면
            self.game.state = .tapToPlay //게임 상태가 tapToPlay가 되고
            self.setupSounds() //사운드 로드
            self.splashScene.isPaused = false //splashScene의 일시정지를 해제한다.
        }
    }
    
    //디졸브(dissolve), 크로스 페이드(cross fade), 컷(cut) 등의 다양한 전환이 있다.
    //SceneKit은 전환 효과를 위해 SpiriteKit의 SKTransition을 활용한다. 전환 종류는 다음과 같다.
    // • crossFade(withDuration:) : 현재 scene에서 새로운 scenen로 Cross fade 한다.
    // • doorsCloseHorizontal(withDuration:) : 새 scene을 닫히는 효과로 수평 전환한다.
    // • doorsCloseVertical(withDuration:) : 새 scene을 닫히는 효과로 수직 전환한다.
    // • doorsOpenHorizontal(withDuration:) : 새 scene을 열리는 효과로 수평 전환한다.
    // • doorsOpenVertical(withDuration:) : 새 scene을 열리는 효과로 수직 전환한다.
    // • doorway(withDuration:) : 현재 scene이 양쪽으로 사라지며 열리는 효과로 새 scene로 전환된다.
    // • fade(withColor:) : 현재 scene이 먼저 일정한 색으로 fade 되고, 새로운 scene가 사라지며 전환된다.
    // • fade(withDuration:) : 현재 scene이 먼저 검은색으로 희미해 지고, 새로운 scene가 사라지며 전환된다.
    // • flipHorizontal(withDuration:) : 현재 scene를 수평 방향으로 뒤집어서 새 scene로 전환한다.
    // • flipVertical(withDuration:) : 현재 scene를 수직 방향으로 뒤집어서 새 scene로 전환한다.
    // • moveIn(withDirection:) : 새 scene를 현재 scene 위로 이동하여 전환한다.
    // • push(withDirection:) : 현재 scene를 보이지 않게 밀어 새로운 scene로 전환한다.
    // • reveal(withDirection:) : 현재 scene이 아래로 이동하여 새 scene를 전환한다.
    // • transition(withCIFilter:) : 코어 이미지 필터를 사용하여 새 scene를 전환한다.
}

extension ViewController{
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if game.state == .tapToPlay { //tapToPlay 상태이면
            startGame() //게임을 시작한다.
        }
    }
}
