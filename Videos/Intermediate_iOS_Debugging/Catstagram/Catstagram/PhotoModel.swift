/**
 * Copyright (c) 2018 Razeware LLC
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

class PhotoModel: NSObject {
  var url: URL?
  var photoID: Int?
  var uploadDateString: String?
  var title: String?
  var descriptionText: String?
  var commentsCount: UInt?
  var likesCount: UInt?
  
  var location: LocationModel?
  var ownerUserProfile: UserModel?
  var commentFeed: CommentFeedModel
  
  init(photoDictionary: [String: Any]) {
    let urlArray = photoDictionary["image_url"] as! [String]
    let urlString = urlArray.first!

    url              = URL(string: urlString)
    uploadDateString = photoDictionary["created_at"] as? String
    photoID          = photoDictionary["id"] as? Int
    title            = photoDictionary["title"] as? String
    descriptionText  = photoDictionary["name"] as? String
    commentsCount    = photoDictionary["comments_count"] as? UInt
    likesCount       = photoDictionary["positive_votes_count"] as? UInt
    uploadDateString = "13h"
    
    location         = LocationModel(photoDictionary: photoDictionary)
    commentFeed      = CommentFeedModel(photoID: photoID!)
    ownerUserProfile = UserModel(withDictionary: photoDictionary)
  }
  
  func descriptionAttributedString(withFontSize size: CGFloat) -> NSAttributedString {
    guard let username = ownerUserProfile?.username, let descriptionText = descriptionText else { return NSAttributedString() }
    return NSAttributedString(string: "\(username) \(descriptionText)", fontSize: CGFloat(size), color: .darkGray, firstWordColor: .darkBlue())
  }
  
  func uploadDateAttributedString(withFontSize size: Float) -> NSAttributedString {
    return NSAttributedString(string: uploadDateString, fontSize: CGFloat(size), color: .lightGray, firstWordColor: nil)
  }
  
  func likesAttributedString(withFontSize size: Float) -> NSAttributedString {
    guard let likesCount = likesCount else { return NSAttributedString() }
    let likesString = String(format: "%d likes".localized(comment: "Indicating the number of 'likes' for the photo"), likesCount)
    return NSAttributedString(string: likesString, fontSize: CGFloat(size), color: .darkBlue(), firstWordColor: nil)
  }
  
  func locationAttributedString(withFontSize size: Float) -> NSAttributedString {
    guard let locationString = location?.locationString else { return NSAttributedString() }
    return NSAttributedString(string: "\(locationString)", fontSize: CGFloat(size), color: .darkGray, firstWordColor: .darkBlue())
  }
}
