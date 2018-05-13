// Copyright (c) 2018 Razeware LLC
// For full license & permission details, see LICENSE.markdown.

// # Mission 3
// Custom `Codable` implementation of `Rover`.
// This will handle a change of "name" to "rover_name" and "value" to "sols".
// ```
//  {"rover_name":"Curiosity","photos":[
//    {"url":"https://go.nasa.gov/2nquyg9","camera":"navcams","time":{"sols":1949}}
//  ]}
// ```
//

import Foundation
import XCTest

// Mars Rover Implementation


struct Sols: Codable, Equatable {
  var value: Double
  init(_ value: Double) {
    self.value = value
  }
    
    enum CodingKeys: String, CodingKey {
        //CodingKey: 인코딩 및 디코딩에서 키로 사용할 수 있다.
        //JSON과 객체에서 변수의 이름이 다른 경우(여기서는 value, sols)
        //http://zeddios.tistory.com/394
        case value = "sols"
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

struct Rover: Equatable {
  var name: String
  var photos: [Photo]
}

extension Rover: Codable {

  enum CodingKeys: String, CodingKey {
    case name = "rover_name"
    //CodingKey: 인코딩 및 디코딩에서 키로 사용할 수 있다.
    //JSON과 객체에서 변수의 이름이 다른 경우(여기서는 name, rover_name)
    case photos
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    name = try container.decode(String.self, forKey: .name)
    photos = try container.decode([Photo].self, forKey: .photos)
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(name, forKey: .name)
    try container.encode(photos, forKey: .photos)
  }
}

// The tests

class Mission3: XCTestCase {
  func testCodable() throws {
    try roundTripTest(item: curiosity)
    try archiveTest(json: curiosityJSON, expected: curiosity)
  }
}

//여기서는 파일 형식에 대한 몇 가지 변경 사항을 처리한다 (name -> rover_name, value -> sols).
