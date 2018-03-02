//
//  DimmingPresentationController.swift
//  StoreSearch
//
//  Created by 근성가이 on 2018. 3. 2..
//  Copyright © 2018년 근성가이. All rights reserved.
//

import UIKit

class DimmingPresentationController: UIPresentationController {
    //UIPresentationController에서 ViewController를 표시하기 위한 논리(advanced view, transition management)를 지정해 줄 수 있다.
    //UIPresentationController는 ViewController가 아니다.
    lazy var dimmingView = GradientView(frame: CGRect.zero)
    
    override var shouldRemovePresentersView: Bool { //프레젠테이션 애니메이션이 끝날 때 뷰 컨트롤러 뷰를 제거할지
        return false
    }
    
    override func presentationTransitionWillBegin() { //프레젠테이션 이동이 시작될 때 //새 뷰 컨트롤러가 표시될 때
        dimmingView.frame = containerView!.bounds
        containerView!.insertSubview(dimmingView, at: 0) //0 : 서브 뷰 중 최상위에
        //containerView는 SearchViewController위에 배치된 새로운 뷰이며 DetailViewController의 뷰를 포함한다.
        //from ViewController위에 배치된 새로운 뷰로, to Viewcontroller 뷰의 슈퍼뷰 역할을 한다.
        
        //Animate background gradient view
        dimmingView.alpha = 0 //완전히 투명
        if let coordinator = presentedViewController.transitionCoordinator {
            //transitionCoordinator는 프레젠테이션 컨트롤러, 애니메이션 컨트롤러, 새 뷰 컨트롤러 전환에 일어나는 모든 이벤트 관리
            coordinator.animate(alongsideTransition: { _ in //전환과 동시에 애니메이션 실행
                self.dimmingView.alpha = 1
            }, completion: nil)
        }
    }
    
    override func dismissalTransitionWillBegin() { //presentationTransitionWillBegin의 반대
        if let coordinator = presentedViewController.transitionCoordinator {
            coordinator.animate(alongsideTransition: { _ in
                self.dimmingView.alpha = 0
            }, completion: nil)
        }
    }
}

//DetailViewController로 넘어갈 때 Modal로 잘 표현되지 않는다. 해결방법은 3가지가 있다.
//1. DetailViewController로 만들지 않고, View로 만들어 SearchViewController의 하위뷰로 추가한다.
//   하지만 이 방법은 SearchViewController에 DetailView의 로직이 섞이므로 좋은 방법이 아니다.
//   각 화면의 로직은 자체 뷰 컨트롤러에 있어야 한다.
//2. View Controller containment API를 사용해 DetailViewController를 SearchViewController 내부에 임베드 한다. (가로모드에 이 방법을 썼다.)
//3. presentation controller를 사용해 Modal segue가 ViewController를 화면에 표시하는 방법을 정의해 줄 수 있다.
//   DimmingPresentationController에서 해결하는 방법이 3번이다.
