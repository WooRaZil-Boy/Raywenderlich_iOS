//
//  MyTabBarController.swift
//  MyLocations
//
//  Created by 근성가이 on 2016. 12. 6..
//  Copyright © 2016년 근성가이. All rights reserved.
//

import UIKit

class MyTabBarController: UITabBarController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override var childViewControllerForStatusBarStyle: UIViewController? {
        return nil //여기서 nil 을 반환하면 preferredStatusBarStyle의 값을 사용하게 된다.
    }
}
