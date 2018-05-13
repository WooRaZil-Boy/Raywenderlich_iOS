// Copyright (c) 2018 Razeware LLC
// For full license & permission details, see LICENSE.markdown.

import XCTest

// Length Phantom types and Distance definition.

protocol Length {}
struct Feet: Length {}
struct Meters: Length {}

struct Distance<Units: Length>: Codable, Equatable, ExpressibleByFloatLiteral {
  var value: Double
  
  init(_ value: Double) {
    self.value = value
  }
  
  init(floatLiteral value: Double) {
    self.value = value
  }
  static func ==(lhs: Distance<Units>, rhs: Distance<Units>) -> Bool {
    return lhs.value == rhs.value
  }
  
  struct UnitsKey: CodingKey {
    var stringValue: String
    init?(stringValue: String) {
      self.stringValue = stringValue
    }
    var intValue: Int? { return nil }
    init?(intValue: Int) { fatalError() }
  }
  
  static var unitName: String {
    return String(describing: Units.self).lowercased()
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: UnitsKey.self)
    self.value = try container.decode(Double.self, forKey: UnitsKey(stringValue: Distance.unitName)!)
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: UnitsKey.self)
    try container.encode(value, forKey: UnitsKey(stringValue: Distance.unitName)!)
  }
}
