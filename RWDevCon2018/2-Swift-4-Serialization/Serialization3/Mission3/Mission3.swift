// Copyright (c) 2018 Razeware LLC
// For full license & permission details, see LICENSE.markdown.

// # Mission 3
//
// For this mission you will modify the behavior of the decoder
// to ignore `Rover` `rockSamples` that are invalid using a
// special key `deleteBadSamplesKey` in the `userInfo` dictionary.

import XCTest

struct FailableDecodeBox<Model: Decodable>: Decodable {
    let model: Model?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        model = try? container.decode(Model.self)
    }
}
//새로 선언한 구조체

// Rover Definition
final class Rover: Codable, Equatable {
  
  var name: String
  var launchDate: Date
  var rockSamples: [RockSample]
    
    static let deleteBadSamplesKey = CodingUserInfoKey(rawValue: "Rover.deleteBadSamples")!
    //커스텀 키
  
  enum CodingKeys: String, CodingKey {
    case name, launchDate = "launch_date", rockSamples = "rock_samples"
  }
  
  init(name: String, launchDate: Date, rockSamples: [RockSample]) {
    self.name = name
    self.launchDate = launchDate
    self.rockSamples = rockSamples
    rockSamples.forEach { $0.rover = self }
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    name = try container.decode(String.self, forKey: .name)
    launchDate = try dateStringDecode(forKey: .launchDate, from: container, with: .yearMonthDay)
    
    if let deleteBadSamples = decoder.userInfo[Rover.deleteBadSamplesKey] as? Bool, deleteBadSamples {
        rockSamples = try container.decode([FailableDecodeBox<RockSample>].self, forKey: .rockSamples).compactMap { $0.model }
    } else {
        rockSamples = try container.decode([RockSample].self, forKey: .rockSamples)
    }
    //if-else 추가
    
    rockSamples.forEach { $0.rover = self }
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(name, forKey: .name)
    try container.encode(DateFormatter.yearMonthDay.string(from: launchDate), forKey: .launchDate)
    try container.encode(rockSamples, forKey: .rockSamples)
  }
  
  static func ==(lhs: Rover, rhs: Rover) -> Bool {
    return lhs.name == rhs.name &&
      lhs.launchDate == rhs.launchDate &&
      lhs.rockSamples == rhs.rockSamples &&
      !zip(lhs.rockSamples, rhs.rockSamples).contains { $0.rover?.name != $1.rover?.name }
  }
}

class Mission3: XCTestCase {
  let jsonString = """
            {
              "name" : "Curiosity",
              "launch_date" : "2011-11-26",
              "rock_samples" : [
                {
                  "mass" : 10,
                  "type" : "igneous",
                  "sample" : {
                    "date" : "2018-02-23T09:51:33.013-0800"
                  }
                },
                {
                  "mass" : 21,
                  "type" : "metamorphical",
                  "sample" : {
                    "date" : "2018-02-23T09:51:33.013-0800"
                  }
                },
                {
                  "mass" : 55,
                  "type" : "sedimentary",
                  "sample" : {
                    "date" : "2018-02-23T09:51:33.013-0800"
                  }
                } ]
            }
            """
  
  func testCustomizeStrictness() throws {
    let data = jsonString.data(using: .utf8)!
    let decoder = JSONDecoder()
    XCTAssertThrowsError(try decoder.decode(Rover.self, from: data))
    
     decoder.userInfo = [Rover.deleteBadSamplesKey: true]
    let rover = try decoder.decode(Rover.self, from: data)
    XCTAssertEqual(rover.rockSamples.count, 2)
  }
}
