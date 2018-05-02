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

class ChatViewController: UITableViewController {
  private let highlightColor = UIColor(red: 243/255.0, green: 242/255.0, blue: 247/255.0, alpha: 1.0)
  private let formatter = DateFormatter.mediumTimeFormatter
    
    private var messages: Results<Message>? //Message의 Results 집합
    private var messagesToken: NotificationToken? //알림 토큰

  // MARK: - View controller life-cycle
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    let realm = try! Realm()
    messages = realm.objects(Message.self)
        .sorted(byKeyPath: Message.properties.date, ascending: false) //date로 정렬
        //byKeyPath를 String으로 직접 쓰지 않고, extension으로 문자열을 만들어 오타를 줄일 수 있다.
    
    messagesToken = messages?.observe { [weak self] _ in //알림 구독
        self?.tableView.reloadData() //메시지 컬렉션이 변경될 때마다 테이블 뷰 다시 로드
    }
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    messagesToken?.invalidate() //구독 해제 //다른 탭을 누를 때 메모리 누수를 막는다
  }
}

// MARK: - UITableView data source
extension ChatViewController {
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return messages?.count ?? 0
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
    let message = messages![indexPath.row] //해당 message 객체를 가져온다.
    let formattedDate = formatter.string(from: message.date) //date를 String으로 변환
    
    cell.contentView.backgroundColor = message.isNew ? highlightColor: .white
    cell.textLabel?.text = message.isNew ? "[\(message.from)]" : message.from
    cell.detailTextLabel?.text = String(format: "(%@) %@", formattedDate, message.text)
    //cell 업데이트
    
    return cell
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: false)
    
    let message = messages![indexPath.row]
    
    let realm = try! Realm()
    
    try! realm.write { //토글 트랜잭션
        message.isNew = false
    }
  }
}

// MARK: - UITableView delegate
extension ChatViewController {
  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
  }

  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    guard editingStyle == .delete else { return }

  }
}
