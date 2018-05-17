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

@objcMembers class Video: Content {
  dynamic var authorNotes: String?
  dynamic var episode: Int = 0
  dynamic var format: String = ""
  let clips = List<Clip>()
  let collections = LinkingObjects(fromType: Collection.self, property: "videos")
  private(set) lazy var viewing: Viewing = realm!.viewingFor(video: self)
  
  override static func ignoredProperties() -> [String] {
    return ["viewing", "viewingChangeToken", "progressChangedCallback"]
  }
  
  private enum CodingKeys: String, CodingKey {
    case authorNotes = "author_notes"
    case episode
    case format
    case clips
  }
  
  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.authorNotes = try? container.decode(String.self, forKey: .authorNotes)
    self.episode     = (try? container.decode(Int.self, forKey: .episode)) ?? 0
    self.format      = try container.decode(String.self, forKey: .format)
    
    try super.init(from: decoder)
    
    if let clips = try? container.decode([Clip].self, forKey: .clips) {
      self.clips.append(objectsIn: clips)
    }
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

extension Video {
  var streamUrl: URL? {
    guard let clip = clips.first,
      let stream = clip.attachments.first(where: { $0.kind == .stream }) else { return .none }
    
    return URL(string: stream.url)
  }
}

extension Video: CardViewModel {
  func observeProgressChange(callback: @escaping (ProgressChange) -> ()) -> NotificationToken {
     return viewing.observe({ change in
      switch change {
      case .change(let properties):
        // Only care if the change affects the progress
        if properties.filter({ ["time", "duration", "finished"].contains($0.name) }).count > 0 {
          callback(.changed)
        }
      default:
        callback(.deleted)
      }
    })
  }
  
  var imageURL: URL? {
    guard let urlString = attachments.filter("retina == true && rawKind == %@", Attachment.Kind.video_banner.rawValue).first?.url else { return .none }
    return URL(string: urlString)
  }
  
  var proportionComplete: Double {
    return viewing.proportionComplete
  }
  
  var complete: Bool {
    return viewing.finished
  }
}
