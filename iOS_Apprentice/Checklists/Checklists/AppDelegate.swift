//
//  AppDelegate.swift
//  Checklists
//
//  Created by 근성가이 on 2018. 1. 3..
//  Copyright © 2018년 근성가이. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow? //UIWindow는 모든 앱 뷰의 최상위 컨테이너. 하나의 앱에는 하나의 UIWindow만 존재한다. (데스트 탑 앱과 다른 점)
    //따라서 앱이 실행되면 반드시 window는 존재하게 된다. 하지만, 앱이 실행되고 스토리보드가 로드 될 때까지 잠시 동안 window가 nil이 될 수 있어 옵셔널로 선언한다.
    let dataModel = DataModel() //AllListsViewController의 dataModel과는 별개.
    //let으로 선언했어도 DataModel 객체에 대한 참조. 일반 Int, String 등과 다르다.
    //객체를 let으로 선언했다는 것은 메모리 주소를 바꿀 수 없다는 것. 객체 내부의 변수는 바뀔 수 있고, 참조한 원본의 데이터가 바뀌도 객체를 let으로 선언했어도 각 변수의 값은 바뀌게 된다.
    //옵셔널은 값이 변경될 수 있음을 의미하므로 반드시 var로 선언해야 한다.

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool { //프로그램이 시작하자 마자 호출된다.
        // Override point for customization after application launch.
        
        let navigationController = window!.rootViewController as! UINavigationController //윈도우 변수에서 루트 뷰 컨트롤러를 찾는다.
        //window가 nil이라면 모든 뷰 컨트롤러도 nil 이다. 따라서 옵셔널을 강제로 풀 수 있다.
        let controller = navigationController.viewControllers[0] as! AllListsViewController //루트 뷰에서 메인뷰를 찾는다.
        controller.dataModel = dataModel //AppDelegate에서 생성된 DataModel을 컨트롤러에 넘겨준다.
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) { //백 그라운드 전환 시 호출된다.
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        saveData() //백 그라운드로 전환 된 이후 저장
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) { //Xcode의 중지 버튼으로 종료하는 경우 applicationWillTerminate(_ :) 알림을 받지 못한다. 시뮬레이터로 테스트 하는 경우 시뮬레이터의 홈 버튼을 누른 후 종료해야 한다.
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        saveData() //종료되기 전 데이터 저장
    }
}

extension AppDelegate {
    func saveData() { //저장을 너무 자주 할 필요 없다. 앱이 중단되거나 정상 종료되는 경우에 해 주면 된다.
        dataModel.saveChecklists()
    }
}

//앱이 종료되는 상황
//1. iOS 4 이전에는 사용자가 앱을 실행하는 동안에도 종료될 수 있었다. //iOS 4부터 멀티 태스킹 지원. - 일시중지되어 백그라운드로 간다. (ex. iOS 4 이전에는 앱 실행 중 전화가 오면 종료됨)
//2. 앱이 일시 중지된 경우라도(백 그라운드) OS가 많은 메모리를 필요하는 앱(게임)을 실행해야 될 때 리소스 확보를 위해 강제 종료하는 경우가 있다. 알림이 전송되지 않는다.
//3. 충돌로 인한 종료.
