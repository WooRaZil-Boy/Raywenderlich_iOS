// Copyright (c) 2018 Razeware LLC
// For full license & permission details, see LICENSE.markdown.

import Foundation

extension DateFormatter {
  // Handles dates of the form "2018-04-07"
  public static let yearMonthDay: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    formatter.locale = Locale(identifier: "en_US_POSIX")
    return formatter
  }()
  
  // Handles dates of the form "2018-02-22T23:35:48.945-0800"
  public static let iso8601Milliseconds: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    formatter.locale = Locale(identifier: "en_US_POSIX")
    return formatter
  }()
  
  // Handles dates of the form "2018-02-22T23:34:24-0800"
  public static let iso8601: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ";
    formatter.locale = Locale(identifier: "en_US_POSIX")
    return formatter
  }()
}

public
func dateStringDecode<C>(forKey key: C.Key, from container: C, with formatters: DateFormatter...) throws -> Date
  where C: KeyedDecodingContainerProtocol {
    let dateString = try container.decode(String.self, forKey: key)
    
    for formatter in formatters {
      if let date = formatter.date(from: dateString) {
        return date
      }
    }
    throw DecodingError.dataCorruptedError(forKey: key, in: container, debugDescription: dateString)
}

// Sample Definition
class Sample: Codable, Equatable {
  var date: Date
  weak var rover: Rover?
  init(date: Date) {
    self.date = date
  }
  
  enum SampleCodingKeys: String, CodingKey {
    case date, rover
  }
  
  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: SampleCodingKeys.self)
    self.date = try dateStringDecode(forKey: .date, from: container, with: .iso8601Milliseconds, .iso8601)
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: SampleCodingKeys.self)
    try container.encode(date, forKey: .date)
    try container.encode(DateFormatter.iso8601Milliseconds.string(from: date), forKey: .date)
  }
}

// RockSample Definition
class RockSample: Sample {
  enum CodingKeys: String, CodingKey {
    case sample, mass, rockType = "type"
  }
  
  enum RockType: String, Equatable, Codable {
    case metamorphic, igneous, sedimentary
  }
  
  var mass: Double
  var rockType: RockType
  
  init(mass: Double, rockType: RockType, date: Date) {
    self.mass = mass
    self.rockType = rockType
    super.init(date: date)
  }
  
  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.mass = try container.decode(Double.self, forKey: .mass)
    self.rockType = try container.decode(RockType.self, forKey: .rockType)
    try super.init(from: container.superDecoder(forKey: .sample))
  }
  
  override func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(mass, forKey: .mass)
    try container.encode(rockType, forKey: .rockType)
    try super.encode(to: container.superEncoder(forKey: .sample))
  }
}


func ==(lhs: Sample, rhs: Sample) -> Bool {
  return lhs.date == rhs.date
}
