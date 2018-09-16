//
//  GameViewController.swift
//  MarbleMaze
//
//  Created by 근성가이 on 2018. 9. 16..
//  Copyright © 2018년 근성가이. All rights reserved.
//

import UIKit
import SceneKit

class GameViewController: UIViewController {
    var scnView:SCNView! //SCNView는 SCNScene의 내용을 scene에 표시한다.
    var scnScene:SCNScene! //SCNScene 클래스는 scene를 나타낸다. SCNView의 인스턴스에 scene를 표시한다.
    //scene에 필요한, 조명, 카메라, 기하 도형, 입자 emitter 등을 이 scene의 자식으로 사용한다.
    
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
        scnView = self.view as? SCNView //self.view를 SCNView로 캐스팅해서 scnView 속성에 저장한다.
        //뷰를 참조해야 할 때마다 다시 캐스팅할 필요 없어진다. 뷰는 Main.storyboard에서 SCNView로 되어 있다.
        //SCNView는 UIView(macOS에서는 NSView)의 하위 클래스이다.
        
        scnView.delegate = self //delegate 설정
        
        scnView.allowsCameraControl = true //제스처로 활성화된 camera를 수동으로 제어할 수 있다.
        //SceneKit이 카메라 노드를 생성하고 터치 이벤트를 처리하여 사용자가 scene의 제스처 처리를 할 수 있도록 한다.
        // • Single finger swipe : 회전
        // • Two finger swipe: 이동
        // • Two finger pinch: 줌 인/아웃
        // • Double-tap : 여러 개의 camera 객체 있는 경우 전환. 하나 밖에 없는 경우에는 기본 위치와 설정으로 camera를 재설정한다.
        
        scnView.showsStatistics = true //실시간 통계 패널 보기
        // • fps : 초당 프레임. 60fps 이상이 나와야 쾌적하게 게임이 실행된다. 높을 수록 좋다.
        // • ◆ : 프레임 당 총 draw 호출 수. 단일 프레임 당 그려져(draw) 표시되는 객체의 총량. 광원 효과도 이 양을 증가 시킬 수 있다. 낮을 수록 좋다.
        // • ▲ : 프레임 당 총 폴리곤 수. 보여지는 모든 geometry에 대한 단일 프레임을 그릴(draw) 때 사용되는 폴리곤의 총량. 낮을 수록 좋다.
        // • ✸ : 총 가시 광선 광원 수. 현재 보이는 객체에 영향을 주는 광원의 총량. 한 번에 3 개 이상 사용하지 않을 것을 권장
        
        // + 버튼을 누르면, 세부 정보가 나타난다.
        // • Frame time : 단일 프레임을 그리는데 걸린 총 시간. 60fps 일 때 16.7ms의 시간이 걸린다.
        // • The color chart : 프레임을 그리는 데 걸린 대략적인 시간의 백분율을 표시한다.
        
        scnScene = SCNScene(named: "art.scnassets/game.scn") //scn file로 scene 초기화
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
        
    }
}

//Lighting models
//SceneKit은 여러 material의 속성을 scene의 광원과 결합하여 렌더링 된 최종 색상을 생성하는 모델을 지원한다. 다음과 같은 모델이 있다. p.199
// • Constant : 주변(ambient) 조명만을 사용한다. 평면적이다.
// • Lambert : 주변(ambient) 조명과 확산(diffuse) 정보를 통합한다.
// • Blinn : 주변(ambient) 조명과 확산(diffuse), 반사(specular) 조명 정보를 통합한다. Blinn-Phong 공식으로 반사 조명의 하이라이트를 구한다.
// • Phong : 주변(ambient) 조명과 확산(diffuse), 반사(specular) 조명 정보를 통합한다. Phong 공식으로 반사 조명의 하이라이트를 구한다.
// • PBR : Physically Based Rendering(물리 기반 렌더링). 실제 조명과 material을 사실적으로 추상화해서 표현한다.




//Materials
//재질(material)은 색상(color), 반사(specularity), 반사율(reflectivity), 광택(shininess), 거칠기(roughness), 투명도(transparency) 등을 정의한다.
//위와 같은 다양한 속성과 함께 기본 조명 모델을 정의한다. solid colors 나 texture 를 추가해 세부적인 사항을 만들 수 있다.
//텍스처는 기본적으로 3D geometry를 감싸는 2D 이미지로, geometry 내에 저장된 특수한 텍스처 좌표를 사용한다.
//모든 SceneKit의 기본 shape(box, sphere ...)에는 이미 이 좌표정보가 포함되어 있기 때문에 필요한 정보를 제공해 주기만 하면 된다.
//축구공을 생성한다고 할 때, 볼에 기본 색상을 지정하고, 특정 부분을 울퉁불퉁하게 하거나, 반짝이게 하는 등의 효과를 추가해 만들어 줄 수 있다.

//Diffuse map
//geometry에 기본 색상 텍스처를 입힌다. 이 텍스처는 일반적으로 조명 및 특수 효과에 관계없이 객체가 무엇인지 정의한다. p.201

//Normal map
//한 면의 법선 벡터(normal vector)와 표면의 각 픽셀이 조명을 어떻게 받아들이는 지 정의한 법선 벡터를 결합해 얻는다. p.201
//normal map은 geometry의 울퉁불퉁함을 정의하는 텍스처라 생각하면 이해하기 쉽다. (ex. 달의 크레이터, 석판에 새겨진 문자, 축구공의 패치와 가죽 패턴)
//Diffuse map에 Normal map을 결합하면 p.202. Normal map을 생성하는 CrazyBump 라는 툴도 있다.

//Reflective map
//먼저 큐브를 매핑하는 개념(cube mapping)을 이해해야 Reflective map을 이해할 수 있다.
//큐브는 6면 이므로, 6개의 텍스처로 구성되며, 모든 큐브의 면을 텍스처링하는 데 사용되는 하나의 큰 map에 포함되어 있다.
//SceneKit은 다양한 큐브 매핑 패턴을 지원한다. Horizontal Strip(1:6), Vertical Strip(6:1), Vertical Cross(3:4), Horizontal Cross(4:3) p.202
//큐브 맵 이외에도, SceneKit은 Spherical Maps(1:2), MatCaps(1:1) 도 지원한다. p.203
//reflective map은 반사도를 정의한다. 큐브 맵을 사용해 객체에 대한 세부 사항을 정의할 수 있다.
//Diffuse map + Normal map + Reflective map 결과물은 p.204

//Occlusion map
//주변 조명(ambient light)이 있을 때만, 폐색 맵(occlusion map)이 효과적이다. 흑백 텍스처 맵으로 주위의 빛이 geometry의 특정 부분에 도달하는 정도를 정의한다.
//검은 부분은 주변 빛을 완전히 차단하고, 흰색 부분은 주변 조명을 비추게 한다. 복잡한 geometry의 경우, 일부는 다른 지점에서 나오는 주변 광을 차단한다. p.205
//미묘한 효과이지만, 빛의 자연적 속성을 모방하는 데 유용하다.
//Diffuse map + Normal map + Reflective map + Occlusion map 결과물은 p.205

//Specular map
//geometry의 광택(shininess)을 제어한다. 맵의 검은 색 부분은 무광을 정의하고, 흰색 부분은 광택을 나타낸다.
//미묘한 효과이지만, scene에 깊이와 사실감을 더해준다.
//Diffuse map + Normal map + Reflective map + Occlusion map + Specular map 결과물은 p.206

//Emission map
//방출 맵(emission map)은 모든 조명 및 음영 정보를 대체하여 발광 효과를 생성한다. map에 블러 효과를 추가할 때 더욱 두드러진다.
//밝은 색이 가장 강하게 방출되고, 어두운 색이 조금 방출되며, 검은 색은 전혀 방출되지 않는다. p.207
//다른 3D 제작 툴과 달리 Emission map은 SceneKit에서 빛을 생성하지는 않는다.
//Diffuse map + Normal map + Reflective map + Occlusion map + Specular map + Emission map 결과물은 p.207

//Multiply map
//곱셈 맵(multiply map)은 다른 모든 효과 이후에 적용된다. 최종 결과물에 색을 입히거나 밝기를 조정할 수 있다. p.207
//Diffuse map + Normal map + Reflective map + Occlusion map + Specular map + Emission map + Multiply map 결과물은 p.208

//Transparency map
//투명도 맵(transparency map)은 geometry의 일부를 투명하게 하거나 보이지 않게 한다. 검은 색 부분은 불투명하게 흰색 부분은 투명하게 만든다. p.208
//Diffuse map + Normal map + Reflective map + Occlusion map + Specular map + Emission map + Transparency map 결과물은 p.208

//Displacement map
//변위 맵(displacement map)은 정렬된 객체의 geometry와 정점 법선(vertice normals)을 수정한다.
//검은 색에서 중간 회색 섹션은 geometry에서 들어간 효과(indentation)를 만들고, 중간 회색에서 흰색 섹션은 geometry 에서 튀어나온 효과(bump)를 만든다. p.209
//Diffuse map + Normal map + Reflective map + Occlusion map + Specular map + Emission map + Displacement map 결과물은 p.208

//Metalness and Roughness maps
//Physically Based Rendering(PBR) 조명 모델은 metalness map과 Roughness map 을 사용한다.
//물리 기반 조명(physical based lighting), 환경 조명(environmental lighting), 물리적 재질 속성(physical material properties)을
//쉐이더 계산에 통합하기 때문에, PBR은 다른 모델보다 훨씬 현실적인 결과를 만든다. 그러나 ambient, specular, reflective material은 포함하지 않는다. p.210
// • Metalness (금속성) : 굴절, 반사 등과 같은 물리적 표면 특성을 근사해서 나타내 금속 또는 비금속 외관을 생성한다. grayscale color 나 texture를 제공할 수 있다.
// • Roughness (거칠기) : 실제 표면의 미세한 디테일을 대략적으로 나타낸다. 반짝거리거나 무광택한 외관을 만든다. grayscale color 나 texture를 제공할 수 있다.




//Skyboxes
//스카이 박스는 실제 배경이나 풍경의 느낌을 주는 scene 주위의 방대한 상자이다. 대부분의 3D 게임은 이 트릭을 사용한다. (ex. 하늘과 언덕을 배경으로 만든다)
//모든 SceneKit scene camera는 background 속성이 있다. 간단히 특정 색을 채울 수도 있지만, 텍스처가 적용된 큐브 맵으로 대규모 스카이 박스를 생성할 수도 있다.
//스카이 박스에 적용되는 큐브맵 또한, PBR로 매우 사실적으로 만들 거나 다른 모델로 간단히 만들 수도 있다.

//Creating a skybox
//editor에서 camera node를 선택하고 Scene Inspector에서 background를 설정해 준다. 이미지인 경우 library에서 drag and drop 해 주면 된다.




//Reference node
//참조 노드를 사용해, scene에서 객체에 대한 참조를 가져와 수정해 줄 수 있다.







