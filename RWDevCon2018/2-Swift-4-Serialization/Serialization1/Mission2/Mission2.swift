// Copyright (c) 2018 Razeware LLC
// For full license & permission details, see LICENSE.markdown.

// # Mission 2
// Implement some testing for the `Rover`.

import XCTest
import Foundation

// Mars Rover Implementation

struct Sols: Codable, Equatable {
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

struct Rover: Codable, Equatable {
  var name: String
  var photos: [Photo]
}

// Test Utilities


enum TestError: Error {
  case notEqual
  case dataCorrupt
}

func roundTripTest<T: Codable & Equatable>(item: T) throws {
    //인코딩, 디코딩 처리과정에서 손실이 잃어나지 않도록한다.
    //하지만 오래된 기록까지 보호하지는 못한다.
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

// Testing

class Mission2: XCTestCase {
  let curiosity = Rover(name: "Curiosity", photos:
    [Photo(url: URL(string:"https://go.nasa.gov/2nquyg9"),
           camera: .navcams,
           time: Sols(1949))])
  
  let curiosityJSON = """
{"name":"Curiosity","photos":[{"url":"https://go.nasa.gov/2nquyg9","camera":"navcams","time":{"value":1949}}]}
"""
  
  func testCodable() throws {
    try roundTripTest(item: curiosity)
    try archiveTest(json: curiosityJSON, expected: curiosity)
  }
}

//여기서는 Equatable을 준수한다(Extras 참조).
