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

private extension CGFloat {
  static let widthMultiplier: CGFloat = 0.8
  static let outerVerticalOffset: CGFloat = 15
  static let horizontalOffset: CGFloat = 25
  static let innerVerticalOffset: CGFloat = 10
}

class RobinhoodCardCell: UICollectionViewCell {
  
  static let identifier = "RobinhoodCell"
  
  private let textLabel = UILabel()
  private let titleLabel = UILabel()
  private let linkLabel = UILabel()
  private let cardView = UIView()
  
  var backgroundType: BackgroundType {
    didSet {
      textLabel.textColor = backgroundType.textTextColor
      titleLabel.textColor = backgroundType.titleTextColor
      linkLabel.textColor = backgroundType.linkTextColor
    }
  }
  
  var viewModel: RobinhoodCardViewModel? {
    didSet {
      guard let model = viewModel else { return }
      textLabel.configureTextLabel(withText: model.text)
      titleLabel.configureTitleLabel(withText: model.title)
      linkLabel.configureLinkLabel(withText: model.link)
    }
  }
  
  override init(frame: CGRect) {
    backgroundType = .light(priceMovement: .up)
    super.init(frame: frame)
    setUpViews()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func setUpViews() {
    contentView.addSubview(cardView)
    
    cardView.layer.cornerRadius = 4
    cardView.backgroundColor = .white
    cardView.layer.shadowColor = UIColor.black.cgColor
    cardView.layer.shadowOpacity = 0.2
    cardView.layer.shadowRadius = 10
    cardView.layer.shadowOffset = CGSize(width: -1, height: 2)
    cardView.translatesAutoresizingMaskIntoConstraints = false
    
    contentView.addConstraints([
      NSLayoutConstraint(item: cardView, attribute: .height, relatedBy: .equal, toItem: contentView, attribute: .height, multiplier: 0.9, constant: 0.0),
      NSLayoutConstraint(item: cardView, attribute: .width, relatedBy: .equal, toItem: contentView, attribute: .width, multiplier: 0.9, constant: 0.0),
      NSLayoutConstraint(item: cardView, attribute: .centerX, relatedBy: .equal, toItem: contentView, attribute: .centerX, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: cardView, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1.0, constant: 0.0)
      ])
    
    cardView.addSubview(titleLabel)
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    
    cardView.addSubview(textLabel)
    textLabel.translatesAutoresizingMaskIntoConstraints = false
    
    cardView.addSubview(linkLabel)
    linkLabel.translatesAutoresizingMaskIntoConstraints = false
    
    contentView.addConstraints([
      NSLayoutConstraint(item: titleLabel, attribute: .leading, relatedBy: .equal, toItem: cardView, attribute: .leading, multiplier: 1.0, constant: CGFloat.horizontalOffset),
      NSLayoutConstraint(item: titleLabel, attribute: .trailing, relatedBy: .equal, toItem: cardView, attribute: .trailing, multiplier: 1.0, constant: -CGFloat.horizontalOffset),
      NSLayoutConstraint(item: titleLabel, attribute: .top, relatedBy: .equal, toItem: cardView, attribute: .top, multiplier: 1.0, constant: CGFloat.outerVerticalOffset)
      ])
    
    contentView.addConstraints([
      NSLayoutConstraint(item: textLabel, attribute: .leading, relatedBy: .equal, toItem: titleLabel, attribute: .leading, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: textLabel, attribute: .trailing, relatedBy: .equal, toItem: titleLabel, attribute: .trailing, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: textLabel, attribute: .top, relatedBy: .equal, toItem: titleLabel, attribute: .bottom, multiplier: 1.0, constant: CGFloat.innerVerticalOffset),
      ])
    
    contentView.addConstraints([
      NSLayoutConstraint(item: linkLabel, attribute: .leading, relatedBy: .equal, toItem: titleLabel, attribute: .leading, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: linkLabel, attribute: .trailing, relatedBy: .equal, toItem: titleLabel, attribute: .trailing, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: linkLabel, attribute: .bottom, relatedBy: .equal, toItem: cardView, attribute: .bottom, multiplier: 1.0, constant: -CGFloat.outerVerticalOffset)
      ])
  }
  
}

