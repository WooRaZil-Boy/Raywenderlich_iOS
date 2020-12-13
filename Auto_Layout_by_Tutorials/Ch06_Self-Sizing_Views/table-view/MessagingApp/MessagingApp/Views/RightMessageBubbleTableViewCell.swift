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

class RightMessageBubbleTableViewCell: MessageBubbleTableViewCell {
  override func configureLayout() {
    super.configureLayout()
    
    NSLayoutConstraint.activate([
      contentView.topAnchor.constraint(equalTo: bubbleImageView.topAnchor, constant: -10),
      contentView.trailingAnchor.constraint(equalTo: bubbleImageView.trailingAnchor, constant: 20),
      contentView.bottomAnchor.constraint(equalTo: bubbleImageView.bottomAnchor, constant: 10),
      contentView.leadingAnchor.constraint(lessThanOrEqualTo: bubbleImageView.leadingAnchor, constant: -20),
      //LeftMessageBubbleTableViewCell과 반대로 leadingAnchor에 제약조건을 추가한다.
      //오른쪽에서 왼쪽으로 수평으로 확장된다.

      bubbleImageView.topAnchor.constraint(equalTo: messageLabel.topAnchor, constant: -5),
      bubbleImageView.trailingAnchor.constraint(equalTo: messageLabel.trailingAnchor, constant: 20),
      bubbleImageView.bottomAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 5),
      bubbleImageView.leadingAnchor.constraint(equalTo: messageLabel.leadingAnchor, constant: -10)
      //LeftMessageBubbleTableViewCell과 유사하지만, 오른쪽으로 정렬되어야 하므로
      //leadingAnchor와 trailingAnchor의 값이 조금 변경되어야 한다.
    ])
    
    let insets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 20) //패딩
    let image = UIImage(named: greenBubbleImageName)!.imageFlippedForRightToLeftLayoutDirection()
    //이미지가 왼쪽에서 오른쪽으로 모두 올바른지 확인한다.
    bubbleImageView.image = image.resizableImage(withCapInsets: insets, resizingMode: .stretch)
    //패딩을 적용하고, stretch모드로 이미지 품질에 영향을 주지 않고 크기가 다른 거품 이미지를 만들 수 있다.
    //insets을 지정한 부분의 px를 늘린다.
  }
}
