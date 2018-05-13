// Copyright (c) 2018 Razeware LLC
// For full license & permission details, see LICENSE.markdown.

// # Mission 3
//
// Make an `AnyDistance` type that can handle `Distance<Meters>` or `Distance<Feet>`
// It should be able to read in a JSON archive that looks like this:
// [{"feet":3.25},{"meters":4.25},{"feet":0.25}]

import XCTest

enum AnyDistance: Codable {
  
  enum CodingKeys: String, CodingKey {
    case meters
    case feet
  }
  
  case meters(Distance<Meters>)
  case feet(Distance<Feet>)
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    
    switch self {
    case .meters(let meters):
      try container.encode(meters.value, forKey: .meters)
    case .feet(let feet):
      try container.encode(feet.value, forKey: .feet)
    }
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    guard container.allKeys.count == 1 else {
      let context = DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "wrong number of keys")
      throw DecodingError.dataCorrupted(context)
    }
    
    let key = container.allKeys[0]
    
    switch key {
    case .meters:
        self = .meters(try Distance<Meters>(from: decoder))
    case .feet:
        self = .feet(try Distance<Feet>(from: decoder))
    }
    
//    enum Err: Error { case NotImplemented }
//    throw Err.NotImplemented
  }
}

//다형성 컨트롤

class Mission3: XCTestCase {
  func testVariantDistance() throws {
    let jsonString = """
      [{"feet":3.25},{"meters":4.25},{"feet":0.25}]
      """
    let jsonData = jsonString.data(using: .utf8)!
  
    let decoder = JSONDecoder()
    let restored = try decoder.decode([AnyDistance].self, from: jsonData)
    //AnyDistance로 업데이트
    XCTAssertEqual(restored.count, 3)
  }
}


