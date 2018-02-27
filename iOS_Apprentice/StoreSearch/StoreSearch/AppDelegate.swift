//
//  AppDelegate.swift
//  StoreSearch
//
//  Created by 근성가이 on 2018. 2. 27..
//  Copyright © 2018년 근성가이. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        customizeAppearance()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

// MARK:- Helper Methods
extension AppDelegate {
    func customizeAppearance() {
        let barTintColor = UIColor(red: 20/255, green: 160/255, blue: 160/255, alpha: 1)
        UISearchBar.appearance().barTintColor = barTintColor //앱의 모든 UISearchBar에 영향
        
        window!.tintColor = UIColor(red: 10/255, green: 80/255, blue: 80/255, alpha: 1) //Global Tint
    }
}

//AppDelegate는 main window와 최상위 뷰 컨트롤러를 가지고 있다.
//AppDelegate에 너무 많은 기능을 넣는 경우가 많은데(DB와 비슷하게 사용), 그러한 디자인 모델은 피해야 한다.
//수행할 기능이 있다면, 그 기능을 위한 별도의 클래스를 만들고, D.I(dependency injection)를 활용해 제어권을 넘겨줘야 한다.
//밑의 코드처럼 사용하지 말 것.
//let appDelegate = UIApplication.shared.delegate as! AppDelegate
//appDelegate.someProperty = . . .

