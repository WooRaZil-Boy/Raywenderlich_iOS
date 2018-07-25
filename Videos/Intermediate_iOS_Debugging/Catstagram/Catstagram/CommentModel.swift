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

class CommentModel {
  let dictionaryRepresentation: [String: Any]

  let commentID: UInt?
  let commenterID: UInt?
  let commenterUsername: String?
  let commenterAvatarURL: String?
  let body: String?
  let uploadDateString: String?

  init(withDictionary dictionary: [String: Any]) {
    dictionaryRepresentation = dictionary

    commentID = dictionary["id"] as? UInt
    commenterID = dictionary["user_id"] as? UInt
    body = dictionary["body"] as? String

    if let userDictionary = dictionary["user"] as? [String: Any] {
      commenterUsername = userDictionary["username"] as? String
      commenterAvatarURL = dictionary["userpic_url"] as? String
    } else {
      commenterUsername = nil
      commenterAvatarURL = nil
    }

    if let rawDate = dictionary["created_at"] as? String {
      uploadDateString = NSString.elapsedTime(sinceDate: rawDate) as String
    } else {
      uploadDateString = nil
    }
  }
  
  func commentAttributedString() -> NSAttributedString {
    return NSAttributedString(string: "\(commenterUsername?.lowercased() ?? "") \(body ?? "")", fontSize: 14, color: .darkGray, firstWordColor: .darkBlue())
  }

  func uploadDateAttributedString(with fontSize: CGFloat) -> NSAttributedString {
    return NSAttributedString(string: uploadDateString, fontSize: fontSize, color: .lightGray, firstWordColor: nil)
  }
}
