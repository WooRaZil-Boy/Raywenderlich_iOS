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
    
    var pigNode: SCNNode!
    var cameraNode: SCNNode!
    var cameraFollowNode: SCNNode!
    var lightFollowNode: SCNNode!
    var trafficNode: SCNNode!
    
    var collisionNode: SCNNode!
    var frontCollisionNode: SCNNode!
    var backCollisionNode: SCNNode!
    var leftCollisionNode: SCNNode!
    var rightCollisionNode: SCNNode!
    
    var driveLeftAction: SCNAction!
    var driveRightAction: SCNAction!
    //차량의 Action
    
    var jumpLeftAction: SCNAction!
    var jumpRightAction: SCNAction!
    var jumpForwardAction: SCNAction!
    var jumpBackwardAction: SCNAction!
    //돼지의 Action
    
    var triggerGameOver: SCNAction!
    
    let BitMaskPig = 1
    let BitMaskVehicle = 2
    let BitMaskObstacle = 4
    let BitMaskFront = 8
    let BitMaskBack = 16
    let BitMaskLeft = 32
    let BitMaskRight = 64
    let BitMaskCoin = 128
    let BitMaskHouse = 256
    //Collision mask
    
    //Bit-masks
    //비트는 0과 1로 이루어져 이진수를 나타내는 데 사용된다. 각 비트는 특정 숫자 값을 나타내며 최하위 비트에서 최 상위 비트까지 반대 방향으로 읽는다(그냥 이진수 표기).
    //비트가 1이면 On으로 간주되고 0이면 Off이다. p.254 Bit mask는 이진수로 매핑한다. 비트 마스킹은 물리 시뮬레이션의 모든 객체에 id를 부여하는 방법이다.
    //비트 마스크를 사용해 서로 충돌이 난 객체를 필터링할 수 있다. 이 방법은 충돌을 탐지할 때, 관련된 객체의 양을 줄이므로 프로세스가 빨라진다.
    
    //Category masks
    //Category mask는 객체에 충돌 감지를 위한 고유한 id를 제공한다. 객체에 고유한 id를 부여하는 것 외에도 그룹화할 수 있다.
    //Pac-Man에서 팩맨과 충돌할 수 있는 것은 Good과 Bad 두 가지로 나눠 볼 수 있다. p.255
    //예시에서 Good은 6번째 비트(2의 5승: 64)가 true이면 되고 Bad는 7번째 비트(2의 6승: 128)이 true이면 된다.
    //조건문에서 각 해당 비트단위를 비교하여(&, 논리곱) 결과를 판단한다. p.256 https://blog.naver.com/badwin/221178028123
    
    //Defining category masks
    //해당 프로젝트의 Category mask는 좀 더 간단하게 구현할 수 있다. p.256
    
    //Collision masks
    //collision mask를 사용해, 물리 엔진이 일부 객체가 서로 충돌하도록 지정해 줄 수 있다. 물리엔진은 이 객체들이 서로 통과하지 못하게 하고 충돌효과를 트리거 한다.
    //충돌 마스크를 정의하려면 객체와 충돌하는 모든 category mask를 함께 추가해야 한다. 이 게임에서는 Pearl을 제외한 모든 것과 충돌해야 한다. p.257
    //collision mask 와 category mask 를 비교해서 봐야 한다. 충돌하는 카테고리가 true가 된다.
    
    //Contact masks
    //contact mask 는 물리 엔진이 어떤 객체가 충돌시 이벤트가 일어나는 지 알려준다. 이는 물리 엔진에 직접 영향을 미치지 않고, 프로그래밍 코드로 트리거 해야 한다.
    //collision mask와 같은 방법으로 contact mask를 설정한다. p.258
    
    var activeCollisionsBitMask: Int = 0 //활성된 충돌을 추적할 bit mask
    
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
        
        // Bugfix
        let trees = gameScene.rootNode.childNode(withName: "Trees", recursively: false)
        for treeNode in trees!.childNodes {
            treeNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
            treeNode.physicsBody?.collisionBitMask = -1
            treeNode.physicsBody?.categoryBitMask = 4
        }
        
        // Bugfix: Moved "Home Reference" under new parent node called "Home" for this to work
        let home = gameScene.rootNode.childNode(withName: "Home", recursively: false)
        for homeNode in home!.childNodes {
            homeNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
            homeNode.physicsBody?.collisionBitMask = -1
            homeNode.physicsBody?.categoryBitMask = 4
        }
        
        splashScene = SCNScene(named: "/MrPig.scnassets/SplashScene.scn") //scn file로 scene 초기화
        
        scnView.scene = splashScene //scnView에서 사용할 scene 설정
        //splashScene 부터 시작한다.
        
        scnView.delegate = self //delegate 설정
        
        gameScene.physicsWorld.contactDelegate = self //물리 엔진 delegate 설정
    }
    
    func setupNodes() {
        pigNode = gameScene.rootNode.childNode(withName: "MrPig", recursively: true)!
        //scene 노드가 이미 로드되어 있으므로, rootNode.childNode 를 사용해 name으로 쉽게 가져올 수 있다.
        //recursively 매개 변수를 true로 하면 노드의 전체 하위 트리를 검색해서 해당 노드를 찾는다.
        //false일 시에는 직접적인 하위 노드만을 검색한다.
        //참조 노드이지만, 일반 노드인 것처럼 액세스할 수 있다.
        
        
        
        
        //Creating the follow camera node
        cameraNode = gameScene.rootNode.childNode(withName: "camera", recursively: true)! //카메라 노드 추가
        cameraNode.addChildNode(game.hudNode) //HUD 추가
        
        cameraFollowNode = gameScene.rootNode.childNode(withName: "FollowCamera", recursively: true)!
        //cameraFollowNode는 카메라가 돼지를 따라갈 때, 위치를 돼지와 동일하게 업데이트한다.
        
        //카메라와 조명은 빈 노드를 생성하고, 셀피를 찍는 것처럼 위치를 설정해 두는 것이 사용하기 편리하다(selfie stick).
        
        //Creating the follow light node
        lightFollowNode = gameScene.rootNode.childNode(withName: "FollowLight", recursively: true)!
        //FollowCamera와 같은 위치로 하여, 해당 영역에 보이는 객체에 그림자를 줄 수 있다.
        
        //전체적으로 scene을 채우는 주변 조명인 ambient light와 햇빛을 모방하는 directional light(그림자 생성) 두 가지 조명이 있다.
        //그림자 설정 시 Sample radius를 0으로 하면, 그림자가 생기는 가장자리에 흐린 부분을 선명하게 해 준다.
        //이 게임은 야외의 환경을 모방하기 때문에 햇빛과 그 빛으로 만들어지는 그림자를 모방해야 한다.
        //여기서는 햇빛(directional light)이 돼지를 따라가도록 설정되는데, 이는 실제 햇빛과는 다르다.
        //그림자가 directional light로 생기기 때문에 실제 디바이스에서 표시되는 이외의 영역은 광원이 없어 그림자를 생성하지 않는다.
        //따라서 성능을 최적화할 수 있고, 카메라가 계속해서 돼지를 따라가면서 보여지는 영역을 정렬해야 한다.
        
        trafficNode = gameScene.rootNode.childNode(withName: "Traffic", recursively: true)!
        //각 참조 노드에 대한 속성을 만드는 대신 하나의 컨테이너 노드를 사용해 모든 차량을 관리한다.
        
        
        
        
        //Adding the collision reference node
        collisionNode = gameScene.rootNode.childNode(withName: "Collision", recursively: true)!
        frontCollisionNode = gameScene.rootNode.childNode(withName: "Front", recursively: true)!
        backCollisionNode = gameScene.rootNode.childNode(withName: "Back", recursively: true)!
        leftCollisionNode = gameScene.rootNode.childNode(withName: "Left", recursively: true)!
        rightCollisionNode = gameScene.rootNode.childNode(withName: "Right", recursively: true)!
        
        
        
        
        //Setting contact bit masks
        pigNode.physicsBody?.contactTestBitMask = BitMaskVehicle | BitMaskCoin | BitMaskHouse
        //돼지는 차량, 동전, 집과 충돌할 수 있다.
        frontCollisionNode.physicsBody?.contactTestBitMask = BitMaskObstacle
        backCollisionNode.physicsBody?.contactTestBitMask = BitMaskObstacle
        leftCollisionNode.physicsBody?.contactTestBitMask = BitMaskObstacle
        rightCollisionNode.physicsBody?.contactTestBitMask = BitMaskObstacle
        //hidden geometry의 각 box는 Obstacle을 감지한다.
        
        //SceneKit editor에서 Contact Mask를 설정할 수 있지만, 코드에서 수동으로 설정해 줄 수도 있다.
    }
    
    func setupActions() {
        //Animating the traffic
        driveLeftAction = SCNAction.repeatForever(SCNAction.move(by: SCNVector3Make(-2.0, 0, 0), duration: 1.0))
        driveRightAction = SCNAction.repeatForever(SCNAction.move(by: SCNVector3Make(2.0, 0, 0), duration: 1.0))
        //SCNAction.repeatForever(_:) 메서드는 단순히 다른 Action을 반복하거나 반복하는 특수 Action을 만든다.
        //SCNAction.move(by:duration:) 메서드는 특정 시간 동안 지정된 벡터만큼 노드를 이동하게 한다.
        
        
        
        
        //Adding pig movement
        let duration = 0.2 //변수를 사용해, 애니메이션의 시간을 일괄적으로 제어할 수 있다.
        
        let bounceUpAction = SCNAction.moveBy(x: 0, y: 1.0, z: 0, duration: duration * 0.5)
        let bounceDownAction = SCNAction.moveBy(x: 0, y: -1.0, z: 0, duration: duration * 0.5)
        //돼지를 뛰어 오르게 하는 Action(Splash Scene에서 사용한 것과 비슷)
        
        bounceUpAction.timingMode = .easeOut
        bounceDownAction.timingMode = .easeIn
        //Timing function을 추가 시켜 준다.
        
        let bounceAction = SCNAction.sequence([bounceUpAction, bounceDownAction])
        //Action을 조합해 Sequence로 만든다.
        
        let moveLeftAction = SCNAction.moveBy(x: -1.0, y: 0, z: 0, duration: duration)
        let moveRightAction = SCNAction.moveBy(x: 1.0, y: 0, z: 0, duration: duration)
        let moveForwardAction = SCNAction.moveBy(x: 0, y: 0, z: -1.0, duration: duration)
        let moveBackwardAction = SCNAction.moveBy(x: 0, y: 0, z: 1.0, duration: duration)
        //각 4방향으로 한 칸 이동하는 Action
        
        let turnLeftAction = SCNAction.rotateTo(x: 0, y: convertToRadians(angle: -90), z: 0, duration: duration, usesShortestUnitArc: true)
        let turnRightAction = SCNAction.rotateTo(x: 0, y: convertToRadians(angle:90), z: 0, duration: duration, usesShortestUnitArc: true)
        let turnForwardAction = SCNAction.rotateTo(x: 0, y: convertToRadians(angle: 180), z: 0, duration: duration, usesShortestUnitArc: true)
        let turnBackwardAction = SCNAction.rotateTo(x: 0, y: convertToRadians(angle: 0), z: 0, duration: duration, usesShortestUnitArc: true)
        //각 4방향으로 회전하는 Action
        
        jumpLeftAction = SCNAction.group([turnLeftAction, bounceAction, moveLeftAction])
        jumpRightAction = SCNAction.group([turnRightAction, bounceAction, moveRightAction])
        jumpForwardAction = SCNAction.group([turnForwardAction, bounceAction, moveForwardAction])
        jumpBackwardAction = SCNAction.group([turnBackwardAction, bounceAction, moveBackwardAction])
        //각 Action들을 합쳐 그룹을 만들어 준다. Sequence와 다르게 Group은 해당 Action을 모두 병렬로 실행한다.
        
        
        
        
        //Creating the game over sequence
        let spinAround = SCNAction.rotateBy(x: 0, y: convertToRadians(angle: 720), z: 0, duration: 2.0) //돼지를 회전 시킨다.
        let riseUp = SCNAction.moveBy(x: 0, y: 10, z: 0, duration: 2.0) //돼지를 하늘로 이동시킨다.
        let fadeOut = SCNAction.fadeOpacity(to: 0, duration: 2.0) //돼지를 fadeOut 해 사라지게 한다.
        let goodByePig = SCNAction.group([spinAround, riseUp, fadeOut]) //Action을 그룹화 해, gameOver 되었을 때 돼지의 액션을 만들어 준다.
        
        let gameOver = SCNAction.run { (node: SCNNode) -> Void in
            //The SCNAction.runAction(_:) 클래스 메서드는 Action에 코드 로직을 삽입할 수 있는 특수한 action을 생성한다.
            self.pigNode.position = SCNVector3(x: 0, y: 0, z: 0)
            self.pigNode.opacity = 1.0
            self.startSplash()
            //돼지의 위치와 방향을 원래대로 되돌리고 보이게 한다. 또한, 시작 scene로 이동한다.
        }
        
        triggerGameOver = SCNAction.sequence([goodByePig, gameOver]) //게임 종료시 실행할 Action을 시퀀스로 만든다.
        
        //코드에서 액션은 SCNAction 인스턴스로 표현된다. 위의 기본 Action을 코드로도 생성할 수 있다. ex. 이동 액션은 SCNAction.move(by:duration:)
    }
    
    func setupTraffic() {
        for node in trafficNode.childNodes {
            //setupNodes에서 이미 scene의 traffic 노드에 연결된 trafficNode를 초기화했다.
            //SCNNode의 childNodes 들을 loop로 각 노드를 가져온다(모든 차량 노드들을 loop에서 가져오게 된다).
            
            //Buses are slow, the rest are speed demons
            if node.name?.contains("Bus") == true { //해당 노드가 버스인 경우
                driveLeftAction.speed = 1.0
                driveRightAction.speed = 1.0
            } else { //버스가 아닌 다른 차량인 경우(버스 보다 속도가 빠르게 설정한다).
                driveLeftAction.speed = 2.0
                driveRightAction.speed = 2.0
            }
            
            //Let vehicle drive towards its facing direction
            if node.eulerAngles.y > 0 { //차량들은 좌 우로 움직인다. 방향을 확인한 후, 노드에 action을 실행한다(올바른 방향으로 이동시킨다).
                node.runAction(driveLeftAction)
            } else {
                node.runAction(driveRightAction)
            }
        }
    }
    
    func setupGestures() {
        //각 제스처를 등록해 준다.
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.handleGesture(_:)))
        swipeRight.direction = .right
        scnView.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.handleGesture(_:)))
        swipeLeft.direction = .left
        scnView.addGestureRecognizer(swipeLeft)
        
        let swipeForward = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.handleGesture(_:)))
        swipeForward.direction = .up
        scnView.addGestureRecognizer(swipeForward)
        
        let swipeBackward = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.handleGesture(_:)))
        swipeBackward.direction = .down
        scnView.addGestureRecognizer(swipeBackward)
    }
    
    func setupSounds() {
        //Add music
        if game.state == .tapToPlay { //splashScene에서만 음악을 재생한다.
            let music = SCNAudioSource(fileNamed: "MrPig.scnassets/Audio/Music.mp3")! //SCNAudioSource 객체 생성
            music.volume = 0.3 //음량
            music.loops = true //반복 여부
            music.shouldStream = true //스트리밍되거나 메모리에 미리 로드되는 지 여부
            //일반적으로 대용량 오디오 파일은 스트리밍해야 하지만, 크기가 작은 경우 빠른 미리보기를 위해 메모리에 미리 로드하는 것이 좋다.
            music.isPositional = false //오디오 소스에서 3D spatialized playback 사용 여부
            
            let musicPlayer = SCNAudioPlayer(source: music) //오디오 소스를 사용하는 오디오 플레이어
            splashScene.rootNode.addAudioPlayer(musicPlayer) //오디오 플레이어를 rootNode에 추가하여 음악 스트림을 시작한다.
        }
        
        
        
        
        //Adding ambiance
        else if game.state == .playing { //playing 상태에서만
            let traffic = SCNAudioSource(fileNamed: "MrPig.scnassets/Audio/Traffic.mp3")! //오디오 소스 설정
            traffic.volume = 0.3
            traffic.loops = true
            traffic.shouldStream = true
            traffic.isPositional = true
            
            let trafficPlayer = SCNAudioPlayer(source: traffic) //오디오 소스를 사용하는 오디오 플레이어
            gameScene.rootNode.addAudioPlayer(trafficPlayer) //오디오 플레이어를 rootNode에 추가하여 음악 스트림을 시작한다.
            //오디오 소스가 rootNode에 추가되자마자 오디오 소스가 재생된다.
            
            game.loadSound(name: "Jump", fileNamed: "MrPig.scnassets/Audio/Jump.wav")
            game.loadSound(name: "Blocked", fileNamed: "MrPig.scnassets/Audio/Blocked.wav")
            game.loadSound(name: "Crash", fileNamed: "MrPig.scnassets/Audio/Crash.wav")
            game.loadSound(name: "CollectCoin", fileNamed: "MrPig.scnassets/Audio/CollectCoin.wav")
            game.loadSound(name: "BankCoin", fileNamed: "MrPig.scnassets/Audio/BankCoin.wav")
            //사용할 사운드 효과 로드(sound effect), Music과는 다르다.
        }
        
        //Audio in SceneKit
        // • SCNAudioSource : 오디오 소스는 음악이나 사운드 효과와 같은 오디오 파일을 나타내는 개체이다. 메모리에 미리 로드되거나 실시간으로 스트리밍된다.
        // • SCNAudioPlayer : 오디오 소스를 SCNNode 객체의 위치를 사용해, 3D 공간 오디오로 재생할 수 있다.
        // • SCNAction.playAudio(_:waitForCompletion:) : 오디오 소스를 재생할 SCNNode에서 실행할 수 있는 특수 액션
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
        resetCoins()
        setupTraffic()
        
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
        stopTraffic() //차량의 애니메이션 제거
        
        game.state = .gameOver //게임 상태를 gameOver로
        game.reset() //게임을 리셋
        
        pigNode.runAction(triggerGameOver)
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




//Add trees
//tree line과 tree patch 두 가지 유형의 나무 그룹을 생성한다.

//나무를 하나씩 심는 것 보다 한 무리의 나무로 구성된 재사용 가능한 scene를 만든 후 참조노드로 사용하는 것이 편리하다.
//그리드를 보며 나무를 심는다. p.377, p.379

//모든 나무들을 Trees 노드 안에서 관리한다.




//Add coins
//모든 코인들은 Coins 노드 안에서 관리한다.




//Actions
//action을 사용하면 scene 내의 노드의 위치, 크기, 회전, 불투명도를 조작할 수 있다.
//ex. 제스처로 왼쪽 swipe하면, 돼지는 왼쪽으로 한 칸 뒤면서 회전한다.
//이러한 기본 동작은 돼지 노드에서 연속적인 그룹을 병렬로 실행한 결과이다.
//노드가 선택된 상태에서 editor의 아래 보조 편집기를 Drag and Drop하여 액션 시퀀스를 빌드할 수 있다.
//코딩 관점에서 먼저 SCNAction 객체를 생성하고, 원하는 경우 해당 timingMode를 설정한 다음 노드에서 runAction(_:) 메서드를 사용해서
//SCNNode 인스턴스에서 해당 작업을 실행할 수 있다. 기본 동작에는 네 가지 범주가 있다(Move, Scale, Rotate, Fade).
//두 개의 특수한 작업을 실행하는 범주가 있는데 이것은 Sequence 또는 Group 이라 한다.
//Mr.Pig 는 물리 엔진이 아닌, 수동으로(사용자의 조작으로) 캐릭터를 움직인다.

//Moving actions
//한 지점에서 다른 지점으로 노드를 이동하는 경우 Move를 사용한다. p.387
// • Move Action : 노드의 현재 위치에서(오프셋) 노드를 이동한다.
// • MoveTo Action : 노드의 현재 위치에 관계 없이 노드를 3D 공간의 저징된 위치로 이동한다.
//상하좌우로 이동하는 액션을 만들 수 있다. p.388

//Scaling actions
//확대 축소에 Scaling을 사용한다. p.388
// • Scale Action : 노드의 현재 비율을 기준으로 조정한다.
// • ScaleTo Action : 노드의 현재 비율에 관계 없이 노드를 지정된 비율로 조정한다.
//각 축을 독립적으로 확대/축소할 수 있다(ex. 마리오 파워 업). p.389

//Rotating actions
//이 게임에서는 돼지가 점프할 때 그 방향으로 Rotating이 일어난다. p.389
// • Rotate Action : 노드의 현재 회전 각도 기준에서 회전한다.
// • RotateTo Action : 현재 회전 각도에 상관없이 노드를 지정된 각도로 회전한다.
// • RotateTo Action (Shortest) : 노드의 현재 회전 각도에 상관없이 노드를 지정된 각도로 회전한다. 가장 짧은 경로로 회전한다.
// • RotateBy Axis Angle Action : 노드의 현재 회전 각도에서 지정한 축의 각도만큼 회전한다.
// • RotateTo Axis Angle Action : 노드의 현재 회전 각도에 상관없이 지정한 축의 각도만큼 회전한다.
//RotateTo Action (Shortest)를 사용한 예는 p.390 회전을 사용해, 돼지의 위쪽이나 아래를 보이게 하거나 뒤쪽으로 넘어뜨릴 수도 있다.

//Fade actions
//객체를 반 투명 상태로 만든다. p.391
// • FadeOut Action : 완전히 보이지 않게 해 사라지게 한다.
// • FadeIn Action : 완전히 볼 수 있게 해 나타나게 한다.
// • FadeOpacityTo Action : 불투명도를 지정된 값으로 전환한다.
//게임에서 쓰일 FadeOut의 예시는 p.391

//Sequenced and grouped actions
//기본 Action을 sequence와 group으로 함께 연결해 Action이 차례대로 실행(sequence)하거나 동시에 실행(group)되게 할 수 있다. p.392
// • Actions : 기본 Action들로 지정되며, Action editor time line에 위치가 표시된다.
// • Sequence : 시간에 따라 순차적으로 진행되는 동작들
// • Group : 그룹화되어 병렬적으로 실행되는 동작들
//p.392의 다이어그램과 p.393의 스크린샷을 비교해 보면 쉽게 이해할 수 있다.




//Action timing functions
//SceneKit은 시간이 지남에 따라 Action의 진행 상태를 제어하는 데 사용할 수 있는 몇 가지 기본 타이밍 기능을 제공한다.
//이 기능이 없으면, 돼지는 단순히 정의된 지점으로 점프 후 다시 지상으로 내려오는 데 선형적인 방식으로 진행되므로 이상해 보일 수 있다.
//일반적인 상황을 생각해 보면, 물리학적으로 중력의 영향으로 속도가 일정할 수 없다.
//네 가지 기본 타이밍이 있다. p.394
// • Linear : 모든 동작에 사용되는 기본 타이밍. 동작이 지속되는 동안 동일한 속도로 재생된다.
// • Ease-In : 느리게 시작하여 나머지 시간 동안 최고 속도까지 가속된다.
// • Ease-Out : 최고 속도로 시작하여, 끝날 때 느려진다.
// • East-In-Out : 느리게 시작후, 가속하여 중간에서 최고 속도가 된후, 끝날 때까지 감속된다.
//SCNAction에서 timingMode 속성을 사용해 코드에서 함수를 정의할 수 있다.

//The action editor
//SceneKit 에서 보조 편집기로 노드에 대한 action을 지정해 줄 수 있다. p.396
//단순히 library에서 해당 action을 editor에 Drag and Drop 해 주면 된다.
//우 클릭으로 Create Loop을 선택한 후 루프 설정을 한다. 설정 후 Edit Loop로 에디팅해 줄 수 있다.
//주의할 점은 여기서 X 를 누르면 loop를 삭제하므로 빈 영역을 눌러 Loop 에디터를 나와야 한다.

//Animating the coins
//loop를 만들 때 여러 가지 Action을 함께 선택 한 후, 그룹으로 루프를 설정해 줄 수 있다.




//Add movement gestures
extension ViewController {
    @objc func handleGesture(_ sender: UISwipeGestureRecognizer) {
//        stopGame()
//        return
        //게임 종료 시 테스트 위한 코드
        
        //돼지가 제스처에 응답하도록 연결 시켜 준다.
        guard game.state == .playing else { //게임이 playing 상태가 아니라면 종료
            return
        }
        
        let activeFrontCollision = activeCollisionsBitMask & BitMaskFront == BitMaskFront
        let activeBackCollision = activeCollisionsBitMask & BitMaskBack == BitMaskBack
        let activeLeftCollision = activeCollisionsBitMask & BitMaskLeft == BitMaskLeft
        let activeRightCollision = activeCollisionsBitMask & BitMaskRight == BitMaskRight
        //비트 AND로 activeCollisionsBitMask에 저장된 각 방향의 활성 충돌을 확인하고 개별 상수에 저장한다.
        
        guard (sender.direction == .up && !activeFrontCollision) ||
            (sender.direction == .down && !activeBackCollision) ||
            (sender.direction == .left && !activeLeftCollision) ||
            (sender.direction == .right && !activeRightCollision) else { //장애물에 걸린 겅유
                game.playSound(node: pigNode, name: "Blocked") //장애물에 걸린 경우 사운드 효과
                return
        }
        
        //제스처 방향에 활성 충돌이 없는 경우에만 계속 진행한다.
        
        
        
        
        
        switch sender.direction { //제스처 인식기의 방향을 확인한다.
        case UISwipeGestureRecognizer.Direction.up:
            pigNode.runAction(jumpForwardAction)
        case UISwipeGestureRecognizer.Direction.down:
            pigNode.runAction(jumpBackwardAction)
        case UISwipeGestureRecognizer.Direction.left:
            if pigNode.position.x > -15 { //가장 좌측을 벗어나지 않게 하기 위해
                pigNode.runAction(jumpLeftAction)
            }
        case UISwipeGestureRecognizer.Direction.right:
            if pigNode.position.x < 15 { //가장 우측을 벗어나지 않게 하기 위해
                pigNode.runAction(jumpRightAction)
            }
        default:
            break
        }
        
        
        
        
        //Add sound effects
        game.playSound(node: pigNode, name: "Jump") //유효한 제스처가 처리될 때마다 사운드 효과를 재생
        
    }
}




//Hidden geometry for collisions
//숨겨진 geometry를 사용해 충돌을 감지할 수 있다. 이 geometry는 보이지 않지만 여전히 물리 엔진과 상호작용한다.
//돼지는 4 방향으로 움직일 수 있다. 따라서 각 방향에 네 개의 hidden box를 만들면, 돼지 주변의 충돌을 추적할 수 있다.
//이 Hidden geometry(box)와 충돌하는 객체가 없다면 돼지는 점프해서 이동할 수 있다. 객체가 있다면, 그 방향으로는 이동할 수 없다. p.415

//Create a hidden collision node
//Collision.scn 을 만들어 충돌을 감지하는 객체를 만든다.

//Enabling physics
//각 box(hidden geometry)에는 category bit mask가 있어야 장애물과의 충돌에서 어느 것이 관련되어 있는 지 확인할 수 있다.
//여러 노드를 함께 선택한 후, 노드의 속성과 물리 속성을 편집할 수 있다(비슷한 특성이나 동일한 값을 가진 경우에만 가능).
//여기서는 Hidden geometry의 물리엔진을 Kinematic 타입으로 설정한다.
//Node inspector에서 Visibility를 0으로 한다(테스트 중에는 0.5 정도로 해서 확인해 주는 것이 좋다).
//여기서 Visibility를 제어하지 않고, Hidden으로 설정하면, 노드가 완전히 제거되어 물리 특성이 적용되지 않는다(충돌이 일어나지 않는다).
//Casts Shadow 체크 박스도 해제해, 그림자가 생기지 않도록 한다.
//각 Hidden geometry에 bit mask를 설정해 준다. p.421

//physics body type 은 객체의 물리 상호작용 방식을 정의한다. 3가지 유형이 있다.
//• Static : 움직이지 않는다. 다른 물체는 이 물체와 충돌할 수 있지만, static 물체 자체는 모든 힘과 충돌에 영향을 받지 않는다(ex. 벽, 바위).
//• Dynamic : 물리 엔진이 힘과 충돌에 대응해 물체를 이동 시킨다(ex. 의자, 테이블, 컵).
//• Kinematic : 수동으로 힘과 충돌에 대응해 물체를 이동 시켜야 한다.
//  Dynamic 물체와 Kinematic 물체가 충돌하면, Dynamic 물체는 움직이지만, Kinematic 물체는 움직이지 않는다.
//  하지만 코드로 움직여 줄 수 있다(ex. 이동하는 엘리베이터, 개폐 가능한 문과 같이 수동으로 제어되는 물체).




extension ViewController {
    //Create the render loop
    //collision Node는 돼지를 따라가야 한다. 가장 간단히 구현하는 방법은 collision node의 위치를 렌더링 루프에서 돼지 노드의 위치와 동일하게 만드는 것이다.
    func updatePositions() { //render loop 에서 노드의 위치를 업데이트 한다.
        collisionNode.position = pigNode.position //collision node의 위치를 돼지 노드의 위치와 동일하게 되도록 업데이트한다.
        
        
        
        
        //Update the cameraʼs position
        let lerpX = (pigNode.position.x - cameraFollowNode.position.x) * 0.05
        let lerpZ = (pigNode.position.z - cameraFollowNode.position.z) * 0.05
        //카메라가 돼지를 따라가도록 한다(보간된 계수로 살짝 느리게 따라가게 해 부드럽게 움직인다).
        //0.05가 아닌 1이 되면 실시간으로 추적한다.
        
        cameraFollowNode.position.x += lerpX
        cameraFollowNode.position.z += lerpZ
        //카메라의 위치를 돼지보다 약간 늦게 따라가도록 업데이트 시켜준다.
        
        
        
        
        //Update the lightʼs position
        lightFollowNode.position = cameraFollowNode.position
        //조명 노드의 위치를 카메라 노드와 동일하게 업데이트 하여 동기화한다.
    }
}

extension ViewController: SCNSceneRendererDelegate {
    //SceneKit은 SCNView 객체를 사용해 scene의 내용을 렌더링 한다. SCNView 에 SCNSceneRendererDelegate 프로토콜을 구현 하면,
    //SCNView는 애니메이션 이벤트가 발생하고 각 프레임의 렌더링 프로세스가 진행될 때 해당 delegate 대한 메서드를 호출한다.
    //이런 식으로 SceneKit이 scene의 각 프레임을 렌더링 할 때 각 step을 거치게 된다. 이 step 들이 반복되는 loop를 구성한다.
    //render loop의 step은 다음과 같다. p.72
    //1. Update : view가 delegate의 renderer(_: updateAtTime:)를 호출한다. 기본적인 scene 업데이트 로직을 진행한다.
    //2. Execute Actions & Animations : SceneKit이 모든 액션을 실행하고 scene graph 노드에 attach된 모든 애니메이션을 실행한다.
    //3. Did Apply Animations : delegate의 renderer(_: didApplyAnimationsAtTime:)를 호출한다.
    //  이 시점에서 scene의 모든 노드들은 적용된 액션과 애니메이션을 기반으로 단일 프레임 애니메이션을 완성한다.
    //4. Simulates Physics : SceneKit은 scene의 모든 physics body에 물리 시뮬레이션의 single step을 적용한다.
    //5. Did Simulate Physics : delegate의 renderer(_: didSimulatePhysicsAtTime:)를 호출한다.
    //  이 시점에서 물리 시뮬레이션 step이 완료되며, 물리에 대한 논리를 추가할 수 있다.
    //6. Evaluates Constraints : SceneKit은 제약 조건을 평가하고 적용한다.
    //  제약조건은 SceneKit 에서 노드의 transformation을 자동으로 조정하도록 하는 규칙이다.
    //7. Will Render Scene : delegate의 renderer(_: willRenderScene: atTime:)를 호출한다.
    //  이 시점에서 view는 scene의 렌더링 정보를 가져오기 때문에 변경할 수 있는 마지막 지점이 된다.
    //8. Renders Scene In View : SceneKit가 view의 scene를 렌더링한다.
    //9. Did Render Scene : delegate의 renderer(_: didRenderScene: atTime:)를 호출한다. 렌더 루프의 한 사이클이 끝이 나는 곳으로
    //  이곳에 게임의 로직을 넣을 수 있다. 이 게임 로직은 프로세스가 새로 시작하기 전에 실행해야 한다.
    
    func renderer(_ renderer: SCNSceneRenderer, didApplyAnimationsAtTime time: TimeInterval) {
        //애니메이션 Action이 render loop 내에서 완료된 직후에 호출된다. 각 노드들의 scene에서의 정확한 위치를 알 수 있다.
        guard game.state == .playing else { //playing 상태에서만 메서드 실행
            return
        }
        
        game.updateHUD() //HUD 업데이트
        updatePositions() //collisionNode와 pigNode 위치 동기화
        updateTraffic() //차량 업데이트
    }
}




extension ViewController: SCNPhysicsContactDelegate {
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        //두 객체가 충돌하는 이벤트가 발생시 호출된다.
        guard game.state == .playing else { //게임이 실행 중인지 확인
            return
        }
        
        var collisionBoxNode: SCNNode! //충돌 상자
        if contact.nodeA.physicsBody?.categoryBitMask == BitMaskObstacle {
            collisionBoxNode = contact.nodeB
        } else {
            collisionBoxNode = contact.nodeA
        }
        
        activeCollisionsBitMask |= collisionBoxNode.physicsBody!.categoryBitMask
        //충돌 상자의 category bit mask를 activeCollisionsBitMask에 추가하기 위해 비트 OR 연산을 한다.
        
        
        
        
        //Collisions with vehicles
        var contactNode: SCNNode! //돼지가 아닌 노드를 찾는다.
        if contact.nodeA.physicsBody?.categoryBitMask == BitMaskPig {
            contactNode = contact.nodeB
        } else {
            contactNode = contact.nodeA
        }
        
        if contactNode.physicsBody?.categoryBitMask == BitMaskVehicle { //해당 노드가 차량이면 게임을 종료시킨다.
            game.playSound(node: pigNode, name: "Crash") //효과 사운드 재생
            stopGame()
        }
        
        
        
        
        //Collisions with coins
        if contactNode.physicsBody?.categoryBitMask == BitMaskCoin { //해당 노드가 코인이면
            contactNode.isHidden = true //코인 노드를 숨긴다.
            contactNode.runAction(SCNAction.waitForDurationThenRunBlock(duration: 60) { (node: SCNNode!) -> Void in
                //60초 후에 코인을 다시 보이게 한다.
                node.isHidden = false
            })
            
            game.collectCoin() //점수 업데이트
            game.playSound(node: pigNode, name: "CollectCoin") //효과 사운드 재생
        }
        
        
        
        
        if contactNode.physicsBody?.categoryBitMask == BitMaskHouse { //돼지가 집으로 온 경우
            if game.bankCoins() == true {
                game.playSound(node: pigNode, name: "BankCoin") //효과 사운드 재생
            }
        }
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didEnd contact: SCNPhysicsContact) {
        //두 객체가 충돌하는 이벤트가 완료될 시 호출된다.
        guard game.state == .playing else { //게임이 실행 중인지 확인
            return
        }
        
        var collisionBoxNode: SCNNode! //충돌 상자
        if contact.nodeA.physicsBody?.categoryBitMask == BitMaskObstacle {
            collisionBoxNode = contact.nodeB
        } else {
            collisionBoxNode = contact.nodeA
        }
        
        activeCollisionsBitMask &= ~collisionBoxNode.physicsBody!.categoryBitMask
        //비트 NOT 연산 이후, AND 연산을 수행하여 activeCollisionsBitMask에서 충돌 상자의 category bit mask를 제거한다.
    }
    
    //Handling collisions
    //mask 값과 일치하는 category mask를 가진 다른 physics body와 충돌할 때마다 알림을 보내 해당 physics body의 contactTestBitMask를 설정한다.
    //활성화된 collision을 추적하려면 activeCollisionsBitMask라는 특수 속성을 만든다. 네 방향의 충돌 박스 중 하나가 장애물과 충돌하면, physicsWorld(_:didBegin:)가 호출된다.
    //그 후 해당 충돌 박스의 category mask를 사용해 OR(|) 연산으로 activeCollisionsBitMask에 추가한다.
    //그 후 gesture handler에서 activeCollisionsBitMask를 검사하고 활성된 충돌 방향의 제스처를 차단한다.
    //충돌이 끝나면, physicsWorld(_:didEnd:)이 호출된다. 이 때, activeCollisionsBitMask에서 해당 상자의 category bit mask를 제거할 수 있다.
    //이 작업은 NOT(~) 연산 결과를 AND(&) 하여 진행한다.
}




//Update traffic bounds
extension ViewController {
    func updateTraffic() {
        for node in trafficNode.childNodes { //trafficNode 아래의 모든 node loop
            if node.position.x > 25 { //트래픽의 x 위치가 25 이상이 되면,
                node.position.x = -25 //-25로 재이동한다.
            } else if node.position.x < -25 { //트래픽의 x 위치가 -25 이하가 되면,
                node.position.x = 25 //25로 재 이동한다.
            }
        }
    }
}




//Oh, thereʼs one more thing! :]
extension ViewController {
    func stopTraffic() {
        //여러 번 게임을 진행하면, 차량이 서로 겹쳐지기 시작한다. 액션 애니메이션이 제대로 멈추지 않기 때문이다.
        for node in trafficNode.childNodes {
            //이를 해결하기 위해 모든 차량 노드들의 액션 애니메이션을 제거한다.
            node.removeAllActions()
        }
    }
    
    func resetCoins() { //게임이 재시작 될때 코인도 다시 재설정한다.
        let coinsNode = gameScene.rootNode.childNode(withName: "Coins", recursively: true)!
        
        for node in coinsNode.childNodes {
            for child in node.childNodes {
                child.isHidden = false
            }
        }
    }
}


















