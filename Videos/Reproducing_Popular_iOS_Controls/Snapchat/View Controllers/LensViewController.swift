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

class LensViewController: UIViewController {
  @IBOutlet weak var faceImage: UIImageView!
  @IBOutlet weak var lensCollectionView: UICollectionView!
  
  private lazy var lensFiltersImages: [UIImage] = {
    var images: [UIImage] = []
    for i in 0...19 {
      guard let image = UIImage(named: "face\(i)") else { break }
      images.append(image)
    }
    return images
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    lensCollectionView.delegate = self
    lensCollectionView.dataSource = self
    lensCollectionView.decelerationRate = UIScrollView.DecelerationRate.fast
    lensCollectionView.register(LensCircleCell.self, forCellWithReuseIdentifier: LensCircleCell.identifier)
  }
  
  override func viewDidLayoutSubviews() {
    //뷰 컨트롤러가 서브 뷰를 배치한 경우 호출된다. //default에서는 아무것도 구현하지 않는다.
    super.viewDidLayoutSubviews()
    
    let middleIndexPath = IndexPath(item: lensFiltersImages.count/2, section: 0) //처음의 위치 지정
    selectCell(for: middleIndexPath, animated: false) //처음에는 애니메이션 없이 select
  }
  
  private func selectCell(for indexPath: IndexPath, animated: Bool) {
    lensCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: animated)
    //컬렉션 뷰 스크롤
    faceImage.image = lensFiltersImages[indexPath.row] //뷰 중간의 face image를 교체한다.
  }
}

// MARK: UICollectionViewDelegate
extension LensViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return lensFiltersImages.count
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    selectCell(for: indexPath, animated: true)
  }
}

// MARK: UICollectionViewDataSource
extension LensViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LensCircleCell.identifier, for: indexPath) as? LensCircleCell else { fatalError() }
    
    cell.image = lensFiltersImages[indexPath.row]
    return cell
  }
}

// MARK: UICollectionViewDelegateFlowLayout
extension LensViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let side = lensCollectionView.frame.height * 0.9
    return CGSize(width: side, height: side)
  }
}

// MARK: UIScrollViewDelegate
extension LensViewController: UIScrollViewDelegate {
  
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    //스크롤뷰의 스크롤이 종료된 경우(감속이 마무리 된 경우).
    //감속이 된 경우에만 호출된다. 감속 없이 단순 드래그만 된 경우에는 호출되지 않는다.
    let bounds = lensCollectionView.bounds
    
    let xPosition = lensCollectionView.contentOffset.x + bounds.size.width/2.0
    let yPosition = bounds.size.height/2.0
    let xyPoint = CGPoint(x: xPosition, y: yPosition)
    
    guard let indexPath = lensCollectionView.indexPathForItem(at: xyPoint) else { return }
    //indexPathForItem으로 해당 point에 위치한 셀의 IndexPath를 가져올 수 있다.
    
    selectCell(for: indexPath, animated: true)
  }
  
  func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
    //스크롤 뷰 스크롤 애니메이션이 끝난 경우
    scrollViewDidEndDecelerating(scrollView)
  }
  
  func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    //스크롤 뷰의 스크롤이 종료된 경우
    //감속이 없는 단순 드래그 시에도 호출된다.
    if !decelerate { //감속이 없는 경우에도 scrollViewDidEndDecelerating를 호출해 같은 로직을 적용해 준다.
      scrollViewDidEndDecelerating(scrollView)
    }
  }
}
