//
//  AppDelegate.swift
//  Spacetime
//
//  Created by Ellen Shapiro on 10/22/17.
//  Copyright © 2017 RayWenderlich.com. All rights reserved.
//

import SpacetimeUI //프레임워크
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  
  func applicationDidFinishLaunching(_ application: UIApplication) {
    self.setupAppearanceProxies()
  }
  
  private func setupAppearanceProxies() {
    UITabBar.appearance().tintColor = SpacetimeColor.tabBarContent.color
    //SpacetimeColor의 enum에서 색상을 가져온다.
    UITabBarItem.appearance().setTitleTextAttributes([
      .font: SpacetimeFont.standard.of(size: .tiny),
      ], for: .normal)
    
    UINavigationBar.appearance().barTintColor = SpacetimeColor.navigationBarBackground.color
    //SpacetimeColor의 enum에서 색상을 가져온다.
    UINavigationBar.appearance().titleTextAttributes = [
      .foregroundColor: SpacetimeColor.navigationBarContent.color,
//      .font: UIFont.spc_bold(size: .normal),
      .font: SpacetimeFont.bold.of(size: .normal),
      //SpacetimeFonts의 enum에서 폰트를 가져온다.
    ]
    
    UIBarButtonItem.appearance().tintColor = SpacetimeColor.navigationBarContent.color
    UIBarButtonItem.appearance().setTitleTextAttributes([
      .font: SpacetimeFont.standard.of(size: .medium),
    ], for: .normal)
  }
}
