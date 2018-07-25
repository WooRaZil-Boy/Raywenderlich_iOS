//
//  CatDetailViewController.swift
//  Catstagram
//
//  Created by Jerry Beers on 1/9/18.
//  Copyright © 2018 Luke Parham. All rights reserved.
//

import UIKit

class CatDetailViewController: UIViewController {
  var keyboardShowNotification: NSObjectProtocol?
  var keyboardHideNotification: NSObjectProtocol?

  override func viewDidLoad() {
    super.viewDidLoad()
    keyboardShowNotification = NotificationCenter.default.addObserver(forName: .UIKeyboardWillShow, object: nil, queue: OperationQueue.main) { (notification) in
      self.adjustViewForKeyboard(notification: notification)
    }
    keyboardHideNotification = NotificationCenter.default.addObserver(forName: .UIKeyboardWillHide, object: nil, queue: OperationQueue.main) { (notification) in
      self.adjustViewForKeyboard(notification: notification)
    }
  }

  @objc private func adjustViewForKeyboard(notification: Notification) {
    guard let info = notification.userInfo else { return }
    guard let keyboardFrame = (info[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
    guard let duration = (info[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue else { return }
    guard let superview = self.view.superview else { return }

    let keyRect = superview.convert(keyboardFrame, from: UIApplication.shared.keyWindow)
    var viewRect = self.view.frame
    let difference = viewRect.maxY - keyRect.minY

    UIView.animate(withDuration: duration) {
      viewRect.origin.y -= difference
      self.view.frame = viewRect
    }
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "exitSegue" {
      if let keyboardShowNotification = keyboardShowNotification {
        NotificationCenter.default.removeObserver(keyboardShowNotification)
      }
      if let keyboardHideNotification = keyboardHideNotification {
        NotificationCenter.default.removeObserver(keyboardHideNotification)
      }
      view.endEditing(true)
    }
  }
}
