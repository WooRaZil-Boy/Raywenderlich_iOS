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
    
    var driveLeftAction: SCNAction!
    var driveRightAction: SCNAction!
    //차량의 Action
    
    var jumpLeftAction: SCNAction!
    var jumpRightAction: SCNAction!
    var jumpForwardAction: SCNAction!
    var jumpBackwardAction: SCNAction!
    //돼지의 Action
    
    var triggerGameOver: SCNAction!
    
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
    }
}










