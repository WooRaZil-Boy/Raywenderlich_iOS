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
import Realm

@objcMembers class Viewing: Object, Decodable {
  let rawCollectionId = RealmOptional<Int>()
  dynamic var videoId: Int = 0
  dynamic var time: Int = 0
  dynamic var duration: Int = 0
  dynamic var finished: Bool = false
  dynamic var updatedAt: Date = Date(timeIntervalSince1970: 0)
  dynamic var dirty: Bool = false
  
  var collectionId: Int? {
    get {
      return rawCollectionId.value
    }
    set {
      rawCollectionId.value = newValue
    }
  }
  
  var proportionComplete: Double {
    return Double(time) / Double(duration)
  }
  
  enum CodingKeys: String, CodingKey {
    case collectionId = "collection_id"
    case videoId = "video_id"
    case time
    case duration
    case finished
    case updatedAt = "updated_at"
  }
  
  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    videoId   = try container.decode(Int.self, forKey: .videoId)
    time      = try container.decode(Int.self, forKey: .time)
    duration  = try container.decode(Int.self, forKey: .duration)
    finished  = try container.decode(Bool.self, forKey: .finished)
    updatedAt = try container.decode(Date.self, forKey: .updatedAt)
    
    super.init()
    
    collectionId = try? container.decode(Int.self, forKey: .collectionId)
  }
  
  required init() {
    super.init()
  }
  
  required init(value: Any, schema: RLMSchema) {
    super.init(value: value, schema: schema)
  }
  
  required init(realm: RLMRealm, schema: RLMObjectSchema) {
    super.init(realm: realm, schema: schema)
  }
}

extension Viewing {
  func updateFrom(remote: Viewing) {
    self.finished = remote.finished
    self.updatedAt = remote.updatedAt
    self.time = remote.time
    self.dirty = false
  }
}
