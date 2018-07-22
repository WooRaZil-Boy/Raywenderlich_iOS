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

class LensCircleCell: UICollectionViewCell {
  
  static let identifier = "LensCell"
  private let imageView = UIImageView()
  private let blackBorderView = UIView()
  
  var image: UIImage? {
    didSet {
      guard let image = image else { return }
      imageView.image = image
    }
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setUpViews()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setUpViews() {
    
    contentView.addSubview(blackBorderView)
    blackBorderView.translatesAutoresizingMaskIntoConstraints = false
    
    blackBorderView.addSubview(imageView)
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.backgroundColor = .clear
    
    contentView.addConstraints([
      NSLayoutConstraint(item: blackBorderView, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: blackBorderView, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: blackBorderView, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: blackBorderView, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1.0, constant: 0.0)
      ])
    
    blackBorderView.backgroundColor = .black
    blackBorderView.layer.cornerRadius = 36
    
    contentView.addConstraints([
      NSLayoutConstraint(item: imageView, attribute: .centerX, relatedBy: .equal, toItem: blackBorderView, attribute: .centerX, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: imageView, attribute: .centerY, relatedBy: .equal, toItem: blackBorderView, attribute: .centerY, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal, toItem: blackBorderView, attribute: .width, multiplier: 0.98, constant: 0.0),
      NSLayoutConstraint(item: imageView, attribute: .height, relatedBy: .equal, toItem: blackBorderView, attribute: .height, multiplier: 0.98, constant: 0.0)
      ])
    
    imageView.contentMode = .scaleAspectFit
    imageView.clipsToBounds = true
    imageView.layer.cornerRadius = 35
    imageView.layer.borderColor = UIColor.white.cgColor
    imageView.layer.borderWidth = 3
  }
}

