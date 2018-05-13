// Copyright (c) 2018 Razeware LLC
// For full license & permission details, see LICENSE.markdown.

// # Mission 1
//
// Modify Photo so that when the `url` is `nil` it always outputs
//   a url key with a JSON value of null.

import XCTest

struct Photo: Codable, Equatable {
  
  enum CodingKeys: String, CodingKey {
    case url, camera, time
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
//    try container.encodeIfPresent(url, forKey: .url)
    //nil이 아닐 때 인코딩
    try container.encode(url, forKey: .url)
    //테스트를 위해서 nil인 경우에도 인코딩
    try container.encode(camera, forKey: .camera)
    try container.encode(time, forKey: .time)
  }
  
  init(url: URL?, camera: Camera, time: Sols) {
    self.url = url
    self.camera = camera
    self.time = time
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.url = try container.decodeIfPresent(URL.self, forKey: .url)
    //nil이 아닐 때 디코딩
    self.camera = try container.decode(Camera.self, forKey: .camera)
    self.time = try container.decode(Sols.self, forKey: .time)
  }
  
  var url: URL?
  var camera: Camera
  var time: Sols
}

class Mission1: XCTestCase {
    func testAlwaysIncludeNull() throws {
      let photo = Photo(url: nil, camera: .chemcam, time: Sols(2))
      let encoder = JSONEncoder()
      let data = try encoder.encode(photo)
      let string = String(data: data, encoding: .utf8)!
      print(string)
      try roundTripTest(item: photo)
      XCTAssertNotNil(string.range(of: "\"url\":"))
    }
}

//nil 처리

//값이 누락되거나, 잘못된 다형성 유형, 충돌, nil 등의 경우의 직렬화
