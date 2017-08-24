//
//  RevealAnimator.swift
//  LogoReveal
//
//  Created by 근성가이 on 2017. 1. 19..
//  Copyright © 2017년 근성가이. All rights reserved.
//

import UIKit

class RevealAnimator: UIPercentDrivenInteractiveTransition, UIViewControllerAnimatedTransitioning, CAAnimationDelegate { //네비게이션 애니메이션도 뷰 컨트롤러처럼 UIViewControllerAnimatedTransitioning를 통해 제어할 수 있다. //UIPercentDrivenInteractiveTransition는 UIViewControllerInteractiveTransitioning의 서브 클래스. UIViewControllerInteractiveTransitioning는 사용자 동작을 기반으로 한 애니메이션을 만들 수 있다. //UIViewControllerInteractiveTransition가 클래스 이므로 가장 앞에 와야 한다.
    //MARK: - Properties
    let animationDuration = 2.0
    var operation: UINavigationControllerOperation = .push
    weak var storedContext: UIViewControllerContextTransitioning? //애니메이션이 되는 컨텍스트를 저장하고, 델리게이트로 넘겨준다.
    
    var interactive = false
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval { //애니메이션 지속 시간
        return animationDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) { //실제 애니메이션
        storedContext = transitionContext
        
        if operation == .push { //푸쉬의 경우에만
            let fromVC = transitionContext.viewController(forKey: .from) as! MasterViewController
            let toVC = transitionContext.viewController(forKey: .to) as! DetailViewController
            transitionContext.containerView.addSubview(toVC.view) //containerView는 직접 애니메이션이 실행될 컨테이너
            toVC.view.frame = transitionContext.finalFrame(for: toVC) //최종 프레임
            
            let animation = CABasicAnimation(keyPath: "transform")
            animation.fromValue = NSValue(caTransform3D: CATransform3DIdentity)
            animation.toValue = NSValue(caTransform3D: CATransform3DConcat(CATransform3DMakeTranslation(0.0, -10.0, 0.0), CATransform3DMakeScale(150.0, 150.0, 1.0))) //상단으로 이동하면서 //크기 150배 크기 증가
            animation.duration = animationDuration
            animation.delegate = self
            animation.fillMode = kCAFillModeForwards
            animation.isRemovedOnCompletion = false
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
            
            let maskLayer: CAShapeLayer = RWLogoLayer.logoLayer() //CAShapeLayer는 BezierPath를 이용해 애니메이션 또는 도형을 그리기 위한 특수 CALayer //단순 크기 조정과 이동 만이라면 CALayer만 써도 문제 없다.
            maskLayer.position = fromVC.logo.position
            toVC.view.layer.mask = maskLayer
            maskLayer.add(animation, forKey: nil)
            
            fromVC.logo.add(animation, forKey: nil)
            
            let fadeIn = CABasicAnimation(keyPath: "opacity")
            fadeIn.fromValue = 0.0
            fadeIn.toValue = 1.0
            fadeIn.duration = animationDuration
            toVC.view.layer.add(fadeIn, forKey: nil)
        } else {
            let fromView = transitionContext.view(forKey: .from)!
            let toView = transitionContext.view(forKey: .to)!
            
            transitionContext.containerView.insertSubview(toView, belowSubview: fromView)
            
            UIView.animate(withDuration: animationDuration, delay: 0.0, options: .curveEaseIn, animations: {
                fromView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01) //0,0 으로 하면 오류날 확률이?
            }, completion: { _ in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })
        }
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) { //completeTransition()을 사용해야 전환이 완료 //여기서는 레이어 애니메이션이므로 클로저 대신 델리게이트에서 따로 설정해 준다.
        if let context = storedContext { //프로퍼티에서 저장해둔 컨텍스트를 불러온다.
            context.completeTransition(!context.transitionWasCancelled)
            //reset logo
            let fromVC = context.viewController(forKey: .from) as! MasterViewController
            fromVC.logo.removeAllAnimations()
            
            let toVC = context.viewController(forKey: .to) as! DetailViewController
            toVC.view.layer.mask = nil //마스크 효과 제거
        }
        storedContext = nil
    }
    
    func handlePan(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: recognizer.view!.superview!)
        var progress: CGFloat = abs(translation.x / 200.0) //절대값 //200포인트 이동하면 애니메이션 종료
        progress = min(max(progress, 0.01), 0.99) //정확히 0.00 이나 1.00까지 되어야 애니메이션이 시작, 완료되게 하면 사용감이 좋지 않을 수 있다. //max 와 min 값으로 제어하므로 위에서 0 ~ 200까지의 값이 나와도 여기에서 0.01 ~ 0.99 사이의 값이 나오게 된다.
        
        switch recognizer.state {
        case .changed:
            update(progress) //update()는 UIPercentDrivenInteractiveTransition에서 전환 애니메이션의 현재 진행률을 설정하는 메서드
        case .cancelled, .ended:
            let transitionLayer = storedContext?.containerView.layer
            transitionLayer?.beginTime = CACurrentMediaTime() //현재 멈춘 시간을 다시 애니메이션 시작하는 시간으로 설정
            
            if progress < 0.5 {
                cancel()
                transitionLayer?.speed = -1.0 //롤백
            } else {
                transitionLayer?.speed = 1.0 //진행
                finish()
            }
            
            interactive = false //true일 때만 동작 반응 애니메이션이 되도록 해 놓았고, 처음 제스쳐시. true가 되므로 다시 해제해 줘야 pop 애니메이션이 작동할 수 있다. //이 줄이 없으면 navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning)에서 nil이 반환되지 않고 항상 transition이 반환된다.  
        default:
            break
        }
    }
}
