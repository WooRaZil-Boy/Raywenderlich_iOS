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

// MARK: - Animations
extension NavigationView {
  
  func animateIconColor(offset: CGFloat) {
    chatIconWhiteView.alpha = 1 - offset
    chatIconGrayView.alpha = offset
    discoverIconWhiteView.alpha = chatIconWhiteView.alpha
    discoverIconGrayView.alpha = chatIconGrayView.alpha
  }
  
  func animateIconPosition(offset: CGFloat) {
    // Line the controls up along the bottom
    let finalDistanceFromBottom: CGFloat = 25.0
    var distance = cameraButtonBottomConstraintConstant - finalDistanceFromBottom
    cameraButtonBottomConstraint.constant = cameraButtonBottomConstraintConstant - (distance * offset)
    distance = chatIconBottomConstraintConstant - finalDistanceFromBottom
    chatIconBottomConstraint.constant = chatIconBottomConstraintConstant - (distance * offset)
  }
  
  func animateIconScale(offset: CGFloat) {
    // Scale the controls using width constraints
    let finalWidthScale: CGFloat = cameraButtonWidthConstraintConstant * 0.2
    cameraButtonWidthConstraint.constant = cameraButtonWidthConstraintConstant - (finalWidthScale * offset)
    let scale = chatIconWidthConstraintConstant * 0.2
    chatIconWidthConstraint.constant = chatIconWidthConstraintConstant - (scale * offset)
  }
  
  func animateIconCenter(offset: CGFloat) {
    // Move chat and discover icons towards the center
    // Subtract the original multiplier and add in the new
    // multiplier as constant values
    
    // Because the constraint multiplier is read only,
    // to change the layout, you have to use the constant.
    // You calculate the constant less the multiplier.
    // The original constraint multiplier is approx 0.2 of half the width,
    // so if the width = 375, the center would be 37.5
    
    // The transformed center should be 0.27 (27%) of bounds width,
    // so the new multiplier should be 0.54
    
    let originalMultiplier = chatIconHorizontalConstraint.multiplier * bounds.width * 0.5
    let newMultiplier = (bounds.width * 0.54 * 0.5) - originalMultiplier
    chatIconHorizontalConstraint.constant = newMultiplier * offset
    discoverIconHorizontalConstraint.constant = -newMultiplier * offset
  }
  
  func animateBottomBar(percent: CGFloat) {
    // Controller Indicator Line
    let offset = abs(percent)
    let scaleTransform = CGAffineTransform(scaleX: offset, y: 1)
    let distance = 0.23 * bounds.width
    
    // use percent as it has the correct sign
    let transform = indicatorTransform.translatedBy(x: distance * percent, y: 0)
    indicator.transform = transform.concatenating(scaleTransform)
    indicator.alpha = offset
  }
  
}

