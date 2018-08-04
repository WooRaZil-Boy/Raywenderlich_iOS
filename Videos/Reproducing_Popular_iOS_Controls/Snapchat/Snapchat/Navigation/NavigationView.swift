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

class NavigationView: UIView {
  
  // MARK: - Properties
  lazy var cameraButtonWidthConstraintConstant: CGFloat = {
    return self.cameraButtonWidthConstraint.constant
  }()
  lazy var cameraButtonBottomConstraintConstant: CGFloat = {
    return self.cameraButtonBottomConstraint.constant
  }()
  lazy var chatIconWidthConstraintConstant: CGFloat = {
    return self.chatIconWidthConstraint.constant
  }()
  lazy var chatIconBottomConstraintConstant: CGFloat = {
    return self.chatIconBottomConstraint.constant
  }()
  lazy var chatIconHorizontalConstraintConstant: CGFloat = {
    return self.chatIconHorizontalConstraint.constant
  }()
  lazy var discoverIconHorizontalConstraintConstant: CGFloat = {
    return self.discoverIconHorizontalConstraint.constant
  }()
  lazy var indicatorTransform: CGAffineTransform = {
    return self.cameraButtonView.transform
  }()
  
  @IBOutlet var cameraButtonView: UIView!
  @IBOutlet var cameraButtonWhiteView: UIImageView!
  @IBOutlet var cameraButtonGrayView: UIImageView!
  @IBOutlet var cameraButtonWidthConstraint: NSLayoutConstraint!
  @IBOutlet var cameraButtonBottomConstraint: NSLayoutConstraint!
  
  @IBOutlet var chatIconView: UIView!
  @IBOutlet var chatIconWhiteView: UIImageView!
  @IBOutlet var chatIconGrayView: UIImageView!
  @IBOutlet var chatIconWidthConstraint: NSLayoutConstraint!
  @IBOutlet var chatIconBottomConstraint: NSLayoutConstraint!
  @IBOutlet var chatIconHorizontalConstraint: NSLayoutConstraint!
  
  @IBOutlet var discoverIconView: UIView!
  @IBOutlet var discoverIconWhiteView: UIImageView!
  @IBOutlet var discoverIconGrayView: UIImageView!
  @IBOutlet var discoverIconHorizontalConstraint: NSLayoutConstraint!
  
  @IBOutlet var indicator: UIView!
  
  @IBOutlet var colorView: UIView!
  
  // MARK: - Internal
  func shadow(layer: CALayer, color: UIColor) {
    layer.shadowColor = color.cgColor
    layer.masksToBounds = false
    layer.shadowOffset = .zero
    layer.shadowOpacity = 1.0
    layer.shadowRadius = 0.5
  }
  
  func setup() {
    shadow(layer: cameraButtonWhiteView.layer, color: .black)
    shadow(layer: chatIconWhiteView.layer, color: .darkGray)
    shadow(layer: discoverIconWhiteView.layer, color: .darkGray)
  }
  
  // MARK: - View Life Cycle
  override func layoutSubviews() {
    super.layoutSubviews()
    indicator.layer.cornerRadius = indicator.bounds.height / 2
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    setup()
  }
  
  override func prepareForInterfaceBuilder() {
    super.prepareForInterfaceBuilder()
    setup()
  }
  
  // let touches through except for buttons.
  // Buttons have tap gestures on them
  override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
    let view = super.hitTest(point, with: event)
    return view == self ? nil : view
  }
  
  func animate(to controller: UIViewController?, percent: CGFloat) {
    let offset = abs(percent)
    
    // fade white to gray
    cameraButtonWhiteView.alpha = 1 - offset
    cameraButtonGrayView.alpha = offset
    
    animateIconColor(offset: offset)
    animateIconPosition(offset: offset)
    animateIconScale(offset: offset)
    animateIconCenter(offset: offset)
    
    animateBottomBar(percent: percent)
    
    // Background color view
    if let controller = controller as? ColoredView {
      colorView.backgroundColor = controller.controllerColor //색 적용
    }
    
    // animation starts at 0.2 of the way across
    // and is fully faded in at 0.8
    //20% 까지는 색 전환이 없고, 그 이후 부터 색이 변환된다.
    var colorOffset = (offset - 0.2) / (0.8 - 0.2)
    colorOffset = min(max(colorOffset, 0), 1)
    colorView.alpha = colorOffset
    
    layoutIfNeeded() //레이아웃 업데이트
  }
}

