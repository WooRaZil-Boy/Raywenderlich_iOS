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
import RealmSwift

struct RealmProvider {
  struct ServerConfig {
    static let host = "refined-plastic-salad.us1.cloud.realm.io" //Realm Flatform의 인스턴스 경로
    static let user = "chatuser"
    static let password = "chatuser"
  }

  let configuration: Realm.Configuration

  private init(config: Realm.Configuration) {
    configuration = config
  }

  func realm(callback: @escaping (Realm?, Error?) -> Void) {
    Realm.asyncOpen(configuration: configuration, callback: callback)
    //원격 Realm을 비동기로 연다.
  }

  // MARK: - Chat realm
  private static let chatConfig = SyncConfiguration.automatic()
  //SyncConfiguration.automatic()는 현재 연결된 서버의 기본 DB를 가리키는
  //미리 구성된 Realm.Configuration를 반환한다.
  
  public static var chat: RealmProvider = {
    return RealmProvider(config: chatConfig)
  }()
}


