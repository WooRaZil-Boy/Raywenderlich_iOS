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

class ViewController: UIViewController {
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    if !LoginStatus.loggedIn {
      performSegue(withIdentifier: "ShowLogin", sender: self)
    }
  }
  
  @IBAction func loggedIn(segue: UIStoryboardSegue) {
    dismiss(animated: true, completion: nil)
  }
  
  @IBAction func logout(_ sender: Any) {
    LoginStatus.loggedIn = false
    performSegue(withIdentifier: "ShowLogin", sender: self)
  }
  
}

//Password Auto Fill은 iOS 11에도 있었지만, iOS 12에서는 더 쉽게 구현할 수 있게 되었다.
//strong password generation 과 SMS authentication이 추가 되기도 했다.




//Main.storyboard 에서, NewAccountViewController의 username textField를 선택한다.
//Attribute inspector의 Text Input Traits 섹션에서 Content Type를 Username으로 선택한다.
//이는 해당 textField 선택시 키보드 타입을 바꿔준다.




//Main.storyboard 에서, NewAccountViewController의 password textField를 선택한다.
//iOS 12에서는 New password라는 Content Type이 추가 되었는데, password textField 에 이를 적용하면, strong password가 적용된다.
//New password로 Type을 설정하면, 자동으로 iCloud keychain에 저장이 되어 다음에 자동 로그인으로 사용할 수 있다.
//device의 settings - Passwords & Accounts - AutoFill Passwords 를 on으로 설정해 두어야 한다.




//Main.storyboard 에서, PasscodeViewController의 passcode textField를 선택한다.
//iOS 12에서는 One Time Code라는 Content Type이 추가 되었는데, passcode textField 에 이를 적용한다.
//이를 설정하면, iOS는 User의 device로 인증에 필요한 코드를 담은 SMS를 수신할 시 자동으로 채워진다. (실제 device에서 실행해야 한다).
//이를 사용해 Two-factor authentication을 구현할 수 있다.




//Simulator - Hardware - Keyboard 에서 키보드를 토클할 수 있다(⌘ + K).

