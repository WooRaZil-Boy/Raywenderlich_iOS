/**
 * Copyright (c) 2018 Razeware LLC
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
import SceneKit
import ARKit

class ViewController: UIViewController {

  // MARK: - Properties

  @IBOutlet var sceneView: ARSCNView!
  @IBOutlet weak var messageLabel: UILabel!
  
  @IBOutlet weak var recordButton: UIButton!
    
    var session: ARSession {
        return sceneView.session
    }

  // MARK: - View Management

  override func viewDidLoad() {
    super.viewDidLoad()
    setupScene()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    UIApplication.shared.isIdleTimerDisabled = true
    //true로 해두면, 디바이스가 절전모드로 전환되지 않는다.
    resetTracking() //트래킹 재 시작
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    UIApplication.shared.isIdleTimerDisabled = false //default
    //iOS는 일정 시간 동안 사용자의 터치가 없으면 디바이스 화면을 끈다.
    //이 시간을 판단하는 것이 IdleTimer로, 화면을 터치할 때마다 초기화되고 지정된 시간이 되면 화면을 끈다.
    //항상 화면이 켜진 상태로 두려면 IdleTimer를 꺼야 한다(그때는 true로 설정하면 된다: viewDidAppear).
    sceneView.session.pause()
    //앱이 background로 전환될 때 세션을 중지시킨다.
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }

  override var prefersStatusBarHidden: Bool {
    return true
  }

  // MARK: - Button Actions

  @IBAction func didTapReset(_ sender: Any) {
    print("didTapReset")
    resetTracking() //사용자가 세션을 재설정하고하 할 때마다 버튼을 눌러 재설정할 수 있다.
  }

  @IBAction func didTapMask(_ sender: Any) {
    print("didTapMask")
  }

  @IBAction func didTapGlasses(_ sender: Any) {
    print("didTapGlasses")
  }

  @IBAction func didTapPig(_ sender: Any) {
    print("didTapPig")
  }

  @IBAction func didTapRecord(_ sender: Any) {
    print("didTapRecord")
  }
}

// MARK: - ARSCNViewDelegate

extension ViewController: ARSCNViewDelegate {

  // Tag: SceneKit Renderer

  // Tag: ARNodeTracking

  // Tag: ARFaceGeometryUpdate

  // Tag: ARSession Handling
    func session(_ session: ARSession, didFailWithError error: Error) {
        print("** didFailWithError")
        updateMessage(text: "Session failed.")
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        print("** sessionWasInterrupted")
        updateMessage(text: "Session interrupted.")
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        print("** sessionInterruptionEnded")
        updateMessage(text: "Session interruption ended.")
    }
}

// MARK: - Private methods

private extension ViewController {

  // Tag: SceneKit Setup
  func setupScene() {
    // Set the view's delegate
    sceneView.delegate = self

    // Show statistics such as fps and timing information
    sceneView.showsStatistics = true
  }

  // Tag: ARFaceTrackingConfiguration
    func resetTracking() {
        guard ARFaceTrackingConfiguration.isSupported else {
            //얼굴 추적을 위해서는 ARFaceTrackingConfiguration을 사용해야 한다.
            //이전까지는 AROrientationTrackingConfiguration이나 ARWorldTrackingConfiguration를 사용했다.
            updateMessage(text: "Face Tracking Not Supported.")
            return
        }
        
        updateMessage(text: "Looking for a face.")
        
        let configuration = ARFaceTrackingConfiguration() //기본 얼굴 인식 설정
        configuration.isLightEstimationEnabled = true //default setting //조명 분석 여부
        configuration.providesAudioData = false //default setting //오디오 캡쳐 여부
        
        session.run(configuration, options: [.resetTracking, .removeExistingAnchors]) //세션 시작
        //해당 옵션은 세션이 시작될 때마다 트래킹을 재설정하고, 기존 앵커를 모두 제거한다.
    }

  // Tag: CreateARSCNFaceGeometry

  // Tag: Setup Face Content Nodes

  // Tag: Update UI
  func updateMessage(text: String) {
    //UI를 업데이트하는 작업은 메인 스레드에서 실행되어야 한다.
    DispatchQueue.main.async {
      self.messageLabel.text = text
    }
  }
}

// MARK: - RPPreviewViewControllerDelegate (ReplayKit)




//ARKit for face-based AR
//ARKit은 TrueDepth 전면 카메라를 사용하여 얼굴 추적을 할 수 있다. 현재는 iPhoneX가 이 카메라가 장착된 유일한 장치이다.
//ARKit의 얼굴 추적은 사람 얼굴만 추적하며, 네 가지 기본 기능이 포함되어 있다.
//• Face detection and tracking(얼굴 탐지 및 추적) : 초당 60프레임 재생 빈도로 실시간 얼굴 탐지 및 추적
//• Real-time facial expression tracking(실시간 표정 추적) : 50개 이상의 특정 표정을 실시간으로 추적
//• Font color image, front depth image : 색상 픽셀 버퍼와 image의 depth를 캡쳐한다.
//• Light estimation : 얼굴 기반 AR 프로그램을 사용하여 감지된 얼굴의 방향과 조명을 측정할 수 있다.



