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

class MessagesViewController: UIViewController {
  private let toolbarView = ToolbarView() //추가
  private var toolbarViewTopConstraint: NSLayoutConstraint! //추가
  //애니메이션을 만드는 제약조건
  
  private let defaultBackgroundColor = UIColor(
    red: 249/255.0,
    green: 249/255.0,
    blue: 249/255.0,
    alpha: 1)
  private var messages: [Message] = []
  @IBOutlet weak var tableView: UITableView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = defaultBackgroundColor
    tableView.backgroundColor = defaultBackgroundColor
    
    loadMessages()
    setupToolbarView()
    
    let gesture = UITapGestureRecognizer(target: self, action: #selector(hideToolbarView))
    gesture.numberOfTapsRequired = 1
    gesture.delegate = self
    tableView.addGestureRecognizer(gesture)
    //사용자가 테이블 뷰를 탭하면 hideToolbarView()가 호출된다.
  }
  
  func loadMessages() {
    messages.append(Message(text: "Hello, it's me", sentByMe: true))
    messages.append(Message(text: "I was wondering if you'll like to meet, to go over this new tutorial I'm working on", sentByMe: true))
    messages.append(Message(text: "I'm in California now, but we can meet tomorrow morning, at your house", sentByMe: false))
    messages.append(Message(text: "Sound good! Talk to you later", sentByMe: true))
    messages.append(Message(text: "Ok :]", sentByMe: false))
  }
  
  private func setupToolbarView() {
    view.addSubview(toolbarView) //뷰 추가
    
    toolbarViewTopConstraint = toolbarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -100)
    toolbarViewTopConstraint.isActive = true
    //제약조건을 할당하고, 위로 -100을 줘서 숨긴다.
    
    toolbarView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 30).isActive = true
    //ToolbarView는 초기화되면서 width와 height가 설정되므로, horizontal과 vertical 제약조건만 표시하면 된다.
    
    toolbarView.delegate = self //추가 //좋아요, 즐겨찾기 상태 저장을 처리
  }
  
  @objc func hideToolbarView() {
    self.toolbarViewTopConstraint.constant = -100
    //다시 -100으로 제약조건 상수를 줘서 보이지 않게 한다.
    
    UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1, options: [], animations: { //애니메이션 설정
      self.toolbarView.alpha = 0 //alpha가 0으로 서서히 사라지도록 한다.
      self.view.layoutIfNeeded() //layout pass가 적용되도록 한다.
    }, completion: nil)
  }
}

//MARK: - UITableView Delegate & Data Source
extension MessagesViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return messages.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    //1
    let message = messages[indexPath.row]
    
    //2
    let cellIdentifier = message.sentByMe ? "RightBubble" : "LeftBubble"
    
    let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier,
                                             for: indexPath) as! MessageBubbleTableViewCell
    cell.messageLabel.text = message.text
    cell.backgroundColor = defaultBackgroundColor
    cell.delegate = self
    
    return cell
  }
}

extension MessagesViewController: MessageBubbleTableViewCellDelegate {
  //더블 탭 시의 작업을 위해 MessageBubbleTableViewCellDelegate를 구현해야 한다.
  func doubleTapForCell(_ cell: MessageBubbleTableViewCell) {
    guard let indexPath = self.tableView.indexPath(for: cell) else { return }
    
    let message = messages[indexPath.row]
    
    guard message.sentByMe == false else { return }
    //local user가 보낸 메시지가 아닌지 확인한다.
    
    toolbarViewTopConstraint.constant = cell.frame.midY //toolbarViewTopConstraint 변경
    toolbarView.alpha = 0.95 //투명도 조정
    toolbarView.update(isLiked: message.isLiked, isFavorited: message.isFavorited)
    //toolbarView의 Button을 업데이트 한다.
    toolbarView.tag = indexPath.row //tag로 indexPath를 식별할 수 있도록 할당
    
    UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1, options: [], animations: { //애니메이션 실행
      self.view.layoutIfNeeded()
      //Update Pass를 강제하므로, 자동 레이아웃은 새로운 제약조건을 충족해야 한다.
      //Update Pass는 Update Pass의 Render Loop에 속하며, 제약 조건을 사용하여 UI를 최신 상태로 유지한다.
    }, completion: nil)
  }
}

extension MessagesViewController: UIGestureRecognizerDelegate { //프로토콜 준수
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
    return touch.view == tableView
    //터치한 뷰가 테이블 뷰인 경우에 작동
  }
}

extension MessagesViewController: ToolbarViewDelegate {
  func toolbarView(_ toolbarView: ToolbarView, didFavoritedWith tag: Int) {
    messages[tag].isFavorited.toggle()
  }
  
  func toolbarView(_ toolbarView: ToolbarView, didLikedWith tag: Int) {
    messages[tag].isLiked.toggle()
  }
  //좋아요, 즐겨찾기 상태 저장
  
}

//애니메이션을 만들 때는 start value, end value, time 등 세 가지를 고려해야 한다.

//Animate Auto Layout using Core Animations
//제약 조건의 상수를 변경하거나 제약 조건 자체를 활성화 비활성화 하여 애니메이션화할 수 있다.


