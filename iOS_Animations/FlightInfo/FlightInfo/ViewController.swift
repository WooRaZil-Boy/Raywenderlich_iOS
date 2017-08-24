//
//  ViewController.swift
//  FlightInfo
//
//  Created by 근성가이 on 2017. 1. 6..
//  Copyright © 2017년 근성가이. All rights reserved.
//

import UIKit
import QuartzCore

// A delay function
func delay(seconds: Double, completion: @escaping ()-> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: completion)
}

class ViewController: UIViewController {
    enum AnimationDirection: Int {
        case positive = 1
        case negative = -1
    }
    
    // MARK: - Properties
    @IBOutlet var bgImageView: UIImageView!
    
    @IBOutlet var summaryIcon: UIImageView!
    @IBOutlet var summary: UILabel!
    
    @IBOutlet var flightNr: UILabel!
    @IBOutlet var gateNr: UILabel!
    @IBOutlet var departingFrom: UILabel!
    @IBOutlet var arrivingTo: UILabel!
    @IBOutlet var planeImage: UIImageView!
    
    @IBOutlet var flightStatus: UILabel!
    @IBOutlet var statusBanner: UIImageView!
    
    var snowView: SnowView!

    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //adjust ui
        summary.addSubview(summaryIcon)
        summaryIcon.center.y = summary.frame.size.height/2
        
        //add the snow effect layer
        snowView = SnowView(frame: CGRect(x: -150, y:-100, width: 300, height: 50))
        let snowClipView = UIView(frame: view.frame.offsetBy(dx: 0, dy: 50)) //뷰의 오프셋에서 떨어진 만큼의 크기 //offsetBy(dx: 0, dy: 0)이면 뷰랑 같은 크기
        snowClipView.clipsToBounds = true
        snowClipView.addSubview(snowView)
        view.addSubview(snowClipView)
        
        //start rotating the flights
        changeFlight(to: londonToParis)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: - custom methods
extension ViewController {
    func changeFlight(to data: FlightData, animated: Bool = false) {
        // populate the UI with the next flight's data
        summary.text = data.summary
        flightNr.text = data.flightNr
        gateNr.text = data.gateNr
        departingFrom.text = data.departingFrom
        arrivingTo.text = data.arrivingTo
        flightStatus.text = data.flightStatus
        
        if animated {
            planeDepart()
            summarySwitch(to: data.summary)
            
            fade(imageView: bgImageView, toImage: UIImage(named: data.weatherImageName)!, showEffects: data.showWeatherEffects)
            
            let direction: AnimationDirection = data.isTakingOff ? .positive : .negative
            
            cubeTransition(label: flightNr, text: data.flightNr, direction: direction)
            cubeTransition(label: gateNr, text: data.gateNr, direction: direction)
            
            let offsetDeparting = CGPoint(x: CGFloat(direction.rawValue * 80), y: 0.0) //수평이동
            moveLabel(label: departingFrom, text: data.departingFrom, offset: offsetDeparting)
            
            let offsetArriving = CGPoint(x: 0.0, y: CGFloat(direction.rawValue * 50)) //수직이동
            moveLabel(label: arrivingTo, text: data.arrivingTo, offset: offsetArriving)
            
            cubeTransition(label: flightStatus, text: data.flightStatus, direction: direction)
        } else {
            bgImageView.image = UIImage(named: data.weatherImageName)
            snowView.isHidden = !data.showWeatherEffects
            
            flightNr.text = data.flightNr
            gateNr.text = data.gateNr
            
            departingFrom.text = data.departingFrom
            arrivingTo.text = data.arrivingTo
            
            flightStatus.text = data.flightStatus
        }
        
        // schedule next flight
        delay(seconds: 3.0) {
            self.changeFlight(to: data.isTakingOff ? parisToRome : londonToParis, animated: true)
        }
    }
    
    func fade(imageView: UIImageView, toImage: UIImage, showEffects: Bool) {
        UIView.transition(with: imageView, duration: 1.0, options: .transitionCrossDissolve, animations: { //이미지 전환 //transition은 애니메이션이 아닌 속성애 대한 변경 사항을 애니메이션으로 적용할 수 있다.
            imageView.image = toImage
        })
        
        UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseOut, animations: { //애니메이션 투명도
            self.snowView.alpha = showEffects ? 1.0 : 0.0
        })
    }
    
    func cubeTransition(label: UILabel, text: String, direction: AnimationDirection) {
        //텍스트만 제외하고 다른 요소가 모두 같은 레이블 생성
        let auxLabel = UILabel(frame: label.frame)
        auxLabel.text = text
        auxLabel.font = label.font
        auxLabel.textAlignment = label.textAlignment
        auxLabel.textColor = label.textColor
        auxLabel.backgroundColor = label.backgroundColor
        
        let auxLabelOffset = CGFloat(direction.rawValue) * label.frame.size.height / 2.0 //direction.rawValue은 1 또는 -1 수직 오프셋
        
        auxLabel.transform = CGAffineTransform(scaleX: 1.0, y: 0.1).concatenating(CGAffineTransform(translationX: 0.0, y: auxLabelOffset)) //scaleX: 1.0, y: 0.1을 하면 가로는 그대로, 세로는 10%로 축소 //그 CGAffineTransform 위치에서 x는 그대로, y는 auxLabelOffset만큼 이동 -> 레이블의 상단이나 하단으로 이동
        
        label.superview?.addSubview(auxLabel)
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut, animations: {
            auxLabel.transform = .identity //본래 transform(frame) 대로??
            label.transform = CGAffineTransform(scaleX: 1.0, y: 0.1).concatenating(CGAffineTransform(translationX: 0.0, y: -auxLabelOffset)) //auxLabel의 반대방향으로 축소하며 이동
        }, completion: { _ in //label이 auxLabel의 텍스트를 보여줘서 변화 없는 것 처럼 보이지만, auxLabel을 제거해 다음 애니메이션을 준비한다.
            label.text = auxLabel.text
            label.transform = .identity
            
            auxLabel.removeFromSuperview()
        })
    }
    
    func moveLabel(label: UILabel, text: String, offset: CGPoint) {
        let auxLabel = UILabel(frame: label.frame)
        auxLabel.text = text
        auxLabel.font = label.font
        auxLabel.textAlignment = label.textAlignment
        auxLabel.textColor = label.textColor
        auxLabel.backgroundColor = UIColor.clear
        auxLabel.transform = CGAffineTransform(translationX: offset.x, y: offset.y)
        auxLabel.alpha = 0
        
        view.addSubview(auxLabel)
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseIn, animations: {
            label.transform = CGAffineTransform(translationX: offset.x, y: offset.y)
            label.alpha = 0.0
        })
        
        UIView.animate(withDuration: 0.25, delay: 0.1, options: .curveEaseIn, animations: {
            auxLabel.transform = .identity
            auxLabel.alpha = 1.0
        }, completion: { _ in
            auxLabel.removeFromSuperview()
            
            label.text = text
            label.alpha = 1.0
            label.transform = .identity
        })
    }
    
    func planeDepart() {
        let originalCenter = planeImage.center
        
        UIView.animateKeyframes(withDuration: 1.5, delay: 0.0, options: [], animations: { //키 프레임 애니메이션 //옵션은 일반 애니메이션이나 트랜지션 외에 키프레임 옵션이 따로 있다. - 보통 애니메이션에서 옵션으로 사용하는 curveEaseOut을 사용할 수 없는데, 전체적 애니메이션이 깨지기 때문에. //일반 애니메이션을 주고 완료 클로저에 연결해 늘어뜨릴 필요없이 키 프레임을 계속해서 추가해 주면 순차적으로 실행한다.
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.25, animations: { //키프레임을 추가한다. //키프레임은 개별 프레임들이 순차적으로 연결되어 실행되는 애니메이션 //여기서 입력되는 시간은 모두 상대적인 개념이다. 0 ~ 1 까지의 값을 가지며 0.25는 전체시간의 25% 동안 지속 //전체 시간이 1.5초 이므로 1.5 * 0.25 = 0.375초 동안 지속
                self.planeImage.center.x += 80.0
                self.planeImage.center.y -= 10.0
            })
            
            UIView.addKeyframe(withRelativeStartTime: 0.1, relativeDuration: 0.4, animations: {
                self.planeImage.transform = CGAffineTransform(rotationAngle: -.pi / 8) //앵글 회전
            })
            
            UIView.addKeyframe(withRelativeStartTime: 0.25, relativeDuration: 0.25, animations: {
                self.planeImage.center.x += 100.0
                self.planeImage.center.y -= 50.0
                self.planeImage.alpha = 0.0
            })
            
            UIView.addKeyframe(withRelativeStartTime: 0.51, relativeDuration: 0.01, animations: {
                self.planeImage.transform = .identity //원래 프레임으로
                self.planeImage.center = CGPoint(x: 0.0, y: originalCenter.y) //왼쪽 가장자리로 이동 //왼쪽은 뷰 밖에, 오른쪽은 뷰 안에
            })
            
            UIView.addKeyframe(withRelativeStartTime: 0.55, relativeDuration: 0.45, animations: {
                self.planeImage.alpha = 1.0
                self.planeImage.center = originalCenter
            })
            
        }, completion: nil)
    }
    
    func summarySwitch(to summaryText: String) {
        UIView.animateKeyframes(withDuration: 1.0, delay: 0.0, options: [], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.45, animations: {
                self.summary.center.y -= 100.0
            })
            
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.45, animations: {
                self.summary.center.y += 100.0
            })
        })
        
        delay(seconds: 0.5) {
            self.summary.text = summaryText
        }
    }
}
