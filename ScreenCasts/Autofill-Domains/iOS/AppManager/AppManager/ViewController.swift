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
//이 프로젝트에서는 2번을 사용한다.

//vapor와 heroku가 필요하다.

//Capabilities에서 Associated Domains를 on 한다. 서버 주소가 필요하다.
//Server App(Vapor)에서 Public - .well-known - apple-app-site-association을 선택한다.
//"Team Identifier.App Bundle ID"에 해당 앱의 정보를 입력한다.
//heroku에 commit 후 push한다.
//해당 heroku 페이지에 접속해 username과 password를 저장한다(실제 앱에서는 로그인 할 때 API로 처리한다).
//다음에 앱에서 로그인 할 때 저장된 username과 password로 autofill할 수 있다.

