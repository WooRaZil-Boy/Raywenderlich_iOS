/// Copyright (c) 2020 Razeware LLC
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
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit
import AuthenticationServices

class LoginViewController: UIViewController {
  var webAuthenticationSession: ASWebAuthenticationSession?

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    getGitHubIdentity()
  }

  func getGitHubIdentity() {
    var authorizeURLComponents = URLComponents(string: GitHubConstants.authorizeURL)
    authorizeURLComponents?.queryItems = [
      URLQueryItem(name: "client_id", value: GitHubConstants.clientID),
      URLQueryItem(name: "scope", value: GitHubConstants.scope)
    ]
    guard let authorizeURL = authorizeURLComponents?.url else {
      return
    }
    webAuthenticationSession = ASWebAuthenticationSession.init(
      url: authorizeURL,
      callbackURLScheme: GitHubConstants.redirectURI) { (callBack: URL?, error: Error?) in
      guard
        error == nil,
        let successURL = callBack
      else {
        return
      }
      //Retrieve access code
      guard let accessCode = URLComponents(string: (successURL.absoluteString))?
        .queryItems?.first(where: { $0.name == "code" }) else {
        return
      }
      guard let value = accessCode.value else {
        return
      }
      print(value)
      //TODO: Call to fetch access token will be added here
      GitAPIManager.shared.fetchAccessToken(accessCode: value) { [self] isSuccess in
        if !isSuccess {
          print("Error fetching access token")
        }
        navigationController?.popViewController(animated: true)
      }
    }
    webAuthenticationSession?.presentationContextProvider = self
    webAuthenticationSession?.start()
  }
}

// MARK: - ASWebAuthenticationPresentationContextProviding
extension LoginViewController: ASWebAuthenticationPresentationContextProviding {
  func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
    return view.window ?? ASPresentationAnchor()
  }
}
