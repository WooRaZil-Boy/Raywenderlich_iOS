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

import Foundation
import UIKit

enum PriceMovement {
  case up, down
  
  var accentColor: UIColor {
    switch self {
    case .up:
      return .upAccentColor
    case .down:
      return .downAccentColor
    }
  }
}

enum BackgroundType {
  case light(priceMovement: PriceMovement)
  case dark(priceMovement: PriceMovement)
  
  var titleTextColor: UIColor {
    switch self {
    case .dark:
      return .lightTitleTextColor
    case .light:
      return .darkTitleTextColor
    }
  }
  
  var textTextColor: UIColor {
    switch self {
    case .dark:
      return .lightTextTextColor
    case .light:
      return .darkTextTextColor
    }
  }
  
  var linkTextColor: UIColor {
    switch self {
    case .dark(let movement), .light(let movement):
      return movement.accentColor
    }
  }
}

extension UIColor {
  static let upAccentColor: UIColor = UIColor(red: 0.19, green: 0.8, blue: 0.6, alpha: 1.0)
  static let downAccentColor: UIColor = UIColor(red: 0.95, green: 0.34, blue: 0.23, alpha: 1.0)
  
  static let lightTextTextColor: UIColor = .white
  static let darkTextTextColor: UIColor = .black
  
  static let lightTitleTextColor: UIColor = .gray
  static let darkTitleTextColor: UIColor = .gray
}

extension CGFloat {
  static let titleTextSize: CGFloat = 12.0
  static let textTextSize: CGFloat = 24.0
  static let linkTextSize: CGFloat = 12.0
}

extension UILabel {
  
  func configureTitleLabel(withText text: String) {
    configure(withText: text.uppercased(), size: .titleTextSize, alignment: .left, lines: 0, robotoWeight: .medium)
  }
  
  func configureTextLabel(withText text: String) {
    configure(withText: text, size: .textTextSize, alignment: .left, lines: 0, robotoWeight: .regular)
  }
  
  func configureLinkLabel(withText text: String) {
    configure(withText: text.uppercased(), size: .linkTextSize, alignment: .left, lines: 0, robotoWeight: .medium)
  }
  
  private func configure(withText newText: String,
                         size: CGFloat,
                         alignment: NSTextAlignment,
                         lines: Int,
                         robotoWeight: RobotoWeight) {
    text = newText
    font = UIFont(name: robotoWeight.rawValue, size: size)
    textAlignment = alignment
    numberOfLines = lines
    lineBreakMode = .byTruncatingTail
  }
}

enum RobotoWeight: String {
  case thin = "Roboto-Thin"
  case regular = "Roboto-Regular"
  case medium = "Roboto-Medium"
  case bold = "Roboto-Bold"
}

