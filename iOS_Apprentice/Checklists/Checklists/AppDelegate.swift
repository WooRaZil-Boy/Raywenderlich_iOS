//
//  AppDelegate.swift
//  Checklists
//
//  Created by 근성가이 on 2016. 10. 23..
//  Copyright © 2016년 근성가이. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    //MARK: - Properties
    var window: UIWindow? //window = 최상위 컨테이너. 오로지 하나만 존재. - Mac 용 프로그램은 window 객체가 여러개 될 수 있다. - 멀티 태스킹
    let dataModel = DataModel() //reference 타입의 let은 주소값이 바뀌지 않는 것. 그 주소값의 객체 내부의 값이 바뀌는 것은 상관없다. 

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let navigationController = window!.rootViewController as! UINavigationController
        let controller = navigationController.viewControllers[0] as! AllListsViewController //topViewController 파라미터는 현재 가장 위에 보이는 뷰 컨트롤러를 반환. [0]과 다를 수 있다.
        controller.dataModel = dataModel
        
        let center = UNUserNotificationCenter.current()
//        center.requestAuthorization(options: [.alert, .sound]) { granted, error in //권한 체크. alert 형식으로 sound와 함께
//            if granted {
//                print("We have permission")
//            } else {
//                print("Permission denied")
//            }
//        }
//        
//        let content = UNMutableNotificationContent() //Local Notification 생성
//        content.title = "Hello"
//        content.body = "I am a local notification"
//        content.sound = UNNotificationSound.default()
//        
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false) //10초 뒤 실행. 반복 X
//        let reguest = UNNotificationRequest(identifier: "MyNotification", content: content, trigger: trigger)
//        
//        center.add(reguest) //앱이 Active 중이라면 Notification이 발생하지 않는다.
        center.delegate = self
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        saveData()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        saveData()
    }


}

extension AppDelegate {
    func saveData() {
//        let controller = navigationController.viewControllers[0] as! AllListsViewController //네비게이션 컨트롤러는 따로 rootViewController가 없다. //topViewController 프로퍼티는 NaviagationController의 현재 뷰 컨트롤러를 반환하므로 crash 난다.
        dataModel.saveChecklists()
    }
}

//MARK: - Delegate
extension AppDelegate: UNUserNotificationCenterDelegate {
//    func userNotificationCenter(_ center: UNUserNotificationCenter,
//                                willPresent notification: UNNotification,
//                                withCompletionHandler completionHandler:
//        @escaping (UNNotificationPresentationOptions) -> Void) {
//        print("Received local notification \(notification)")
//    }
    
    
    
    
    
    
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("Received local notification \(notification)")
    }
    
    
    
    
    
    
    
    
    
    
}

