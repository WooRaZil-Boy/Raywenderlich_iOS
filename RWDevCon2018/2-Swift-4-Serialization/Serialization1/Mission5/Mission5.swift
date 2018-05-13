// Copyright (c) 2018 Razeware LLC
// For full license & permission details, see LICENSE.markdown.

// # Mission 5
// Just like photos Mission 4, "photos" are wrapped by a "mission_data" container
// and "photos" may or may not be present. This time you will solve it using
// a custom Codable implementation and not use a `MissionData` model.
//
// ```
// {"rover_name":"Curiosity","mission_data":{"photos":[{"url":"https://go.nasa.gov/2nquyg9","camera":"navcams","time":{"sols":1949}}]}}
// ```

import Foundation
import XCTest

// Mars Rover Implementation

struct Rover: Equatable {
  var name: String
  var photos: [Photo]
}

extension Rover: Codable { //Mission 3에서 복사
    
    enum CodingKeys: String, CodingKey {
        case name = "rover_name"
        //CodingKey: 인코딩 및 디코딩에서 키로 사용할 수 있다.
        //JSON과 객체에서 변수의 이름이 다른 경우(여기서는 name, rover_name)
        case missionData = "mission_data" //업데이트
    }
    
    enum MissionDataCodingKeys: String, CodingKey {
        case photos
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        let missionDataContainer = try container.nestedContainer(keyedBy: MissionDataCodingKeys.self, forKey: .missionData)
        photos = try missionDataContainer.decodeIfPresent([Photo].self, forKey: .photos) ?? []
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        let optionalPhotos: [Photo]? = photos.isEmpty ? nil : photos
        var missionDataContainer = container.nestedContainer(keyedBy: MissionDataCodingKeys.self, forKey: .missionData)
        try missionDataContainer.encodeIfPresent(optionalPhotos, forKey: .photos)
    }
}

class Mission5: XCTestCase {
  func testCodable() throws {
    try roundTripTest(item: curiosity)
    try archiveTest(json: curiosityJSON, expected: curiosity)
  }
}

//중첩 컨테이너 추가

