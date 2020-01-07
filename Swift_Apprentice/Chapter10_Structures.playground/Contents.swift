//: Chapter 10: Structures

//높은 수준의 추상화는 복잡한 작업을 수행하는 프로그램에서 큰 이점이 있다.
//Int, String, Array 등 외에도, 대부분의 프로그램은 특정 작업에 맞춘 새로운 유형을 사용한다.
//Struct는 그 중 하나로, named type 이다. Struct는 명명된 속성(property)을 저장하고, 자체적인 동작을 정의할 수 있다.
//Int, String, Array 처럼 코드에서 사용할 고유한 Struct를 정의하고 생성할 수 있다.




//Introducing structures
//피자 배달을 위해, 가게의 위치와 고객의 위치를 좌표 평면에 나타낸다 가정한다. 고객이 배달 범위 내에 있는지 계산하는 프로그램을 작성한다.
let restaurantLocation = (2, 4)
let restaurantRange = 2.5
let otherRestaurantLocation = (7, 8)
let otherRestaurantRange = 1.5
//Pythagorean Theorem 📐 🎓
func distance (from source: (x: Int, y: Int), to target: (x: Int, y: Int)) -> Double { //거리 측정
    let distanceX = Double(source.x - target.x)
    let distanceY = Double(source.y - target.y)
    
    return (distanceX * distanceX + distanceY * distanceY).squareRoot() //루트(Double의 메서드로 정의되어 있다)
}
func isInDeliveryRange(location: (x: Int, y: Int)) -> Bool {
    let deleveryDistance = distance(from: location, to: restaurantLocation)
    let secondDeliveryDistance = distance(from: location, to: otherRestaurantLocation)
    
    return deleveryDistance < restaurantRange || secondDeliveryDistance < otherRestaurantRange
    //배달 범위 내에 있거나, 다른 지점의 배달 범위를 벗어나 있어야 한다.
}
//하지만 이런 구현은 지점 수가 늘어나면 모든 좌표와 범위를 확인하고 계산해야 하기 때문에 한계가 있다. 좌표를 튜플로 묶어 Array에 유지할 수 있지만 읽고 쓰기가 비효율적이다.

//Your first structure
//구조체는 관련 속성과 동작들을 캡슐화(encapsulate) 할 수 있는 Swift의 named type 중 하나이다.
//새로운 유형을 선언하고, 이름을 지정한 다음 코드에서 사용할 수 있다. 위의 피자 가게 예에서는 좌표를 x, y 튜플로 나타냈다. 이를 구조체로 표현할 수도 있다.
struct Location {
    let x: Int //property
    let y: Int
}
func distance(from source: Location, to target: Location) -> Double { //Location으로 거리를 재는 함수
    let distanceX = Double(source.x - target.x)
    let distanceY = Double(source.y - target.y)
    return (distanceX * distanceX + distanceY * distanceY).squareRoot()
    //return sqrt(distanceX * distanceX + distanceY * distanceY) 으로 써도 된다.
    //sqrt() 를 사용하려면, Foundation import가 필요하다.
}
//구조체는 struct 키워드와 이름, 중괄호 쌍으로 구성된다. 중괄호 사이의 코드는 구조체의 member가 된다.
//property는 type의 일부로 선언된 상수 또는 변수이다. 해당 type의 모든 인스턴스는 이러한 속성을 가지고 있다.
//구조체를 인스턴스화 하고 상수 또는 변수에 저장할 수 있다.
let storeLocation = Location(x: 2, y: 4) //인스턴스는 각 Properties를 가진다.
//initializer : 자동으로 초기화. 생성자를 따로 작성해줄 필요 없다.
//매개 변수로 속성의 이름과 값을 괄호 안에 지정해 주면 된다. initializer는 구조체를 사용하기 전에 모든 속성이 설정되도록 한다.
//초기화 과정 없이 변수에 접근할 수 있는 다른 프로그래밍 언어들도 있지만, 이는 버그의 원인이 되기도 한다.
//Swift struct의 장점 중 하나는 따로 initializer를 작성해 줄 필요 없다는 것이다.
//Swift는 매개변수 목록의 속성에 대한 기본 initializer를 자동으로 제공한다. 피자 가게의 위치와 배달 반경을 포함하는 구조체를 생성한다.
struct DeliveryArea: CustomStringConvertible {
    let center: Location
    var radius: Double
    var description: String { //프로토콜 구현 //description. print로 출력할 문자열을 지정해 준다.
        """
        Area with center: x: \(center.x) - y: \(center.y),
        radius: \(radius)
        """
    }
    //public protocol CustomStringConvertible { //프로토콜을 반드시 구현해야 만족해야 한다.
    //    // A textual representation of this instance.
    //    public var description: String { get }
    //}
    //description 처럼 다른 곳의 변경에 대응하여 업데이트 되는 값을 computed property 라고 한다.
    
    func contain(_ location: Location) -> Bool { //method //member function을 method라 한다.
        distance(from: (center.x, center.y), to: (location.x, location.y)) < radius
        //구조체의 memeber 속성을 사용한다.
    }
    
    func overlaps(with area: DeliveryArea) -> Bool {
        distance(from: center, to: area.center) <= (radius + area.radius)
    }
}
var storeArea = DeliveryArea(center: storeLocation, radius: 4)
//구조체 안에 구조체가 있을 수도 있다(DeliveryArea의 center 속성).




//Accessing members
//String, Array, Dictionary 등과 마찬가지로, dot syntax를 사용해 member에 액세스할 수 있다.
print(storeArea.radius) // 4.0
print(storeArea.center.x) // 2
//dot syntax로 값을 할당(assign)할 수도 있다.
storeArea.radius = 250 //var로 선언했기에 접근 가능하다.
//상수(constant), 변수(variable)에 따라 값을 변경할 수 있는 지 여부가 결정된다(let으로 center를 선언했다면 변경할 수 없다).
//따라서 DeliveryArea의 속성에서, center는 변경할 수 없으나 radius는 변경할 수 있다.
//구조체를 초기화한 이후에 수정하려면, 변수로 선언해야 한다(storeArea를 let으로 선언했다면, storeArea.radius가 var로 선언되었어도 변경할 수 없다).
let fixedArea = DeliveryArea(center: storeLocation, radius: 4)
//fixedArea.radius = 250 // Error: Cannot assign to property.
//변수가 var이라도 let으로 인스턴스를 선언했다면 변경 불가능하다.




//Introducing methods
//추가적인 구조체 기능을 위해(여기서는 피자 배달 범위를 계산) 함수를 추가해 준다.
let areas = [
    DeliveryArea(center: Location(x: 2, y: 4), radius: 2.5),
    DeliveryArea(center: Location(x: 9, y: 7), radius: 4.5)
]
func isInDeliveryRange(_ location: Location) -> Bool { //한 지점이라도 배달 가능한 범위라면 true. 배달 가능한 지점이 한 곳도 없다면 false
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
print(isInDeliveryRange(customerLocation1)) // false
print(isInDeliveryRange(customerLocation2)) // true
//하지만 위의 구현은 배달 가능한 지역이라는 것은 알 수 있지만, 어느 지점에서 배달 가능한지는 알 수 없다.
//구조체가 상수와 변수를 가질 수 있는 것 처럼 자체 함수를 가질 수도 있다.
//DeliveryArea 구조체 정의에서 contains(_) method를 추가해 준다. 해당 지점에서 배달 가능한지 알수 있다.
//해당 함수는 DeliveryArea의 member이다. 이렇게 memeber인 함수를 method라 한다. 메서드 역시 dot syntax로 접근할 수 있다.
let area = DeliveryArea(center: Location(x: 5, y: 5), radius: 4.5)
let customerLocation = Location(x: 2, y: 2)
area.contain(customerLocation) // true




//Structures as values
//Swift의 Struct는 value type이다. value type은 할당 시 인스턴스가 복사되는 유형이다.
var a = 5
var b = a
print(a) // 5
print(b) // 5
a = 10
print(a) // 10
print(b) // 5
//copy-on-assignment는 a가 b에 할당 될 때, a의 값이 b에 복사된다는 의미이다.
var area1 = DeliveryArea(center: Location(x: 2, y: 4), radius: 2.5)
var area2 = area1 //사본을 얻는다.
print(area1.radius) // 2.5
print(area2.radius) // 2.5
area1.radius = 4
print(area1.radius) // 4.0
print(area2.radius) // 2.5
//struct는 value semantic이다. area2에 area1을 할당하면, 사본이 할당된다.
//area1과 area2는 독립적이다. //still completely independent!
//value semantic과 copy-on-assignment 덕분에 구조체는 다른 코드에 공유되더라도, 변경될 우려가 없다.
//(cf. reference type인 class는 area2.radius도 4.0이 된다)




//Structures everywhere
//많은 Swift의 기본 Type은 Structure로 정의되어 있다. ex. Swift Library에서 Int의 정의를 살펴보면 다음과 같다.
//public struct Int : FixedWidthInteger, SignedInteger {
//    //...
//}
//Int도 구조체이다. Double, String, Bool, Array, Dictionary 등 많은 Type이 구조체로 정의되어 있다.
//구조체의 value semantic은 reference type에 비해 Core Swift type을 표현하는 데 더 많은 이점이 있다.




//Conforming to a protocol
//위의 Int 정의에서 FixedWidthInteger, SignedInteger는 protocol이다. Int는 이 protocol을 구현한다.
//protocol에는 충족해야 하는 일련의 요구사항이 포함되어 있다.
//public protocol CustomStringConvertible {
//    /// A textual representation of this instance.
//  public var description: String { get }
//}
//CustomStringConvertible는 description 한 가지 속성만 가지고 있다.
//CustomStringConvertible protocol을 구현하는 객체는 이 description를 반드시 구현해야 한다.
//DeliveryArea가 CustomAreaConvertible를 구현하도록 수정할 수 있다. 여기서는 computed property로 구현했다.
//CustomStringConvertible을 구현한 객체는 모두 description를 정의해야 하므로,
//모든 유형의 CustomStringConvertible 인스턴스에서 description를 호출할 수 있다.
//Swift에서는 print() 함수로 출력할 때 description이 사용된다.
print(area1) // Area with center: (x: 2, y: 4), radius: 4.0
print(area2) // Area with center: (x: 2, y: 4), radius: 2.5
//모든 named type은 protocol을 사용해서 기능이나 동작을 확장할 수 있다.
