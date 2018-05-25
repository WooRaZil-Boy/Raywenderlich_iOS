//
//  AppDelegate.swift
//  ARPokerDice
//
//  Created by 이 o이 2018. 5. 25..
//  Copyright © 2018년 com. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
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

//A9 이상의 프로세서가 있는 실제 장치를 사용해야 한다.
//• iPhone SE
//• iPhone 6s 및 6s Plus
//• iPhone 7 및 7 Plus
//• iPad Pro (모든 크기의 1 세대 및 2 세대 : 9.7", 10.5" 및 12.9")
//• iPad (2017+ 모델)
//• iPhone 8 및 8 Plus
//• iPhone X

//ARKit을 사용하는 앱은 카메라에 대한 액세스가 반드시 있어야 한다.
//Info.plist의 Find Privacy - Camera Usage Description에서 설정할 수 있다.
//ARKit 템플릿으로 프로젝트를 생성하면, 자동으로 설정되어 있다.
//이 메시지는 카메라에 액세스 요청할 때 사용자에게 표시되는 문자열이다.

//SceneKit Asset Catalog는 .scnassets 확장자로 생성해 주면 된다.
//ARPokerDice group에서 right-click, Add Files to "ARPokerDice"... 선택

//SceneKit Scene File을 생성할 때, Group을 제대로 지정해 줘야 한다. .scnassets 확장자 내의 그룹인지 확인

