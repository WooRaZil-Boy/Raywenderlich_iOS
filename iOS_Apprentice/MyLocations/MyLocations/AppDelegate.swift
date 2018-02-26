//
//  AppDelegate.swift
//  MyLocations
//
//  Created by 근성가이 on 2018. 2. 10..
//  Copyright © 2018년 근성가이. All rights reserved.
//

import UIKit
import CoreData //앱이 시작할 때 저장소를 초기화해야 한다.

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    lazy var persistentContainer: NSPersistentContainer = {
        //1. NSPersistentContainer 인스턴스 변수를 생성한다.(iOS 10부터 추가)
        //2. NSPersistentContainer 객체에 viewContext 속성을 요청해 NSManagedObjectContext를 생성한다.
        let container = NSPersistentContainer(name: "DataModel") //Data Model 이름으로 컨테이너 생성
        container.loadPersistentStores { storeDescription, error in //데이터 모델 로드하고, SQLite에 연결
            if let error = error {
                fatalError("Could load data store: \(error)") //에러 있는 경우 강제 종료
            }
        }
        
        return container
    }() //Core Data와 연결하는 데 사용될 NSManagedObjectContext 객체를 생성
    
    //1. Core Data Model 에서 NSManagedObjectModel을 만든다.
    //DataModel.xcdatamodeld, Location+CoreDataClass.swift, Location+CoreDataProperties.swift
    //이 객체는 런타임 중에 데이터 모델을 나타 내며(엔티티 종류와 특성), NSManagedObjectModel 객체를 직접 사용할 필요는 없다.
    //2. NSPersistentStoreCoordinator 객체를 만든다. SQLite 데이터베이스를 담당한다.
    //3. NSManagedObjectContext 개체를 만들어 persistent store coordinator에 연결합니다.
    //이러한 객체들을 "Core Data stack"라고 부른다.
    
    //iOS 10부터는 NSPersistentContainer로 간단하게 만들 수 있다.
    
    lazy var managedObjectContext: NSManagedObjectContext = self.persistentContainer.viewContext
    //NSPersistentContainer 객체에 viewContext 속성을 요청해 NSManagedObjectContext를 생성한다.

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        customizeAppearance() //UI 변경
        
        //Interface Builder에서는 AppDelegate의 viewController를 만들 수 없다.
        let tabController = window!.rootViewController as! UITabBarController
        //윈도우는 이 앱의 최상위 객체. //rootViewController로 첫 시작 시의 viewController를 가져온다.
        if let tabViewControllers = tabController.viewControllers {
            print("앱 시작 시")
            var navController = tabViewControllers[0] as! UINavigationController //first tab
            let controller1 = navController.viewControllers.first as! CurrentLocationViewController
            controller1.managedObjectContext = managedObjectContext
            
            navController = tabViewControllers[1] as! UINavigationController //second tab
            let controller2 = navController.viewControllers.first as! LocationsViewController
            controller2.managedObjectContext = managedObjectContext
            //managedObjectContext는 lazy로 되어 있으므로 여기에서 NSPersistentContainer 인스턴스가 만들어진다(내부의 클로저가 실행된다).
            let _ = controller2.view //CoreData 버그 때문에. p.672 참고
            
            navController = tabViewControllers[2] as! UINavigationController //third tab
            let controller3 = navController.viewControllers.first as! MapViewController
            controller3.managedObjectContext = managedObjectContext
            
        } //따라서 대신 뷰 계층 구조를 따라가면서 D.I 해주어야 한다.
        
        print(applicationDocumentsDirectory) //파인더에서 Shift + ⌘ + G로 /Users/...로 바로 이동할 수 있다.
        //Data Base는 Documents가 아닌 Library 폴더의 Application Support에 있다.
        
        listenForFatalCoreDataNotifications()
        
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

//MARK: - Helper methods
extension AppDelegate {
    func listenForFatalCoreDataNotifications() { //Core Data Error를 처리하는 데에 Appdelegate가 좋은 위치
        //앱의 최상위 객체이면서 항상 존재한다는 보장이 있기 때문이다.
        NotificationCenter.default.addObserver(forName: CoreDataSaveFailedNotification, object: nil, queue: OperationQueue.main) { notification in
            //CoreDataSaveFailedNotification을 NotificationCenter에 추가해 게시될 때마다 통보를 받는다.
            //통보 시마다 클로저 코드가 실행된다.
            let message = """
There was a fatal error in the app and it cannot continue.
Press OK to terminate the app. Sorry for the inconvenience.
""" //여러 문자열의 경우 \n대신 Python 처럼 """ """로 표현할 수 있다(Swift 4부터). //각 """는 새 줄에 있어야 한다.
            let alert = UIAlertController(title: "Internal Error", message: message, preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default) { _ in
                let exception = NSException(name: .internalInconsistencyException, reason: "Fatal Core Data error", userInfo: nil) //응용 프로그램을 종료하는 NSException
                //fatalError()와 비슷하다.
                exception.raise()
            }
            alert.addAction(action)
            
            let tabController = self.window!.rootViewController! //현재 화면에서 최상위 뷰 컨트롤러를 가져온다.
            tabController.present(alert, animated: true)
        } //알림을 보여주고 앱을 종료한다.
    }
}

//MARK: - Custom UI
extension AppDelegate {
    func customizeAppearance() { 
        UINavigationBar.appearance().barTintColor = UIColor.black //이 앱의 모든 네비게이션 바 틴트 컬러 변경
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white] //이 앱의 모든 네비게이션 바 타이틀 텍스트 설정 변경
        
        UITabBar.appearance().barTintColor = UIColor.black //이 앱의 모든 탭바 바 틴트 컬러 변경
        
        let tintColor = UIColor(red: 255/255.0, green: 238/255.0, blue: 136/255.0, alpha: 1.0)
        UITabBar.appearance().tintColor = tintColor //이 앱의 모든 탭바 틴트 컬러 변경
        
        //탭바 이미지는 최대 30x30(Retina는 60x60, RetinaHD는 90x90)
    }
}
