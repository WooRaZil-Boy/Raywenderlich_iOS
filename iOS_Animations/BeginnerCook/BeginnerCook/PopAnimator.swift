//
//  PopAnimator.swift
//  BeginnerCook
//
//  Created by 근성가이 on 2017. 1. 15..
//  Copyright © 2017년 근성가이. All rights reserved.
//

import UIKit

class PopAnimator: NSObject, UIViewControllerAnimatedTransitioning { //사용자 정의보기 컨트롤러 전환을위한 애니메이션을 구현하기 위해 UIViewControllerAnimatedTransitioning 프로토콜을 구현한다.
    
    let duration = 1.0
    var presenting = true //presenting or dismissing
    var originFrame = CGRect.zero
    var dismissCompletion: (() -> Void)? //따로 프로퍼티를 넘겨서 해도 되지만, 확장성 면에서 이러는 방법이 더 좋을 듯.
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval { //애니메이션 구현 시간
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) { //적용될 애니메이션 내용
        let containerView = transitionContext.containerView //컨터이너 뷰 찾아오기 //컨테이너 뷰는 애니메이션이 실행 되는 곳
        let toView = transitionContext.view(forKey: .to)! //toView 찾아오기 //transitionContext.viewController(forKey: )를 통해 뷰 컨트롤러에 접근할 수도 있다.
        let herbView = presenting ? toView : transitionContext.view(forKey: .from)! //presenting이면 toView, dismissing이면 fromView로 허브 디테일 뷰 가져오기
        
        let initialFrame = presenting ? originFrame : herbView.frame
        let finalFrame = presenting ? herbView.frame : originFrame
        let xScaleFactor = presenting ? initialFrame.width / finalFrame.width : finalFrame.width / initialFrame.width //비율 구하기
        let yScaleFactor = presenting ? initialFrame.height / finalFrame.height : finalFrame.height / initialFrame.height //비율 구하기
        
        let scaleTransform = CGAffineTransform(scaleX: xScaleFactor, y: yScaleFactor)
        
        if presenting {
            herbView.transform = scaleTransform
            herbView.center = CGPoint(x: initialFrame.midX, y: initialFrame.midY)
            herbView.clipsToBounds = true
        }
        
        containerView.addSubview(toView)
        containerView.bringSubview(toFront: herbView) //애니메이션할 뷰를 최상단으로
        
        let herbController = transitionContext.viewController(forKey: presenting ? .to : .from) as! HerbDetailsViewController //뷰 컨트롤러 객체를 가져온다.
        if presenting {
            herbController.containerView.alpha = 0.0 //페이드 인 주기
        }
        
        UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.0, options: [], animations: {
            herbView.transform = self.presenting ? CGAffineTransform.identity : scaleTransform
            herbView.center = CGPoint(x: finalFrame.midX, y: finalFrame.midY)
            herbController.containerView.alpha = self.presenting ? 1.0 : 0.0 //페이드 인 페이드 아웃
        }, completion: { _ in
            if !self.presenting { //닫는 애니메이션일 때 실행
                self.dismissCompletion?()
            }
            transitionContext.completeTransition(true) //애니메이션 완료 블록의 전환 컨텍스트에서 completeTransition ()을 호출하면 UIKit에 전환 애니메이션이 완료되고 UIKit에서 View Controller 전환을 마무리 할 수 ​​있다.
        })
        
        let round = CABasicAnimation(keyPath: "cornerRadius")
        round.fromValue = !presenting ? 0.0 : 20.0 / xScaleFactor
        round.toValue = presenting ? 0.0 : 20.0 / xScaleFactor
        round.duration = duration / 2
        herbView.layer.add(round, forKey: nil)
        herbView.layer.cornerRadius = presenting ? 0.0 : 20.0 / xScaleFactor

        //투명도 조절
//        containerView.addSubview(toView)
//        toView.alpha = 0.0
//        UIView.animate(withDuration: duration, animations: {
//            toView.alpha = 1.0
//        }, completion: { _ in
//            transitionContext.completeTransition(true) //애니메이션 완료 블록의 전환 컨텍스트에서 completeTransition ()을 호출하면 UIKit에 전환 애니메이션이 완료되고 UIKit에서 View Controller 전환을 마무리 할 수 ​​있다.
//        })
        
        
    }

}
