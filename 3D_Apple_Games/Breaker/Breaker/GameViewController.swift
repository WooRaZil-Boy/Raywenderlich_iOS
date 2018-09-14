//
//  GameViewController.swift
//  Breaker
//
//  Created by 근성가이 on 2018. 9. 14..
//  Copyright © 2018년 근성가이. All rights reserved.
//

import UIKit
import SceneKit

class GameViewController: UIViewController {
    var scnView: SCNView! //SCNView는 SCNScene의 내용을 scene에 표시한다.
    var scnScene: SCNScene! //SCNScene 클래스는 scene를 나타낸다. SCNView의 인스턴스에 scene를 표시한다.
    //scene에 필요한, 조명, 카메라, 기하 도형, 입자 emitter 등을 이 scene의 자식으로 사용한다.
    var game = GameHelper.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupScene()
        setupNodes()
        setupSounds()
    }
    
    override var shouldAutorotate: Bool { //디바이스의 회전 여부 처리
        return true
    }
    
    override var prefersStatusBarHidden: Bool { //상태 표시줄 표시 여부
        return true
    }
    
    func setupScene() {
        scnView = self.view as! SCNView //self.view를 SCNView로 캐스팅해서 scnView 속성에 저장한다.
        //뷰를 참조해야 할 때마다 다시 캐스팅할 필요 없어진다. self.view 는 Main.storyboard에서 SCNView로 되어 있다.
        //SCNView는 UIView(macOS에서는 NSView)의 하위 클래스이다.
        
        scnView.delegate = self //delegate 설정
        
        scnScene = SCNScene(named: "Breaker.scnassets/Scenes/Game.scn") //scn file로 scene 초기화
        scnView.scene = scnScene //scnView에서 사용할 scene 설정
    }
    
    func setupNodes() {
        
    }
    
    func setupSounds() {
        
    }
}

extension GameViewController: SCNSceneRendererDelegate {
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
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        //SceneKit의 렌더링 루프의 첫 시작이 된다. 액션, 애니메이션, 물리 법칙이 적용 되기 전에 해야하는 모든 업데이트를 수행한다.
        //SCNView 객체(혹은 SCNSceneRenderer)가 일시 중지되지 않는 한 한 프레임 당 한 번씩 이 메서드를 호출한다.
        //이 메서드를 구현해 게임 논리를 렌더링 루프에 추가한다. 이 메서드에서 scene graph를 변경하면 scene에 즉시 반영된다.
    }
}

//SceneKit editor
//Xcode에서 SceneKit 게임 개발을 위해 몇 가지 새로운 도구를 만들었고, SceneKit scene editor는 그 중 하나이다.
//Xcode 6 에서 SpriteKit built-in scene editor를 도입했고, Xcode 7에서는 SceneKit built-in scene editor를 도입했다.
//SpriteKit scene editor를 사용하여 2D SpriteKit 게임을 시각적으로 디자인하고 SceneKit scene editor를 사용하여 3D SceneKit 게임을 디자인 할 수 있다.
//두 편집자의 목적은 WYSIWYG (what-you-see-that-you-get) 환경을 제공해 결과를 시각화하는 것이다.
//scene editor는 Xcode에서 scene의 애니메이션 및 물리 시뮬레이션을 재생할 수 있다. 따라서 최종 결과를 보다 정확하게 묘사 한다.
//이전 장에서는 코드로 scene 를 만들었지만, SceneKit editor로 scene file를 생성해 scene 을 만들 수도 있다.

//Adding a SceneKit scene
//Breaker.scnassets의 하위 폴더에서 모든 scene을 관리해 주는 것이 좋다.
//New File - iOS/Resource/SceneKit Scene File 로 scene template 파일을 만들 수 있다.
//생성 시, Group을 Breaker.scnassets의 하위 폴더로 지정해 준다.
//에디터에 대한 설명은 p.110


