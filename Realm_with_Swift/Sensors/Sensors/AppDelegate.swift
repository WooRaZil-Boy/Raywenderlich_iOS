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
    RealmProvider.resetSensorData()
    return true
  }
}

//Realm을 사용하면 스레드의 병목 현상을 줄일 수 있다. DB에 대한 동시 액세스를 수행 할 수있는 통합 멀티 스레딩이 있다.




//Realm threading
//Realm을 사용하면, 여러 스레드에서 동일한 DB로 동시에 작업할 수 있다.
//즉, Realm에 액세스할 스레드가 무엇이든 관계없이 데이터 무결성을 보장하기 위한 추가 조치없이 항상 최신 데이터를 읽고 쓴다.
//CoreData 등의 다른 DB와 달리 다중 스레드 작업 시 명시적으로 다른 컨텍스트를 구성하거나 DB를 수동으로 복제할 필요 없다.
//Realm이 뒤에서 알아서 처리하므로, 모든 스레드에서 객체를 읽고 쓸 수 있다.

//Working with Realm on the main thread
//tableView에서 목록을 표시하는 것 같은 간단한 쿼리의 경우 일반적으로 메인스레드를 사용한다.
//데이터의 크기에 따라 다르지만, 일반적으로 큰 성능 저하는 없다.
//Realm 객체를 직접 사용해 앱의 UI를 업데이트할 수 있으므로, 메인 스레드에서 데이터를 읽으면 코드가 간단해 진다.
//ViewController의 모든 Life cycle 메서드와 대부분의 UIKit delegate는 메인 스레드에서 호출 되므로
//viewDidLoad(), viewWillAppear(_), tableView(_:cellForRowAt:) 등에서 바로 UI 업데이트 할 수 있다.
//업데이트의 경우에도, 일반적인 크기의 데이터 집합에서 기본 키로 개체를 가져와 속성 일부를 업데이트하면,
//성능의 큰 저하 없이, 메인 스레드에서 안전하게 수행할 수 있다.

//Working with Realm in a background thread
//Realm의 멀티 스레딩 모델 덕분에 앱의 모든 스레드에서 DB를 안전하고 효율적으로 작업할 수 있다.
//UI 용도로 필요하지 않은 데이터를 작업하는 경우, 백 그라운드 큐에서 수행하여, 메인 스레드의 부하를 줄인다.
//ex. 주기적으로 서버에서 JSON을 가져와 결과를 DB에 저장하는 앱에서 JSON이 웹의 이미지를 참조하는 경우,
//백 그라운드에서 JSON을 가져와야 한다. p.198
//• 메인 스레드의 TableView에 List item을 표시한다.
//• 가져온 JSON을 주기적으로 Swift 객체로 변환하고, 백 그라운드 스레드에 유지한다.
//• 참조된 이미지를 가져와, 디스크에 저장하고, 백 그라운드 스레드에 다운로드할 때, 로컬 파일 경로로 DB를 업데이트한다.
//새 스레드에서 Realm 파일을 열면, DB의 모든 변경사항이 최신으로 포함된다. 각 실행 루프가 시작될 때 현재 스레드에서
//접근할 수 있는 Realm의 스냅 샷은 자동으로 새로 고쳐지고, 다른 스레드에서 commit된 모든 변경 사항을 포함한다.
//Realm.write(_) 혹은 Realm.commitWrite()이 성공적으로 호출된 이후에도 Realm이 새로고쳐진다.
//성능 향상을 위해 수동으로 새로고침 되도록 중지할 수도 있다. autorefresh 속성을 false로 하면 된다.

//Moving objects between threads
//Realm의 객체는 스레드를 통과해 사용할 수 없다. 응용 프로그램의 모든 스레드에서 Realm 파일을 읽고 쓸 수 있지만,
//하나의 스레드에서 Realm 인스턴스를 생성할 수 없고, 다른 스레드에서 동일한 인스턴스를 사용할 수 없다.
//객체가 디스크에서 지속되거나 fetching하게 되면, 해당 객체의 참조는 해당 객체가 시작된 스레드에만 국한된다.
//Realm 인스턴스나 다른 스레드에서 가져온 객체를 사용하면 즉시 충돌이 발생한다.
//따라서 새로운 Realm을 초기화하여 필요한 현재 스레드에 대한 새 인스턴스를 얻는 것이 가장 좋다.
//초기화는 매번 Realm 인스턴스를 새로 만들지 않고 필요할 때마다 캐시된 인스턴스를 반환한다.
//스레드를 넘어 객체를 전달해야 할 때 두 가지의 옵셥이 있다.
//• 스레드 간에 객체의 기본 키를 전달하고 다른 스레드의 스레드 관련 Realm에서 객체를 다시 가져온다.
//  기본 키는 문자열이나 숫자이므로, 스레드를 통과하는 것이 안전하다.
//• Realm의 ThreadSafeReference 클래스를 사용한다. 이 클래스는 스레드 사이에서 자유롭게 전달되고, 대상 스레드에서
//  사용할 수 있는 thread-safe reference를 만든다.
//  let ref = ThreadSafeReference(to: myRealmObject)로 참조를 만들고
//  let myRealmobject = realm.resolve(ref)를 사용하여 다른 스레드에서 사용한다.
//어떤 방법을 사용하든, 스레드 간에 객체를 이동하려면 추가적인 작업이 필요하다.
//ThreadSafeReference를 사용할 때는 thread-safe reference를 작성하면, 해결할 때까지 Realm을 유지한 채로
//할당을 취소할 수 없다. 따라서 짧은 수명 주기를 가질 때 ThreadSafeReferences를 사용하는 것이 좋다.
