//: Chapter 22: Encoding and Decoding Types

import Foundation

//encoding, serialization
//decoding, deserialization

//Encodable and Decodable protocols
//Encodable, Decodable 프로토콜을 각각 구현하면 된다.

//What is Codable?
//Codable은 인코딩 디코딩 될 수 있음을 선언하는 프로토콜
typealias Codable = Encodable & Decodable //기본

//Automatic encoding and decoding
struct Employee { //Codable을 구현하면 stored properties가 모두 Codable해야 한다.
    var name: String //기본적인 유형들은 모두 Codable을 구현했다.
    var id: Int
    var favoriteToy: Toy //추가한 클래스나 구조체는 Codable을 구현해 줘야 한다.
    
    enum CodingKeys: String, CodingKey { //CodingKey를 사용하면, 직렬화된 형식이 일치하지 않을 경우, 이름을 바꿀 수 있다.
        //String 형태로 CodingKey를 구현. 다른 이름을 바꾸지 않을 속성들도 모두 포함시켜야 한다.
        case id = "employeeId"
        case name
        case gift
    } //이렇게 해 두면, JSON 프로퍼티가 CodingKeys에 맞춰서 구현된다.
    //CodingKeys가 컴파일 되면서 기본적으로 만들어 진다. 이름을 변경시켜야 할 경우 이를 직접 구현하면 된다.
}

//Manual encoding and decoding
//{"employeeId":7, "name":"John Appleseed","favoriteToy":{"name":"Teddy Bear"}}를
//{"employeeId":7, "name":"John Appleseed","gift": "Teddy Bear"}와 같이 JSON의 구조를 바꾸는 경우에는 단순히 이름만 변경하는 CodingKeys로 해결할 수 없다. -> 직접 구현해야 한다.

//The encode function
extension Employee: Encodable {
    func encode(to encoder: Encoder) throws { //encode를 직접 구현한다.
        var container = encoder.container(keyedBy: CodingKeys.self) //컨테이너를 가져온다.
        
        try container.encode(name, forKey: .name)
        try container.encode(id, forKey: .id)
        try container.encode(favoriteToy.name, forKey: .gift) //favoriteToy.name을 .gift로 줄인다.
    }
}

//The decode function
extension Employee: Decodable {
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self) //컨테이너를 가져온다.
        
        name = try values.decode(String.self, forKey: .name)
        id = try values.decode(Int.self, forKey: .id)
        
        let gift = try values.decode(String.self, forKey: .gift)
        favoriteToy = Toy(name: gift)
    }
}

struct Toy: Codable {
    var name: String
}
//Array나 Dictionary들도 요소들이 Codable이면 Codable이다.

//JSONEncoder and JSONDecoder
let toy1 = Toy(name: "Teddy Bear")
let employee1 = Employee(name: "John Appleseed", id: 7, favoriteToy: toy1)

let jsonEncoder = JSONEncoder()
let jsonData = try jsonEncoder.encode(employee1) //JSON으로 인코딩한다.
print(jsonData)

let jsonString = String(data: jsonData, encoding: .utf8) //print로 json data를 읽을 수 없다. 변환을 거쳐야 한다.
print(jsonString!)

let jsonDecoder = JSONDecoder()
let employee2 = try jsonDecoder.decode(Employee.self, from: jsonData) //JSON을 디코딩해서 Data(여기서는 Employee)로 만든다.
