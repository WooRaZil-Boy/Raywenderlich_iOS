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

protocol CardStackLayoutProtocol: class {
  func cardShouldRemove(_ flowLayout: CardStackLayout, indexPath: IndexPath)
}

class CardStackLayout: UICollectionViewLayout {
  
  typealias CellWithIndexPath = (cell: UICollectionViewCell, indexPath: IndexPath)
  //편의를 위해 cell과 index를 묶어 새로운 타입을 만든다.
  weak var delegate: CardStackLayoutProtocol? //delegate
  
  private let animationDuration: TimeInterval = 0.15 //애니메이션 지속 시간
  private var panGestureRecognizer: UIPanGestureRecognizer = UIPanGestureRecognizer()
  //Pan gesture(Swipe) 인식기
  private let maxOffsetThresholdPercentage: CGFloat = 0.3
  //30% 이상 Swipe가 되면 다음 카드를 보여준다.
  
  private var topCellWithIndexPath: CellWithIndexPath? {
    //가장 위(현재 보여지고 있는 카드) cell의 cell과 indexPath
    //모든 카드를 Swipe한 경우에는 nil이 되므로 optional
    let lastItem = collectionView?.numberOfItems(inSection: 0) ?? 0
    //맨 아래의 마지막 카드의 index
    //optional이 될 수 있으므로, collectionView의 전체 카드 수를 알아야 한다.
    let indexPath = IndexPath(item: lastItem - 1, section: 0)
    //tableView에서는 IndexPath(row: section:)을 사용하는 것이 좋고,
    //collectionView에서는 IndexPath(item: section:)을 사용하는 것이 좋다.
    //여기서는 CollectionView가 생성될 때 item들이 stack으로 쌓이므로 마지막 item이 가장 위로 올라온다.
    guard let cell = collectionView?.cellForItem(at: indexPath) else { return nil }
    return (cell: cell, indexPath: indexPath)
  }
  
  private var bottomCellWithIndexPath: CellWithIndexPath? {
    //가장 위(현재 보여지고 있는 카드) 바로 아래(다음 보여질 카드)의 cell과 indexPath
    guard let numItems = collectionView?.numberOfItems(inSection: 0), numItems > 1 else { return nil }
    //collectionView에 cell이 2개 이상 있어야 한다.
    let indexPath = IndexPath(item: numItems - 2, section: 0)
    //마지막 아이템이 가장 위의 cell(현재 카드)
    guard let cell = collectionView?.cellForItem(at: indexPath) else { return nil }
    return (cell: cell, indexPath: indexPath)
  }
  
  override func prepare() {
    super.prepare()
    panGestureRecognizer.addTarget(self, action: #selector(handlePan(gestureRecognizer:)))
    //제스처 발생시 호출될 메서드 추가
    collectionView?.addGestureRecognizer(panGestureRecognizer)
    //collectionView에 제스처 인식기 추가
  }
  
  override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
    //각 indexPath의 Cell에 레이아웃 속성을 설정해 준다.
    
    // Here we can just target the top two items on the stack
    let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
    //해당 indexPath에 위치한 Cell의 UICollectionViewLayoutAttributes를 가져온다.
    
    attributes.frame = collectionView?.bounds ?? .zero
    //collectionView의 frame과 같은 크기로 지정해 준다(nil일 경우 zero).
    //모두 같은 frame을 갖기 때문에 cell들이 차례대로 중첩되게 된다.
    
    var isNotTop = false
    if let numItems = collectionView?.numberOfItems(inSection: 0), numItems > 0 {
      isNotTop = indexPath.row != numItems - 1 //해당 cell(card)가 가장 위에 올라와 있는 지 여부 판단
    }
    
    attributes.alpha = isNotTop ? 0 : 1
    //해당 cell(card)가 가장 위에 올라와 있는 경우라면 alpha 1, 아닌 경우는 0으로 설정해 감춘다.
    
    return attributes
  }
  
  override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    //지정된 rect의 모든 cell과 view에 대한 레이아웃 속성을 설정해 준다.
    let indexPaths = indexPathsForElementsInRect(rect) //collectionView의 indexPath 들
    let layoutAttributes = indexPaths.map { self.layoutAttributesForItem(at: $0) }
        //각 indexPath에 해당하는 cell의 rayout을 가져와서
        .filter { $0 != nil }.map { $0! }
        //nil이 아닌 경우 optional을 해제한다.
    return layoutAttributes
  }
  
  fileprivate func indexPathsForElementsInRect(_ rect: CGRect) -> [IndexPath] {
    //collectionViewCell의 전체 indexPath를 반환
    var indexPaths: [IndexPath] = []
    
    if let numItems = collectionView?.numberOfItems(inSection: 0), numItems > 0 {
      for i in 0...numItems-1 {
        indexPaths.append(IndexPath(item: i, section: 0))
      }
    }
    
    return indexPaths
  }
  
  @objc func handlePan(gestureRecognizer: UIPanGestureRecognizer) {
    //selector로 사용하므로 @objc로 선언해 준다.
    let translation = gestureRecognizer.translation(in: collectionView)
    
    let xOffset = translation.x //현재 gesture의 x
    let xMaxOffset = (collectionView?.frame.width ?? 0) * maxOffsetThresholdPercentage
    //30%를 넘어서면 뒤의 카드로 전환
    
    switch gestureRecognizer.state {
    case .changed: //gesture가 진행
      if let topCard = topCellWithIndexPath {
        topCard.cell.transform = CGAffineTransform(translationX: xOffset, y: 0)
        //위의 카드는 이동
      }
      
      if let bottomCard = bottomCellWithIndexPath {
        let draggingScale = 0.5 + (abs(xOffset) / (collectionView?.frame.width ?? 1) * 0.7)
        //Swipe할 때 뒤의 카드는 크기의 최소 0.5에서 부터 점점 커지게 된다. 최대 값은 0.5 + 0.7 = 1.2가 된다.
        let scale = draggingScale > 1 ? 1 : draggingScale //최대 크기는 1
        bottomCard.cell.transform = CGAffineTransform(scaleX: scale, y: scale) //scale 확대/축소
        bottomCard.cell.alpha = scale / 2
        //아래 카드는 보여진다. 보여지지만, 위의 카드랑 겹치는 부분이 있다.
      }
      
    case .ended: //gesture 종료
      if abs(xOffset) > xMaxOffset { //좌측이든 우측이든 30% 이상 진행 (바뀐다)
        if let topCard = topCellWithIndexPath {
          //Animate and remove
          animateAndRemove(left: xOffset < 0, cell: topCard.cell, completion: { [weak self] in
            guard let `self` = self else { return }
            //`은 예약어를 변수명 등의 식별자로 사용할 때 붙인다. 컴파일에 영향 주지 않는다.
            self.delegate?.cardShouldRemove(self, indexPath: topCard.indexPath)
          })
        }
        
        if let bottomCard = bottomCellWithIndexPath {
          //Animate into primary position
          animateIntoPosition(cell: bottomCard.cell)
        }
        
      } else { //30% 미만 진행 (바뀌지 않는다)
        if let topCard = topCellWithIndexPath {
          //Animate back into primary position
          animateIntoPosition(cell: topCard.cell)
        }
      }
    default:
      break
    }
  }
  
  private func animateIntoPosition(cell: UICollectionViewCell) {
    
    UIView.animate(withDuration: animationDuration) {
      cell.transform = CGAffineTransform.identity //원래의 transform으로 돌아간다.
      cell.alpha = 1
    }
  }
  
  private func animateAndRemove(left: Bool, cell: UICollectionViewCell, completion:(()->())?) {
    
    let screenWidth = UIScreen.main.bounds.width
    UIView.animate(withDuration: animationDuration, animations: {
      
      let xTranslateOffscreen = CGAffineTransform(translationX: left ? -screenWidth : screenWidth, y: 0)
      cell.transform = xTranslateOffscreen
      //좌측 Swipe면 width만큼 좌측 이동, 우측 Swipe면 width만큼 우측 이동해서 안 보이게 한다.
    }) { (completed) in
      completion?()
    }
  }
}

//Custom UICollectionViewLayout을 설정한다.
//해당 CardStackLayout를 스토리보드에서 적용한 UICollectionView에서 layout을 Custom으로 한 뒤 적용시켜준다.
//여기서는 해당 Cell들이 뒤로 중첩되는 구조이므로, Debug View Hierachy를 이용해 확인해 볼 수 있다.
//따로 Swipe나 Scroll등의 설정을 하지 않으면, 크기에 맞춰 처음 아이템만 보여지게 된다.
//이런 식으로 Cell을 반복해서 중첩 시키는 것은 메모리 소비가 많다. cell이 많은 경우에는 다른 방법을 찾아야 한다.

//그래프는 line 자체와 특정 시간을 지정하는 indicator로 나누어 생각해 볼 수 있다.
