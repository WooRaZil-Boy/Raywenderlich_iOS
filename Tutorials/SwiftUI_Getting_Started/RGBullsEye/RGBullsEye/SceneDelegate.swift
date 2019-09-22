//
//  SceneDelegate.swift
//  RGBullsEye
//
//  Created by 근성가이 on 22/09/2019.
//  Copyright © 2019 근성가이. All rights reserved.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).

        // Create the SwiftUI view that provides the window contents.
        let contentView = ContentView(rGuess: 0.5, gGuess: 0.5, bGuess: 0.5)

        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: contentView)
            //SwiftUI에서만 사용하는 것은 아니지만, SwiftUI를 사용할 경우, 기본적으로 추가된다.
            //UIHostingController는 SwiftUI View(여기서는 ContentView)를 생성한다.
            
            //UIHostingController를 사용하면, SwiftUI View를 기존의 앱에 통합 할 수 있다.
            //StoryBoard에 Hosting View Controller를 추가하고, UIViewController에서 segue를 만든다.
            //그 후, segue에서 ViewController로 Control-drag를 사용해 hosting controller의 rootView(SwiftUI View)를 지정하는 IBSegueAction를 만든다.
            
            self.window = window
            window.makeKeyAndVisible()
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

//Entering the New World of SwiftUI
//프로젝트를 생성하면, AppDelegate.swift 외에, SceneDelegate.swift도 생성된다.
//SceneDelegate는 window를 포함하고 있다.

