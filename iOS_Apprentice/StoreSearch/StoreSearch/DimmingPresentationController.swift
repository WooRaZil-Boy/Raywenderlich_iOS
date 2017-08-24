//
//  DimmingPresentationController.swift
//  StoreSearch
//
//  Created by 근성가이 on 2016. 12. 14..
//  Copyright © 2016년 근성가이. All rights reserved.
//

import UIKit

class DimmingPresentationController: UIPresentationController { //뷰 컨트롤러를 presenting 할 때의 제어 설정을 할 수 있다. //UIPresentationController가 뷰 컨트롤러는 아니다. //애니메이션 설정을 할 수 있는 animation controller는 따로 있다.
    //MARK: - Properties
    lazy var dimmingView = GradientView(frame: CGRect.zero)
    
    override var shouldRemovePresentersView: Bool { //밑에 깔린 준 컨트롤러를 보이지 않게 할지 여부
        return false
    }
}

extension DimmingPresentationController {
    override func presentationTransitionWillBegin() { //새 뷰 컨트롤러가 화면에 표시될 때 호출
        dimmingView.frame = containerView!.bounds
        containerView!.insertSubview(dimmingView, at: 0) //추가. containerView는 이전 뷰 컨트롤러 최상단에 배치되는 새로운 뷰, 전환되는 뷰 컨트롤러의 뷰를 포함한다.? //두 스크린 사이에 위치한다.
        
        dimmingView.alpha = 0
        if let coordinator = presentedViewController.transitionCoordinator { //transitionCoordinator는 프리젠 테이션 컨트롤러와 애니메이션 컨트롤러 및 새로운 뷰 컨트롤러가 제공 될 때 발생하는 모든 것을 조정한다.
            coordinator.animate(alongsideTransition: { _ in //애니메이션이 진행되면서 페이드 인 된다. //애니메이트 클로저 안에 넣어두면 자연스럽게 애니메이션 효과가 적용되며 변한다.
                self.dimmingView.alpha = 1
            }, completion: nil)
        }
    }
    
    override func dismissalTransitionWillBegin() { //뷰 컨트롤러가 dismiss 될 때 호출
        if let coordinator = presentedViewController.transitionCoordinator {
            coordinator.animate(alongsideTransition: { _ in
                self.dimmingView.alpha = 0
            }, completion: nil)
        }
    }
}
