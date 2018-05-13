// Copyright (c) 2018 Razeware LLC
// For full license & permission details, see LICENSE.markdown.

// # Mission 2
//
// Make `Distance<Units>` output {"feet" = 3} or {"meters" = 1} depending
// on the `Units` type being used.  Generate a runtime error
// if the wrong `Distance` type is loaded from.


import XCTest

// Length Phantom types and Distance definition.

protocol Length {}
struct Feet: Length {}
struct Meters: Length {}

struct Distance<Units: Length>: Codable, Equatable, ExpressibleByFloatLiteral {
  var value: Double
    
    static var unitName: String {
        return String(describing: Units.self).lowercased()
        //일반 매개 변수 Units가 소문자로 변환된다. 이를 CodingKeys 대신 사용한다.
    }
    
    struct UnitsKey: CodingKey { //사용자 정의 키 유형
        var stringValue: String
        var intValue: Int? { return nil }
        
        init?(stringValue: String) {
            self.stringValue = stringValue
        }
        
        init?(intValue: Int) { fatalError() }
    }
    
  init(floatLiteral value: Double) {
    self.value = value
  }
  
  enum CodingKeys: String, CodingKey {
    case value
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: UnitsKey.self)
    self.value = try container.decode(Double.self, forKey: UnitsKey(stringValue: Distance.unitName)!)
    //사용자 정의 키를 사용해 디코딩
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: UnitsKey.self)
    try container.encode(value, forKey: UnitsKey(stringValue: Distance.unitName)!)
    //사용자 정의 키를 사용해 인코딩
  }
}

//Distance <Units> 유형은 현재 { "value": 3.25 } 로 일련화된다.
//유형에 따라 { "feet = 3 } 또는 { "meters "= 1 } 로 직렬화되도록 한다.

class Mission2: XCTestCase {
  func testThrowsKeyNotFound() {
    let measurements: [Distance<Feet>] = [3.25, 4.25, 0.25]
    let encoder = JSONEncoder()
    let data = try! encoder.encode(measurements)
    print(String(data: data, encoding: .utf8)!)
    
    let decoder = JSONDecoder()
    dump(decoder)
    
    XCTAssertThrowsError(try decoder.decode([Distance<Meters>].self, from: data))
  }
}
