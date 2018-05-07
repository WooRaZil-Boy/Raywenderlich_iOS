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

class RoomsViewController: UIViewController {

  // MARK: - outlets

  @IBOutlet private var tableView: UITableView!
  @IBOutlet private var name: UITextField!
  @IBOutlet private var spinner: UIActivityIndicatorView!

  // MARK: - properties

  private var realm: Realm?

  private var roomNames: List<String>?
  private var roomNamesSubscription: NotificationToken?

  private var roomsSubscription: NotificationToken?
  
  private var chatSync: SyncSubscription<Chat>?
  //서버에 주어진 데이터 세트에 대한 동적인 실시간 동기화 연결 생성하는 SyncSubscription
  private var chatSubscription: NotificationToken?
  //동기화 연결 상태에 대한 알림을 받는 NotificationToken

  // MARK: - view controller life cycle

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor(patternImage: UIImage(named: "bg-pattern")!)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    guard realm == nil else { return }

    RealmProvider.chat.realm { [weak self] realm, error in
      //RealmProvider를 사용하여, Realm 인스턴스를 비동기적으로 가져온다.
      //여기서 사용된 기본 Configuration은 기본 로그인 사용자를 얻고
      //모든 연결, 인증 및 파일 URL 세부 정보를 자동으로 처리한다.
      guard error == nil, let realm = realm else {
        return UIAlertController.message("Database error", message: error!.localizedDescription)
      }
      self?.realm = realm //해당 Realm을 저장하고
      self?.fetchRooms(in: realm) //채팅방을 가져온다.
    }
  }

  deinit { //메모리 해제시 구독 취소
    roomNamesSubscription?.invalidate()
    roomsSubscription?.invalidate()
  }

  // MARK: - actions

  private func fetchRooms(in realm: Realm) {
    //서버에 실시간으로 연결한다.
    spinner.startAnimating()
    
    chatSync = realm.objects(Chat.self).subscribe()
    //Local DB에서 Chat 객체를 쿼리하고, 쿼리에서 subscribe()를 호출해, Local의 Results 집합을
    //원격 DB와 동기화하기 시작한다. (subscribe()로 서버와 동기화한다.)
    chatSubscription = chatSync?.observe(\.state, options: .initial) { [weak self] state in
      //옵저버를 추가한다. //원격 DB에서 변경시 트리거 된다.
      guard let this = self, state == .complete else { return }
      //state가 .complete인 경우, 서버에서 일치하는 모든 객체(있는 경우)가 Local에 동기화되었음을 의미한다.
      //이후에는 Local DB로 작업할 수 있다. 다른 사용자가 서버에 새 대화방을 추가하면, 동일한 구독을 사용해
      //해당 변경 사항을 즉시 로컬로 동기화하게 된다.
      
      this.spinner.stopAnimating()
      
      this.roomNames = Chat.default(in: realm).rooms
      //사용 가능한 채팅룸의 이름을 나열하는 List<String>
      this.roomNamesSubscription = this.roomNames?.observe { changes in
        //해당 List에 옵저버를 추가한다. Local 알림과 동일한 로직으로 처리할 수 있다.
        this.tableView.applyRealmChanges(changes)
        //업데이트가 있는 경우 applyRealmChanges()를 호출하여 TableView를 최신 정보로 업데이트한다.
      }
      
      this.roomsSubscription = realm.objects(ChatRoom.self).observe { _ in
        //ChatRoom의 변경사항을 구독해 서버에서 새 채팅방이 동기화 될 때 목록을 새로 고침한다.
        //chatSync.observe 클로저의 내부에 있다.
        this.tableView.reloadData()
      }
    }
  }

  @IBAction func add(_ sender: Any) {
    UIAlertController.input("Create Room") { [weak self] name in
      self?.createRoomAndEnter(withName: name)
    }
  }

  private func createRoomAndEnter(withName roomName: String) {
    guard !roomName.isEmpty, let realm = realm, let myName = name.text else { return }
    
    let newRoom = ChatRoom(roomName).add(to: realm)
    //Help 메서드로 Realm에 ChatRoom 추가
    //추가되면, Realm은 변경 사항을 큐에 넣고, 최대한 빨리 서버에 동기화한다.
    
    let chatVC = ChatViewController.createWith(roomName: newRoom.name, name: myName)
    navigationController?.pushViewController(chatVC, animated: true)
  }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension RoomsViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return roomNames?.count ?? 0
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let roomName = roomNames?[indexPath.row] else {
      fatalError()
    }

//    let isSynced = false //행 체크 표시 위한 동기화되었는지 여부
    let isSynced = realm?.object(ofType: ChatRoom.self, forPrimaryKey: roomName) != nil

    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! RoomCell
    cell.configure(with: roomName, isSynced: isSynced)
    return cell
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let room = roomNames?[indexPath.row], let myName = name.text else { return }

    tableView.deselectRow(at: indexPath, animated: true)
    view.endEditing(false)
    navigationController?.pushViewController(
      ChatViewController.createWith(roomName: room, name: myName), animated: true)
  }
}

extension RoomsViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return false
  }
}

//처음 접속 시, 서버에 DB가 전혀 존재하지 않을 수도 있다.
//현재 프로젝트의 DB 스키마는 서버에서 지속되는 데이터를 반복적으로 탐색할 수 있다.
//Chat Realm object 객체에는 사용 가능한 Chat Room의 이름 목록이 포함된다.
//사용자가 해당 채팅방에 참여하기 원하면 해당 ChatRoom 객체를 동기화하지만, 다른 객체는 동기화하지 않는다.
//이렇게 하면, 앱이 그 시점에서 사용자가 필요로 하는 데이터를 지연 동기화한다.
//원격 DB에는 각 채팅방에 대한 수 많은 메시지가 포함된 매우 많은 대화방이 있을 수 있으므로,
//사용자가 채팅에 참가하려는 방만 동기화라는 것이 좋다.

//Realm Studio에서 동기화 되는 DB를 확인해 볼 수 있다.
