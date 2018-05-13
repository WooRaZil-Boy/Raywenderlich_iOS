// Copyright (c) 2018 Razeware LLC
// For full license & permission details, see LICENSE.markdown.

// # Mission 4
//
// Make the `RockSample` properly `Codable`.  Put the super class information
// in a key called `sample`.

import XCTest

class Sample: Codable, Equatable {
  var date: Date
  init(date: Date) {
    self.date = date
  }
}

// Derived class RockSample

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
//    enum Err: Error { case NotImplemented }
//    throw Err.NotImplemented
    
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.mass = try container.decode(Double.self, forKey: .mass)
    self.rockType = try container.decode(RockType.self, forKey: .rockType)
    try super.init(from: container.superDecoder(forKey: .sample))
    //부모 클래스 디코딩
  }

  override func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(mass, forKey: .mass)
    try container.encode(rockType, forKey: .rockType)
    try super.encode(to: container.superEncoder(forKey: .sample))
    //부모 클래스 인코딩
  }
}

//상속 클래스

class Mission4: XCTestCase {    

  func testDerivedClass() throws {
    let rockSample = RockSample(mass: 10, rockType: .igneous, date: Date())
    
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    let data = try encoder.encode(rockSample)
    print(String(data: data, encoding: .utf8)!)
    
    try roundTripTest(item: rockSample)
  }

}
