//
//  GameViewController.swift
//  GeometryFighter
//
//  Created by 근성가이 on 2018. 9. 11..
//  Copyright © 2018년 근성가이. All rights reserved.
//

import UIKit
import SceneKit

class GameViewController: UIViewController {
    var scnView: SCNView! //SCNView는 SCNScene의 내용을 scene에 표시한다.
    var scnScene: SCNScene! //SCNScene 클래스는 scene를 나타낸다. SCNView의 인스턴스에 scene를 표시한다.
    //scene에 필요한, 조명, 카메라, 기하 도형, 입자 emitter 등을 이 scene의 자식으로 사용한다.
    var cameraNode: SCNNode! //카메라
    var spawnTime: TimeInterval = 0 //타이머
    //타이머로 객체가 생성되는 속도를 조절해, 디바이스가 지원할 수 있는 프레임 속도에 관계없이 일관된 속도로 애니메이션을 만들어야 한다.
    //타이머를 사용하는 것은 게임에서 매우 흔한 객체 관리 기법이다.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupScene()
        setupCamera()
//        spawnShape()
        //렌더링 루프 내부에서 delegate 메서드로 호출되므로 필요없어 진다.
    }
    
    override var shouldAutorotate: Bool { //디바이스의 회전 여부 처리
        return true
    }
    
    override var prefersStatusBarHidden: Bool { //상태 표시줄 표시 여부
        return true
    }
    
    func setupView() {
        scnView = self.view as! SCNView //self.view를 SCNView로 캐스팅해서 scnView 속성에 저장한다.
        //뷰를 참조해야 할 때마다 다시 캐스팅할 필요 없어진다. 뷰는 Main.storyboard에서 SCNView로 되어 있다.
        //SCNView는 UIView(macOS에서는 NSView)의 하위 클래스이다.
        scnView.showsStatistics = true //실시간 통계 패널 보기
        // • fps : 초당 프레임. 60fps 이상이 나와야 쾌적하게 게임이 실행된다. 높을 수록 좋다.
        // • ◆ : 프레임 당 총 draw 호출 수. 단일 프레임 당 그려져(draw) 표시되는 객체의 총량. 광원 효과도 이 양을 증가 시킬 수 있다. 낮을 수록 좋다.
        // • ▲ : 프레임 당 총 폴리곤 수. 보여지는 모든 geometry에 대한 단일 프레임을 그릴(draw) 때 사용되는 폴리곤의 총량. 낮을 수록 좋다.
        // • ✸ : 총 가시 광선 광원 수. 현재 보이는 객체에 영향을 주는 광원의 총량. 한 번에 3 개 이상 사용하지 않을 것을 권장
        
        // + 버튼을 누르면, 세부 정보가 나타난다.
        // • Frame time : 단일 프레임을 그리는데 걸린 총 시간. 60fps 일 때 16.7ms의 시간이 걸린다.
        // • The color chart : 프레임을 그리는 데 걸린 대략적인 시간의 백분율을 표시한다.
        
        scnView.allowsCameraControl = true //제스처로 활성화된 camera를 수동으로 제어할 수 있다.
        //SceneKit이 카메라 노드를 생성하고 터치 이벤트를 처리하여 사용자가 scene의 제스처 처리를 할 수 있도록 한다.
        // • Single finger swipe : 회전
        // • Two finger swipe: 이동
        // • Two finger pinch: 줌 인/아웃
        // • Double-tap : 여러 개의 camera 객체 있는 경우 전환. 하나 밖에 없는 경우에는 기본 위치와 설정으로 camera를 재설정한다.
        
        scnView.autoenablesDefaultLighting = true //Default(무 지향성) 광원 추가
        
        scnView.delegate = self //delegate 설정
        
        scnView.isPlaying = true
        //기본적으로 SceneKit은 재생할 애니메이션이 없으면 "일시 중지"된다.
        //이 속성을 true로 하면 view가 무한 재생모드로 강제 전환되어 재생할 애니메이션이 없어도 중지되지 않는다.
    }
    
    func setupScene() {
        scnScene = SCNScene()
        scnView.scene = scnScene //scnView에서 사용할 scene 설정
        scnScene.background.contents = "GeometryFighter.scnassets/Textures/Background_Diffuse.jpg"
    }
    
    func setupCamera() {
        cameraNode = SCNNode()
        //3D 좌표 공간에서 기하 도형, 조명, 카메라 등 표시 가능한 내용을 추가해 position과 transform를 나타내는 scene graph 의 구성 요소.
        cameraNode.camera = SCNCamera() //노드에 카메라 속성을 할당한다.
        cameraNode.position = SCNVector3(x: 0, y: 5, z: 10) //노드의 위치를 설정한다.
        scnScene.rootNode.addChildNode(cameraNode) //루트 노드의 자식 노드로 scene에 추가한다. //scene graph 구조를 이룬다.
        
        //Cameras
        //카메라가 있는 노드의 위치에 따라 scene를 보는 시점이 결정된다. p.49
        //• 카메라의 방향은 항상 카메라가 포함 된 노드의 -z 축을 따른다.
        //• 시야(field of view)는 카메라 가시 영역의 제한 각도이다. 좁은 각도는 좁은 시야를, 넓은 각도는 넓은 시야를 제공한다.
        //• viewing frustum은 카메라의 가시적인 깊이를 결정한다.
        //이 영역 밖의 모든 것, 즉 카메라에서 너무 가깝거나 너무 멀리있는 부분은 클리핑되어 화면에 나타나지 않는다.
        //SceneKit camera는 SCNCamera로 표현되며, xPov와 yPov 속성을 사용해 시야(field of view)를 조정할 수 있고,
        //zNear와 zFar를 사용해 viewing frustum을 조정할 수 있다.
        //기억해야할 핵심 사항은 카메라가 노드 계층의 일부가 아니라면, 카메라 자체는 아무것도 하지 않는다.
    }
    
    func spawnShape() {
        var geometry: SCNGeometry //Scene에 표시할 수 있는 meterial을 포함한 3차원 기하 도형(model 이나 mesh 라고도 한다).
        
        switch ShapeType.random() { //반환된 모양을 처리할 switch
        case .box:
            geometry = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
            //상자 모양의 기하 도형을 생성한다. //너비, 높이, 길이, 모서리
        case .sphere:
            geometry = SCNSphere(radius: 0.5)
        case .pyramid:
            geometry = SCNPyramid(width: 1.0, height: 1.0, length: 1.0)
        case .torus:
            geometry = SCNTorus(ringRadius: 0.5, pipeRadius: 0.25)
        case .capsule:
            geometry = SCNCapsule(capRadius: 0.3, height: 2.5)
        case .cylinder:
            geometry = SCNCylinder(radius: 0.3, height: 2.5)
        case .cone:
            geometry = SCNCone(topRadius: 0.25, bottomRadius: 0.5, height: 1.0)
        case .tube:
            geometry = SCNTube(innerRadius: 0.25, outerRadius: 0.5, height: 1.0)
        }
        
        geometry.materials.first?.diffuse.contents = UIColor.random() //색상 지정
        //geometry의 material을 가져와 임의의 UIColor로 설정한다.
        //diffusesms material 표면의 각 점에서 모든 방향으로 똑같이 반사되는 빛의 양과 색상을 나타낸다. 기본 색이나 기본 질감으로 생각하면 된다.
        
        let geometryNode = SCNNode(geometry: geometry) //기하 도형(geometry)으로 SCNNode를 생성한다.
        //geometry 매개 변수를 사용해 노드를 만들고 해당 geometry를 자동으로 연결한다.
        
        //Geometry
        //기하 도형은 3차원 도형을 나타내며 폴리곤을 정의하는 정점(vertices)으로부터 생성된다. Geometry에는 material 객체가 포함될 수 있다.
        //material을 사용하면 기하 도형의 색상, 텍스처, 시각 효과, 광원 등의 정보를 지정해 줄 수 있다.
        //정점(vertices)과 재료(materials)의 모음을 model 혹은 mesh라 한다. p.51
        
        geometryNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil) //물리 엔진을 적용한 physics Body 를 연결한다. default는 nil(적용 X)이다.
        //SceneKit에서 모든 physics Body 는 SCNPhysicsBody 객체이다. physics Body를 노드에 할당하면 물리 엔진이 시뮬레이션 할 수 있다.
        //physics Body 생성 시에 type과 shape를 지정해 준다. shape를 nil로 하면, SceneKit는 노드의 geometry를 기반으로 shape를 자동 생성한다.
        //여기서 다른 옵션을 추가 시켜 주지 않으면, 실행되자마자 노드가 떨어지며 사라진다. SceneKit의 scene 은 기본적으로 중력이 적용되기 때문이다.
        //생성 된 객체가 physics Body 이기 때문에 물리 시뮬레이션은 중력과 같은 가상의 힘을 객체에 적용한다.
        
        //Physics
        //객체의 위치나 회전을 애니메이션으로 추가해 줄 수 있지만, 충돌과 같은 다른 객체들의 상호작용에 일일이 적용하려면 많은 코드가 필요하다.
        //대신 SceneKit 물리 엔진을 사용하면 객체에 간단하게 중력 및 충돌 등의 효과를 추가해 줄 수 있다.
        //이 물리 엔진을 사용하려면 먼저 엔진에 객체를 인식 시켜야한다. 노드에 geometry를 attach 한 것과 같은 방법으로 physics body를 노드에 추가할 수 있다.
        //physics body는 shape(모양), mass(질량), friction(마찰), damping(감쇠), restitution(마찰) 등을 포함하여 노드의 모든 물리 특성을 설명할 수 있다.
        
        //Physics body types
        //physics body를 만들 때 지정해야 하는 주요 속성 중 하나가 type 이다. physics body type 은 객체의 물리 상호작용 방식을 정의한다.
        //SceneKit 에는 세 가지 유형이 있다.
        //• Static : 움직이지 않는다. 다른 물체는 이 물체와 충돌할 수 있지만, static 물체 자체는 모든 힘과 충돌에 영향을 받지 않는다(ex. 벽, 바위).
        //• Dynamic : 물리 엔진이 힘과 충돌에 대응해 물체를 이동 시킨다(ex. 의자, 테이블, 컵).
        //• Kinematic : 수동으로 힘과 충돌에 대응해 물체를 이동 시켜야 한다.
        //  Dynamic 물체와 Kinematic 물체가 충돌하면, Dynamic 물체는 움직이지만, Kinematic 물체는 움직이지 않는다.
        //  하지만 코드로 움직여 줄 수 있다(ex. 이동하는 엘리베이터, 개폐 가능한 문과 같이 수동으로 제어되는 물체).
        
        //Physics shapes
        //Physics shapes 는 충돌 감지 중에 물리 엔진이 사용하는 3D 모양을 정의한다.
        //geometry 가 노드의 외형을 정의하는 동안, physics body 는 노드가 다른 객체와 상호 작용하는 방식을 정의한다.
        //(힘과 충돌에 반응하는 모형 정의. 즉 구형 shape로 지정하면, 구체처럼 반응한다)
        //shape 를 geometry 완전히 동일하게 할 수도 있지만, 계속해야 할 값이 증가해 전체적인 속도가 느려질 수 있다.
        //따라서 대략적으로 일치하는 기본 모양 중 하나로 단순화 시키는 경우가 많다.
        
        let randomX = Float.random(min: -2, max: 2)
        let randomY = Float.random(min: 10, max: 18)
        let force = SCNVector3(x: randomX, y: randomY, z: 0) //force Vector. 힘의 양을 지정한다.
        let position = SCNVector3(x: 0.05, y: 0.05, z: 0.05) //position Vector. 힘이 가해질 위치를 지정한다.
        //위치가 약간 빗겨나 있기 때문에 회전이 생긴다.
        geometryNode.physicsBody?.applyForce(force, at: position, asImpulse: true) //physics Body에 Force 적용
        
        //Force
        //physic body 에 힘을 적용하려면 applyForce(direction: at: asImpulse:)를 사용하고 SCNVector3 로 적용할 양과 위치를 전달해야한다.
        //해당 힘은 충돌로 적용 되고, 가속도에 영향을 준다.
        
        //벡터의 force 적용은 p.64 (벡터의 힘이 기준이므로 일반적으로 생각하는 xyz 좌표와 방향이 반대)
        //벡터의 position 적용은 p.65 (특정 위치에 힘을 적용해 다양한 동작을 생성할 수 있다. ex. 회전)
        
        
        
        
        //Torque
        //토크는 applyTorque(torque: asImpulse:)를 사용하여 body에 적용할 수 있는 또 다른 회전이다.
        //토크는 선형 운동량(linear momentum : x,y,z)이 아닌 각 운동량(angular momentum : spin)에 영향을 미친다.
        //토크를 적용하면, 물체가 질량의 중심으로 회전한다. p.67
        //토크를 적용할 때는 SCNVector4 를 사용해야 한다. x, y, z 는 SCNVector3 의 축과 같지만, w 는 회전 각, 토크의 크기를 결정한다.
        
        //SceneKit의 물리 엔진의 측정 단위는 국제 단위(International System of Units, SI) 를 사용한다.
        //Mass : Kilograms, Force : Newtons, Impulse : Newton-second, Torque : Newton-meter
        
        scnScene.rootNode.addChildNode(geometryNode) //노드를 scene의 루트 노드 자식으로 추가한다. //scene graph 구조를 이룬다.
        
        //각 요소로 노드를 만들고, 그 노드를 루트 노드의 자식으로 추가해야 한다. 루트 노드는 scene 좌표계를 정의한다.
        //이들을 연결해 scene graph 구조를 이룬다.
    }
    
    func cleanScene() {
        for node in scnScene.rootNode.childNodes { //root node에서 모든 하위 노드를 가져온다.
            if node.presentation.position.y < -2  {
                //이 시점에서 physics 시뮬레이션이 작동 중인데, 이는 애니메이션의 시작 전 위치를 반영한다.
                //따라서 단순하게 객체의 위치를 그대로 가져오면 안 된다(node.position 으로 가져오면 안 된다는 뜻).
                //SceneKit은 애니메이션 중에 객체의 복사본을 유지하고, 애니메이션이 끝날 때까지 재생한다.
                //애니메이션이 적용되는 동안 객체의 실제 위치를 가져오려면 presentationNode(node.presentation.position)을 사용해야 한다(read only).
                node.removeFromParentNode() //노드를 제거한다.
            }
        }
        
        //Removing child nodes
        //새로운 하위 노드를 계속해서 scene에 추가하지만, 카메라 밖으로 사라져도 자동으로 제거되지 않는다.
        //성능과 프레임 속도를 고려하면, 사라진 노드는 삭제해 줘야 한다. 렌더링 loop에서 이를 처리해 줄 수 있다.
        //물체가 경계선에 도달하면 제거해 준다.
    }
    
    
}

//A history of SceneKit
//SceneKit은 iOS, watchOS, tvOS 및 macOS에서 SceneKit으로 3D 게임을 만드는 것은 쉽다.
//SceneKit이 개발되기 이전에는 OpenGL ES를 사용해 3D 게임을 만들었다.
//OpenGL ES는 (Metal과 함께) 가장 낮은 수준의 3D 그래픽 API이다.
//Unity가 훌륭한 대안이 될 수 있지만, 완전히 새로운 프로그래밍 패러다임을 새로 배워야 한다.
//애플은 2012년에 OS X Mountain Lion을 출시하면서 OS X 개발자에게 SceneKit을 소개했다(나중에 macOS로).
//2 년 후, SceneKit은 iOS 8에 포함되면서 iOS도 지원하게 되었고, 시간이 지나면서 watchOS와 tvOS도 지원하게 되었다.
//Apple의 2D 게임용 그래픽 프레임 워크인 SpriteKit과 SceneKit은 완벽한 통합 가능하다.
//SpriteKit은 3D 콘텐츠를 2D scene에 통합 할 수 있으며, SceneKit은 SpriteKit의 2D 기능을 3D scene에 통합 할 수 있다.
//SceneKit은 OpenGL ES를 기반으로 한다. iOS 9 부터는 Metal을 기반으로 사용할 수도 있다.
//Android, Windows 혹은 크로스 플랫폼 게임을 제작하려는 경우에는 Unity와 같은 크로스 플랫폼 툴을 사용하는 것이 좋다.




//SceneKit은 구성 요소를 scene graph 라고하는 노드 기반 계층 구조로 구성한다. scene는 좌표계를 정의하는 root node로 시작한다.
//root node 아래에 content nodes 를 추가하여 트리 구조를 형성한다.
//이러한 content node 는 scene의 기본 요소이며 조명, 카메라, 기하 도형 및 입자 emitter와 같은 요소를 포함 할 수 있다.

//조명, 카메라, 기하 도형 및 입자 emitter와 같은 요소를 노드라고 하며, 노드는 트리 구조로 저장된다.
//단일 노드는 SCNNode 클래스로 표현되며 부모 노드를 기준으로 3D 공간에서의 위치를 나타낸다.
//노드 자체에는 보이는 내용이 없으므로 scene의 일부로 렌더링 될 때 아무것도 보이지 않는다.
//가시적으로 보이게 하려면, 조명, 카메라 또는 기하 도형과 같은 다른 구성 요소를 노드에 추가해야 한다.
//scene graph는 노드 기반 계층 구조의 기초를 형성하는 특수 노드인 root node를 초함한다.
//scene를 구성하려면 개별 노드를 root node의 하위 노드 또는 root node의 하위 노드의 하위노드(and so on..)로 추가해야 한다.




//Asset catalogs
//SceneKit Asset catalog는 코드와 별도로 Asset을 관리 한다. Asset catalog를 사용해 단일 폴더에서 Asset을 관리 할 수 ​​있다.
//이를 사용하려면 확장명이 .scnassets 인 폴더를 프로젝트에 추가하고 모든 Asset을 해당 폴더에 저장하기만 하면 된다.
//Xcode는 빌드 할 때 catalog의 모든 내용을 앱 번들에 복사한다. Xcode는 Asset 폴더 계층을 보존한다.
//따라서 Asset 폴더를 모델 디자이너와 공유해 변경된 저작물을 프로젝트에 다시 복사하지 않고도 같은 빌드를 준비 할 수 있다.




//The SceneKit coordinate system
//UIKit 이나 SpriteKit과 같은 2D 시스템에서는 점을 사용하여 x, y 축에서 뷰 또는 스프라이트의 위치를 ​​표현한다.
//객체를 3D 공간에 배치하려면 z 축상에 객체 위치의 깊이를 설명해야 한다.
//SceneKit은 SCNVector3 데이터 형식을 사용해 3 차원 벡터로 나타낸다.
//scene에 추가된 노드의 기본 위치는 (x : 0, y : 0, z : 0)이며 항상 부모 노드를 기준으로 한다.
//노드를 원하는 위치에 배치하려면 부모 노드의 위치(local)를 기준으로(world 가 아님을 유의) 조정해야 한다.


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
    //6. Evaluates Constraints : SceneKit은 제약 조건을 평가하고 적용한다. 제약조건은 SceneKit 에서 노드의 transformation을 자동으로 조정하도록 하는 규칙이다.
    //7. Will Render Scene : delegate의 renderer(_: willRenderScene: atTime:)를 호출한다.
    //  이 시점에서 view는 scene의 렌더링 정보를 가져오기 때문에 변경할 수 있는 마지막 지점이 된다.
    //8. Renders Scene In View : SceneKit가 view의 scene를 렌더링한다.
    //9. Did Render Scene : delegate의 renderer(_: didRenderScene: atTime:)를 호출한다. 렌더 루프의 한 사이클이 끝이 나는 곳으로
    //  이곳에 게임의 로직을 넣을 수 있다. 이 게임 로직은 프로세스가 새로 시작하기 전에 실행해야 한다.
    
    //update - animation - physics - render 순으로 진행
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        //SceneKit의 렌더링 루프의 첫 시작이 된다. 액션, 애니메이션, 물리 법칙이 적용 되기 전에 해야하는 모든 업데이트를 수행한다.
        //SCNView 객체(혹은 SCNSceneRenderer)가 일시 중지되지 않는 한 한 프레임 당 한 번씩 이 메서드를 호출한다.
        //이 메서드를 구현해 게임 논리를 렌더링 루프에 추가한다. 이 메서드에서 scene graph를 변경하면 scene에 즉시 반영된다.
        
        if time > spawnTime { //현재 시스템 시간이 spawnTime보다 크다면
            spawnShape() //새로운 shape를 생성한다.
            
            spawnTime = time + TimeInterval(Float.random(min: 0.2, max: 1.5)) //spawnTime 업데이트
            //다음 spawnTime을 현재 시스템 시간에서 0.2 ~ 1.5 사이의 무작위 값을 증가 시킨 시간으로 재설정한다.
            
            //60fps 게임이므로 최소 0.2초, 최대 1.5초 후에 geometry 객체가 다시 생성된다.
            //시스템 시간은 계속해서 증가하고, 객체 생성 이후 spawnTime도 증가하게 되면서 geometry 객체가 생성된다.
        }
        //현재 시스템 시간이 spawnTime보다 크지 않다면 아무런 행동도 하지 않는다.
        
        cleanScene() //노드가 경계선에 도달하면 제거해 준다.
    }
}
