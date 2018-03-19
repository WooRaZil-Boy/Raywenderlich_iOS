//
//  MyTabBarController.swift
//  MyLocations
//
//  Created by 근성가이 on 2018. 2. 26..
//  Copyright © 2018년 근성가이. All rights reserved.
//

import UIKit

class MyTabBarController: UITabBarController { //스토리 보드에서 해당 클래스를 서브 클래싱할 수 있다.
    override var preferredStatusBarStyle: UIStatusBarStyle { //status 바 힌색으로
        return .lightContent
    }
    
    override var childViewControllerForStatusBarStyle: UIViewController? {
        return nil //nil을 반환하면, 탭 바 컨트롤러가 다른 뷰 컨트롤러의 기본 설정 대신 해당 preferredStatusBarStyle를 사용하게 된다.
    }
}

//앱이 시작될 때, iOS는 Info.plist를 보고 상태 표시줄 표시 여부를 결정한다.
//그 이후 탭바를 로드하면서 status bar의 색이 바뀌게 된다. 따라서 로딩 시 짧은 시간 동안 status 바의 색이 기본 설정 색이 된다.
//프로젝트 설정 General - Deployment Info - Status Bar Style을 변경하면, 로딩되는 짧은 시간에도 status 바의 설정을 바꿀 수 있다.
