/// Copyright (c) 2017 Razeware LLC
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

class StoryCell: UITableViewCell, ThemeAdopting {
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String!)  {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setup()
  }
  
  var story: Story? {
    didSet {
      guard let story = story else { return }
      titleLabel.text = story.title
      previewLabel.text = story.content
      reloadTheme()
      setNeedsUpdateConstraints()
    }
  }
  
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.numberOfLines = 0
    label.isOpaque = true
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
    }()
  
  private var previewLabel: UILabel = {
    let label = UILabel()
    label.numberOfLines = 3
    label.isOpaque = true
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
    }()
  
  func reloadTheme()  {
    let theme = Theme.shared
    
    backgroundColor = theme.textBackgroundColor
    contentView.backgroundColor = theme.textBackgroundColor
    
    titleLabel.backgroundColor = theme.textBackgroundColor
    titleLabel.font = theme.preferredFont(forTextStyle: .headline)
    titleLabel.textColor = theme.textColor
    
    previewLabel.backgroundColor = theme.textBackgroundColor
    previewLabel.font = theme.preferredFont(forTextStyle: .body)
    previewLabel.textColor = theme.textColor
  }
  
  private func setup() {
    let stackView = UIStackView(arrangedSubviews: [titleLabel, previewLabel])
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.spacing = 8.0
    stackView.axis = .vertical
    
    contentView.addSubview(stackView)
    
    NSLayoutConstraint.activate([
      stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
      stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15),
      stackView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 15),
      stackView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -15),
      contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 64)
      ])
    
    reloadTheme()
  }
}
