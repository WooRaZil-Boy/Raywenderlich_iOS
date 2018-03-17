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
import CoreData
import UIKit

class Note: NSManagedObject {
  @NSManaged var title: String
  @NSManaged var body: String
  @NSManaged var dateCreated: Date!
  @NSManaged var displayIndex: NSNumber!
//  @NSManaged var image: UIImage? //v2에서 추가됨 //v3에서 삭제됨
  @NSManaged var attachments: Set<Attachment>? //v3에서 추가됨
  
  var image: UIImage? {
    let imageAttachment = latestAttachment as? ImageAttachment
    return imageAttachment?.image
  }
  
  var latestAttachment: Attachment? {
    guard let attachments = attachments, let startingAttachment = attachments.first else {
      //이미지 셋이 존재하고, 첫번째 이미지가 있는 경우에만, 없으면 nil
      return nil
    }
    
    return Array(attachments).reduce(startingAttachment) { //배열로 캐스팅 후 reduce
      $0.dateCreated.compare($1.dateCreated) == .orderedAscending ? $0 : $1
      //reduce는 재귀적으로 클로저를 적용시켜 하나의 값을 만든다.
      //array.reduce(0) {$0 + $1} (ex. 배열 요소들의 총 합) array.reduce(0, +)로 쓸 수도 있다.
      //여기서는 startingAttachment부터 시작해 비교해서 가장 최신의 image를 반환하게 한다.
      //총 합을 구하는 것 외에도 이런 식으로 하나의 값을 찾는 데 사용할 수 있다.
    }
  }
  
  
  override func awakeFromInsert() {
    super.awakeFromInsert()
    dateCreated = Date()
  }
}
