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

final class TickerColumnCell: UICollectionViewCell {
  static let identifier = "TickerColumnCell"
  
  enum Size {
    case mini, small, large
    
    var fontSize: CGFloat {
      switch self {
      case .small: return .smallFontSize
      case .large, .mini: return .largeFontSize
      }
    }
    
    var rectSize: CGSize {
      switch self {
      case .large:
        return CGSize(width: .largeWidth, height: .cellHeight)
      case .small:
        return CGSize(width: .smallWidth, height: .cellHeight)
      case .mini:
        return CGSize(width: .miniWidth, height: .cellHeight)
      }
    }
  }
  
  var tableView: UITableView = UITableView()
  var characters: [String] = [] {
    didSet {
      tableView.reloadData()
    }
  }
  
  var size: Size = .large
  var isScrolling = false
  
  override init(frame: CGRect)  {
    super.init(frame: frame)
    setUpViews()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setUpViews() {
    tableView.isUserInteractionEnabled = false //유저 인터렉션을 false로
    //유저의 터치가 아닌 graph의 indicator로만 값이 바뀐다.
    tableView.register(TickerCell.self, forCellReuseIdentifier: TickerCell.identifier)
    tableView.dataSource = self
    tableView.delegate = self
    tableView.separatorStyle = .none
    tableView.backgroundColor = .clear
    
    contentView.addSubview(tableView)
    tableView.translatesAutoresizingMaskIntoConstraints = false
    
    contentView.addConstraints([
      NSLayoutConstraint(item: tableView, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: tableView, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: tableView, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: tableView, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1.0, constant: 0.0),
      ])
  }
}

// MARK: UITableViewDataSource
extension TickerColumnCell: UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let tickerCell = tableView.dequeueReusableCell(withIdentifier: TickerCell.identifier, for: indexPath) as! TickerCell
    
    let char = characters[indexPath.row]
    tickerCell.digit = "\(char)"
    tickerCell.fontSize = size.fontSize
    
    return tickerCell
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return characters.count
  }
}

// MARK: UITableViewDelegate
extension TickerColumnCell: UITableViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    //스크롤 뷰를 스크롤 할 때
    isScrolling = true
  }

  func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
    //스크롤 뷰의 애니메이션이 끝날 때
    isScrolling = false
  }
    
  //UITableView가 UIScrollView를 구현했으므로, UIScrollViewDelegate로, 스크롤 중인지 쉽게 알 수 있다.
}
