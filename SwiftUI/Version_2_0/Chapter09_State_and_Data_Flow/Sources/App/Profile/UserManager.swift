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

import Combine
import SwiftUI
import Foundation

final class UserManager: ObservableObject {
  //class는 ObservableObject를 준수하므로 publisher가 된다.
  @Published
  var profile: Profile = Profile()
  
  @Published
  var settings: Settings = Settings()
  //@Published attribute로 선언된 두 개의 속성을 정의한다.
  //이러한 속성은 view의 state property처럼 작동한다.
  
  @Published
  var isRegistered: Bool
  
//  var isRegistered: Bool { //computed property
//      //computed property은 publish된 다른 속성을 참조하는 경우, publish된 권한을 상속한다.
//      //즉, view에서 사용하면 computed value가 변경될 때 UI 업데이트를 triggers한다.
//      return profile.name.isEmpty == false
//  }
  
  init() {
    isRegistered = false
  }
  
  init(name: String) {
    isRegistered = name.isEmpty == false
    self.profile.name = name
  }
  
  func setRegistered() {
    isRegistered = profile.name.isEmpty == false
  }
  
  func persistProfile() {
    if settings.rememberUser {
      UserDefaults.standard.set(try? PropertyListEncoder().encode(profile), forKey: "user-profile")
    }
  }
  
  func persistSettings() {
    UserDefaults.standard.set(try? PropertyListEncoder().encode(settings), forKey: "user-settings")
  }
  
  func load() {
    if let data = UserDefaults.standard.value(forKey: "user-profile") as? Data {
      if let profile = try? PropertyListDecoder().decode(Profile.self, from: data) {
        self.profile = profile
      }
    }
    setRegistered()
    
    if let data = UserDefaults.standard.value(forKey: "user-settings") as? Data {
      if let settings = try? PropertyListDecoder().decode(Settings.self, from: data) {
        self.settings = settings
      }
    }
  }
  
  func clear() {
    UserDefaults.standard.removeObject(forKey: "user-profile")
  }
  
  func isUserNameValid() -> Bool {
    return profile.name.count >= 3
  }
}
