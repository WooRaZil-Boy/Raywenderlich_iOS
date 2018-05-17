/*
 * Copyright (c) 2018 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import GuardpostKit

class DependencyContainer: GuardpostProvider, StoreProvider, UserManagerProvider, VideoPlayerProvider, SyncEngineProvider {
  let window: UIWindow
  let guardpost = Guardpost(baseUrl: ProcessInfo.processInfo.environment["GUARDPOST_BASE_URL"]!,
                            urlScheme: "com.razeware.rwdevcon2018.emitron://",
                            ssoSecret: ProcessInfo.processInfo.environment["SSO_SECRET"]!)
  
  private(set) lazy var store = Betamax()
  private(set) lazy var userManager = UserManager(provider: self)
  private(set) lazy var videoPlayer = VideoPlayer(dependencyProvider: self)
  private(set) lazy var syncEngine = SyncEngine(dependencyProvider: self)
  
  init(window: UIWindow) {
    self.window = window
  }
}

extension DependencyContainer: ViewControllerProvider {
  func createRootViewController() -> UIViewController {
    let tabBarController = UITabBarController()
    tabBarController.viewControllers = [
      createCoursesViewController(),
      createScreencastsViewController(),
      createSettingsViewController()
    ]
    return tabBarController
  }
  
  func createLoginViewController(successHandler: @escaping (SingleSignOnUser) -> ()) -> LoginViewController {
    return LoginViewController(dependencyProvider: self, loginSuccessHandler: successHandler)
  }
  
  func createCoursesViewController() -> UIViewController {
    let vc = CoursesViewController(dependencyProvider: self)
    let navController = UINavigationController(rootViewController: vc)
    navController.tabBarItem.image = #imageLiteral(resourceName: "courses-icon")
    navController.tabBarItem.largeContentSizeImage = #imageLiteral(resourceName: "courses-icon")
    return navController
  }
  
  func createScreencastsViewController() -> UIViewController {
    let vc = ScreencastsViewController(dependencyProvider: self)
    let navController = UINavigationController(rootViewController: vc)
    navController.tabBarItem.image = #imageLiteral(resourceName: "screencast-icon")
    navController.tabBarItem.largeContentSizeImage = #imageLiteral(resourceName: "screencast-icon")
    return navController
  }
  
  func createViewController(for course: Collection) -> CourseViewController {
    return CourseViewController(dependencyProvider: self, collection: course)
  }
  
  func createViewController(for video: Video) -> VideoViewController {
    return VideoViewController(dependencyProvider: self, video: video)
  }
  
  func createSettingsViewController() -> SettingsViewController {
    let vc = SettingsViewController(provider: self)
    vc.tabBarItem.image = #imageLiteral(resourceName: "settings-icon")
    vc.tabBarItem.largeContentSizeImage = #imageLiteral(resourceName: "settings-icon")
    return vc
  }
}

extension DependencyContainer: NavigationProvider {
  func setRoot(viewController: UIViewController) {
    guard let currentRootVC = self.window.rootViewController else {
      self.window.rootViewController = viewController
      return
    }
    UIView.transition(from: currentRootVC.view, to: viewController.view, duration: 0.5, options: .transitionFlipFromRight) { (finished) in
      self.window.rootViewController = viewController
    }
  }
  
  func present(_ viewController: UIViewController, animated: Bool, completion: @escaping () -> ()) {
    window.rootViewController?.present(viewController, animated: animated, completion: completion)
  }
  
  func showError(title: String, description: String) {
    let alert = UIAlertController(title: title, message: description, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: .none))
    present(alert, animated: true, completion: {})
  }
}

extension DependencyContainer: DataSourceProvider {
  func createCourseCategoryShelfDataSource(collectionView: UICollectionView, selectionDelegate: ShelfSelectionDelegate) -> CourseCategoryShelfDataSource {
    return CourseCategoryShelfDataSource(dependencyProvider: self, collectionView: collectionView, selectionDelegate: selectionDelegate)
  }
}
