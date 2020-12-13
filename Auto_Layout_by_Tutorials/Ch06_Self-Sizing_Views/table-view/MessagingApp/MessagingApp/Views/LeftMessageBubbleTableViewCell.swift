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

class LeftMessageBubbleTableViewCell: MessageBubbleTableViewCell {
  override func configureLayout() {
    super.configureLayout()
    
    NSLayoutConstraint.activate([
      contentView.topAnchor.constraint(equalTo: bubbleImageView.topAnchor, constant: -10),
      contentView.trailingAnchor.constraint(greaterThanOrEqualTo: bubbleImageView.trailingAnchor, constant: 20),
      //greaterThanOrEqualTo를 사용하므로, 뷰는 수평으로 넓어질 수 있으며, 항상 컨테이너에서 최소 20포인트 여유를 유지한다.
      contentView.bottomAnchor.constraint(equalTo: bubbleImageView.bottomAnchor, constant: 10),
      contentView.leadingAnchor.constraint(equalTo: bubbleImageView.leadingAnchor, constant: -20),
      //contentView의 제약조건을 추가한다. 버블 이미지에 따라 그 크기가 달라진다.
      
      bubbleImageView.topAnchor.constraint(equalTo: messageLabel.topAnchor, constant: -5),
      bubbleImageView.trailingAnchor.constraint(equalTo: messageLabel.trailingAnchor, constant: 10),
      bubbleImageView.bottomAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 5),
      bubbleImageView.leadingAnchor.constraint(equalTo: messageLabel.leadingAnchor, constant: -20)
      //bubbleImageView의 제약조건을 추가한다. messageLabel 사이에 약간의 패딩을 적용한다.
      //글의 양에 따라 버블 이미지뷰가 크기를 조절하도록 한다.
    ])
    
    let insets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 10) //패딩
    let image = UIImage(named: blueBubbleImageName)!.imageFlippedForRightToLeftLayoutDirection()
    //오른쪽에서 왼쪽으로 레이아웃의 가로를 뒤집는다.
    bubbleImageView.image = image.resizableImage(withCapInsets: insets, resizingMode: .stretch)
    //패딩을 적용하고, stretch모드로 이미지 품질에 영향을 주지 않고 크기가 다른 거품 이미지를 만들 수 있다.
    //insets을 지정한 부분의 px를 늘린다.
    //https://onefm2.tistory.com/36
  }
}
