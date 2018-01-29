//: Chapter16: Protocols

//Introducing protocols
protocol Vehicle { //the protocol doesn’t contain any implementation. : 아무것도 구현하지 않는다.
    func accelerate()
    func stop()
}
//let vehicle = Vehicle() //프로토콜은 구현하지 않기 때문에 인스턴스를 바로 만들 수 없다.

//Protocol syntax
//프로토콜은 클래스, 구조체, 열거형에서 모두 구현될 수 있다.
class Unucycle: Vehicle { //클래스에서 상속하는 것과 같은 표현
    var peddling = false
    
    func accelerate() {
        peddling = true
    }
    
    func stop() {
        peddling = false
    }
}

//Methods in protocols
enum Direction {
    case left
    case right
}

protocol DirectionalVehicle { //프로토콜은 구현하지 않는다. 인터페이스와 코드를 분리하도록 도와준다.
    func accelerate()
    func stop()
    func turn() //argument가 다를 경우 여러 가지 버전으로 함수를 정의해 줄 수도 있다.
    func turn(_ direction: Direction)
    //func turn(_ direction: Direction = .left) //프로토콜에선 default 값도 정의해 줄 수 없다.
    func description() -> String
}

//Properties in protocols
protocol VehicleProperties { //프로토콜에서 프로퍼티를 정의할 때는 get, set을 반드시 써야한다.
    var weight: Int { get } //읽기 전용 프로퍼티 //보통 computed properties를 선언할 때.
    //최소한의 사항이므로 선언은 이렇게 읽기 전용으로 하고, 구현은 get, set이 모두 가능하도록 할 수도 있다.
    var name: String { get set } //읽기 쓰기 모두 가능한 프로퍼티
}

//Initializers in protocols
protocol Account { //Protocol이 인스턴스를 생성할 수는 없지만, 생성자를 정의할 수는 있다.
    var value: Double { get set }
    init(initialAmount: Double)
    init?(transferAccount: Account)
}

class BitcoinAccount: Account {
    var value: Double
    required init(initialAmount: Double) {
        value = initialAmount
    }
    required init?(transferAccount: Account) {
        guard transferAccount.value > 0.0 else {
            return nil
        }
        value = transferAccount.value
    }
}

var accountType: Account.Type = BitcoinAccount.self
let account = accountType.init(initialAmount: 30.00)
let transferAccount = accountType.init(transferAccount: account)!

//Protocol inheritance
protocol WheeledVehicle: Vehicle {
    var numberOfWheels: Int { get }
    var wheelSize: Double { get set }
}

//Implementing protocols
//class Bike: Vehicle { //프로토콜에 명시된 프로퍼티, 함수를 구현하지 않으면 에러가 난다.
//    var peddling = false
//    var brakesApplied = false
//
//    func accelerate() {
//        peddling = true
//        brakesApplied = false
//    }
//
//    func stop() {
//        peddling = false
//        brakesApplied = true
//    }
//}

//Implementing properties
class Bike: WheeledVehicle {
    let numberOfWheels: Int = 2
    var wheelSize: Double = 16.0
    
    var peddling = false
    var brakesApplied = false
    
    func accelerate() {
        peddling = true
        brakesApplied = false
    }
    
    func stop() {
        peddling = false
        brakesApplied = true
    }
}

//Associated types in protocols
protocol WeightCalculatable {
    associatedtype WeightType //associatedtype로 associated type을 정의한다. //구현할 때 각 필요한 타입을 결정해 사용하면 된다.
    var weight: WeightType { get }
}

class HeavyThing: WeightCalculatable {
    typealias WeightType = Int //typealias를 삭제 해도 된다.
    
    var weight: Int {
        return 100
    }
}

class LightThing: WeightCalculatable {
    typealias WeightType = Double
    
    var weight: Double {
        return 0.0025
    }
}

///let weightedThing: WeightCalculatable = LightThing() //프로토콜은 제네릭으로만 사용할 수 있다. 인스턴스를 생성할 수 없다.

//Implementing multiple protocols
//클래스는 하나의 클래스만 상속 받을 수 있지만, 프로토콜을 구현하는 데에는 제한이 없다.
protocol Wheeled {
    var numberOfWheels: Int { get }
    var wheelSize: Double { get set }
}

class BikeTwo: Vehicle, Wheeled { //Vehicle과 Wheeled를 모두 구현하면 된다.
    let numberOfWheels = 2
    var wheelSize = 16.0

    var peddling = false
    var brakesApplied = false

    func accelerate() {
        peddling = true
        brakesApplied = false
    }

    func stop() {
        peddling = false
        brakesApplied = true
    }
}

//Protocol Composition
func roundAndRound(transportation: Vehicle & Wheeled) { //두 프로토콜 모두를 구현한 argument가 필요하다.
    transportation.stop() //Vehicle의 stop 필요
    print("The brakes are being applied to \(transportation.numberOfWheels) wheels.") //Wheeled의 numberOfWheels 필요
}

roundAndRound(transportation: BikeTwo())

//Extensions and protocol conformance
protocol Reflective {
    var typeName: String { get }
}

extension String: Reflective { //extension으로 protocol을 구현할 수 있다.
    var typeName: String {
        return "I'm a String"
    }
}

let title = "Swift Apprentice!"
title.typeName

class AnotherBike: Wheeled {
    var pedding = false
    let numberOfWheels = 2
    var wheelSize = 16.0
}

extension AnotherBike: Vehicle { //extension으로 각각 그룹화하여 코드 가독성을 높인다.
    func accelerate() {
        pedding = true
    }

    func stop() {
        pedding = false
    }
} //그러나 extension에서는 stored properties를 선언할 수 없다. 일반적인 오리지널 코드에서 선언하고, extension에서 충족 시킬 수는 있다.

//Requiring reference semantics
//Protocol은 무엇으로 구현하느냐에 따라 value type(struct, enum)이 되거나 reference type(class)이 된다.

protocol Named {
    var name: String { get set }
}

class ClassyName: Named {
    var name: String
    init(name: String) {
        self.name = name
    }
}

struct StrucyName: Named {
    var name: String
}

var named: Named = ClassyName(name: "Classy")
var copy = named

named.name = "Still Classy"
named.name // Still Classy
copy.name // Still Classy
//클래스로 구현한 경우, reference type이 된다.

named = StrucyName(name: "Structy")
copy = named

named.name = "Still Structy?"
named.name // Still Structy?
copy.name // Structy
//구조체로 구현한 경우, value type이 된다.

protocol NamedClass: class { //이런 것을 명확히 하기위해 클래스만 이 프로토콜을 구현할 수 있도록 제약을 걸어줄 수도 있다.
    var name: String { get set }
}

//Protocols in the standard library
//스위프티하게 코드를 짤 수 있다.

//Equatable
struct Record {
    var wins: Int
    var losses : Int
}


let recordA = Record(wins: 10, losses: 5)
let recordB = Record(wins: 10, losses: 5)

//recordA == recordB //Equatable을 구현하지 않았으므로 에러가 난다.
extension Record: Equatable { //프로토콜을 구현해 오버라이트 해 주면 두 변수가 같은 지 확인해 볼 수 있다.
    static func ==(lhs: Record, rhs: Record) -> Bool {
        return lhs.wins == rhs.wins && lhs.losses == rhs.losses
    }
}

recordA == recordB

//Comparable
extension Record: Comparable { //Comparable을 구현하면 비교연산을 할 수 있다. //<, >, <=, >=
    static func <(lhs: Record, rhs: Record) -> Bool {
        if lhs.wins == rhs.wins {
            return lhs.losses > rhs.losses
        }
        return lhs.wins < rhs.wins
    }
}

//"Free" functions
//Equatable과 Comparable를 구현하면 여러 곳에서 활용가능하다.
let teamA = Record(wins: 14, losses: 11)
let teamB = Record(wins: 23, losses: 8)
let teamC = Record(wins: 23, losses: 9)
var leagueRecords = [teamA, teamB, teamC]

leagueRecords.sort()
leagueRecords.max()
leagueRecords.min()
leagueRecords.starts(with: [teamA, teamC])
leagueRecords.contains(teamA)

//Other useful protocols
//Hashable
//Equatable의 서브 protocol. 구현하면 딕셔너리의 키로 사용할 수 있다. 해시값을 사용해 컬렉션의 요소를 찾는다.
//이 작업을 수행하려면 ==로 간주되는 값은 값은 해시 값을 가져야 한다. 대부분의 스위프트 타입은 Hashable을 구현했으므로 이를 활용하면 된다.
class Student {
    let email: String
    var firstName: String
    var lastName: String
    
    init(email: String, firstName: String, lastName: String) { //이메일이 중복되지 않는 키가 된다.
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
    }
}

extension Student: Equatable {
    static func ==(lhs: Student, rhs: Student) -> Bool {
        return lhs.email == rhs.email
    }
}

extension Student: Hashable { //Hashable을 구현하면, 딕셔너리의 Key로 사용가능하다.
    var hashValue: Int {
        return email.hashValue //String은 Hashable을 구현했으므로 그대로 String의 해시값을 반환하면 된다.
    }
}

let john = Student(email: "johnny.appleseed@apple.com", firstName: "Johnny", lastName: "Appleseed")
let lockerMap = [john: "14B"]

//CustomStringConvertible
//디버그 시 유용하다.
print(john) // Student

extension Student: CustomStringConvertible { //description을 구현해 주면 된다.
    var description: String {
        return "\(firstName) \(lastName)"
    }
}

print(john) // Johnny Appleseed
//CustomDebugStringConvertible은 CustomStringConvertible와 거의 유사하다. debugPrint()를 정의.

