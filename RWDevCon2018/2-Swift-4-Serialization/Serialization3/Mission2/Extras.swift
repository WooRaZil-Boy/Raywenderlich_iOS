// Copyright (c) 2018 Razeware LLC
// For full license & permission details, see LICENSE.markdown.

import Foundation

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
    print("<-- RockSample")
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.mass = try container.decode(Double.self, forKey: .mass)
    self.rockType = try container.decode(RockType.self, forKey: .rockType)
    try super.init(from: container.superDecoder(forKey: .sample))
  }
  
  override func encode(to encoder: Encoder) throws {
    print("--> RockSample")
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(mass, forKey: .mass)
    try container.encode(rockType, forKey: .rockType)
    try super.encode(to: container.superEncoder(forKey: .sample))
  }
}

func ==(lhs: Sample, rhs: Sample) -> Bool {
  return lhs.date == rhs.date
}

enum TestError: Error {
  case notEqual
  case dataCorrupt
}

func roundTripTest<T: Codable & Equatable>(item: T) throws {
  let encoder = JSONEncoder()
  let data = try encoder.encode(item)
  let decoder = JSONDecoder()
  let restored = try decoder.decode(T.self, from: data)
  if item != restored {
    NSLog("Expected")
    dump(item)
    NSLog("Actual")
    dump(restored)
    throw TestError.notEqual
  }
}

func archiveTest<T: Codable & Equatable>(json: String, expected: T) throws {
  guard let data = json.data(using: .utf8) else {
    throw TestError.dataCorrupt
  }
  let decoder = JSONDecoder()
  let restored = try decoder.decode(T.self, from: data)
  if expected != restored {
    NSLog("Expected")
    dump(expected)
    NSLog("Actual")
    dump(restored)
    throw TestError.notEqual
  }
}

