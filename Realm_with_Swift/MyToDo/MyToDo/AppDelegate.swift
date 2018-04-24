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

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    SyncManager.shared.logLevel = .off
    
    initializeRealm()
    
    print(Realm.Configuration.defaultConfiguration.fileURL!)

    return true
  }

  private func initializeRealm() { //테스트 데이터 만들기
    let realm = try! Realm() //여러 Realm 객체를 생성하는 것에 대해 걱정할 필요 없다.
    //Realm 객체를 생성하면, 단순히 디스크 파일에 대한 접근을 할 수 있다. 이것은 앱 전체에 공유되고,
    //동일한 스레드에서 사용할 때 마다 반환된다. 따라서 데이터를 복제하지 않고, 추가 메모리를 사용하지 않는다.
    //이 앱의 모든 코드는 동일한 Realm 인스턴스와 디스크의 동일한 파일에서 작동한다. p.37
    guard realm.isEmpty else { return } //realm DB가 비어있는 지 확인
    //비어 있지 않으면 test 데이터가 필요없으므로 종료한다.
    
    try! realm.write { //Dummy 데이터 삽입
      //write로 트랜젝션을 시작한다.
      realm.add(ToDoItem("Buy Milk")) //객체 추가
      realm.add(ToDoItem("Finish Book"))
    }
  }
}
