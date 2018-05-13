// Copyright (c) 2018 Razeware LLC
// For full license & permission details, see LICENSE.markdown.

// # Mission 1
// Implement Codable and test it with some encoders and decoders.

import Foundation
import XCTest

// Mars Rover Implementation

struct Sols: Codable {
  var value: Double
  init(_ value: Double) {
    self.value = value
  }
}

enum Camera: String, Codable {
    //Codable을 선언하면, enum에 대한 코드를 자동으로 생성할 수 없다.
    //String을 추가해서 rawValue에 대한 접근이 가능하도록 해 준다.
  case mahli, mast, navcams, chemcam
}

struct Photo: Codable {
  var url: URL?
  var camera: Camera
  var time: Sols
}

struct Rover: Codable {
  var name: String
  var photos: [Photo]
}

// Testing

class Mission1: XCTestCase {
  let curiosity = Rover(name: "Curiosity", photos:
    [Photo(url: URL(string:"https://go.nasa.gov/2nquyg9"),
           camera: .navcams,
           time: Sols(1949))])
    //테스트 위한 객체 생성(Rover)
  
  func testEncodeDecodeJSON() throws {
    let encoder = JSONEncoder() //인코더
    let data = try encoder.encode(curiosity) //인코딩
    print(String(data: data, encoding: .utf8)!)
    
    let decoder = JSONDecoder() //디코더
    let restored = try decoder.decode(Rover.self, from: data) //디코딩
    dump(restored) //print와 비슷. 정렬해서 출력한다.
  }
  
  func testEncodeDecodePlist() throws {
    let encoder = PropertyListEncoder() //인코더
    encoder.outputFormat = .xml
    let data = try encoder.encode(curiosity) //인코딩
    print(String(data: data, encoding: .utf8)!)
    
    let decoder = PropertyListDecoder() //디코더
    let restored = try decoder.decode(Rover.self, from: data) //디코딩
    dump(restored)
  }
}


//Codable은 Decodable과 Encodable을 합친 것이다.
//JSONncoder, JSONDecoder, PropertyListEncoder, PropertyListDecoder 등으로 인코딩/디코딩 한다.

//간단히 Codable를 선언해 주는 것만으로, 직렬화할 수 있다.

