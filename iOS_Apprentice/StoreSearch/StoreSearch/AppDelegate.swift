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
    
    //iPad //스토리보드 구조대로
    var splitVC: UISplitViewController {
        return window!.rootViewController as! UISplitViewController
    }
    
    var searchVC: SearchViewController {
        return splitVC.viewControllers.first as! SearchViewController
    }
    
    var detailNavController: UINavigationController { //스플릿 뷰를 스와이프하여 표시되도록 하는 버튼 추가 위해
        return splitVC.viewControllers.last as! UINavigationController
    }
    
    var detailVC: DetailViewController {
        return detailNavController.topViewController as! DetailViewController
    }
    
    //iPad에서는 화면이 훨씬 크므로 SplitView를 쓰는 것이 좋다.
    //iPad는 가로, 세로로 쓰기 때문에 모든 방향을 똑같이 지원해야 한다.
    //최신 버전의 Xcode는 iPhone용과 iPad용 뷰 컨트롤러를 한 스토리보드에서 관리할 수 있다.
    //여기에서 Split View Controller는 iPad에서만 사용하고, iPhone에서는 감춰진 상태로 유지될 것이다.

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        customizeAppearance()
        
        //iPad
        detailVC.navigationItem.leftBarButtonItem = splitVC.displayModeButtonItem
        //SplitViewController의 표시 모드 변경 버튼 추가
        //DetailViewController가 UINavigationController에 내장되어 있기 때문에 쉽게 추가할 수 있다.
        searchVC.splitViewDetail = detailVC
        //iPad에서는 DetailViewController를 선택 시 마다 할당 하는 게 아니라 미리 오른쪽 뷰에 할당해 놓고 재사용.
        splitVC.delegate = self
        
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

//MARK: - UISplitViewControllerDelegate(iPad)
extension AppDelegate: UISplitViewControllerDelegate {
    func splitViewController(_ svc: UISplitViewController, willChangeTo displayMode: UISplitViewControllerDisplayMode) { //디스플레이 모드 변경될 때 호출
        print(#function) //현재 메서드의 이름을 출력. //디버깅에 좋다.
        
        if displayMode == .primaryOverlay { //부분적으로 겹쳐지게 되면(마스터 분할 영역 표시되는 경우)
            svc.dismiss(animated: true, completion: nil) //pop-over 되어 있는 뷰 닫기
        }
    }
}

//AppDelegate는 main window와 최상위 뷰 컨트롤러를 가지고 있다.
//AppDelegate에 너무 많은 기능을 넣는 경우가 많은데(DB와 비슷하게 사용), 그러한 디자인 모델은 피해야 한다.
//수행할 기능이 있다면, 그 기능을 위한 별도의 클래스를 만들고, D.I(dependency injection)를 활용해 제어권을 넘겨줘야 한다.
//밑의 코드처럼 사용하지 말 것.
//let appDelegate = UIApplication.shared.delegate as! AppDelegate
//appDelegate.someProperty = . . .

