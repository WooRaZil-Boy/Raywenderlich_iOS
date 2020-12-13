/// Copyright (c) 2019 Razeware LLC
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

class MessagesTableViewController: UITableViewController {
  private var messages = Message.fetchAll()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Messages"
    
    configureTableView()
  }
  
  private func configureTableView() {
    tableView.allowsSelection = false
    tableView.register(
      RightMessageBubbleTableViewCell.self,
      forCellReuseIdentifier: MessageBubbleCellType.rightText.rawValue)
    tableView.register(
      LeftMessageBubbleTableViewCell.self,
      forCellReuseIdentifier: MessageBubbleCellType.leftText.rawValue)
    tableView.separatorStyle = .none
    tableView.rowHeight = UITableView.automaticDimension // 추가
    //1. 테이블 뷰의 행 높이를 자동으로 설정한다.
  }
  
  // MARK: - Table view data source
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return messages.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let message = messages[indexPath.row]
    
    var cell: MessageBubbleTableViewCell
    if message.sentByMe { //sentByMe의 Bool 값에 따라 Cell의 인스턴스가 결정된다.
      cell = tableView.dequeueReusableCell(
        withIdentifier: MessageBubbleCellType.rightText.rawValue,
        for: indexPath) as! RightMessageBubbleTableViewCell
    }
    else {
      cell = tableView.dequeueReusableCell(
        withIdentifier: MessageBubbleCellType.leftText.rawValue,
        for: indexPath) as! LeftMessageBubbleTableViewCell
    }
    
    cell.messageLabel.text = message.text //텍스트 설정
    
    return cell
  }
}

//Table views
//스크롤 뷰 외에도, 테이블 뷰를 사용하여 요소 목록을 쉽게 표시할 수 있다.
//먼저 UITableViewDelegate와 UITableViewDataSource 두 가지 프로토콜에 대해 알아야 한다.
//UITableViewDelegate는 사용자가 특정 셀을 탭할 때, 수행하는 작업을 처리한다.
//UITableViewDataSource는 테이블 뷰의 각 셀에 대한 데이터를 표시하는 데 사용하는 방법을 포함한다.

//Self-sizing table view cells
//self-sizing cells을 사용하려면 다음과 같은 세 가지 규칙을 따라야 한다.
// 1. 테이블 뷰의 rowHeight를 자동으로 설정한다.
// 2. 테이블 뷰의 estimatedRowHeight를 원하는 값이나 delegate의 height와 같게 설정한다.
// 3. 셀에 대해 Auto Layout을 사용한다. 제약조건을 작성해야 한다.
