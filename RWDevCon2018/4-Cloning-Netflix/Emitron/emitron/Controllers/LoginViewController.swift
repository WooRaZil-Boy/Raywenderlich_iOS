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
import Layout

class LoginViewController: UIViewController, LayoutLoading {
  typealias DependencyProvider = GuardpostProvider
  private let provider: DependencyProvider
  
  private lazy var guardpost = provider.guardpost
  private let loginSuccessHandler: (SingleSignOnUser) -> ()
  
  init(dependencyProvider: DependencyProvider, loginSuccessHandler: @escaping (SingleSignOnUser) -> ()) {
    self.provider = dependencyProvider
    self.loginSuccessHandler = loginSuccessHandler
    super.init(nibName: .none, bundle: .none)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension LoginViewController {
  @IBAction func handleLoginPressed() {
    guardpost.logout()
    guardpost.login { (result) in
      switch result {
      case .success(let user):
        self.loginSuccessHandler(user)
      case .failure(let error):
        print(error)
      }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    loadLayout(named: "Login.xml", constants: GLOBAL_CONSTANTS.dictionary)
  }
}
