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

class ChatViewController: UIViewController {

  // MARK: - outlets

  @IBOutlet private var tableView: UITableView!
  @IBOutlet private var leave: UIBarButtonItem!
  @IBOutlet private var message: UITextField!
  @IBOutlet var footerBottomSpace: NSLayoutConstraint!

  // MARK: - properties

  private var realm: Realm?

  private var roomSync: SyncSubscription<ChatRoom>?
  private var roomSubscription: NotificationToken?

  private var items: List<ChatItem>?
  private var itemsSubscription: NotificationToken?

  private var room: ChatRoom?
  private var roomName: String!
  private var name: String!

  // MARK: - view controller life cycle

  static func createWith(storyboard: UIStoryboard = UIStoryboard.main,
                         roomName: String, name: String) -> ChatViewController {
    let vc = storyboard.instantiateViewController(ChatViewController.self)
    vc.name = name
    vc.title = roomName
    vc.roomName = roomName
    return vc
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = UIColor(patternImage: UIImage(named: "bg-pattern")!)
    message.layer.borderColor = UIColor(red:0.38, green:0.33, blue:0.66, alpha:1.0).cgColor

    constrainToKeyboardTop(constraint: footerBottomSpace) { [weak self] in
      guard let count = self?.items?.count else { return }

      self?.tableView.scrollToRow(at: IndexPath(row: count-1, section: 0), at: .bottom, animated: true)
    }
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    //RoomsViewController와 비슷한 로직

    RealmProvider.chat.realm { [weak self] realm, error in
      //동기화된 Realm의 인스턴스
      guard error == nil, let realm = realm else {
        return UIAlertController.message("Database error", message: error!.localizedDescription)
      }

      self?.realm = realm
      self?.fetchMessages(in: realm) //동기화
    }
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    view.endEditing(false)
    
    itemsSubscription?.invalidate() //구독 해제
    roomSubscription?.invalidate()
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  // MARK: - actions

  private func fetchMessages(in realm: Realm) {
    roomSync = realm.objects(ChatRoom.self)
      .filter(NSPredicate(format: "%K = %@", ChatRoom.Property.name.rawValue, roomName))
      //선택한 채팅방의 이름으로 Local DB를 쿼리한다.
      .subscribe() //그 결과를 서버와 동기화 구독
      //결국 이 subscribe로 채팅방 객체와 그 방의 모든 메시지를 동기화한다.
      //RoomsViewController와 비슷한 로직
    
    roomSubscription = roomSync?.observe(\.state) { [weak self] state in
      guard let this = self, state == .complete else { return }
      //.complete로 초기 동기화가 완료되었다면
      
      this.room = realm.object(ofType: ChatRoom.self, forPrimaryKey: this.roomName)
      //DB에서 해당 ChatRoom 객체를 가져온다.
      this.items = this.room?.items
      //items 속성에 채팅방의 메시지 목록을 저장한다.
      
      this.itemsSubscription = this.items?.observe { changes in
        guard let tableView = this.tableView else { return }
        //변경 사항이 있다면 UI업데이트
        tableView.applyRealmChanges(changes)
        
        guard !this.items!.isEmpty else { return }
        tableView.scrollToRow(at: IndexPath(row: this.items!.count-1, section: 0), at: .bottom, animated: true)
        //최근 추가된 곳으로 스크롤
      }
      
      this.leave.isEnabled = true
    }
  }

  @IBAction func send(_ sender: Any) {
    //메시지 추가. 메시지는 Realm에 의해 서버 및 연결된 다른 클라이언트에 자동으로 동기화 된다.
    guard let text = message.text, !text.isEmpty, let room = room else { return }
    
    ChatItem(sender: name, message: text).add(in: room) //메시지를 현재 채팅방에 추가
    message.text = nil
  }

  @IBAction func leave(_ sender: Any) {
    navigationController!.popViewController(animated: true)
  }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension ChatViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return items?.count ?? 0
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! BubbleCell
    if let item = items?[indexPath.row] {
      cell.configure(with: item, isMe: name == item.sender)
    }
    return cell
  }
}

extension ChatViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return false
  }
}

//다른 시뮬레이터로 똑같은 앱을 실행한 후 메시지를 보내 동기화되는 지 확인할 수 있다.
//iOS, tvOS, Android 등 다른 플랫폼에서도 동일한 Realm Cloud에 연결해 확인할 수 있다.
//https://docs.realm.io/cloud
