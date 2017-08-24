//
//  ViewController.swift
//  Iris
//
//  Created by 근성가이 on 2017. 1. 14..
//  Copyright © 2017년 근성가이. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    //MARK: - Properties
    @IBOutlet weak var meterLabel: UILabel!
    @IBOutlet weak var speakButton: UIButton!
    
    let monitor = MicMonitor()
    let assistant = Assistant()
    
    let replicator = CAReplicatorLayer() //반복적으로 계속되는 애니메이션을 완성할 때 주로 사용. 조금씩 효과를 다르게 줄 수 있다.
    let dot = CALayer()
    
    let dotLength: CGFloat = 6.0
    let dotOffset: CGFloat = 8.0
    
    var lastTransformScale: CGFloat = 0.0 //스케일 애니메이션에서 마지막 스케일을 저장해 둘 변수
}

//MARK: - View Life Cycle
extension ViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        replicator.frame = view.bounds
        view.layer.addSublayer(replicator)
        
        dot.frame = CGRect(x: replicator.frame.size.width - dotLength, y: replicator.position.y, width: dotLength, height: dotLength)
        dot.backgroundColor = UIColor.lightGray.cgColor
        dot.borderColor = UIColor(white: 1.0, alpha: 1.0).cgColor
        dot.borderWidth = 0.5
        dot.cornerRadius = 1.5
        
        replicator.addSublayer(dot) //복제할 레이어를 서브레이어에 추가
    
        replicator.instanceCount = Int(view.frame.size.width / dotOffset) //복제할 수를 지정 //디바이스마다 크기가 다르므로 계산 후 구한다. //이 값만 넣으면 복사된 객체가 전부 한 곳에 겹쳐 있어 아무런 변화가 없는 것 처럼 보인다.
        replicator.instanceTransform = CATransform3DMakeTranslation(-dotOffset, 0.0, 0.0) //객체들 간의 트랜스폼 //객체들이 왼쪽으로 조금씩 이동하도록 설정
        replicator.instanceDelay = 0.02 //각 객체들 애니메이션들의 딜레이 지정
        
        
        
    }
}

//MARK: - Methods & Actions
extension ViewController {
    @IBAction func actionStartMonitoring(_ sender: AnyObject) { //버튼을 눌렀을 떄
        dot.backgroundColor = UIColor.green.cgColor
        monitor.startMonitoringWithHandler { level in //음성 따라서 게이지 움직이게
            self.meterLabel.text = String(format: "%.2f db", level)
            let scaleFactor = max(0.2, CGFloat(level) + 50) / 2
            
            let scale = CABasicAnimation(keyPath: "transform.scale.y")
            scale.fromValue = self.lastTransformScale
            scale.toValue = scaleFactor
            scale.duration = 0.1
            scale.isRemovedOnCompletion = false
            scale.fillMode = kCAFillModeForwards
            self.dot.add(scale, forKey: nil)
            
            self.lastTransformScale = scaleFactor
        }
    }
    
    @IBAction func actionEndMonitoring(_ sender: AnyObject) { //버튼을 땠을 때
        monitor.stopMonitoring()
        
        let scale = CABasicAnimation(keyPath: "transform.scale.y")
        scale.fromValue = lastTransformScale
        scale.toValue = 1.0
        scale.duration = 0.2
        scale.isRemovedOnCompletion = false
        scale.fillMode = kCAFillModeForwards
        dot.add(scale, forKey: nil)
        
        dot.backgroundColor = UIColor.magenta.cgColor
        
        let tint = CABasicAnimation(keyPath: "backgroundColor")
        tint.fromValue = UIColor.green.cgColor
        tint.toValue = UIColor.magenta.cgColor
        tint.duration = 1.2
        tint.fillMode = kCAFillModeBackwards
        dot.add(tint, forKey: nil)
        
        //speak after 1 second
        delay(seconds: 1.0) {
            self.startSpeaking()
        }
    }
    
    func startSpeaking() {
        print("speak back")

        meterLabel.text = assistant.randomAnswer()
        assistant.speak(meterLabel.text!, completion: endSpeaking)
        speakButton.isHidden = true
        
        let scale = CABasicAnimation(keyPath: "transform")
        scale.fromValue = NSValue(caTransform3D: CATransform3DIdentity) //기본 스케일
        scale.toValue = NSValue(caTransform3D: CATransform3DMakeScale(1.4, 15, 1.0)) //x,y,z = 1.4배, 15배, 1배
        scale.duration = 0.33
        scale.repeatCount = .infinity
        scale.autoreverses = true
        scale.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        dot.add(scale, forKey: "dotScale")
        
        let fade = CABasicAnimation(keyPath: "opacity")
        fade.fromValue = 1.0
        fade.toValue = 0.2
        fade.duration = 0.33
        fade.beginTime = CACurrentMediaTime() + 0.33
        fade.repeatCount = .infinity
        fade.autoreverses = true
        fade.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        dot.add(fade, forKey: "dotOpacity")
        
        let tint = CABasicAnimation(keyPath: "backgroundColor")
        tint.fromValue = UIColor.magenta.cgColor
        tint.toValue = UIColor.cyan.cgColor
        tint.duration = 0.66
        tint.beginTime = CACurrentMediaTime() + 0.28
        tint.fillMode = kCAFillModeBackwards
        tint.repeatCount = .infinity
        tint.autoreverses = true
        tint.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        dot.add(tint, forKey: "dotColor")
        
        let initialRotation = CABasicAnimation(keyPath: "instanceTransform.rotation")
        initialRotation.fromValue = 0.0 //단위 :: radian
        initialRotation.toValue = 0.01
        initialRotation.duration = 0.33
        initialRotation.isRemovedOnCompletion = false
        initialRotation.fillMode = kCAFillModeForwards
        initialRotation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        replicator.add(initialRotation, forKey: "initialRotation") //CAReplicatorLayer도 CALayer의 서브 클래스이므로 애니메이션 적용이 가능하다. //viewDidLoad의 설정은 그대로 있고, 애니메이션을 추가해 줄 수 있다. //처음에만 이 애니메이션이 적용되고
        
        let rotation = CABasicAnimation(keyPath: "instanceTransform.rotation")
        rotation.fromValue = 0.01
        rotation.toValue = -0.01
        rotation.duration = 0.99
        rotation.beginTime = CACurrentMediaTime() + 0.33
        rotation.repeatCount = .infinity
        rotation.autoreverses = true
        rotation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        replicator.add(rotation, forKey: "replicatorRotation") //두 번째 부터는 첫 애니메이션이 끝나고 이 것이 계속 오토 리버스 되며 반복된다.
    }
    
    func endSpeaking() {
        replicator.removeAllAnimations() //모든 애니메이션 제거
        
        let scale = CABasicAnimation(keyPath: "transform")
        scale.toValue = NSValue(caTransform3D: CATransform3DIdentity) //초기화 되는 것이므로 fromValue는 필요 없다.
        scale.duration = 0.33
        scale.isRemovedOnCompletion = false
        scale.fillMode = kCAFillModeForwards
        dot.add(scale, forKey: nil) //초기 스케일로
        
        dot.removeAnimation(forKey: "dotColor")
        dot.removeAnimation(forKey: "dotOpacity")
        dot.backgroundColor = UIColor.lightGray.cgColor
        speakButton.isHidden = false
    }
}

