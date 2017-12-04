//: Chapter 10: Structures

//Introducing structures
let restaurantLocation = (2, 4)
let restaurantRange = 2.5

let otherRestaurantLocation = (7, 8)
let otherRestaurantRange = 1.5

//피타고라스 정리
func distance (from source: (x: Int, y: Int), to target: (x: Int, y: Int)) -> Double {
    let distanceX = Double(source.x - target.x)
    let distanceY = Double(source.y - target.y)
    
    return (distanceX * distanceX + distanceY * distanceY).squareRoot() //루트 방법
}

func isInDeliveryRange(location: (x: Int, y: Int)) -> Bool {
    let deleveryDistance = distance(from: location, to: restaurantLocation)
    let secondDeliveryDistance = distance(from: location, to: otherRestaurantLocation)
    
    return deleveryDistance < restaurantRange || secondDeliveryDistance < otherRestaurantRange
}

//Your first structure
struct Location {
    let x: Int //properties
    let y: Int
}

let storeLocation = Location(x: 2, y: 4) //인스턴스는 각 Properties를 가진다. //initializer : 자동으로 초기화. 생성자를 따로 작성해줄 필요 없다.

//public protocol CustomStringConvertible { //프로토콜은 반드시 만족해야 한다. //이미 기본으로 있는 프로토콜
//    /// A textual representation of this instance.
//    public var description: String { get }
//}

struct DeliveryArea: CustomStringConvertible {
    let center: Location
    var radius: Double
    var description: String { //프로토콜 구현 //특별한 프로토콜. description. print에서 출력하게 된다.
        return """
        Area with center: x: \(center.x) - y: \(center.y),
        radius: \(radius),
        """
    }
    
    func contain(_ location: Location) -> Bool { //관련된 메서드로
        let distanceFromCenter = distance(from: (center.x, center.y), to: (location.x, location.y))
        
        return distanceFromCenter < radius
    }
}

var storeArea = DeliveryArea(center: storeLocation, radius: 4)

//Accessing members
print(storeArea.radius)
print(storeArea.center.x)

storeArea.radius = 250 //var로 선언했기에 접근 가능하다

let fixedArea = DeliveryArea(center: storeLocation, radius: 4)
//fixedArea.radius = 250 // Error: Cannot assign to property. 프로퍼티가 var이라도 let으로 인스턴스를 받으면 변경 불가능하다.

//Introducing methods
let areas = [
    DeliveryArea(center: Location(x: 2, y: 4), radius: 2.5),
    DeliveryArea(center: Location(x: 9, y: 7), radius: 4.5)
]

func isInDeliveryRange(_ location: Location) -> Bool {
    for area in areas {
        let distanceToStore = distance(from: (area.center.x, area.center.y), to: (location.x, location.y))
        if distanceToStore < area.radius {
            return true
        }
    }
    return false
}

let customerLocation1 = Location(x: 8, y: 1)
let customerLocation2 = Location(x: 5, y: 5)

print(isInDeliveryRange(customerLocation1))
print(isInDeliveryRange(customerLocation2))


let area = DeliveryArea(center: Location(x: 5, y: 5), radius: 4.5)
let customerLocation = Location(x: 2, y: 2)
area.contain(customerLocation)

//Structures as values
var a = 5
var b = a
print(a) // 5
print(b) // 5

a = 10
print(a) // 10
print(b) // 5

var area1 = DeliveryArea(center: Location(x: 2, y: 4), radius: 2.5)
var area2 = area1
print(area1.radius) // 2.5
print(area2.radius) // 2.5

area1.radius = 4
print(area1.radius) // 4.0
print(area2.radius) // 2.5
//Structure는 값을 복사하기 때문에 달라진다. //still completely independent!

//Structures everywhere
//많은 스위프트 타입은 Structure로 정의되어 있다.

//Conforming to a protocol
//Protocols contain a set of requirements that conforming types must satisfy.

print(area1)
print(area2)
