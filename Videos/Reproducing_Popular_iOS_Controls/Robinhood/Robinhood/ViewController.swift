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

// Layout constants
private extension CGFloat {
  static let tickerHeightMultiplier: CGFloat = 0.4
  static let graphHeightMultiplier: CGFloat = 0.6
}

class ViewController: UIViewController {
  
  @IBOutlet weak var topView: UIView!
  @IBOutlet weak var cardCollectionView: UICollectionView!
  
  private var cardsData = RobinhoodData.data.cards
  private var graphData = RobinhoodChartData.portfolioData
  
  lazy private var graphView: GraphView = {
    return GraphView(data: graphData)
  }()
  
  lazy private var tickerControl: TickerControl = {
    return TickerControl(value: graphData.openingPrice)
  }()
  
  override func viewDidLoad() {
    
    cardCollectionView.delegate = self
    cardCollectionView.dataSource = self
    cardCollectionView.register(RobinhoodCardCell.self, forCellWithReuseIdentifier: RobinhoodCardCell.identifier)
    
    if let layout = cardCollectionView.collectionViewLayout as? CardStackLayout {
      layout.delegate = self //delegate 지정
    }
    
    addChild(tickerControl)
    topView.addSubview(tickerControl.view)
    tickerControl.view.translatesAutoresizingMaskIntoConstraints = false
    
    view.addConstraints([
      NSLayoutConstraint(item: tickerControl.view, attribute: .top, relatedBy: .equal, toItem: topView, attribute: .top, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: tickerControl.view, attribute: .leading, relatedBy: .equal, toItem: topView, attribute: .leading, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: tickerControl.view, attribute: .trailing, relatedBy: .equal, toItem: topView, attribute: .trailing, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: tickerControl.view, attribute: .height, relatedBy: .equal, toItem: topView, attribute: .height, multiplier: .tickerHeightMultiplier, constant: 0.0)
      ])
    
    tickerControl.didMove(toParent: self)
    
    graphView.backgroundColor = .white
    graphView.translatesAutoresizingMaskIntoConstraints = false
    graphView.delegate = self
    topView.addSubview(graphView)
    
    view.addConstraints([
      NSLayoutConstraint(item: graphView, attribute: .bottom, relatedBy: .equal, toItem: topView, attribute: .bottom, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: graphView, attribute: .leading, relatedBy: .equal, toItem: topView, attribute: .leading, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: graphView, attribute: .trailing, relatedBy: .equal, toItem: topView, attribute: .trailing, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: graphView, attribute: .height, relatedBy: .equal, toItem: topView, attribute: .height, multiplier: .graphHeightMultiplier, constant: 0.0)
      ])
  }
}

// MARK: UICollectionViewDataSource
extension ViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return cardsData.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RobinhoodCardCell.identifier, for: indexPath) as? RobinhoodCardCell else {
      return UICollectionViewCell()
    }
    
    cell.viewModel = cardsData[indexPath.row]
    cell.backgroundType = .light(priceMovement: .up)
    
    return cell
  }
}

// MARK: UICollectionViewDelegate
extension ViewController: UICollectionViewDelegate {  }

// MARK: CardStackLayoutProtocol
extension ViewController: CardStackLayoutProtocol {
  func cardShouldRemove(_ flowLayout: CardStackLayout, indexPath: IndexPath) {
    //카드가 사라진 후(뷰 밖으로 이동) 호출된다.
    cardsData.removeLast() //가장 위의 카드를 Data에서 삭제하고
    cardCollectionView.reloadData() //collectionView를 다시 로드한다.
  }
}

// MARK: GraphViewDelegate
extension ViewController: GraphViewDelegate {
  func didMoveToPrice(_ graphView: GraphView, price: Double) {
    tickerControl.showNumber(price)
  }
}

//카드 UI를 구성할 때, 얼마까지 카드를 Swipe 했을 때 다음 카드를 보여주는 지 계산해야 한다.
//여기서는 10%이상 Swipe한 경우, 뒤의 카드가 나타나면서 점점 확대되고, 30%이상 Swipe한 경우, 다음 카드를 보여준다.
//각 카드는 UICollectionViewCell이며, 카드 UI는 UICollectionView로 만든다.
//Swipe와 Stack 등의 카드의 전환효과는 UICollectionViewLayout으로 만든다.
