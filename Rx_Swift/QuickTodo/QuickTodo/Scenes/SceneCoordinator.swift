/*
 * Copyright (c) 2016 Razeware LLC
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
import RxSwift
import RxCocoa

class SceneCoordinator: SceneCoordinatorType {

  fileprivate var window: UIWindow
  fileprivate var currentViewController: UIViewController

  required init(window: UIWindow) {
    self.window = window
    currentViewController = window.rootViewController!
  }

  static func actualViewController(for viewController: UIViewController) -> UIViewController {
    if let navigationController = viewController as? UINavigationController {
      return navigationController.viewControllers.first!
    } else {
      return viewController
    }
  }

  @discardableResult
  func transition(to scene: Scene, type: SceneTransitionType) -> Completable {
    let subject = PublishSubject<Void>()
    let viewController = scene.viewController()
    switch type {
      case .root:
        currentViewController = SceneCoordinator.actualViewController(for: viewController)
        window.rootViewController = viewController
        subject.onCompleted()

      case .push:
        guard let navigationController = currentViewController.navigationController else {
          fatalError("Can't push a view controller without a current navigation controller")
        }
        // one-off subscription to be notified when push complete
        //전환이 완료되면, 콜백과 같이 작동한다.
        _ = navigationController.rx.delegate
          .sentMessage(#selector(UINavigationControllerDelegate.navigationController(_:didShow:animated:)))
          .map { _ in }
          .bind(to: subject)
        navigationController.pushViewController(viewController, animated: true)
        currentViewController = SceneCoordinator.actualViewController(for: viewController)

      case .modal:
        //Modal의 경우, 다음 세 가지 기술 중 하나를 사용하는 것이 좋다.
        //1. 첫째 View Model이 구독할 수 있는 둘째 View Model에서, Observable을 노출한다.
        //   둘째 View Model이 프레젠테이션을 닫을 때 Observable에서 하나 이상의 결과 요소를 emit할 수 있다.
        //2. Variable이나 Subject 같은 Observer 객체를 제시된 View Model에 전달한다.
        //   이 객체는 해당 객체를 사용하여 하나 이상의 결과를 내 보낸다.
        //3. 하나 이상의 Actions를 제시된 View model에 전달하여 적절한 결과와 함께 실행한다.
        currentViewController.present(viewController, animated: true) {
          subject.onCompleted()
        }
        currentViewController = SceneCoordinator.actualViewController(for: viewController)
    }
    return subject.asObservable() //반환
      .take(1)
      .ignoreElements()
    //반환된 Observable은 emit된 요소를 취하지만 전달하지 않고 완료한다.
    //반환된 Observable는 하나의 요소만 take한 후 완료된다. 완료되면 구독을 삭제한다.
    //따라서 반환된 Observable을 구독하지 않으면
    //해당 Subject는 메모리에서 삭제되고 구독도 종료되기 때문에 메모리 누수가 없다.
  }

  @discardableResult
  func pop(animated: Bool) -> Completable {
    let subject = PublishSubject<Void>()
    if let presenter = currentViewController.presentingViewController {
      // dismiss a modal controller
      currentViewController.dismiss(animated: animated) {
        self.currentViewController = SceneCoordinator.actualViewController(for: presenter)
        subject.onCompleted()
      }
    } else if let navigationController = currentViewController.navigationController {
      // navigate up the stack
      // one-off subscription to be notified when pop complete
      _ = navigationController.rx.delegate
        .sentMessage(#selector(UINavigationControllerDelegate.navigationController(_:didShow:animated:)))
        .map { _ in }
        .bind(to: subject)
      guard navigationController.popViewController(animated: animated) != nil else {
        fatalError("can't navigate back from \(currentViewController)")
      }
      currentViewController = SceneCoordinator.actualViewController(for: navigationController.viewControllers.last!)
    } else {
      fatalError("Not a modal, no navigation controller: can't navigate back from \(currentViewController)")
    }
    return subject.asObservable()
      .take(1)
      .ignoreElements()
  }
}

//Scene coordinator는 Scene 간의 전환을 처리한다.
//각 View Model은 coordinator를 알고 있으며 Scene을 push하도록 요청한다.

//MVVM 패턴에서 Scene 전환 로직에 대한 효율적인 해결책은 다음과 같다.
//1. View Model은 다음 Scene에 대한 View Model을 생성한다.
//2. 첫 번째 View Model은 Scene coordinator를 호출하여, 다음 Scene로 전환을 시작한다.
//3. Scene coordinator는 Scenes enum extenstion을 이용해 View Controller를 인스턴스화 한다.
//4. 인스턴스화된 View Controller는 전환할 View Model를 바인딩한다.
//5. 마지막으로 전환할 View Controller를 표시한다.
//p.410. 이 구조를 사용하면, View Model을 사용하는 View Controller에서 View Model을 완전히 격리할 수 있다.
//또한 다음 View Controller를 세부 정보에서부터 격리할 수 있다.

//Scene를 Modal로 표현할때 coordinator가 어떤 View Controller가 가장 위에 있는지 확인하려면
//transition(to:type:)과 pop()을 이용해야 한다. segues를 사용해선 안 된다.
