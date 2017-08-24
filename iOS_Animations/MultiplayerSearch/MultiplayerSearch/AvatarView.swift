//
//  AvatarView.swift
//  MultiplayerSearch
//
//  Created by 근성가이 on 2017. 1. 10..
//  Copyright © 2017년 근성가이. All rights reserved.
//

import UIKit
import QuartzCore

@IBDesignable //스토리 보드에 실시간 렌더링을 하기 위해 선언한다.

class AvatarView: UIView {
    //constants
    let lineWidth: CGFloat = 6.0
    let animationDuration = 1.0
    
    //ui
    let photoLayer = CALayer()
    let circleLayer = CAShapeLayer()
    let maskLayer = CAShapeLayer()
    let label: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "ArialRoundedMTBold", size: 18.0)
        label.textAlignment = .center
        label.textColor = UIColor.black
        return label
    }()
    
    //variables
    @IBInspectable //바로 반영될 속성을 정의한다.
    var image: UIImage? = nil {
        didSet {
            photoLayer.contents = image?.cgImage
        }
    }
    
    @IBInspectable
    var name: String? = nil {
        didSet {
            label.text = name
        }
    }
    
    var shouldTransitionToFinishedState = false
    var isSquare = false
    
    override func didMoveToWindow() { //윈도우 변경될 때 마다 추가 액션 위해?
        photoLayer.mask = maskLayer //마스크로 사용할 레이어를 설정한다. //원형모향
        layer.addSublayer(photoLayer)
        layer.addSublayer(circleLayer)
        addSubview(label)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let image = image else {
            return
        }
        
        //Size the avatar image to fit
        photoLayer.frame = CGRect(
            x: (bounds.size.width - image.size.width + lineWidth)/2,
            y: (bounds.size.height - image.size.height - lineWidth)/2,
            width: image.size.width,
            height: image.size.height)
        
        //Draw the circle
        circleLayer.path = UIBezierPath(ovalIn: bounds).cgPath
        circleLayer.strokeColor = UIColor.white.cgColor
        circleLayer.lineWidth = lineWidth
        circleLayer.fillColor = UIColor.clear.cgColor
        
        //Size the layer
        maskLayer.path = circleLayer.path
        maskLayer.position = CGPoint(x: 0.0, y: 10.0)
        
        //Size the label
        label.frame = CGRect(x: 0.0, y: bounds.size.height + 10.0, width: bounds.size.width, height: 24.0)
    }
}

extension AvatarView {
    func bounceOff(point: CGPoint, morphSize: CGSize) {
        let originalCenter = center //나중에 다시 원래 좌표로 옮겨야 하므로 저장해 둔다.
        
        UIView.animate(withDuration: animationDuration, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.0, animations: {
            self.center = point
        }, completion: { _ in
            if self.shouldTransitionToFinishedState {
                self.animateToSquare()
            }
        })
        
        UIView.animate(withDuration: animationDuration, delay: animationDuration, usingSpringWithDamping: 0.7, initialSpringVelocity: 1.0, options: [], animations: {
            self.center = originalCenter
        }, completion: { _ in
            delay(seconds: 0.1, completion: {
                if !self.isSquare {
                    self.bounceOff(point: point, morphSize: morphSize)
                }
            })
        })
        
        let morpgedFrame = (originalCenter.x > point.x) ? CGRect(x: 0.0, y: bounds.height - morphSize.height, width: morphSize.width, height: morphSize.height) : CGRect(x: bounds.width - morphSize.width, y: bounds.height - morphSize.height, width: morphSize.width, height: morphSize.height) //좌측 레이어, 우측 레이어 구분
        
        let morphAnimation = CABasicAnimation(keyPath: "path")
        morphAnimation.duration = animationDuration
        morphAnimation.toValue = UIBezierPath(ovalIn: morpgedFrame).cgPath //타원형 만든다.
        morphAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        
        circleLayer.add(morphAnimation, forKey: nil)
        maskLayer.add(morphAnimation, forKey: nil)
    }
    
    func animateToSquare() {
        isSquare = true
        
        let squarePath = UIBezierPath(rect: bounds).cgPath
        let morph = CABasicAnimation(keyPath: "path")
        morph.duration = 0.25
        morph.fromValue = circleLayer.path
        morph.toValue = squarePath
        
        circleLayer.add(morph, forKey: nil)
        maskLayer.add(morph, forKey: nil)
        
        circleLayer.path = squarePath
        maskLayer.path = squarePath
    }
}
