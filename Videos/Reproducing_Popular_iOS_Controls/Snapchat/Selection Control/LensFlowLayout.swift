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

let defaultItemScale: CGFloat = 0.7 //중간의 원 위치에 왔을 때에 맞춰 확대, 축소된다. default 값이 0.7

class LensFlowLayout: UICollectionViewFlowLayout { //CollectionView의 레이아웃을 설정해 준다.
  
  override func prepare() {
    super.prepare()
    
    scrollDirection = .horizontal //수평방향
    minimumLineSpacing = 0 //최소 간격 0
  }
  
  override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? { //Collection 내부의 지정된 아이템의 레이아웃 속성 관리
    let attributes = super.layoutAttributesForElements(in: rect)
    var attributesCopy: [UICollectionViewLayoutAttributes] = []
    
    for itemAttributes in attributes! {
      let itemAttributesCopy = itemAttributes.copy() as! UICollectionViewLayoutAttributes
      
      changeLayoutAttributes(itemAttributesCopy)
      
      attributesCopy.append(itemAttributesCopy)
    }
    
    return attributesCopy
  }
  
  override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
    return true //경계 변경 시 레이아웃 갱신 여부
  }
  
  private func changeLayoutAttributes(_ attributes: UICollectionViewLayoutAttributes) {
    //중간 위치에 맞춰 크기를 확대 축소 한다.
    //normalization fomula를 이용한다.
    
    let collectionCenter = collectionView!.frame.size.width / 2
    let offset = collectionView!.contentOffset.x
    let normalizedCenter = attributes.center.x - offset
    
    let maxDistance = itemSize.width + minimumLineSpacing
    let actualDistance = abs(collectionCenter - normalizedCenter)
    let scaleDistance = min(actualDistance, maxDistance)
    
    let ratio = (maxDistance - scaleDistance) / maxDistance
    let scale = defaultItemScale + ratio * (1 - defaultItemScale)
    
    attributes.transform3D = CATransform3DScale(CATransform3DIdentity, scale, scale, 1)
    //확대 축소
  }
}

