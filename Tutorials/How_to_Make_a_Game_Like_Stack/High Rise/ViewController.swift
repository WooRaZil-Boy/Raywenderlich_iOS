/**
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
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import SceneKit
import SpriteKit

class ViewController: UIViewController {
    @IBOutlet weak var scnView: SCNView!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    
    var scnScene: SCNScene!
    
    var direction = true //블록 position이 increasing 또는 decreasing 인지
    var height = 0 //타워의 높이
    
    var previousSize = SCNVector3(1, 0.2, 1) //이전 layer의 size
    var previousPosition = SCNVector3(0, 0.1, 0) //이전 layer의 position
    var currentSize = SCNVector3(1, 0.2, 1) //현재 layer의 size
    var currentPosition = SCNVector3Zero //현재 layer의 position
    
    var offset = SCNVector3Zero
    var absoluteOffset = SCNVector3Zero
    var newSize = SCNVector3Zero
    //새 layer의 size를 계산하기 위한 변수들
  
    var perfectMatches = 0 //플레이어가 완벽하게 이전 layer와 일치한 횟수
    
    var sounds = [String: SCNAudioSource]() //사운드
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scnScene = SCNScene(named: "HighRise.scnassets/Scenes/GameScene.scn")
        scnView.scene = scnScene //scnView에서 사용할 scene 설정
        
        
        
        
        //Loading Sounds
        loadSound(name: "GameOver", path: "HighRise.scnassets/Audio/GameOver.wav")
        loadSound(name: "PerfectFit", path: "HighRise.scnassets/Audio/PerfectFit.wav")
        loadSound(name: "SliceBlock", path: "HighRise.scnassets/Audio/SliceBlock.wav")
    
        
        
        
        //Adding Your First Block
//        let blockNode = SCNNode(geometry: SCNBox(width: 1, height: 0.2, length: 1, chamferRadius: 0))
//        //기하 도형(geometry - box)으로 SCNNode를 생성한다.
//        blockNode.position.z = -1.25 //block의 z 위치 설정
//        blockNode.position.y = 0.1 //block의 y 위치 설정
//        blockNode.name = "Block\(height)" //block의 name 설정
//        //scene graph를 쉽게 관리하기 위해, 노드에 설명이 포함된 name 을 지정해 줄 수 있다.
//        //childNode(withName: recursively:) 나 childNodes(passingTest:) 등의 메서드를 이용해 scene graph에서 해당 노드를 검색할 수 있다.
//        blockNode.geometry?.firstMaterial?.diffuse.contents = UIColor(red: CGFloat(0.01 * Float(height)), green: 0, blue: 1, alpha: 1)
//        //material을 설정해 준다. diffuse의 red 값을 height 만큼 증가시켜 준다.
//        //diffusesms material 표면의 각 점에서 모든 방향으로 똑같이 반사되는 빛의 양과 색상을 나타낸다. 기본 색이나 기본 질감으로 생각하면 된다.
//
//        scnScene.rootNode.addChildNode(blockNode) //루트 노드의 자식 노드로 scene에 추가한다. //scene graph 구조를 이룬다.
        //playGame() 메서드로 대체
        
        scnView.isPlaying = true //기본적으로 SceneKit은 scene를 일시 정지 한다.
        //기본적으로 SceneKit은 재생할 애니메이션이 없으면 "일시 중지"된다.
        //이 속성을 true로 하면 view가 무한 재생모드로 강제 전환되어 재생할 애니메이션이 없어도 중지되지 않는다.
        scnView.delegate = self //delegate 설정
    }
    
    override var prefersStatusBarHidden: Bool { //상태 표시줄 표시 여부
        return true
    }
}

//Stack 게임의 목적은 블록을 다른 블록 위에 놓는 것이다.




//Setting up the Scene
//GameScene.scn 에 카메라를 추가하고, Attributes Inspector의 Projection type을 Orthographic으로 변경한다.
//Light를 추가하고, 기본 tower가 될 box 를 추가한다. box의 Shading을 Blinn으로 하고 diffuse를 설정해 준다.
//Base Block(box)에 물리엔진을 static type으로 추가해 준다.
//Base Block를 선택한 채로 Scene Inspector에서 배경을 설정해 줄 수 있다.
//스토리보드에서 label을 추가하고, IBOutlet으로 연결한다.

//physics body type 은 객체의 물리 상호작용 방식을 정의한다. 3가지 유형이 있다.
//• Static : 움직이지 않는다. 다른 물체는 이 물체와 충돌할 수 있지만, static 물체 자체는 모든 힘과 충돌에 영향을 받지 않는다(ex. 벽, 바위).
//• Dynamic : 물리 엔진이 힘과 충돌에 대응해 물체를 이동 시킨다(ex. 의자, 테이블, 컵).
//• Kinematic : 수동으로 힘과 충돌에 대응해 물체를 이동 시켜야 한다.
//  Dynamic 물체와 Kinematic 물체가 충돌하면, Dynamic 물체는 움직이지만, Kinematic 물체는 움직이지 않는다.
//  하지만 코드로 움직여 줄 수 있다(ex. 이동하는 엘리베이터, 개폐 가능한 문과 같이 수동으로 제어되는 물체).




//Moving the Blocks
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
  
    //update - animation - physics - render 순으로 진행
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        //SceneKit의 렌더링 루프의 첫 시작이 된다. 액션, 애니메이션, 물리 법칙이 적용 되기 전에 해야하는 모든 업데이트를 수행한다.
        //SCNView 객체(혹은 SCNSceneRenderer)가 일시 중지되지 않는 한 한 프레임 당 한 번씩 이 메서드를 호출한다.
        //이 메서드를 구현해 게임 논리를 렌더링 루프에 추가한다. 이 메서드에서 scene graph를 변경하면 scene에 즉시 반영된다.
        for node in scnScene.rootNode.childNodes {
            //BrakeBoxNode는 사라지지 않고 무한히 떨어진다. 따라서 강제로 삭제해 줘야 한다.
            if node.presentation.position.y <= -20 { //y위치가 -20보다 작으면
                //이 시점에서 physics 시뮬레이션이 작동 중인데, 이는 애니메이션의 시작 전 위치를 반영한다.
                //따라서 단순하게 객체의 위치를 그대로 가져오면 안 된다(node.position 으로 가져오면 안 된다는 뜻).
                //SceneKit은 애니메이션 중에 객체의 복사본을 유지하고, 애니메이션이 끝날 때까지 재생한다.
                //애니메이션이 적용되는 동안 객체의 실제 위치를 가져오려면 presentationNode(node.presentation.position)을 사용해야 한다(read only).
                node.removeFromParentNode() //삭제
            }
        }
        
        if let currentNode = scnScene.rootNode.childNode(withName: "Block\(height)", recursively: false) {
            //rootNode.childNode 를 사용해 지정한 name으로 child node를 가져올 수 있다.
            //recursively 매개 변수를 true로 하면 노드의 전체 하위 트리를 검색해서 해당 노드를 찾는다.
            //false일 시에는 직접적인 하위 노드만을 검색한다.
            if height % 2 == 0  { //block을 layer가 있는 x축이나 z축으로 이동해야 한다. 짝수 layer의 경우
                //짝수 layer는 z축으로 이동하고, 홀수 layer는 x축으로 이동한다.
                if currentNode.position.z >= 1.25 { //box의 위치가 1.25에 도달하면 방향을 변경한다.
                    direction = false
                } else if currentNode.position.z <= -1.25 { //box의 위치가 -1.25에 도달하면 방향을 변경한다.
                    direction = true
                }
                
                switch direction { //방향에 따라 box는 z축을 따라 앞 또는 뒤로 움직인다.
                case true:
                    currentNode.position.z += 0.03
                case false:
                    currentNode.position.z -= 0.03
                }
            } else { //위의 코드와 같지만, x축에 대해서 작동한다. 홀수 layer의 경우
                if currentNode.position.x >= 1.25 {
                    direction = false
                } else if currentNode.position.x <= -1.25 {
                    direction = true
                }
                
                switch direction {
                case true:
                    currentNode.position.x += 0.03
                case false:
                    currentNode.position.x -= 0.03
                }
            }
        }
    }
}




//Handling Taps
//플레이어가 화면을 탭할 때마다 새 block을 추가하고 이전 block의 크기를 조정해야 한다.
extension ViewController {
    @IBAction func handleTap(_ sender: UITapGestureRecognizer) {
        if let currentBoxNode = scnScene.rootNode.childNode(withName: "Block\(height)", recursively: false) {
            //rootNode.childNode 를 사용해 지정한 name으로 child node를 가져올 수 있다.
            //recursively 매개 변수를 true로 하면 노드의 전체 하위 트리를 검색해서 해당 노드를 찾는다.
            //false일 시에는 직접적인 하위 노드만을 검색한다.
            currentPosition = currentBoxNode.presentation.position
            //이 시점에서 physics 시뮬레이션이 작동 중인데, 이는 애니메이션의 시작 전 위치를 반영한다.
            //따라서 단순하게 객체의 위치를 그대로 가져오면 안 된다(node.position 으로 가져오면 안 된다는 뜻).
            //SceneKit은 애니메이션 중에 객체의 복사본을 유지하고, 애니메이션이 끝날 때까지 재생한다.
            //애니메이션이 적용되는 동안 객체의 실제 위치를 가져오려면 presentationNode(node.presentation.position)을 사용해야 한다(read only).
            let boundsMin = currentBoxNode.boundingBox.min
            let boundsMax = currentBoxNode.boundingBox.max
            currentSize = boundsMax - boundsMin
            
            offset = previousPosition - currentPosition //이전 layer와 현재 layer 사이의 postion 차이이다.
            absoluteOffset = offset.absoluteValue()
            newSize = currentSize - absoluteOffset
            //다음 block의 offset과 size
            
            
            
            
            //Handling Misses
            //이전 layer와 일치하는 부분이 없는 경우. newSize가 음수가 된다. 게임이 종료된다.
            if height % 2 == 0 && newSize.z <= 0 { //짝수 layer의 경우. x축에서 움직이므로 z값을 확인한다(이전 layer 확인).
                height += 1 //block을 더 이상 쌓지 않게 하기 위해 1 증가
                currentBoxNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(geometry: currentBoxNode.geometry!, options: nil))
                //dynamic 물리엔진을 적용한다. dynamic이므로 밑으로 떨어지게 된다.
                
                playSound(sound: "GameOver", node: currentBoxNode) //사운드 재생
                gameOver()
                
                return
            } else if height % 2 != 0 && newSize.x <= 0 { //홀수 layer의 경우. z축에서 움직이므로 x값을 확인한다(이전 layer 확인).
                height += 1 //block을 더 이상 쌓지 않게 하기 위해 1 증가
                currentBoxNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(geometry: currentBoxNode.geometry!, options: nil))
                //dynamic 물리엔진을 적용한다. dynamic이므로 밑으로 떨어지게 된다.
                
                playSound(sound: "GameOver", node: currentBoxNode) //사운드 재생
                gameOver()
                
                return
            }
            
            checkPerfectMatch(currentBoxNode) //완벽히 일치하는 지 확인
            
            currentBoxNode.geometry = SCNBox(width: CGFloat(newSize.x), height: 0.2, length: CGFloat(newSize.z), chamferRadius: 0)
            //현재 block 에서 이전 layer 부분과 겹치는 부분만을 가져와 새로 block 객체를 만든다.
            currentBoxNode.position = SCNVector3Make(currentPosition.x + (offset.x/2), currentPosition.y, currentPosition.z + (offset.z/2))
            //남은 block의 위치를 이전 layerdhk 겹치도록 변경해 준다. offset을 2로 나눈 값을 설정하면 block의 가장자리가 이전 layer의 가장자리와 일치한다.
            currentBoxNode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: currentBoxNode.geometry!, options: nil))
            //static 물리엔진을 적용한다.
            
            addBrokenBlock(currentBoxNode) //떨어져 나가는 block 효과 추가
            addNewBlock(currentBoxNode) //새 block 추가
            playSound(sound: "SliceBlock", node: currentBoxNode) //사운드 재생
            
            if height >= 5 { //높이가 5보다 크거나 같으면 카메라를 이동한다.
                let moveUpAction = SCNAction.move(by: SCNVector3Make(0.0, 0.2, 0.0), duration: 0.2) //Action 설정. y축으로 움직인다.
                let mainCamera = scnScene.rootNode.childNode(withName: "Main Camera", recursively: false)!
                //rootNode.childNode 를 사용해 지정한 name으로 child node를 가져올 수 있다.
                //recursively 매개 변수를 true로 하면 노드의 전체 하위 트리를 검색해서 해당 노드를 찾는다.
                //false일 시에는 직접적인 하위 노드만을 검색한다.
                mainCamera.runAction(moveUpAction) //Action 적용
            }
            
            scoreLabel.text = "\(height+1)" //점수 레이블 업데이트
            
            previousSize = SCNVector3Make(newSize.x, 0.2, newSize.z)
            previousPosition = currentBoxNode.position
            height += 1
            //변수들을 업데이트 해, 다음 block을 쌓을 때 이전 layer의 정보로 가져올 수 있도록 한다.
        }
    }
    
    func addNewBlock(_ currentBoxNode: SCNNode) {
        let newBoxNode = SCNNode(geometry: currentBoxNode.geometry) //새로운 layer //기하 도형(geometry - box)으로 SCNNode를 생성한다.
        newBoxNode.position = SCNVector3Make(currentBoxNode.position.x, currentBoxNode.position.y + 0.2, currentBoxNode.position.z)
        //위치 설정 이전 box와 y만 다르다.
        newBoxNode.name = "Block\(height+1)" //box의 name 설정
        //scene graph를 쉽게 관리하기 위해, 노드에 설명이 포함된 name 을 지정해 줄 수 있다.
        //childNode(withName: recursively:) 나 childNodes(passingTest:) 등의 메서드를 이용해 scene graph에서 해당 노드를 검색할 수 있다.
        newBoxNode.geometry?.firstMaterial?.diffuse.contents = UIColor(red: CGFloat(0.01 * Float(height)), green: 0, blue: 1, alpha: 1)
        //material을 설정해 준다. diffuse의 red 값을 height 만큼 증가시켜 준다.
        //diffusesms material 표면의 각 점에서 모든 방향으로 똑같이 반사되는 빛의 양과 색상을 나타낸다. 기본 색이나 기본 질감으로 생각하면 된다.
        
        //viewDidLoad() 에서 Base layer를 추가한 코드와 비슷하다.
        
        if height % 2 == 0 { //짝수 layer의 경우. x축에서 움직인다.
            newBoxNode.position.x = -1.25
        } else { //홀수 layer의 경우. z축에서 움직인다.
            newBoxNode.position.z = -1.25
        }

        scnScene.rootNode.addChildNode(newBoxNode) //루트 노드의 자식 노드로 scene에 추가한다. //scene graph 구조를 이룬다.
    }
}

//Implementing Physics
extension ViewController {
    //물리엔진을 구현해, block이 타워 아래로 떨어질 때의 효과를 다듬어 줄 수 있다.
    func addBrokenBlock(_ currentBoxNode: SCNNode) {
        let brokenBoxNode = SCNNode() //노드 생성
        brokenBoxNode.name = "Broken\(height)" //rootNode.childNode 를 사용해 지정한 name으로 child node를 가져올 수 있다.
        
        if height % 2 == 0 && absoluteOffset.z > 0 { //짝수 layer의 경우. x축에서 움직이므로 z 값이 0보다 큰지 확인한다(이전 layer 확인).
            //absoluteOffset.z 값이 0인 경우에는 효과를 줄 brokenBoxNode가 없기 때문이다.
            brokenBoxNode.geometry = SCNBox(width: CGFloat(currentSize.x), height: 0.2, length: CGFloat(absoluteOffset.z), chamferRadius: 0)
            //기하 도형(geometry - box)으로 SCNNode를 생성한다.
            //handleTap(_:)에서는 겹치는 부분을 찾기 위해 offset을 빼줬지만, 여기에서는 offset이 해당 크기와 같으므로 그대로 사용하면 된다.
            
            if offset.z > 0 {
                brokenBoxNode.position.z = currentBoxNode.position.z - (offset.z/2) - ((currentSize - offset).z/2)
            } else {
                brokenBoxNode.position.z = currentBoxNode.position.z - (offset.z/2) + ((currentSize + offset).z/2)
            }
            //brokenBox의 위치를 변경한다.
            //현재 위치에서 offset의 절반을 뺀 block으로 brokenBox의 position을 찾는다.
            //그 후, 블록의 위치에 따라 현재 크기의 절반에서 offset을 더하거나 뺀다.
            
            brokenBoxNode.position.x = currentBoxNode.position.x
            brokenBoxNode.position.y = currentPosition.y
            
            brokenBoxNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(geometry: brokenBoxNode.geometry!, options: nil))
            //dynamic 물리엔진을 적용한다. dynamic이므로 밑으로 떨어지게 된다.
            brokenBoxNode.geometry?.firstMaterial?.diffuse.contents = UIColor(red: CGFloat(0.01 * Float(height)), green: 0, blue: 1, alpha: 1)
            //material을 설정해 준다. diffuse의 red 값을 height 만큼 증가시켜 준다.
            //diffusesms material 표면의 각 점에서 모든 방향으로 똑같이 반사되는 빛의 양과 색상을 나타낸다. 기본 색이나 기본 질감으로 생각하면 된다.
            
            scnScene.rootNode.addChildNode(brokenBoxNode) //루트 노드의 자식 노드로 scene에 추가한다. //scene graph 구조를 이룬다.
        } else if height % 2 != 0 && absoluteOffset.x > 0 { //홀수 layer의 경우. z축에서 움직이므로 x값이 0보다 큰지 확인한다(이전 layer 확인).
            //absoluteOffset.x 값이 0인 경우에는 효과를 줄 brokenBoxNode가 없기 때문이다.
            brokenBoxNode.geometry = SCNBox(width: CGFloat(absoluteOffset.x), height: 0.2, length: CGFloat(currentSize.z), chamferRadius: 0)
            //기하 도형(geometry - box)으로 SCNNode를 생성한다.
            //handleTap(_:)에서는 겹치는 부분을 찾기 위해 offset을 빼줬지만, 여기에서는 offset이 해당 크기와 같으므로 그대로 사용하면 된다.
            
            if offset.x > 0 {
                brokenBoxNode.position.x = currentBoxNode.position.x - (offset.x/2) - ((currentSize - offset).x/2)
            } else {
                brokenBoxNode.position.x = currentBoxNode.position.x - (offset.x/2) + ((currentSize + offset).x/2)
            }
            //brokenBox의 위치를 변경한다.
            //현재 위치에서 offset의 절반을 뺀 block으로 brokenBox의 position을 찾는다.
            //그 후, 블록의 위치에 따라 현재 크기의 절반에서 offset을 더하거나 뺀다.
            
            brokenBoxNode.position.y = currentPosition.y
            brokenBoxNode.position.z = currentBoxNode.position.z
            
            brokenBoxNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(geometry: brokenBoxNode.geometry!, options: nil))
            //dynamic 물리엔진을 적용한다. dynamic이므로 밑으로 떨어지게 된다.
            brokenBoxNode.geometry?.firstMaterial?.diffuse.contents = UIColor(red: CGFloat(0.01 * Float(height)), green: 0, blue: 1, alpha: 1)
            //material을 설정해 준다. diffuse의 red 값을 height 만큼 증가시켜 준다.
            //diffusesms material 표면의 각 점에서 모든 방향으로 똑같이 반사되는 빛의 양과 색상을 나타낸다. 기본 색이나 기본 질감으로 생각하면 된다.
            
            scnScene.rootNode.addChildNode(brokenBoxNode) //루트 노드의 자식 노드로 scene에 추가한다. //scene graph 구조를 이룬다.
        }
    }
}




//Handling Perfect Matches
//이전 block과 완벽히 일치하는 경우 보너스를 준다.
extension ViewController {
    func checkPerfectMatch(_ currentBoxNode: SCNNode) {
        if height % 2 == 0 && absoluteOffset.z <= 0.03 { //짝수 layer의 경우. x축에서 움직이므로 z 값을 확인한다(이전 layer 확인).
            //이전 layer의 0.03 내에서 block을 쌓으면 완벽하게 일치하는 것으로 간주한다.
            currentBoxNode.position.z = previousPosition.z //현재 위치와 이전 위치를 동일하게 설정한다.
            currentPosition.z = previousPosition.z //변수 업데이트
            perfectMatches += 1 //완벽하게 일치한 수를 증가 시킨다.
            
            if perfectMatches >= 7 && currentSize.z < 1 { //7번 이상 완벽히 일치했고, 크기가 처음 시작 때보다 작아졌다면 보너스
                newSize.z += 0.05
            }
            
            offset = previousPosition - currentPosition
            absoluteOffset = offset.absoluteValue()
            newSize = currentSize - absoluteOffset
            //변수 재 설정
            
            playSound(sound: "PerfectFit", node: currentBoxNode) //사운드 재생
            
        } else if height % 2 != 0 && absoluteOffset.x <= 0.03 { //홀수 layer의 경우. z축에서 움직이므로 x값을 확인한다(이전 layer 확인).
            //이전 layer의 0.03 내에서 block을 쌓으면 완벽하게 일치하는 것으로 간주한다.
            currentBoxNode.position.x = previousPosition.x //현재 위치와 이전 위치를 동일하게 설정한다.
            currentPosition.x = previousPosition.x //변수 업데이트
            perfectMatches += 1 //완벽하게 일치한 수를 증가 시킨다.
            
            if perfectMatches >= 7 && currentSize.x < 1 { //7번 이상 완벽히 일치했고, 크기가 처음 시작 때보다 작아졌다면 보너스
                newSize.x += 0.05
            }
            
            offset = previousPosition - currentPosition
            absoluteOffset = offset.absoluteValue()
            newSize = currentSize - absoluteOffset
            //변수 재 설정
            
            playSound(sound: "PerfectFit", node: currentBoxNode) //사운드 재생
            
        } else {
            perfectMatches = 0
        }
    }
}




//Adding Sound Effects
extension ViewController {
    func loadSound(name: String, path: String) {
        if let sound = SCNAudioSource(fileNamed: path) { //지정된 경로에서 오디오 파일을 로드
            sound.isPositional = false
            sound.volume = 1
            sound.load()
            sounds[name] = sound //dictionary에 저장한다.
        }
    }
    
    func playSound(sound: String, node: SCNNode) {
        node.runAction(SCNAction.playAudio(sounds[sound]!, waitForCompletion: false))
        //dictionary의 오디오 파일 재생
    }
}




//Handling Win/Lose Condition
extension ViewController {
    @IBAction func playGame(_ sender: UIButton) {
        playButton.isHidden = true
        
        let gameScene = SCNScene(named: "HighRise.scnassets/Scenes/GameScene.scn")! //scn file로 scene 초기화
        scnScene = gameScene //scnView에서 사용할 scene 설정
        
        let transition = SKTransition.fade(withDuration: 1.0)
        let mainCamera = scnScene.rootNode.childNode(withName: "Main Camera", recursively: false)!
        //rootNode.childNode 를 사용해 지정한 name으로 child node를 가져올 수 있다.
        //recursively 매개 변수를 true로 하면 노드의 전체 하위 트리를 검색해서 해당 노드를 찾는다.
        //false일 시에는 직접적인 하위 노드만을 검색한다.
        scnView.present(scnScene, with: transition, incomingPointOfView: mainCamera, completionHandler: nil)
        //전환효과를 사용한다. //incomingPointOfView로 전환에 사용할 시점을 지정할 수 있다.
        
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
        
        height = 0
        scoreLabel.text = "\(height)"
        
        direction = true
        perfectMatches = 0
        
        previousSize = SCNVector3(1, 0.2, 1)
        previousPosition = SCNVector3(0, 0.1, 0)
        
        currentSize = SCNVector3(1, 0.2, 1)
        currentPosition = SCNVector3Zero
        //모든 게임 변수 초기화
        
        //Adding Your First Block
        let boxNode = SCNNode(geometry: SCNBox(width: 1, height: 0.2, length: 1, chamferRadius: 0))
        //기하 도형(geometry - box)으로 SCNNode를 생성한다.
        boxNode.position.z = -1.25 //block의 z 위치 설정
        boxNode.position.y = 0.1 //block의 y 위치 설정
        boxNode.name = "Block\(height)" //block의 name 설정
        //scene graph를 쉽게 관리하기 위해, 노드에 설명이 포함된 name 을 지정해 줄 수 있다.
        //childNode(withName: recursively:) 나 childNodes(passingTest:) 등의 메서드를 이용해 scene graph에서 해당 노드를 검색할 수 있다.
        boxNode.geometry?.firstMaterial?.diffuse.contents = UIColor(red: CGFloat(0.01 * Float(height)), green: 0, blue: 1, alpha: 1)
        //material을 설정해 준다. diffuse의 red 값을 height 만큼 증가시켜 준다.
        //diffusesms material 표면의 각 점에서 모든 방향으로 똑같이 반사되는 빛의 양과 색상을 나타낸다. 기본 색이나 기본 질감으로 생각하면 된다.
        scnScene.rootNode.addChildNode(boxNode) //루트 노드의 자식 노드로 scene에 추가한다. //scene graph 구조를 이룬다.
        //초기화한 첫 번째 block 추가
    }
    
    func gameOver() {
        let mainCamera = scnScene.rootNode.childNode(withName: "Main Camera", recursively: false)!
        //rootNode.childNode 를 사용해 지정한 name으로 child node를 가져올 수 있다.
        //recursively 매개 변수를 true로 하면 노드의 전체 하위 트리를 검색해서 해당 노드를 찾는다.
        //false일 시에는 직접적인 하위 노드만을 검색한다.
        
        let fullAction = SCNAction.customAction(duration: 0.3) { _, _ in //custom action을 만들어 준다.
            let moveAction = SCNAction.move(to: SCNVector3Make(mainCamera.position.x, mainCamera.position.y * (3/4), mainCamera.position.z), duration: 0.3)
            //Action 설정. 전체 tower를 표시하기 위해 카메라를 축소한다.
            mainCamera.runAction(moveAction) //Action 적용
            
            if self.height <= 15 { //카메라 배율을 조정한다.
                mainCamera.camera?.orthographicScale = 1
                //orthographicScale은 직교 투영을 사용할 때 카메라 배율
            } else {
                mainCamera.camera?.orthographicScale = Double(Float(self.height/2) / mainCamera.position.y)
            }
        }
        
        mainCamera.runAction(fullAction) //카메라 이동
        playButton.isHidden = false //playButton 활성화
    }
}




//SceneKit은 구성 요소를 scene graph 라고하는 노드 기반 계층 구조로 구성한다. scene는 좌표계를 정의하는 root node로 시작한다.
//root node 아래에 content nodes 를 추가하여 트리 구조를 형성한다.
//이러한 content node 는 scene의 기본 요소이며 조명, 카메라, 기하 도형 및 입자 emitter와 같은 요소를 포함 할 수 있다.
