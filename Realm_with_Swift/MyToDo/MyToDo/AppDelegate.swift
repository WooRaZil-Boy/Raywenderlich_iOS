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
//    SyncManager.shared.logLevel = .off
//    initializeRealm()
//    print(Realm.Configuration.defaultConfiguration.fileURL!)
    
    setupRealm()
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

  private func setupRealm() {
    SyncManager.shared.logLevel = .off
    
    if !TodoRealm.plain.fileExists && !TodoRealm.encrypted.fileExists {
        //일반 Realm 파일이나(plain), 암호화된 Realm 파일(encrypted)이 없으면 (앱을 처음 시작하면)
        try! FileManager.default.copyItem(at: TodoRealm.bundle.url, to: TodoRealm.plain.url)
        //bundle 파일로 시작. bundle 파일을 plain의 경로로 복사해 준다.
        //Realm 파일도 보통의 파일처럼, FileManager에서 처리해 주면 된다.
    }

  }
}

// MARK: - Enumeration of all Realm file locations on disk

enum TodoRealm { //이 앱에서 사용할 3개의 Realm 파일에 대한 경로
  case bundle //bundled.realm 번들
  case plain //암호화되지 않은 todo Realm. mytodo.realm 파일 사용
  case encrypted //암호화된 todo Realm. mytodoenc.realm 파일 사용
    //일반 Realm 파일이나(plain), 암호화된 Realm 파일(encrypted)이 있는 지 체크하고,
    //없으면 번들 파일을 Dicuments 폴더로 복사한다.

  var url: URL {
    do {
      switch self {
      case .bundle: return try Path.inBundle("bundled.realm")
      case .plain: return try Path.inDocuments("mytodo.realm")
      case .encrypted: return try Path.inDocuments("mytodoenc.realm")
      }
    } catch let err {
      fatalError("Failed finding expected path: \(err)")
    }
  }

  var fileExists: Bool {
    return FileManager.default.fileExists(atPath: path)
  }

  var path: String {
    return url.path
  }
}

//이 프로젝트는 현재 Documents 폴더에 있는 mytodo.realm를 사용한다.
//앱의 최종 로직은 p.149

//미리 Realm의 번들(여기서는 bundled.realm)을 앱에 첨부하여, 미리 파일들을 채워넣을 수 있다.
//ex. 사용자가 수정할 데이터 세트가 필요하거나, 새 앱 버전을 출시할 때 등.
//번들을 앱의 처음 시작점으로 사용할 수 있다.

