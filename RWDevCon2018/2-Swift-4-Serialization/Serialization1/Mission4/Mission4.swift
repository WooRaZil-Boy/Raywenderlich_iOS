// Copyright (c) 2018 Razeware LLC
// For full license & permission details, see LICENSE.markdown.

// # Mission 4
// Another custom `Codable` implementation of `Rover`. This time "photos"
// is wrapped by a "mission_data" container and "photos" may or may not be
// present.  You will solve this by creating a new type `MissionData`.
// ```
//  {"rover_name":"Curiosity",
//   "mission_data": {
//      "photos":[
//          {"url":"https://go.nasa.gov/2nquyg9","camera":"navcams","time":{"sols":1949}}
//      ]}
//  }
// ```

import Foundation
import XCTest

// Mars Rover Implementation

struct Rover: Codable, Equatable {
  
  enum CodingKeys: String, CodingKey {
    case name = "rover_name"
    case missionData = "mission_data"
  }
  
  var name: String
  
  struct MissionData: Codable, Equatable {
    var photos: [Photo]?
  }
  var missionData: MissionData
}

// Testing

class Mission4: XCTestCase {

  let curiosity = Rover(name: "Curiosity", missionData: Rover.MissionData(photos:
    [Photo(url: URL(string:"https://go.nasa.gov/2nquyg9"),
           camera: .navcams,
           time: Sols(1949))]))
  
  let curiosityJSON = """
{"rover_name":"Curiosity","mission_data": {"photos":[{"url":"https://go.nasa.gov/2nquyg9","camera":"navcams","time":{"sols":1949}}]}}
"""
  
  func testCodable() throws {
     try roundTripTest(item: curiosity)
     try archiveTest(json: curiosityJSON, expected: curiosity)
  }
}

//photos가 중첩된 Dictionary 안에 쌓여 있다(mission_data). optional
//이것을 처리하기 위해 모델을 변경하고 컴파일러를 사용하여 직렬화한다.
