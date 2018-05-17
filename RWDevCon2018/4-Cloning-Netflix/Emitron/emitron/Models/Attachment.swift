/*
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
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import Foundation
import RealmSwift

@objcMembers class Attachment: Object, Decodable {
  enum Kind: String, Decodable {
    case card_artwork
    case featured_banner
    case materials
    case stream
    case thumbnail
    case video_banner
    case watchlist_artwork
    case subtitles
    case twitter_card
    case collection_asset_bundle
    case video_asset_bundle
  }
  
  dynamic var id: Int = 0
  dynamic var url: String = ""
  dynamic var retina: Bool = false
  dynamic var rawKind: String = ""
  
  var kind: Kind {
    set {
      self.rawKind = kind.rawValue
    }
    get {
      return Kind(rawValue: self.rawKind)!
    }
  }
  
  enum CodingKeys: String, CodingKey {
    case id
    case url
    case retina
    case rawKind = "kind"
  }
  
  override static func primaryKey() -> String? {
    return "id"
  }
}
