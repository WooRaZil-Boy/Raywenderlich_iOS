// Copyright (c) 2018 Razeware LLC
// For full license & permission details, see LICENSE.markdown.

import Foundation

// test instance
let curiosity = Rover(name: "Curiosity", photos:
  [Photo(url: URL(string:"https://go.nasa.gov/2nquyg9"),
         camera: .navcams,
         time: Sols(1949))])

// test data
let curiosityJSON = """
{"rover_name":"Curiosity","photos":[{"url":"https://go.nasa.gov/2nquyg9","camera":"navcams","time":{"sols":1949}}]}
"""

// Required by Swift 4 and earlier.
func ==(lhs: Sols, rhs: Sols) -> Bool {
  return lhs.value == rhs.value
}
func ==(lhs: Photo, rhs: Photo) -> Bool {
  return lhs.url == rhs.url && lhs.camera == rhs.camera && lhs.time == rhs.time
}
func ==(lhs: Rover, rhs: Rover) -> Bool {
  return lhs.name == rhs.name && lhs.photos == rhs.photos
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
  let restored: T
  do {
    restored = try decoder.decode(T.self, from: data)
  }
  catch {
    dump(error)
    throw error
  }
  if expected != restored {
    NSLog("Expected")
    dump(expected)
    NSLog("Actual")
    dump(restored)
    throw TestError.notEqual
  }
}
