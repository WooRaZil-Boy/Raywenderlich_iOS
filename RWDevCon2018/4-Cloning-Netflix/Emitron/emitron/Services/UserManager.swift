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

import Foundation
import UIKit
import GuardpostKit

class UserManager {
  typealias DependencyProvider = GuardpostProvider & StoreProvider & NavigationProvider & ViewControllerProvider & SyncEngineProvider
  private let provider: DependencyProvider
  
  private lazy var betamax = provider.store
  private lazy var guardpost = provider.guardpost
  private lazy var syncEngine = provider.syncEngine
  
  init(provider: DependencyProvider) {
    self.provider = provider
  }
  
  var currentUser: SingleSignOnUser? {
    return guardpost.currentUser
  }
  
  var isLoggedIn: Bool {
    return currentUser != .none
  }
  
  func logout() {
    DispatchQueue.main.async {
      self.showLoginVC()
      self.syncEngine.stopSync()
      self.guardpost.logout()
      self.betamax.emptyCache()
    }
  }
  
  func prepareInitialViewController() {
    if isLoggedIn {
      showRootVC(currentUser!)
    } else {
      showLoginVC()
    }
  }
  
  private func showRootVC(_ user: SingleSignOnUser) {
    betamax.token = user.token
    syncEngine.startSync(for: user.externalId)
    
    let rootViewController = provider.createRootViewController()
    provider.setRoot(viewController: rootViewController)
  }
  
  private func showLoginVC() {
    let loginViewController = provider.createLoginViewController(successHandler: { [weak self] (user) in
      DispatchQueue.main.async { [weak self] in
        self?.showRootVC(user)
      }
    })
    provider.setRoot(viewController: loginViewController)
  }
}
