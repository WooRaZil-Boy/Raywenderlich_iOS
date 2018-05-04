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

class ToDoListController: UITableViewController {
  private var items: Results<ToDoItem>? //Realm에서 fetch해 온 결과. 실패하거나 없을 수 있으므로 optional
  private var itemsToken: NotificationToken? //변경 알림 구독에 대한 참조를 유지

  // MARK: - View controller life-cycle

  override func viewDidLoad() {
    super.viewDidLoad()
    items = ToDoItem.all() //Realm에서 fetch
    
    if Realm.Configuration.defaultConfiguration.encryptionKey != nil {
      navigationItem.leftBarButtonItem = nil
    }
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    // Set up a changes observer and act on changes to the Realm data
    itemsToken = items!.observe { [weak tableView] changes in //Realm의 observe 메서드
        //observe 해 주면, 콜렉션(Results)이 변경될 때 마다 Realm이 블록을 호출해 실행한다.
        //클로저는 구독을 생성한 스레드에서 호출된다. viewWillAppear(_)에서 구독되므로
        //UI 업데이트를 안전하게 할 수 있다.
      guard let tableView = tableView else { return }

      switch changes {
      case .initial:
        tableView.reloadData()
      case .update(_, let deletions, let insertions, let updates):
        //삭제, 삽입, 업데이트 될 때
        tableView.applyChanges(deletions: deletions, insertions: insertions, updates: updates)
        //해당 부분만 업데이트 해 준다. //helper method
      case .error: break
      }
    }
    //데이터 변경을 업데이트 하는 방법은 tableView를 새로 고치는 방법이 있다.
    //하지만, 이 방법은 리소스가 낭비될 수 있고, 다른 클래스나 백그라운드에서 실행되는 경우 변경 사항을 알기 어렵다.
    //Realm에서는 자체 알림 메커니즘을 통해 독립적으로 데이터를 읽고 쓰면서, 변경사항을 실시간으로 알 수 있다.
    //Realm의 자체 알림 시스템은 DB 코드를 깨끗하게 분리할 수 있다. 알림 시스템에는 두 개의 클래스가 있다. p.41
    //• Networking class : 백그라운드 큐에서 JSON을 Realm 오브젝트로 유지하는 클래스
    //• View Controller : 불러온 개체를 Collection View에 표시하는 클래스
    //두 클래스는 깔끔하게 분리되어 있다. 하나는 오직 DB에 쓰기만 가능하고, 다른 하나는 오직 읽고, 변화를 관찰한다.
    //이 설정을 사용하면, View Controller를 만들지 않고 DB를 테스트하기도 쉽다.
    //또한, 앱이 오프라인 상태가 되어도, View Controller는 객체가 어떤 작업을 하는 지 신경 쓸 필요 없다.
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)

    // Invalidate the Observer so we don't keep getting updates
    itemsToken?.invalidate() //구독 해제하고 토큰 무효화
  }

  // MARK: - Actions

  @IBAction func addItem() {
    userInputAlert("Add Todo Item") { text in
      ToDoItem.add(text: text) //Realm DB에 추가
    }
  }

  func toggleItem(_ item: ToDoItem) {  //체크 / 언 체크
    item.toggleCompleted()
  }

  func deleteItem(item: ToDoItem) {
    item.delete()
  }

  @IBAction func encryptRealm() {
    showSetPassword()
  }

  // MARK: - Navigation
  func showSetPassword() {
    let list = storyboard!.instantiateViewController(withIdentifier: "SetupViewController") as! SetupViewController
    list.setPassword = true

    UIView.transition(with: view.window!,
                      duration: 0.33,
                      options: .transitionFlipFromRight,
                      animations: {
                        self.view.window!.rootViewController = list
                      },
                      completion: nil)
  }
}

// MARK: - Table Data Source

extension ToDoListController {
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return items?.count ?? 0
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ToDoTableViewCell

    if let item = items?[indexPath.row] {
      cell.update(with: item)
      cell.didToggleCompleted = { [weak self] in
        self?.toggleItem(item)
        } //변경된 사항이 알림으로 전파되고, Table View는 최신 데이터가 반영된다.
        //또한, Realm 클래스가 객체를 재정렬하기 때문에, 변경 사항에 따라 자동으로 정렬되어 업데이트 된다.
    }

    return cell
  }
}

// MARK: - Table Delegate

extension ToDoListController {
  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
  }

  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    guard editingStyle == .delete else { return }

    if let item = items?[indexPath.row] {
      deleteItem(item: item) //삭제
    }
  }
}

//Realm은 두 가지의 Product가 있다.
//• Realm Database : 무료. 오픈 소스 DB
//• Realm Platform : Realm Cloud를 통해 서버에서 자체 호스팅되거나 클라우드 서비스로 사용되는 동기화 서버 솔루션

//Realm은 iOS와 Android에서 모두 사용할 수 있다.
//Realm Platform은 Android, iPhone, Windows, MacOS에서 동기화할 수 있다. p.19

//Realm Database 클라이언트 측 DB. 이전까지 iOS와 Android에서 모바일 앱을 구축하는데 필요한 표준은 SQLite 였다.
//SQLite는 C로 작성되었으며, 빠르고 많은 플랫폼에 이식 가능하며 SQL 표준을 따르는 장점이 있다.
//반면 Realm은 다목적 DB는 아니고, SQL과 조금 다르지만 데이터를 빠르게 읽고 쓸 수 있다.
//따라서 Realm은 일반적은 SQL DB와 동일한 방법으로 사용해서는 안 된다.

//Live Objects : Realm Database 철학 중 하나는 응용 프로그램은 객체와 함께 작동해야 한다는 것이다.
//이전의 DB들은 Dictionary 형태로 데이터를 가져오고, 앱에서 사용할 수 있는 형식으로 변환을 한다.
//그 과정에서 불필요하게 과다한 코드를 작성해야 하거나, 코드가 엉키는 경우가 빈번하다.
//Realm은 클래스를 사용하여 DB 스키마를 정의한다(DB에서 유지할 수 있는 데이터 유형).
//따라서 DB와 앱에서 사용하는 객체를 별도의 파싱 과정없이 동일하게 유지할 수 있다. p.21

//데이터가 객체에 항상 포함되어 있기 때문에, 클래스를 검사하고
//DB 스키마에 대한 변경사항을 자동으로 감지하므로 데이터가 항상 최신으로 유지된다.
//Realm Database Core는 C++로 작성되어 있고, 다른 플랫폼에서도 정확히 동일한 방식으로 작동한다.
//Core는 다양한 언어로 래핑된 SDK를 제공해, 플랫폼을 통합해 동기화를 유지하기도 용이하다.

//Realm은 사용자 정의 클래스를 사용하여 데이터를 유지할 수 있을 뿐 아니라, 원하는 방식으로 자체 API를 정의할 수도 있다.
//ex. toStruct(), fromStruct() 메서드로 DB에서 Swift 구조체로 데이터를 빠르게 읽을 수 있다. p.23

//Realm Studio를 사용해, 응용 프로그램 파일의 내용을 검사하고 필요한 경우 수동으로 변경할 수 있다.
//파일에 저장된 모든 개체를 찾고, 수정할 수 있으며, 따로 저장(csv, excel..)하거나 쿼리할 수 있다.
//Realm Studio는 Realm Platform 시작 코드를 포함하고 있다.

//SimPholders는 시뮬레이터에서 앱의 데이터베이스를 빠르게 검사할 수 있는 응용프로그램이다(유료).

//CRUD는 Create, Read, Update, Delete의 약어로 데이터 엔티티에서 수행할 수 있는 지속성 작업이다.
