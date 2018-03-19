//
//  BounceAnimationController.swift
//  StoreSearch
//
//  Created by 근성가이 on 2018. 3. 2..
//  Copyright © 2018년 근성가이. All rights reserved.
//

import UIKit

class BounceAnimationController: NSObject { //애니메이션 컨트롤러가 되려면, NSObject가 필요하다. //UIViewControllerAnimatedTransitioning가 NSObject이 구현해야 한다.
    
}

extension BounceAnimationController :UIViewControllerAnimatedTransitioning {
    //UIViewControllerAnimatedTransitioning : 뷰 컨트롤러 전환 애니메이션 구현
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval { //지속 시간
        return 0.4
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) { //애니메이션 수행
        //UIViewControllerContextTransitioning : 뷰 컨트롤러 간 전환 애니메이션에 대한 상황 별 정보를 가지고 있다.
        //전환 시 관련 애니메이터 객체는 UIKit에서 UIViewControllerContextTransitioning를 제공받기 때문에 임의로 객체를 직접 생성해선 안 된다.
        if let toViewController = transitionContext.viewController(forKey: .to), let toView = transitionContext.view(forKey: .to) {
            let containerView = transitionContext.containerView //containerView는 전환에 관련해 슈퍼 뷰 역할을 한다.
            //from ViewController위에 배치된 새로운 뷰로, to Viewcontroller 뷰의 슈퍼뷰 역할을 한다.
            toView.frame = transitionContext.finalFrame(for: toViewController) //해당 뷰 컨트롤러 view의 마지막 frame
            containerView.addSubview(toView)
            toView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7) //70%로 축소된 상태
            
            //실제 애니메이션 시작 //키 프레임별로 애니메이션을 추가한다.
            UIView.animateKeyframes(withDuration: transitionDuration(using: transitionContext), delay: 0, options: .calculationModeCubic, animations: {
                UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.334, animations: {
                    toView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2) //120% 확대
                })
                UIView.addKeyframe(withRelativeStartTime: 0.334, relativeDuration: 0.333, animations: {
                    toView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9) //90%로 축소
                })
                UIView.addKeyframe(withRelativeStartTime: 0.666, relativeDuration: 0.333, animations: {
                    toView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0) //원본 크기
                }) //시간은 초단위가 아니라, duration의 비율이다.
            }, completion: { finished in
                transitionContext.completeTransition(finished) //전환 애니메이션이 완료되었음을 시스템에 알린다. //성공 여부를 매개변수로.
                //이 메서드를 구현해서 animator에서 animationEnded(_ :)를 호출할 수 있게 한다.
                })
        }
    }
}
