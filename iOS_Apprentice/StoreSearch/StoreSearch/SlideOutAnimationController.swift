//
//  SlideOutAnimationController.swift
//  StoreSearch
//
//  Created by IndieCF on 2018. 3. 2..
//  Copyright © 2018년 근성가이. All rights reserved.
//

import UIKit

class SlideOutAnimationController: NSObject { //애니메이션 컨트롤러가 되려면, NSObject가 필요하다. //UIViewControllerAnimatedTransitioning가 NSObject이 구현해야 한다.
    
}

extension SlideOutAnimationController: UIViewControllerAnimatedTransitioning {
    //UIViewControllerAnimatedTransitioning : 뷰 컨트롤러 전환 애니메이션 구현
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval { //지속 시간
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) { //애니메이션 수행
        //UIViewControllerContextTransitioning : 뷰 컨트롤러 간 전환 애니메이션에 대한 상황 별 정보를 가지고 있다.
        //전환 시 관련 애니메이터 객체는 UIKit에서 UIViewControllerContextTransitioning를 제공받기 때문에 임의로 객체를 직접 생성해선 안 된다.
        if let fromView = transitionContext.view(forKey: .from) {
            let containerView = transitionContext.containerView //containerView는 전환에 관련해 슈퍼 뷰 역할을 한다.
            //from ViewController위에 배치된 새로운 뷰로, to Viewcontroller 뷰의 슈퍼뷰 역할을 한다.
            let time = transitionDuration(using: transitionContext)
            //실제 애니메이션 시작
            UIView.animate(withDuration: time, animations: {
                fromView.center.y -= containerView.bounds.size.height
                fromView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5) //축소
            }, completion: { finished in //전환 애니메이션이 완료되었음을 시스템에 알린다. //성공 여부를 매개변수로.
                transitionContext.completeTransition(finished)
                //이 메서드를 구현해서 animator에서 animationEnded(_ :)를 호출할 수 있게 한다.
            })
        }
    }
}
