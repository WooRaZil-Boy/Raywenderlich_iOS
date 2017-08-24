//
//  AppDelegate.swift
//  MyLocations
//
//  Created by 근성가이 on 2016. 11. 11..
//  Copyright © 2016년 근성가이. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate { //SQLite에 연결. CoreData 사용 설정. 보통 NSManagedObjectModel을 직접 사용할 필요는 없다.
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "DataModel") //SQLite
        container.loadPersistentStores(completionHandler: { storeDescription, error in
            if let error = error {
                fatalError("Could load data store: \(error)")
            }
        })
        return container
    }() //()가 있어도 Lazy라 바로 실행되지 않고 할당 될 때에 실행 된다. 따로 이니셜라이저를 만들고 할당하고 할 수 있지만 클로저를 사용하는 것이 훨씬 깔끔하다.
    
    lazy var managedObjectContext: NSManagedObjectContext = self.persistentContainer.viewContext

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        customizeAppearance()
        
        //AppDelegate는 스토리보드와 직접 연결할 수 없으므로 코드로 찾아야 한다.
        let tabBarController = window!.rootViewController as! UITabBarController
        if let tabBarViewControllers = tabBarController.viewControllers {
            let currentLocationViewController = tabBarViewControllers[0] as! CurrentLocationViewController
            currentLocationViewController.managedObjectContext = managedObjectContext
            
            let navigationController = tabBarViewControllers[1] as! UINavigationController
            let locationsViewController = navigationController.viewControllers[0] as! LocationsViewController
            locationsViewController.managedObjectContext = managedObjectContext
            
            let mapViewController = tabBarViewControllers[2] as! MapViewController
            mapViewController.managedObjectContext = managedObjectContext
            
            let _ = locationsViewController.view //LocationsViewController가 뷰를로드하도록 강제 한다. 이 기능이 없으면 탭을 전환 할 때까지 뷰 로드가 지연되어 코어 데이터 불러 올 때 오류 나는 경우들이 있다. //CoreData 버그 때문에 씀.
        }
        
        print(applicationDocumentsDirectory)
        listenForFatalCoreDataNotifications() //Notification 등록
        
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

//MARK: - Notifications
extension AppDelegate { //Notification을 받는 클래스는 Appdelegate가 좋다. 앱의 최상위에 위치하는 클래스이므로 언제나 notification에 필요한 객체들이 존재하기 때문에
    func listenForFatalCoreDataNotifications() {
        NotificationCenter.default.addObserver(forName: MyManagedObjectContextSaveDidFailNotification, object: nil, queue: OperationQueue.main, using: { notification in //Notofocation 옵저버를 등록한다. post해서 notification을 받는다. //현재 실행 큐
            let alert = UIAlertController(title: "Internal Error", message: "There was a fatal error in the app and it cannot continue.\n\n" + "Press OK to terminate the app. Sorry for the inconvenience.", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default) { _ in
                let exception = NSException(name: NSExceptionName.internalInconsistencyException, reason: "Fatal Core Data error", userInfo: nil) //crash log를 남기는 데 NSException으로 종료하면 많은 정보를 담을 수 있다.
                exception.raise() //실제 앱 종료
            }
            alert.addAction(action)
            
            self.viewControllerForShowingAlert().present(alert, animated: true, completion: nil)
        })
    }
    
    func viewControllerForShowingAlert() -> UIViewController { //Alert 창이 실행될 뷰 컨트롤러를 찾는다.
        let rootViewController = self.window!.rootViewController!
        if let presentedViewController = rootViewController.presentedViewController {
            return presentedViewController
        } else {
            return rootViewController
        }
    }
}

//MARK: - Customize
extension AppDelegate {
    func customizeAppearance() {
        UINavigationBar.appearance().barTintColor = UIColor.black
        UINavigationBar.appearance().titleTextAttributes = [ NSForegroundColorAttributeName: UIColor.white ]
        UITabBar.appearance().barTintColor = UIColor.black
        
        let tintColor = UIColor(red: 255/255.0, green: 238/255.0, blue: 136/255.0, alpha: 1.0)
        UITabBar.appearance().tintColor = tintColor
    }
}

