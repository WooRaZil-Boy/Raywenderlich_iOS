//
//  MasterViewController.swift
//  LogoReveal
//
//  Created by 근성가이 on 2017. 1. 17..
//  Copyright © 2017년 근성가이. All rights reserved.
//

import UIKit
import QuartzCore

func delay(seconds: Double, completion: @escaping ()-> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: completion)
}

class MasterViewController: UIViewController {
    //MARK: - Properties
    let logo = RWLogoLayer.logoLayer()
    let transition = RevealAnimator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Start"
        navigationController?.delegate = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        // add the tap gesture recognizer
//        let tap = UITapGestureRecognizer(target: self, action: #selector(didTap))
//        view.addGestureRecognizer(tap)
        
        // add the pan gesture recognizer
        let pan = UIPanGestureRecognizer(target: self, action: #selector(didPan))
        view.addGestureRecognizer(pan)
        
        // add the logo to the view
        logo.position = CGPoint(x: view.layer.bounds.size.width/2, y: view.layer.bounds.size.height/2 - 30)
        logo.fillColor = UIColor.white.cgColor
        view.layer.addSublayer(logo)
    }
    
    //
    // MARK: Gesture recognizer handler
    //
    func didTap() {
        performSegue(withIdentifier: "details", sender: nil)
    }
    
    func didPan(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            transition.interactive = true
            performSegue(withIdentifier: "details", sender: nil) //시작할 때 세그가 실행되면서 애니메이션 메서드가 실행된다.
        default:
            transition.handlePan(recognizer: recognizer)
        }
    }
}

extension MasterViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? { //네비게이션 컨트롤러 전환 시에 애니메이션을 추가해 줄 수 있는 델리게이트 메서드 //operation :: .push, .pop //fromVC :: 현재 화면 뷰 컨트롤러 //toVC :: 전환할 뷰 컨트롤러
        transition.operation = operation
        return transition
    }
    
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? { //사용자 동작에 반응하는 애니메이션을 지정하는 메서드
        if !transition.interactive {
            return nil
        }
        return transition //interactive이 있는 경우에만 제스처 통한 애니메이션 적용
    }
}
