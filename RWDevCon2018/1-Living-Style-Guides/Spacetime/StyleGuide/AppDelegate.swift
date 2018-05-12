//
//  AppDelegate.swift
//  StyleGuide
//
//  Created by Ellen Shapiro on 3/25/18.
//  Copyright © 2018 RayWenderlich.com. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
}

//target scheme를 StyleGuide로 바꿀 수 있다.
//앱 설정 - StyleGuide - Build Phases - Target Dependencies에서 SpacetimeUI를 추가해 준다.
//그래야 StyleGuide를 빌드할 때 SpacetimeUI 라이브러리에서 발생한 변경 사항이 해당 빌드에 적용된다.
//적용해 주면, StyleGuide이 빌드될 때, SpacetimeUI도 함께 빌드된다.
//Link Binary With Libraries에서 바이너리에도 추가해 준다.
