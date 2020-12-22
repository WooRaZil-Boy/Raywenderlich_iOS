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

import SwiftUI

class NoteData: ObservableObject {
  let passwordKey = "Password"
  let textKey = "StoredText"

  @Published var noteText: String {
    didSet {
      UserDefaults.standard.set(noteText, forKey: textKey)
    }
  }

  var isPasswordBlank: Bool {
    getStoredPassword() == ""
  }

  func getStoredPassword() -> String {
//    UserDefaults.standard.string(forKey: passwordKey) ?? ""
    //keychain으로 변경
    
    let kcw = KeychainWrapper()
    if let password = try? kcw.getGenericPasswordFor(
      account: "RWQuickNote",
      service: "unlockPassword"
    ) {
      return password
    }
    
    return ""
  }

  func updateStoredPassword(_ password: String) {
//    UserDefaults.standard.set(password, forKey: passwordKey)
    //keychain으로 변경
    
    let kcw = KeychainWrapper()
    do {
      try kcw.storeGenericPasswordFor(
        account: "RWQuickNote",
        service: "unlockPassword",
        password: password)
    } catch let error as KeychainWrapperError {
      print("Exception setting password: \(error.message ?? "no message")")
    } catch {
      print("An error occurred setting the password.")
    }
  }

  func validatePassword(_ password: String) -> Bool {
    let currentPassword = getStoredPassword()
    return password == currentPassword
  }

  func changePassword(currentPassword: String, newPassword: String) -> Bool {
    guard validatePassword(currentPassword) == true else { return false }
    updateStoredPassword(newPassword)
    return true
  }

  init() {
    noteText = UserDefaults.standard.string(forKey: textKey) ?? ""
  }
}

