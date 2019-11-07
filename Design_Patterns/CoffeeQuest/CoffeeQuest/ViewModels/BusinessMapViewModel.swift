/// Copyright (c) 2019 Razeware LLC
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
import MapKit

public class BusinessMapViewModel: NSObject {
  
  // MARK: - Properties
  public let coordinate: CLLocationCoordinate2D
  public let name: String
  public let rating: Double
  public let image: UIImage //추가
  public let ratingDescription: String //추가
  
  // MARK: - Object Lifecycle
  public init(coordinate: CLLocationCoordinate2D,
              name: String,
              rating: Double,
              image: UIImage) {
    self.coordinate = coordinate
    self.name = name
    self.rating = rating
    self.image = image
    self.ratingDescription = "\(rating) stars"
  }
}

// MARK: - MKAnnotation
extension BusinessMapViewModel: MKAnnotation {
  
  public var title: String? {
    return name
  }
  
  public var subtitle: String? { //subtitle 설정 추가
    return ratingDescription
  }
}

//MapPin을 View Model로 변경한다. 먼저 적절한 이름으로 바꿔준다.
//MapPin을 마우스 우클릭 한 후, Refactor ▸ Rename을 선택한다.
//BusinessMapViewModel으로 이름을 변경해 준다.
//Models Group도 ViewModels으로 이름을 변경해 준다.
//다음, 기본 MapPin보다 더 다양한 속성을 표시하기 위해 코드를 추가한다.
//image, ratingDescription 속성을 추가해 준다.
//기본 핀 대신 이미지를 사용하여 사용자가 annotation을 누를 때마다 ratingDescription을 표시한다.
//생성자에서도 해당 속성을 초기화 시켜 준다.
