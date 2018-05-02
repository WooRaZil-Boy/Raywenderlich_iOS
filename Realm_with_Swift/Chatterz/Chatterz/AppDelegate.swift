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

import UIKit
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  private let api = ChatAPI() //API 생성

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

    // Connect to mocked API
    api.connect { [unowned self] newMessages in //서버에 연결(dummy) //JSON 형식으로 데이터를 가져온다.
      self.persist(messages: newMessages) //API에서 반환한 메시지 전달
    }

    return true
  }

  private func persist(messages: [(String, String)]) {
    // Persist a list of messages to database
    print(messages)
    
    SyncManager.shared.logLevel = .off //모든 동기화 관련 디버그 메시지를 끈다.
    
    DispatchQueue.global(qos: .background).async {
        //JSON 객체 변환 등과 같이 과중한 작업을 수행하는 동안 앱의 UI를 처리하는 메인 스레드를 차단하지 않으려면
        //백 그라운드 스레드로 전환해서 작업해야 한다.
        let objects = messages.map { message in
            return Message(from: message.0, text: message.1) //Message 객체 생성
        }
        
        let realm = try! Realm()
        
        try! realm.write { //쓰기 트랜잭션
            realm.add(objects)
        }
    }
  }
}

//리액티브 시스템은 변경 사항에 대응하고, 메시지 기반 워크 플로우를 사용하며, 확장할 수 있다.
//Realm을 사용하면 이 기능을 쉽게 구현할 수 있다.
