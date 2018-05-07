/// Copyright (c) 2018 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import Foundation
import UIKit

struct WeakConstraint {
  public typealias Callback = () -> Void

  fileprivate weak var constraint: NSLayoutConstraint?
  fileprivate let callback: Callback
  fileprivate init(_ constraint: NSLayoutConstraint, callback: @escaping Callback) {
    self.constraint = constraint
    self.callback = callback
  }
}

private var constraints = [WeakConstraint]()

extension UIViewController {
  func constrainToKeyboardTop(constraint: NSLayoutConstraint, callback: @escaping WeakConstraint.Callback) {
    constraints = [WeakConstraint(constraint, callback: callback)] + constraints.filter { $0.constraint != nil }

    NotificationCenter.default.addObserver(self,
                                           selector: #selector(keyboardNotification),
                                           name: Notification.Name.UIKeyboardDidShow,
                                           object: nil)
  }

  @objc func keyboardNotification(notification: Notification) {
    guard let userInfo = notification.userInfo,
          let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
          let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue,
          let animationCurveRaw = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber else { return }

    let curve = UIViewAnimationOptions(rawValue: animationCurveRaw.uintValue)

    for constraint in constraints.filter({ $0.constraint != nil })
                                 .map({ $0.constraint! }) {
      if endFrame.origin.y >= UIScreen.main.bounds.size.height {
        constraint.constant = 0.0
      } else {
        constraint.constant = endFrame.size.height - view.safeAreaInsets.bottom
      }
    }

    UIView.animate(withDuration: duration,
                   delay: 0,
                   options: [curve],
                   animations: {
                    self.view.layoutIfNeeded()
                   },
                   completion: {_ in
                    constraints.forEach { $0.callback() }
                   })
  }

}
