//
//  ContainerViewController.swift
//  OfficeBuddy
//
//  Created by 근성가이 on 2017. 1. 19..
//  Copyright © 2017년 근성가이. All rights reserved.
//

import UIKit
import QuartzCore

class ContainerViewController: UIViewController {
    
    let menuWidth: CGFloat = 80.0
    let animationTime: TimeInterval = 0.5
    
    let menuViewController: UIViewController
    let centerViewController: UINavigationController
    
    var isOpening = false
    
    init(sideMenu: UIViewController, center: UINavigationController) {
        menuViewController = sideMenu
        centerViewController = center
        super.init(nibName: nil, bundle: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        view.backgroundColor = .black
        setNeedsStatusBarAppearanceUpdate()
        
        addChildViewController(centerViewController) //하나의 뷰 컨트롤러에 자식으로 붙인다.
        view.addSubview(centerViewController.view)
        centerViewController.didMove(toParentViewController: self) //컨트롤러가 컨테이너 뷰에 추가되거나 제거된 후에 호출된다. //removeFromParentViewController()는 didMove가 자동으로 호출되지만, 컨트롤러가 전환되거나 addChildViewController()를 호출한 후에는 호출해 주어야 한다.?
        
        addChildViewController(menuViewController) //하나의 뷰 컨트롤러에 자식으로 붙인다.
        view.addSubview(menuViewController.view)
        menuViewController.didMove(toParentViewController: self)
        
        menuViewController.view.layer.anchorPoint.x = 1.0 //레이어 경계의 기준 (0.5, 0.5) - (사각형의 중앙)가 디폴트 값이다. //프레임을 설정하기 전에 앵커포인트를 잡아줘야 한다.
        menuViewController.view.frame = CGRect(x: -menuWidth, y: 0, width: menuWidth, height: view.frame.height)
        
        let panGesture = UIPanGestureRecognizer(target:self, action:#selector(ContainerViewController.handleGesture(_:)))
        view.addGestureRecognizer(panGesture)
        
        setMenu(toPercent: 0.0) //애니메이션이 처음 실행 될 때에도 3D 애니메이션이 적용되도록
    }
    
    func handleGesture(_ recognizer: UIPanGestureRecognizer) {
        
        let translation = recognizer.translation(in: recognizer.view!.superview!)
        
        var progress = translation.x / menuWidth * (isOpening ? 1.0 : -1.0)
        progress = min(max(progress, 0.0), 1.0)
        
        switch recognizer.state {
        case .began:
            let isOpen = floor(centerViewController.view.frame.origin.x/menuWidth)
            isOpening = isOpen == 1.0 ? false: true
            
            // Improve the look of the opening menu //Core Animation은 컨트롤러의 내용을 계속해서 새로 그리기 때문에 메모리 상으로도 낭비가 되고, 3D효과의 픽셀화가 나타나기도 한다. //캐싱을 설정해 성능을 향상시킨다.
            menuViewController.view.layer.shouldRasterize = true //캐싱하도록 설정
            menuViewController.view.layer.rasterizationScale = UIScreen.main.scale //기준 크기. 비율을 조정. 큰 값은 내용을 확대하고 작은 값은 축소한다.
            
        case .changed:
            self.setMenu(toPercent: isOpening ? progress: (1.0 - progress)) //제스처 중이면 뷰가 보이도록 이동
            
        case .ended: fallthrough
        case .cancelled: fallthrough
        case .failed:
            
            var targetProgress: CGFloat
            if (isOpening) {
                targetProgress = progress < 0.5 ? 0.0 : 1.0 //절반 넘었는지 넘지 않았는지 계산해서 위치로 이동
            } else {
                targetProgress = progress < 0.5 ? 1.0 : 0.0
            }
            
            UIView.animate(withDuration: animationTime, animations: {
                self.setMenu(toPercent: targetProgress)
            }, completion: {_ in
            
            })
            
        default: break
        }
    }
    
    func toggleSideMenu() {
        let isOpen = floor(centerViewController.view.frame.origin.x/menuWidth)
        let targetProgress: CGFloat = isOpen == 1.0 ? 0.0: 1.0
        
        UIView.animate(withDuration: animationTime, animations: {
            self.setMenu(toPercent: targetProgress)
        }, completion: { _ in
            self.menuViewController.view.layer.shouldRasterize = false //더 이상 캐싱이 필요하지 않기 때문에 캐싱을 취소해 준다.
        })
    }
    
    func setMenu(toPercent percent: CGFloat) {
        centerViewController.view.frame.origin.x = menuWidth * CGFloat(percent)
//        menuViewController.view.frame.origin.x = menuWidth * CGFloat(percent) - menuWidth //2D 이동
        menuViewController.view.layer.transform = menuTransform(percent: percent)
        menuViewController.view.alpha = CGFloat(max(0.2, percent)) //최소값이 0.2가 되므로 최소값일 때에도 희미하게 레이어가 보인다.
        
        let centerVC = centerViewController.viewControllers.first as? CenterViewController
        if let menuButton = centerVC?.menuButton {
            menuButton.imageView.layer.transform = buttonTransform(percent: percent) //회전
        }
    }
    
}

extension ContainerViewController {
    func menuTransform(percent: CGFloat) -> CATransform3D { //진행상황에 따른 3D효과를 준다.
        var identity = CATransform3DIdentity
        identity.m34 = -1.0/1000 //3행 4열 //매트릭스를 변형한다. -1.0 / 카메라 거리 //0.1 ... 500 : 아주 가깝고 많은 투시 왜곡. //750 ... 2,000 : 멋진 관점, 내용이 선명하게 보인다. //2,000 이상 : 원근 왜곡이 거의 없다.
        let remainingPercent = 1.0 - percent
        let angle = remainingPercent * .pi * -0.5 //메뉴의 현재 각도 조절
        let rotationTransform = CATransform3DRotate(identity, angle, 0.0, 1.0, 0.0)
        let translationTransform = CATransform3DMakeTranslation(menuWidth * percent, 0, 0)
        
        return CATransform3DConcat(rotationTransform, translationTransform)
    }
    
    func buttonTransform(percent: CGFloat) -> CATransform3D { //버튼 회전
        var identity = CATransform3DIdentity
        identity.m34 = -1.0/1000
        
        let angle = percent * .pi
        let rotationTransform = CATransform3DRotate(identity, angle, 1.0, 1.0, 0.0) //identity, angle, x, y, z //3D 변형을 사용하지 않고 버튼을 직접 돌리면 탐색 막대보기와 충돌하고 탐색 막대가 부분적으로 가려 질 수 있다.
        
        return rotationTransform
    }
}
