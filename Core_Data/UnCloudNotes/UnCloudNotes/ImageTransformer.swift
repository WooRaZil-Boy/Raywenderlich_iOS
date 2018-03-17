/**
 * Copyright (c) 2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
 * distribute, sublicense, create a derivative work, and/or sell copies of the
 * Software in any work that is designed, intended, or marketed for pedagogical or
 * instructional purposes related to programming, coding, application development,
 * or information technology.  Permission for such use, copying, modification,
 * merger, publication, distribution, sublicensing, creation of derivative works,
 * or sale is expressly withheld.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import Foundation
import UIKit

class ImageTransformer: ValueTransformer { //값을 변환해 준다.

  override class func transformedValueClass() -> AnyClass {
    return NSData.self
  }

  override class func allowsReverseTransformation() -> Bool {
    return true
  }
  
  override func reverseTransformedValue(_ value: Any?) -> Any? {
    guard let data = value as? Data else { return nil }

    return UIImage(data: data)
  }

  override func transformedValue(_ value: Any?) -> Any? {
    guard let image = value as? UIImage else { return nil }

    return UIImagePNGRepresentation(image)
  }
}

//Data Model 편집기에서 어트리뷰트의 속성을 Transformable로 지정하면, 이진 비트로 저장한다.
//기본 자료형이 아닌 경우 타입을 Transformable 유형으로 지정할 수 있다.
//편집기에서 직접 해당 클래스를 지정해 줄 수 있는데, Custom Class에 클래스 이름을 설정하고 모듈을 지정해 주면 된다. p.151
//NSCoding을 구현한 객체이면 Custom Class에 그냥 추가해 주면 된다. 그렇지 않으면 NSValueTransformer로 변환기를 만들어야 한다.

//여기에서는 Custom Class에 ImageTransformer를 직접 추가해 줬지만,
//Custom class는 UIImage로 하고, Value Transformer Name에 ValueTransformer를 넣어줘도 된다.
//https://soooprmx.com/archives/9047

//Lightweight migrations으로 v2에 추가되면, 이미지는 optional이고 default nil이다. (3번 패턴)
//optional로 설정하지 않는 경우 기본값을 따로 설정해 주지 않으면 Lightweight migrations이 되지 않는다.
