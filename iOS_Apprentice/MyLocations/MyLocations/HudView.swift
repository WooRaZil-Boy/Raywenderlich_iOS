//
//  HudView.swift
//  MyLocations
//
//  Created by 근성가이 on 2016. 11. 30..
//  Copyright © 2016년 근성가이. All rights reserved.
//

import UIKit

class HudView: UIView {
    var text = ""
    
    class func hud(inView view: UIView, animated: Bool) -> HudView { //convenience constructor. 항상 클래스 메서드로
        let hudView = HudView(frame: view.bounds)
        hudView.isOpaque = false
        
        view.addSubview(hudView)
        view.isUserInteractionEnabled = false //선택 안 되어지게 하기 위해. (뒤 뷰 컨트롤러 블락) - 이 뷰가 모든 터치를 가져간다?
        
        hudView.show(animated: animated)
        
        return hudView
    }
    
    override func draw(_ rect: CGRect) { //뷰를 그린다. 모든 iOS 기능은 이벤트 기반. 보통은 UIKit이 자동으로 실행하며 이 메서드가 실행되지 않으면 뷰를 그리지 않는다. setNeedsDisplay() 메서드를 호출하면 UIKit이 draw()를 트리거 한다. setNeedsDisplay는 따로 구현하지 않으며, draw()를 오버라이드 한다.
        
        //Image
        let boxWidth: CGFloat = 96
        let boxHeight: CGFloat = 96
        
        let boxRect = CGRect(x: round((bounds.size.width - boxWidth) / 2), y: round((bounds.size.height - boxHeight) / 2), width: boxWidth, height: boxHeight) //반올림을 한다. 반올림 하지 않고, 소수로 사용하면 픽셀이 뭉개져 흐려 보일 수 있다.
        
        let roundRect = UIBezierPath(roundedRect: boxRect, cornerRadius: 10) //배지어 곡선
        UIColor(white: 0.3, alpha: 0.8).setFill()
        roundRect.fill()
        
        if let image = UIImage(named: "Checkmark") {
            let imagePoint = CGPoint(x: center.x - round(image.size.width / 2), y: center.y - round(image.size.height / 2) - boxHeight / 8)
            
            image.draw(at: imagePoint)
        }
        
        //Text
        let attribs = [NSFontAttributeName: UIFont.systemFont(ofSize: 16), NSForegroundColorAttributeName: UIColor.white ]
        let textSize = text.size(attributes: attribs)
        
        let textPoint = CGPoint(x: center.x - round(textSize.width / 2), y: center.y - round(textSize.height / 2) + boxHeight / 4)
        
        text.draw(at: textPoint, withAttributes: attribs) //String도 draw가 있다. - NSString
    }
    
    func show(animated: Bool) {
        if animated {
            alpha = 0
            transform = CGAffineTransform(scaleX: 1.3, y: 1.3)

            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [], animations: {
                self.alpha = 1
                self.transform = CGAffineTransform.identity //원래대로
            }, completion: nil)
        }
    }
}
