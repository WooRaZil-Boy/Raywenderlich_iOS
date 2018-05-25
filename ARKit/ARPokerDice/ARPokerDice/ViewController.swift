//
//  ViewController.swift
//  ARPokerDice
//
//  Created by 근성가이 on 2018. 5. 25..
//  Copyright © 2018년 com. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    //ARSCNView는 카메라의 라이브 배경 이미지 위에 3D scene 을 오버레이할 수 있다.
    //ARKit과 SceneKit 간의 완벽한 통합을 제공한다.
    
    //SpriteKit과 ARKit을 통합한 ARSKView도 있다. 2D SpriteKit 컨텐츠를 사용하는 경우 사용한다.
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var styleButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    
    @IBAction func startButtonPressed(_ sender: Any) {
    }
    
    @IBAction func styleButtonPressed(_ sender: Any) {
    }
    
    @IBAction func resetButtonPressed(_ sender: Any) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
//        let scene = SCNScene(named: "art.scnassets/ship.scn")! //default 비행기
        let scene = SCNScene(named: "PokerDice.scnassets/SimpleScene.scn")! //지구
        
        // Set the scene to the view
        sceneView.scene = scene
        
        statusLabel.text = "Greetings! :]"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
        //true로 하면, statusBar를 가린다.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}

//앱이 시작되면 ARKit은 공간에서의 디바이스의 현재 위치를 앵커로 사용한다.
//그 후, SceneKit을 로드하고 해당 scene 을 증강현실 공간에 배치한다.

//SceneKit은 앱의 모든 그래픽 및 오디오 콘텐츠를 만들고 관리할 수 있는 그래픽 프레임워크이다.
//art.scnassets에는 Scene, Texture, 3D Model, Animation, Sound effect 같은 다양한 Asset을 저장할 수 있다.

//Xcode의 AR 템플릿은 UI요소를 지원하지 않기 때문에 스토리보드에서 추가해 줘야 한다.
//스토리보드에서 ARSCNView 위에 UI객체를 삽입하면, 해당 UI로 대체되어 버린다.
//따라서 UIView가 자식으로 ARSCNView를 가지도록 계층 구조를 정리해 주는 것이 좋다.

//Auto Layout를 설정할 때 아이폰 X의 notch를 고려해야 한다. Safe Area로 맞춰주는 것이 좋다.
