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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupScene()
        setupCamera()
        spawnShape()
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
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 10) //노드의 위치를 설정한다.
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
        
        let geometryNode = SCNNode(geometry: geometry) //기하 도형(geometry)으로 SCNNode를 생성한다.
        //geometry 매개 변수를 사용해 노드를 만들고 해당 geometry를 자동으로 연결한다.
        scnScene.rootNode.addChildNode(geometryNode) //노드를 scene의 루트 노드 자식으로 추가한다. //scene graph 구조를 이룬다.
        
        //각 요소로 노드를 만들고, 그 노드를 루트 노드의 자식으로 추가해야 한다. 루트 노드는 scene 좌표계를 정의한다.
        //이들을 연결해 scene graph 구조를 이룬다.
        
        //Geometry
        //기하 도형은 3차원 도형을 나타내며 폴리곤을 정의하는 정점(vertices)으로부터 생성된다. Geometry에는 material 객체가 포함될 수 있다.
        //material을 사용하면 기하 도형의 색상, 텍스처, 시각 효과, 광원 등의 정보를 지정해 줄 수 있다.
        //정점(vertices)과 재료(materials)의 모음을 model 혹은 mesh라 한다. p.51
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
