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

protocol MessageBubbleTableViewCellDelegate { //셀을 두번 탭할 때 일어나는 작업을 정의하는 프로토콜
  func doubleTapForCell(_ cell: MessageBubbleTableViewCell)
}

class MessageBubbleTableViewCell: UITableViewCell {
  var delegate: MessageBubbleTableViewCellDelegate? //추가
  
  @IBOutlet var messageLabel: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    let gesture = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
    gesture.numberOfTapsRequired = 2
    gesture.cancelsTouchesInView = true
    contentView.addGestureRecognizer(gesture)
    //제스처를 추가한다.
  }
  
  override func prepareForReuse() {
    messageLabel.text = ""
  }
  
  @objc func doubleTapped() { //더블 탭 시 호출될 메서드
    delegate?.doubleTapForCell(self)
  }
}

//Setting up the delegate for MessageBubbleTableViewCell
//더블 탭 시 작업을 처리하는 프로토콜을 정의하고 delegate를 만든다.
