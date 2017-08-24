//
//  RefreshView.swift
//  PullToRefresh
//
//  Created by 근성가이 on 2017. 1. 12..
//  Copyright © 2017년 근성가이. All rights reserved.
//

import UIKit
import QuartzCore

// MARK: Refresh View Delegate Protocol
protocol RefreshViewDelegate: class {
    func refreshViewDidRefresh(_ refreshView: RefreshView)
}

// MARK: Refresh View
class RefreshView: UIView, UIScrollViewDelegate {
    
    weak var delegate: RefreshViewDelegate?
    var scrollView: UIScrollView
    var refreshing: Bool = false
    var progress: CGFloat = 0.0
    
    var isRefreshing = false
    
    let ovalShapeLayer: CAShapeLayer = CAShapeLayer() //CAShapeLayer는 BezierPath를 이용해 애니메이션 또는 도형을 그리기 위한 특수한 CALayer
    let airplaneLayer: CALayer = CALayer()
    
    init(frame: CGRect, scrollView: UIScrollView) { //ViewController의 tableView가 스크롤 뷰로
        self.scrollView = scrollView
        
        super.init(frame: frame)
        
        //add the background image
        let imgView = UIImageView(image: UIImage(named: "refresh-view-bg.png"))
        imgView.frame = bounds
        imgView.contentMode = .scaleAspectFill
        imgView.clipsToBounds = true
        addSubview(imgView)
        
        ovalShapeLayer.strokeColor = UIColor.white.cgColor
        ovalShapeLayer.fillColor = UIColor.clear.cgColor
        ovalShapeLayer.lineWidth = 4.0
        ovalShapeLayer.lineDashPattern = [2, 3] //점선 굵기, 빈 점선 굵기. //[1,3,4,2] 등 꼭 2개가 아니어도 된다.
        
        let refreshRadius = frame.size.height / 2 * 0.8
        ovalShapeLayer.path = UIBezierPath(ovalIn: CGRect(x: frame.size.width / 2 - refreshRadius, y: frame.size.height / 2 - refreshRadius, width: 2 * refreshRadius, height: 2 * refreshRadius)).cgPath //디폴트가 원 임. 사각형은 따로 설정값을 넣어줘야 한다. //UIBezierPath(rect: bounds).cgPath :: 사각형 만들기 //UIBezierPath(ovalIn: bounds).cgPath :: 원형 만들기
        layer.addSublayer(ovalShapeLayer)
        
        
        
        
        
        
//        let airplaneImage = UIImage(named: "airplane.png")!
//        airplaneLayer.contents = airplaneImage.cgImage
//        airplaneLayer.bounds = CGRect(x: 0.0, y: 0.0,
//                                      width: airplaneImage.size.width,
//                                      height: airplaneImage.size.height)
//        airplaneLayer.position = CGPoint(
//            x: frame.size.width/2 + frame.size.height/2 * 0.8,
//            y: frame.size.height/2)
//        layer.addSublayer(airplaneLayer)
        
        let airplaneImage = #imageLiteral(resourceName: "airplane")
        airplaneLayer.contents = airplaneImage.cgImage
        airplaneLayer.bounds = CGRect(x: 0.0, y: 0.0, width: airplaneImage.size.width, height: airplaneImage.size.height)
        airplaneLayer.position = CGPoint(x: frame.size.width / 2 + frame.size.height / 2 * 0.8, y: frame.size.height / 2)
        layer.addSublayer(airplaneLayer)
        airplaneLayer.opacity = 0.0
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Scroll View Delegate methods
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        let offsetY = max(-(scrollView.contentOffset.y + scrollView.contentInset.top), 0.0)
        progress = min(max(offsetY / frame.size.height, 0.0), 1.0)
        
        if !isRefreshing {
            redrawFromProgress(self.progress)
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if !isRefreshing && self.progress >= 1.0 {
            delegate?.refreshViewDidRefresh(self)
            beginRefreshing()
        }
    }
    
    // MARK: animate the Refresh View
    
    func beginRefreshing() {
        isRefreshing = true
        
        UIView.animate(withDuration: 0.3) {
            var newInsets = self.scrollView.contentInset
            newInsets.top += self.frame.size.height
            self.scrollView.contentInset = newInsets
        }
        
        let strokeStartAnimation = CABasicAnimation(keyPath: "strokeStart") //keyPath는 프로퍼티들.
        strokeStartAnimation.fromValue = -0.5 //음수로 설정해도 0이나 똑같지만, 시간 차를 내기 위한 트릭
        strokeStartAnimation.toValue = 1.0
        
        let strokeEndAnimation = CABasicAnimation(keyPath: "strokeEnd")
        strokeEndAnimation.fromValue = 0.0
        strokeEndAnimation.toValue = 1.0
        
        let strokeAnimationGroup = CAAnimationGroup()
        strokeAnimationGroup.duration = 1.5
        strokeAnimationGroup.repeatDuration = 5.0
        strokeAnimationGroup.animations = [strokeStartAnimation, strokeEndAnimation]
        ovalShapeLayer.add(strokeAnimationGroup, forKey: nil)
        
        let flightAnimation = CAKeyframeAnimation(keyPath: "position")
        flightAnimation.path = ovalShapeLayer.path
        flightAnimation.calculationMode = kCAAnimationPaced//설정 한 키 시간을 무시하고 일정한 속도로 레이어에 애니메이션을 적용. //kCAAnimationDiscrete는 Core Animation이 보간없이 키 값에서 키 값으로 점프하게 한다. -> 애니메이션을 적용하지 않는다.
        
        let airplaneOrientationAnimation = CABasicAnimation(keyPath: "transform.rotation")
        airplaneOrientationAnimation.fromValue = 0
        airplaneOrientationAnimation.toValue = 2.0 * .pi //360도
        
        let flightAnimationGroup = CAAnimationGroup()
        flightAnimationGroup.duration = 1.5
        flightAnimationGroup.repeatDuration = 5.0
        flightAnimationGroup.animations = [flightAnimation, airplaneOrientationAnimation]
        airplaneLayer.add(flightAnimationGroup, forKey: nil)
        
        //이 방법 외에 CAKeyframeAnimation의 rotationMode라는 특수 속성을 이용할 수도 있다. kCAAnimationRotateAuto로 설정하면 레이어가 이동하는 방향으로 자동으로 방향이 지정된다.
    }
    
    func endRefreshing() {
        
        isRefreshing = false
        
        UIView.animate(withDuration: 0.3, delay:0.0, options: .curveEaseOut, //다시 애니메이션 뷰를 위로 숨긴다.
                       animations: {
                        var newInsets = self.scrollView.contentInset
                        newInsets.top -= self.frame.size.height
                        self.scrollView.contentInset = newInsets
        },
                       completion: {_ in
                        //finished
        }
        )
    }
    
    func redrawFromProgress(_ progress: CGFloat) {
        ovalShapeLayer.strokeEnd = progress //0.0 ~ 1.0 의 값. 경로 그리는 것을 그만 둘 위치를 지정한다. //살짝만 스크롤 해보면 차이
        airplaneLayer.opacity = Float(progress)
    }
    
}
