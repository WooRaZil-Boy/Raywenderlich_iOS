/**
 * Copyright (c) 2017 Razeware LLC
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

//iOS는 두 가지의 Autofill을 지원한다.
//1. device의 iCloud keychain 에 저장된 password를 link로 가져온다. 유저는 저장된 비밀번호 중 선택한다.
//2. domain 기반으로 password를 저장한다. 유저는 따로 할 일 없이 자동으로 autofill이 된다.
//이 프로젝트에서는 1번을 사용한다.




//Main.storyboard 에서, ViewController의 username textField를 선택한다.
//Attribute inspector의 Text Input Traits 섹션에서 Content Type를 Username으로 선택한다.
//같은 방식으로 password textField는 Content Type를 Password로 선택한다.
//이는 해당 textField 선택시 키보드 타입을 바꿔준다.

//그후 device의 settings - Safari - AutoFill - Names and Passwords (iOS 11)
//device의 settings - Passwords & Accounts - Website & App Passwords - + 으로 추가해 준다(iOS 12).
//https://appmanager-rw.herokuapp.com

//device의 settings - Passwords & Accounts - AutoFill Passwords 를 on으로 하면,
//이후 앱에서 키보드가 토글 될 때 password 버튼이 보이며 이를 터치해 자동 입력해 주면 된다.

//Simulator - Hardware - Keyboard 에서 키보드를 토클할 수 있다(⌘ + K).

