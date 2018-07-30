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

// Ticker UI Constants
extension CGFloat {
  static let miniWidth: CGFloat = 8.0
  static let smallWidth: CGFloat = 20.0
  static let largeWidth: CGFloat = 32.0
  static let smallFontSize: CGFloat = 35.0
  static let largeFontSize: CGFloat = 60.0
  static let cellHeight: CGFloat = 48
  static let columnHeight: CGFloat = 50
}

final class TickerControl: UIViewController {
  
  private let numericAlphabet = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
  private var stringValue: String
  private var numberValue: Double {
    didSet {
      stringValue = String(format: "$%.2f", numberValue)
    }
  }
  
  private let columnsCollectionView: UICollectionView = {
    let flowLayout                     = UICollectionViewFlowLayout()
    flowLayout.scrollDirection         = .horizontal
    flowLayout.minimumInteritemSpacing = 0
    flowLayout.minimumLineSpacing      = 0
    return UICollectionView(frame: .zero, collectionViewLayout:flowLayout)
  }()
  
  init(value: Double) {
    self.stringValue = String(format: "$%.2f", value)
    self.numberValue = value
    
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    columnsCollectionView.backgroundColor = .white
    columnsCollectionView.delegate = self
    columnsCollectionView.dataSource = self
    columnsCollectionView.register(TickerColumnCell.self, forCellWithReuseIdentifier: TickerColumnCell.identifier)
    
    view.addSubview(columnsCollectionView)
    columnsCollectionView.translatesAutoresizingMaskIntoConstraints = false
    
    view.addConstraints([
      NSLayoutConstraint(item: columnsCollectionView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: columnsCollectionView, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: columnsCollectionView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: CGFloat(CGFloat.columnHeight)),
      NSLayoutConstraint(item: columnsCollectionView, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1.0, constant:0.0)
      ])
    
    view.backgroundColor = .white
  }
  
  override func viewDidAppear(_ animated: Bool) {
    showNumber(numberValue)
  }
  
  func showNumber(_ number: Double) {
    numberValue = number
    
    for (index, char) in stringValue.enumerated() {
      let indexPath = IndexPath(item: index, section: 0)
      //UICollectionView에서는 IndexPath(item: section:)
      //UITableView에서는 IndexPath(row: section:)
        
      guard let cell = columnsCollectionView.cellForItem(at: indexPath) as? TickerColumnCell,
        let characterIndex = cell.characters.index(of: "\(char)") else { return }
        //문자에 해당하는 인덱스를 가져온다.
      
      let charIndexPath = IndexPath(item: characterIndex, section: 0)
        
      if !cell.isScrolling {
        cell.tableView.scrollToRow(at: charIndexPath, at: .middle, animated: true)
        //tableView가 스크롤 중이 아닐 때에만 스크롤을 한다.
        //모든 경우에 (!cell.isScrolling 조건 없이) 스크롤 할 경우, Pan Gesture가 길어지면,
        //이전 스크롤이 완료되기 전에 다음 스크롤을 진행하기에 멈춰 있는 듯한 장면이 나오게 된다.
        //이거 좀 안 맞는 부분도 생기는 듯?
      }
      //문자(0 ~ 9) 숫자가 각 자리 수의 tableView에 펼쳐져 있다.
      //그 tableView가 collectionView에 펼쳐져 있다. 즉, CollectionViewCell마다 TableView가 있다.
      //해당 테이블 뷰를 스크롤하면서(작은 숫자면 위로, 큰 숫자면 아래로) 애니메이션이 되는 듯한 효과가 난다.
    }
  }
}

// MARK: UICollectionViewDelegateFlowLayout
extension TickerControl: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    
    let count = stringValue.count
    var size: TickerColumnCell.Size
    
    switch indexPath.row {
    case 0, count - 1, count - 2:
      size = .small
    case count - 3:
      size = .mini
    default:
      size = .large
    }
    
    return size.rectSize
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    
    let count = stringValue.count
    let largeCharsCount = count - 4 // "$", ".", 2 decimal places at the end
    
    let totalCellWidth = 1 * CGFloat.miniWidth + 3 * CGFloat.smallWidth + CGFloat(largeCharsCount) * CGFloat.largeWidth
    
    let leftInset = (collectionView.layer.frame.size.width - CGFloat(totalCellWidth)) / 2
    let rightInset = leftInset
    
    return UIEdgeInsets.init(top: 0, left: leftInset, bottom: 0, right: rightInset)
  }
}

// MARK: UICollectionViewDataSource
extension TickerControl: UICollectionViewDataSource {

  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return stringValue.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TickerColumnCell.identifier, for: indexPath) as! TickerColumnCell
    
    let character = "\(stringValue[indexPath.row])"
    let characters: [String]
    
    if numericAlphabet.contains(character) {
      characters = numericAlphabet
      // If it's not the last OR second to last index, then make it big
      cell.size = ![stringValue.count - 1, stringValue.count - 2].contains(indexPath.row) ? .large : .small
    } else {
      characters = [character]
      cell.size = character == "." ? .mini : .small
    }
    
    cell.characters = characters
    
    return cell
  }
}

// MARK: UICollectionViewDelegate
extension TickerControl: UICollectionViewDelegate { }

//Ticker로 UICollectionView나, StackView를 사용할 수 있다.
//여기서는 UITableView와 UICollectionView 활용
