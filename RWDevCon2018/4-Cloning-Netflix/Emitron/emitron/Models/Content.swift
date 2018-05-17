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

@objcMembers class Content: Object, Decodable {
  dynamic var id: Int = 0
  dynamic var name: String = ""
  dynamic var contentDescription: String = ""
  dynamic var duration: Int = 0
  dynamic var prettyDuration: String = ""
  dynamic var releasedAt: Date = Date()
  dynamic var language: String?
  dynamic var platform: String?
  dynamic var editor: String?
  dynamic var rawDifficulty: String?
  dynamic var free: Bool = false
  
  let categories = List<Category>()
  let attachments = List<Attachment>()
  let authors = List<Author>()
  
  var difficulty: Difficulty? {
    set {
      self.rawDifficulty = newValue?.rawValue
    }
    get {
      guard let rawDifficulty = rawDifficulty else { return .none }
      return Difficulty(rawValue: rawDifficulty)
    }
  }
  
  override static func primaryKey() -> String? {
    return "id"
  }
  
  private enum CodingKeys: String, CodingKey {
    case id
    case name
    case contentDescription = "description"
    case duration
    case prettyDuration = "pretty_duration"
    case releasedAt = "released_at"
    case language
    case platform
    case editor
    case rawDifficulty = "raw_difficulty"
    case free
    case categories
    case authors
    case attachments
  }
  
  required init() {
    super.init()
  }
  
  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.id                 = try container.decode(Int.self, forKey: .id)
    self.name               = try container.decode(String.self, forKey: .name)
    self.contentDescription = try container.decode(String.self, forKey: .contentDescription)
    self.duration           = try container.decode(Int.self, forKey: .duration)
    self.prettyDuration     = try container.decode(String.self, forKey: .prettyDuration)
    self.releasedAt         = try container.decode(Date.self, forKey: .releasedAt)
    self.language           = try? container.decode(String.self, forKey: .language)
    self.platform           = try? container.decode(String.self, forKey: .platform)
    self.editor             = try? container.decode(String.self, forKey: .editor)
    self.rawDifficulty      = try? container.decode(String.self, forKey: .rawDifficulty)
    self.free               = try container.decode(Bool.self, forKey: .free)
    
    super.init()
    
    if let attachments = try? container.decode([Attachment].self, forKey: .attachments) {
      self.attachments.append(objectsIn: attachments)
    }
    if let authors = try? container.decode([Author].self, forKey: .authors) {
      self.authors.append(objectsIn: authors)
    }
    if let categories = try? container.decode([Category].self, forKey: .categories) {
      self.categories.append(objectsIn: categories)
    }
  }
  
  required init(value: Any, schema: RLMSchema) {
    super.init(value: value, schema: schema)
  }
  
  required init(realm: RLMRealm, schema: RLMObjectSchema) {
    super.init(realm: realm, schema: schema)
  }
}

extension Content {
  var domain: String? {
    return categories.filter("name BEGINSWITH %@", "domain:").first?.name
  }
  
  var primaryCategory: String? {
    return categories.filter("NOT name BEGINSWITH %@", "domain:").first?.name
  }
}

// Beginnings of CardViewModel conformance
extension Content {
  var labelText: String? {
    return self.free ? "FREE" : .none
  }
  
  var title: String {
    return name
  }
}
