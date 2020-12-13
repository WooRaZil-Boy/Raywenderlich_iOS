/// Copyright (c) 2020 Razeware LLC
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
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.


import UIKit
import CoreGraphics

class CheckMark: UIView {
  
  override func draw(_ rect: CGRect) {
    super.draw(rect)
    drawRectChecked()
  }
  
  func drawRectChecked() {
    // General Declarations
    let context = UIGraphicsGetCurrentContext()
    
    // Color Declarations
    let checkmarkBlue2 = UIColor(red: 0.078, green: 0.435, blue: 0.875, alpha: 1.0)
    
    // Shadow Declarations
    let shadow2 = UIColor.black
    let shadow2Offset = CGSize(width: 0.1, height: -0.1)
    let shadow2BlurRadius = 2.5
    
    // Frames
    let frame = bounds
    
    // Subframes
    let group = CGRect(x: frame.minX + 3, y: frame.minY + 3, width: frame.width - 6, height: frame.height - 6)
    
    // CheckedOval Drawing
    let checkedOvalPath = UIBezierPath(ovalIn:CGRect(x: group.minX + 0.5, y: group.minY + 0.5, width: group.width + 1, height: group.height + 1))
    context?.saveGState()
    context?.setShadow(offset: shadow2Offset, blur: CGFloat(shadow2BlurRadius), color: shadow2.cgColor)
    checkmarkBlue2.setFill()
    checkedOvalPath.fill()
    context?.restoreGState()
    
    UIColor.white.setStroke()
    checkedOvalPath.lineWidth = 1
    checkedOvalPath.stroke()
    
    
    // Bezier Drawing
    let bezierPath = UIBezierPath()
    bezierPath.move(to: CGPoint(x: group.minX + 0.27083 * group.width, y: group.minY + 0.54167 * group.height))
    bezierPath.addLine(to: CGPoint(x: group.minX + 0.41667 * group.width, y: group.minY + 0.68750 * group.height))
    bezierPath.addLine(to: CGPoint(x: group.minX + 0.75000 * group.width, y: group.minY + 0.35417 * group.height))
    bezierPath.lineCapStyle = .square
    
    UIColor.white.setStroke()
    bezierPath.lineWidth = 1.3
    bezierPath.stroke()
  }
}
