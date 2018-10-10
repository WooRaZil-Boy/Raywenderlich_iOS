/**
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
 * Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
 * distribute, sublicense, create a derivative work, and/or sell copies of the
 * Software in any work that is designed, intended, or marketed for pedagogical or
 * instructional purposes related to programming, coding, application development,
 * or information technology.  Permission for such use, copying, modification,
 * merger, publication, distribution, sublicensing, creation of derivative works,
 * or sale is expressly withheld.
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

class NewAccountViewController: UIViewController {
  
  @IBOutlet weak var userNameTextField: UITextField!
  @IBOutlet weak var passwordTextField: UITextField!
  @IBOutlet weak var continueButton: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    enableLoginButton(false)
  }
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  //sends the user back to the login screen after registration
  @IBAction func login(_ sender: Any) {
    performSegue(withIdentifier: "Registered", sender: self)
  }
  
  private func validate(username: String?, password: String?) -> Bool {
  //performs some simple validation; your real app should do more!
    guard let username = username,
      let password = password,
      username.count >= 5,
      password.count >= 5 else {
        return false
    }
    return true
  }
  
  private func enableLoginButton(_ enable: Bool) {
    continueButton.isEnabled = enable
    continueButton.alpha = enable ? 1.0 : 0.5
  }
  
  @IBAction func accountCreated(segue: UIStoryboardSegue) {
    dismiss(animated: true, completion: nil)
  }
}

//This extension helps deal with the first responders for the text fields as well as performing validation
extension NewAccountViewController: UITextFieldDelegate {
  
  func textField(_ textField: UITextField,
                 shouldChangeCharactersIn range: NSRange,
                 replacementString string: String) -> Bool {
    
    var usernameText = userNameTextField.text
    var passwordText = passwordTextField.text
    if let text = textField.text {
      
      let proposed = (text as NSString)
        .replacingCharacters(in: range, with: string)
      if textField == userNameTextField {
        usernameText = proposed
      } else {
        passwordText = proposed
      }
    }

    let isValid = validate(username: usernameText,
                           password: passwordText)
    enableLoginButton(isValid)
    return true
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField == userNameTextField {
      passwordTextField.becomeFirstResponder()
    } else {
      passwordTextField.resignFirstResponder()
      if validate(username: userNameTextField.text,
                  password: passwordTextField.text) {
        login(continueButton)
      }
    }
    return false
  }
}
