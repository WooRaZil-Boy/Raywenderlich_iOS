//
//  AnimatedMaskLabel.swift
//  SlideToReveal
//
//  Created by 근성가이 on 2017. 1. 11..
//  Copyright © 2017년 근성가이. All rights reserved.
//

import UIKit
import QuartzCore

class AnimatedMaskLabel: UIView {
    let gradientLayer: CAGradientLayer = { //클로저
        let gradientLayer = CAGradientLayer()
        
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)

        let colors = [
            UIColor.yellow.cgColor,
            UIColor.green.cgColor,
            UIColor.orange.cgColor,
            UIColor.cyan.cgColor,
            UIColor.red.cgColor,
            UIColor.yellow.cgColor
        ]
        gradientLayer.colors = colors
        
        let locations: [NSNumber] = [0.0, 0.0, 0.0, 0.0, 0.0, 0.25]
        gradientLayer.locations = locations
        
        return gradientLayer
    }()
    
    let textAttributes: [String: AnyObject] = { //NSAttributeString 속성
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        return [NSFontAttributeName: UIFont(name: "HelveticaNeue-Thin", size: 28.0)!,NSParagraphStyleAttributeName: style]
    }()
    
    @IBInspectable var text: String! { //미리보기 가능하게
        didSet {
            setNeedsDisplay()
            
            let image = UIGraphicsImageRenderer(size: bounds.size).image { _ in //레이블의 글자를 이미지로
                text.draw(in: bounds, withAttributes: textAttributes)
            }
            
            let maskLayer = CALayer()
            maskLayer.backgroundColor = UIColor.clear.cgColor
            maskLayer.frame = bounds.offsetBy(dx: bounds.size.width, dy: 0)
            maskLayer.contents = image.cgImage
            
            gradientLayer.mask = maskLayer
        }
    }
    
    override func layoutSubviews() {
        layer.borderColor = UIColor.green.cgColor
        
        gradientLayer.frame = CGRect(x: -bounds.size.width, y: bounds.origin.y, width: 3 * bounds.size.width, height: bounds.size.height)
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        
        layer.addSublayer(gradientLayer)

        let gradientAnimation = CABasicAnimation(keyPath: "locations") //CAGradientLayer가 CALayer의 서브 클래스 이기 때문에 애니메이션을 적용 가능
        gradientAnimation.fromValue = [0.0, 0.0, 0.0, 0.0, 0.0, 0.25] //Any? 이므로 배열 가능. //그라디언트의 포인트 들이 이동한다.
        gradientAnimation.toValue = [0.65, 0.8, 0.85, 0.9, 0.95, 1.0]
        gradientAnimation.duration = 3.0
        gradientAnimation.repeatCount = Float.infinity //무한 반복
        
        gradientLayer.add(gradientAnimation, forKey: nil)
    }
}
