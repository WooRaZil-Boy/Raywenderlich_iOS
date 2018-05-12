//
//  AppDelegate.swift
//  StyleGuide
//
//  Created by Ellen Shapiro on 2/4/18.
//  Copyright © 2018 RayWenderlich.com. All rights reserved.
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

//target scheme를 StyleGuide로 바꿀 수 있다.
//앱 설정 - StyleGuide - Build Phases - Target Dependencies에서 SpacetimeUI를 추가해 준다.
//그래야 StyleGuide를 빌드할 때 SpacetimeUI 라이브러리에서 발생한 변경 사항이 해당 빌드에 적용된다.
//적용해 주면, StyleGuide이 빌드될 때, SpacetimeUI도 함께 빌드된다.
//Link Binary With Libraries에서 바이너리에도 추가해 준다.

//이런 샘플 앱을 만들면, 협업하기도 좋고 거대한 실제 응용 프로그램에 적용한 것을 확인하는 것보다 시간을 절약할 수 있다.
//이런 앱을 만들 때 고려 해야 할 사항은
//• 최대한 심플하게 만든다(스타일 목업 앱이므로 적용된 스타일을 확인할 수만 있으면 된다).
//• enum을 활용한다.
//• protocol을 활용한다.
//• extension을 활용한다.
