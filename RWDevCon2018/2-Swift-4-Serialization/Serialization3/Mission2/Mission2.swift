// Copyright (c) 2018 Razeware LLC
// For full license & permission details, see LICENSE.markdown.

// # Mission 2
//
// For this mission you will create a relationship between
// `Sample` and `Rover` and encode and decode this
// relationship properly.

import XCTest

// Sample Definition
class Sample: Codable, Equatable {
  var date: Date
    weak var rover: Rover?
  init(date: Date) {
    self.date = date
  }
  
  enum SampleCodingKeys: String, CodingKey {
    case date //, rover
  }
  
  required init(from decoder: Decoder) throws {
    print("<-- Sample")
    let container = try decoder.container(keyedBy: SampleCodingKeys.self)
    self.date = try dateStringDecode(forKey: .date, from: container, with: .iso8601Milliseconds, .iso8601)
    // self.rover = try container.decodeIfPresent(Rover.self, forKey: .rover)
  }
  
  func encode(to encoder: Encoder) throws {
    print("--> Sample")
    var container = encoder.container(keyedBy: SampleCodingKeys.self)
    try container.encode(date, forKey: .date)
    try container.encode(DateFormatter.iso8601Milliseconds.string(from: date), forKey: .date)
    // try container.encode(rover, forKey: .rover)
  }
}

// Rover Definition
final class Rover: Codable, Equatable {
  var name: String
  var launchDate: Date
  var rockSamples: [RockSample]
  
  enum CodingKeys: String, CodingKey {
    case name, launchDate = "launch_date", rockSamples = "rock_samples"
  }
  
  init(name: String, launchDate: Date, rockSamples: [RockSample]) {
    //member-wise initializer
    self.name = name
    self.launchDate = launchDate
    self.rockSamples = rockSamples
    rockSamples.forEach { $0.rover = self } //추가
  }
  
  init(from decoder: Decoder) throws {
    print("<-- Rover")
    let container = try decoder.container(keyedBy: CodingKeys.self)
    name = try container.decode(String.self, forKey: .name)
    launchDate = try dateStringDecode(forKey: .launchDate, from: container, with: .yearMonthDay)
    rockSamples = try container.decode([RockSample].self, forKey: .rockSamples)
    rockSamples.forEach { $0.rover = self } //추가
  }
  
  func encode(to encoder: Encoder) throws {
    print("--> Rover")
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(name, forKey: .name)
    try container.encode(DateFormatter.yearMonthDay.string(from: launchDate), forKey: .launchDate)
    try container.encode(rockSamples, forKey: .rockSamples)
  }
  
  static func ==(lhs: Rover, rhs: Rover) -> Bool {
    return lhs.name == rhs.name &&
      lhs.launchDate == rhs.launchDate &&
        lhs.rockSamples == rhs.rockSamples && !zip(lhs.rockSamples, rhs.rockSamples).contains { $0.rover?.name != $1.rover?.name }
    //rockSample도 확인해(name 확인) equal 확인
  }
}

//relationship 처라

class Mission2: XCTestCase {
  func testRoverCodable() throws {
    let testDate = DateFormatter.iso8601Milliseconds.date(from: "2018-02-23T09:51:33.013-0800")!
    let rockSamples = [
      RockSample(mass: 10, rockType: .igneous, date: testDate),
      RockSample(mass: 21, rockType: .metamorphic, date: testDate),
      RockSample(mass: 55, rockType: .sedimentary, date: testDate)]
    
    let curiosity = Rover(name: "Curiosity", launchDate: DateFormatter.yearMonthDay.date(from: "2011-11-26")!, rockSamples: rockSamples)
    dump(curiosity)
//    XCTFail()
    XCTAssertEqual(curiosity.rockSamples.first?.rover?.name, "Curiosity")
    
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    let data = try encoder.encode(curiosity)
    print(String(data: data, encoding: .utf8)!)
    try roundTripTest(item: curiosity)
  }
}
