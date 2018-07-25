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

class UserModel {
  let userID: Int?
  let username: String?
  let firstName: String?
  let lastName: String?
  let fullName: String?
  let city: String?
  let state: String?
  let country: String?
  let about: String?
  let domain: String?

  let userPicURL: URL?
  let photoCount: Int?
  let galleriesCount: Int?
  let affection: Int?
  let friendsCount: Int?
  let followersCount: Int?
  let following: Bool?

  init?(withDictionary dictionary:[String: Any]) {
    guard let userDictionary = dictionary["user"] as? [String: Any] else { return nil }

    userID = userDictionary["user"] as? Int

    if let username = userDictionary["username"] as? String {
      self.username = username
    } else {
      username = "Anonymous".localized(comment: "User name, if none is found")
    }

    firstName = userDictionary["firstname"] as? String
    lastName = userDictionary["lastname"] as? String
    fullName = userDictionary["fullname"] as? String
    city = userDictionary["city"] as? String
    state = userDictionary["state"] as? String
    country = userDictionary["country"] as? String
    about = userDictionary["about"] as? String
    domain = userDictionary["domain"] as? String
    photoCount = userDictionary["photos_count"] as? Int

    galleriesCount = userDictionary["galleries_count"] as? Int
    affection = userDictionary["affection"] as? Int
    friendsCount = userDictionary["friends_count"] as? Int
    followersCount = userDictionary["followers_count"] as? Int
    following = userDictionary["following"] as? Bool

    if let urlString = userDictionary["userpic_url"] as? String {
      userPicURL = URL(string: urlString)
    } else {
      userPicURL = nil
    }
  }

  func usernameAttributedString(withFontSize fontSize: CGFloat) -> NSAttributedString {
    return NSAttributedString(string: username, fontSize: fontSize, color: .darkBlue(), firstWordColor: nil)
  }

  func fullNameAttributedString(withFontSize fontSize: CGFloat) -> NSAttributedString {
    return NSAttributedString(string: fullName, fontSize: fontSize, color: .lightGray, firstWordColor: nil)
  }

  func fetchAvatarImage(withCompletion completion: (() -> Void)) {

  }

  func downloadUserData(withCompletion completion: (() -> Void)) {

  }
}
