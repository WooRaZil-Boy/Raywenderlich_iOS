//
//  BounceAnimationController.swift
//  StoreSearch
//
//  Created by 근성가이 on 2016. 12. 15..
//  Copyright © 2016년 근성가이. All rights reserved.
//

import UIKit

class BounceAnimationController: NSObject, UIViewControllerAnimatedTransitioning { //UIViewControllerAnimatedTransitioning 프로토콜은 transitionDuration, animateTransition 구현해야 한다.
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval { //애니메이션 지속시간
        return 0.4
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) { //애니메이션 실행 //transitionContext에 뷰 컨트롤러와 여러 정보들이 들어 있다.
        if let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to), let toView = transitionContext.view(forKey: UITransitionContextViewKey.to) {
            let containerView = transitionContext.containerView
            toView.frame = transitionContext.finalFrame(for: toViewController)
            containerView.addSubview(toView)
            toView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
            
            UIView.animateKeyframes(withDuration: transitionDuration(using: transitionContext), delay: 0, options: .calculationModeCubic, animations: {
                UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.334, animations: {
                    toView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                })
                
                UIView.addKeyframe(withRelativeStartTime: 0.334, relativeDuration: 0.333, animations: {
                    toView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                })
                
                UIView.addKeyframe(withRelativeStartTime: 0.666, relativeDuration: 0.333, animations: {
                    toView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                })
            }, completion: { finished in
                transitionContext.completeTransition(finished)
            })
        }
    }
}
