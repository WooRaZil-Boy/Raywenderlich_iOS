// Copyright (c) 2018 Razeware LLC
// For full license & permission details, see LICENSE.markdown.

import Foundation


// Stuff you have looked at before
struct Sols: Codable, Equatable {
  
  enum CodingKeys: String, CodingKey {
    case value = "sols"
  }
  
  var value: Double
  init(_ value: Double) {
    self.value = value
  }
}

enum Camera: String, Codable, Equatable {
  case mahli, mast, navcams, chemcam
}

struct Photo: Codable, Equatable {
  var url: URL?
  var camera: Camera
  var time: Sols
}

// Required by Swift 4 and earlier.
func ==(lhs: Sols, rhs: Sols) -> Bool {
  return lhs.value == rhs.value
}
func ==(lhs: Photo, rhs: Photo) -> Bool {
  return lhs.url == rhs.url && lhs.camera == rhs.camera && lhs.time == rhs.time
}
func ==(lhs: Rover, rhs: Rover) -> Bool {
  return lhs.name == rhs.name && lhs.missionData == rhs.missionData
}
func ==(lhs: Rover.MissionData, rhs: Rover.MissionData) -> Bool {
  switch (lhs.photos, rhs.photos) {
  case (let left?, let right?):
    return left == right
  default:
    return false
  }
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
