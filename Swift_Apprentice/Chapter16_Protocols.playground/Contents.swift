//Chapter 16: Protocols

//지금까지 세 가지 named type에 대해 알아봤다(구조체, 클래스, 열거형). 프로토콜(protocol)이라는 또 하나의 named type이 있다.
//다른 named type과 달리, 프로토콜은 직접 인스턴화 하지 않는다. 대신 실제 type이 준수하는 interface 또는 청사진(blueprint)을 정의한다.
//프로토콜을 사용해 실제 type이 구현하는 일반적인 속성과 동작의 집합을 정의한다.




//Introducing protocols
//다른 named type과 마찬가지 방법으로 프로토콜을 정의한다.
protocol Vehicle { //the protocol doesn’t contain any implementation. : 아무것도 구현하지 않는다.
    func accelerate()
    func stop()
}
//protocol 키워드 뒤에는 프로토콜의 이름이 오고, 그 뒤에 중괄호로 감싸 멤버를 정의해 준다. 가장 큰 차이점은 프로토콜은 구현을 포함하고 있지 않다는 것이다.
//이는, 프로토콜을 직접 인스턴화할 수 없다는 의미이다.
//let vehicle = Vehicle() //Error
//대신 프로토콜을 사용하여 type에 대한 메서드 및 특성을 정의한다.

//Protocol syntax
//프로토콜은 클래스, 구조체 또는 열거형에서 구현할(채택 - adopted) 수 있다. 프로토콜을 채택하면 해당 type은 프로토콜에 정의된 메서드와 속성을 구현해야 한다.
//해당 type이 프로토콜의 모든 구성을 구현하면, 해당 유형은 프로토콜을 준수(conform)한다고 한다.
class Unucycle: Vehicle { //클래스에서의 상속과 같은 표현
    var peddling = false
    
    func accelerate() {
        peddling = true
    }
    
    func stop() {
        peddling = false
    }
}
//클래스 명 뒤에 콜론으로 준수하는 프로토콜을 지정해 준다. 클래스에서의 상속을 선언해 주는 것과 동일한 구문이다.
//클래스의 상속과 동일하게 보이지만, 실제로는 그렇지 않다. 구조체와 열거형도 같은 식으로 프로토콜을 준수해 줄 수 있다.
//Unicycle에서 stop()을 제거하면, Unicycle이 Vehicle 프로토콜을 '완전히' 준수하지 않으므로, 오류가 발생한다.

//Methods in protocols
//위의 Vehicle 프로토콜에서, 이를 준수하는 모든 type에서 구현해야 하는 accelerate()과 stop()를 정의한다.
//클래스, 구조체, 열거형에서와 마찬가지로 매개변수 및 반환 값을 사용하여 프로토콜에서 메서드를 정의한다.
enum Direction {
    case left
    case right
}
protocol DirectionalVehicle { //프로토콜은 구현하지 않는다. 인터페이스와 코드를 분리하도록 도와준다.
    func accelerate()
    func stop()
    func turn()
    func description() -> String
}
//주의해야할 몇 가지 차이점이 있다. 메서드의 구현을 정의할 수 없으며, 구현하려 하는 경우 오류가 난다.
//프로토콜 자체는 이를 구현하는 다른 type의 세부 구현 사항에 대해 가정하지 않으므로, interface와 code를 엄격하게 분리하는 게 도움이 된다.
protocol OptionalDirectionVehicle {
//    func turn(_ direction: Direction = .left) //Error //프로토콜에선 default 값을 정의해 줄 수 없다.
    func turn()
    func turn(_ direction: Direction) //argument가 다를 경우 여러 가지로 함수를 정의해 줄 수도 있다.
}
//또한 프로토콜에 정의된 메서드는 default 매개 변수를 포함할 수 없다. 대신 매개변수를 다양하게 하여 여러 메서드를 정의해 줄 수 있다.
//OptionalDirectionVehicle를 구현할 때는 turn()과 turn(_:)를 모두 구현해야 한다. default 매개 변수를 사용하여 하나의 메서드만 구현하면, Xcode에서 오류를 발생한다.

//Properties in protocols
//프로토콜에 property를 선언해 줄 수도 있다.
protocol VehicleProperties { //프로토콜에서 속성을 정의할 때는 get, set을 반드시 써야한다.
    var weight: Int { get } //읽기 전용 속성
    var name: String { get set } //읽기 쓰기 모두 가능한 속성
}
//프로토콜에서 속성을 정의할 때는 computed property와 유사하게 명시적으로 get 또는 set을 설정해 줘야 한다. 하지만 메서드에서와 같이, 프로토콜의 속성은 어떠한 구현도 포함하지 않는다.
//속성에 get, set을 명시한다는 사실은 프로토콜이 속성에 대한 상세 구현을 알지 못한다는 것을 의미한다. 이러한 속성은 일반 변수 혹은 computed property로 구현 가능하다.
//프로토콜의 속성에 get만 있는 경우는 읽기가 가능하다는 의미(readable)이고, get과 set이 모두 있는 속성은 읽고 쓸수 있다는 의미이다(readable, writable).
//프로토콜의 속성에서 get은 최소 요구 사항이다. 따라서, get만 표시된 속성일지라도, 실제 구현에서 stored property나 read-write computed property로 구현할 수 있다.

//Initializers in protocols
//프로토콜 자체는 초기화할 수 없지만(인스턴스를 생성할 수 없다), 이를 준수하는 type의 initializer는 다음과 같이 선언할 수 있다.
protocol Account {
    var value: Double { get set }
    init(initialAmount: Double)
    init?(transferAccount: Account)
}
//Account 프로토콜은 두 개의 initializer를 정의한다. 이를 구현하는 모든 type은 해당 initializer가 있어야 한다.
//따라서 initializer가 있는 프로토콜을 클래스에서 구현하는 경우에는, 해당 initializer는 required 키워드와 함께 사용해야 한다.
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
//클래스에서의 상속과 같이, 프로토콜도 다른 프로토콜을 상속 가능하다.
protocol WheeledVehicle: Vehicle {
    var numberOfWheels: Int { get }
    var wheelSize: Double { get set }
}
//WheeledVehicle 프로토콜을 구현하면 중괄호 내의 해당 멤버들 뿐 아니라, Vehicle의 모든 멤버들까지 함께 정의된다.
//subclassing과 마찬가지로, WheeledVehicle을 구현한 모든 type은 Vehicle 프로토콜과 is-a 관계가 된다.




//Implementing protocols
//프로토콜을 준수하는 것으로 type을 선언하면, 프로토콜의 모든 요구 사항을 구현해야 한다.
class Bike1: Vehicle {
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
//Bike1 클래스는 Vehicle에 정의 된 모든 메서드(accelerate(), stop())을 구현한다. 해당 메서드 가 정의되지 않은 경우에는 빌드 시 오류가 발생한다.
//프로토콜을 준수하는 모든 type은 프로토콜에서 정의한 모든 멤버를 포함한다.

//Implementing properties
//프로토콜의 속성은 get 이며, set을 함께 구현해야 하는 경우도 있다. 이러한 요구 사항을 반드시 준수해야 한다.
class Bike2: WheeledVehicle {
    let numberOfWheels: Int = 2 //Vehicle 프로토콜. get 준수
    var wheelSize: Double = 16.0 //Vehicle 프로토콜. get, set 준수
    
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
//프로토콜은 요구 사항을 구현하는 한 세부적인 구현 방식에 신경 쓰지 않는다. 속성의 get 요구 사항을 구현하는 방법은 다음과 같다.
// • A constant stored property : 상수 stored property
// • A variable stored property : 변수 stored property
// • A read-only computed property : 읽기 전용 computed property
// • A read-write computed property : 읽기-쓰기 computed property
//get, set을 모두 구현하는 방법은 a variable stored property와 a read-write computed property로 가능하다.

//Associated types in protocols
//associated type을 프로토콜의 멤버로 추가할 수도 있다. 프로토콜에서 associatedtype을 사용하면 어떤 type이어야 하는지 명시하지 않으면서, 해당 type이 있음을 나타낸다.
//정확한 type을 결정하는 것은 프로토콜을 구현할 때 이다. 이로 최종적으로 어떤 type을 사용하는지 정확하게 지정하지 않고도 type에 임의의 이름을 지정할 수 있다.
protocol WeightCalculatable {
    associatedtype WeightType //구현할 때 필요한 type을 결정해 사용하면 된다.
    var weight: WeightType { get }
}
//weight의 구체적인 type 결정을 구현 시점으로 위임한다.
class HeavyThing: WeightCalculatable {
    // This heavy thing only needs integer accuracy
    typealias WeightType = Int //typealias를 삭제 해도 된다.
    
    var weight: Int {
        return 100
    }
}

class LightThing: WeightCalculatable {
    // This light thing needs decimal places
    typealias WeightType = Double
    
    var weight: Double {
        return 0.0025
    }
}
//여기서는 typealias를 사용해 관련 type을 명시적으로 지정했다. 컴파일러는 type을 유추할 수 있으므로 일반적으로는 생략해도 된다.
//WeightCalculatable의 구현이 사용하는 type에 따라 달라진다. 컴파일러는 어떤 WeightType을 사용하는지 미리 알 수 없기 때문에 프로토콜을 simple variable type으로 사용할 수 없다.
//let weightedThing: WeightCalculatable = LightThing() // Build error!
// protocol 'WeightCalculatable' can only be used as a generic // constraint because it has Self or associated type requirements.
//generic constraint를 사용해 이를 해결할 수 있다.

//Implementing multiple protocols
//클래스는 단일 클래스만 상속할 수 있지만(single inheritance), 프로토콜은 클래스, 구조체, 열거형에서 원하는 만큼 구현할 수 있다.
protocol Wheeled {
    var numberOfWheels: Int { get }
    var wheelSize: Double { get set }
}

class Bike: Vehicle, Wheeled { //다중 프로토콜 구현이 가능하다.
     //Implement both Vehicle and Wheeled
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
//프로토콜은 multiple conformance를 지원하므로, 정의한 type에 따라 여러 프로토콜을 적용할 수 있다.
//위의 예제에서 Bike는 Vehicle와 Wheeled 프로토콜에 정의된 모든 멤버를 구현해야 한다.

//Protocol composition
//여러 프로토콜을 준수할 때, 이에 부합하는 data type을 선택하기 위한 함수가 필요한 경우가 있다. protocol composition를 사용해 이를 구현할 수 있다.
func roundAndRound(transportation: Vehicle & Wheeled) { //두 프로토콜 모두를 구현한 argument가 필요
    transportation.stop() //Vehicle의 stop 필요
    print("The brakes are being applied to \(transportation.numberOfWheels) wheels.") //Wheeled의 numberOfWheels 필요
}
roundAndRound(transportation: Bike()) // The brakes are being applied to 2 wheels.
//Vehicle 프로토콜의 stop() 메서드와 Wheeled 프로토콜의 numberOfWheels 속성에 액세스해야 하는 함수가 필요한 경우 & 연산자를 사용해 이를 수행할 수 있다.

//Extensions & protocol conformance
//extension을 사용하여 프로토콜을 구현할 수도 있다. 이를 사용하면, 선언 시에 프로토콜을 구현하지 않았더라도 추가적으로 프로토콜을 준수할 수 있다.
protocol Reflective {
    var typeName: String { get }
}

extension String: Reflective { //extension으로 protocol을 구현할 수 있다.
    var typeName: String {
        "I'm a String"
    }
}

let title = "Swift Apprentice!"
title.typeName // I’m a String
//String은 standard library이지만 Reflective 프로토콜을 구현할 수 있다. extension을 사용하는 또 다른 이점은 type의 정의 부분과 구분하여 프로토콜 구현을 그룹화할 수 있다는 것이다.
class AnotherBike: Wheeled {
    var pedding = false
    let numberOfWheels = 2
    var wheelSize = 16.0
}

extension AnotherBike: Vehicle { //extension을 사용해 각각 그룹화하면, 코드 가독성을 높일 수 있다.
    func accelerate() {
        pedding = true
    }

    func stop() {
        pedding = false
    }
}
//extension에서 해당 프로토콜을 구현해 준다. 차후에 구현된 프로토콜을 제거하게 되더라도, extension 구문만 삭제하면 된다.
//주의해야 할 점은 extension에서는 stored property를 선언할 수 없다는 점이다.
//본래의 type 선언에서 stored property를 선언하고 extension에서 준수하는 프로토콜을 구현할 수 있지만, extension의 한계로 프로토콜의 완전한 구현이 항상 가능한 것은 아니다.

//Requiring reference semantics
//프로토콜은 value type(struct, enum)과 reference type(class)에서 모두 구현할 수 있다. 프로토콜은 이것이 구현되는 객체에 따라 value type과 reference type이 결정된다.
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
//변수에 reference type 인스턴스를 할당하면, reference semantic을 가지게 된다.
var named: Named = ClassyName(name: "Classy")
var copy = named
named.name = "Still Classy"
named.name // Still Classy
copy.name // Still Classy
//클래스로 구현한 경우, reference type이 된다.
//마찬가지로, value type 인스턴스를 할당하면, value semantic을 가지게 된다.
named = StrucyName(name: "Structy")
copy = named
named.name = "Still Structy?"
named.name // Still Structy?
copy.name // Structy
//구조체로 구현한 경우, value type이 된다.
//하지만 이런 상황이 항상 명확한 것은 아니다. 대부분의 경우 Swift는 reference semantic보다 value semantic를 선호한다.
//클래스로만 구현되는 protocol을 설계하는 경우, 해당 프로토콜을 구현하는 type이 reference semantic을 사용하도록 지정해 주는 것이 좋다.
protocol NamedClass: class { //명확히 하기위해 클래스만이 해당 프로토콜을 구현할 수 있도록 제약을 걸어준다.
    var name: String { get set }
}
//위와 같이 제약 조건을 사용하면 클래스만이 해당 프로토콜을 구현할 수 있다. Swift가 reference semantic을 사용해야 한다는 것을 분명한다.

//Protocols: More than bags of syntax
//프로토콜을 사용하면 type에 대한 요구 사항을 지정해 줄 수 있다. 그러나 모든 요구 사항을 컴파일러가 확인할 수 없으며, 그렇게 구현해서도 안 된다.
//ex. 프로토콜 작업에 대한 복잡도 O(1) vs O(n)를 지정해야 하는 경우에는 주석을 사용해야만 한다. 프로토콜이 정확하게 준수해야 하는 모든 요건을 이해하는 것이 중요하다.
//무슨 말인지 정확히 모르겠음...




//Protocols in the Standard Library
//프로토콜은 Swift의 Standard Library에서 광범위하게 사용된다. Swift에서 프로토콜이 수행하는 역할을 이해하면, 깔끔하게 분리된 "Swiftty"한 코드를 작성하는 데 도움이 된다.

//Equatable
//== 연산자를 사용해 두 개의 정수를 비교한다.
let a = 5
let b = 5
a == b // true
//String을 사용해서 동일한 작업을 할 수 있다.
let swiftA = "Swift"
let swiftB = "Swift"
swiftA == swiftB // true
//그러나 any type에서는 ==를 사용할 수 없다. (ex. class)
class Record {
    var wins: Int
    var losses: Int
    
    init(wins: Int, losses: Int) {
        self.wins = wins
        self.losses = losses
    }
}
let recordA = Record(wins: 10, losses: 5)
let recordB = Record(wins: 10, losses: 5)
//recordA == recordB // Build error!
//해당 클래스에서는 == 연산자를 바로 사용할 수 없다. 항등 연산자(==)의 사용은 Standard Library에만 한정된 것이 아니다.
//Swift 기본 type들은 구조체로 구현되어 있으며, 이는 custom type도 이 연산자를 확장해 사용할 수 있다는 것을 의미한다.
//Int와 String은 모두 Equatable 프로토콜의 static 메서드를 구현하고 있다. 해당 부분은 다음과 같다.
//protocol Equatable {
//    static func ==(lhs: Self, rhs: Self) -> Bool
//}
//Record에서 이 프로토콜을 구현할 수 있다.
extension Record: Equatable {
    static func == (lhs: Record, rhs: Record) -> Bool {
        lhs.wins == rhs.wins && lhs.losses == rhs.losses
    }
}
//== 연산자를 정의(혹은 overloading)해 준다. 여기서는 승패가 같을 경우 동일한 것으로 간주한다.
//이를 구현해 주면, String 혹은 Int와 마찬가지로 == 연산자를 사용하여 Record type을 비교할 수 있다.
recordA == recordB // true

//Comparable
//Comparable은 Equatable의 하위 프로토콜이다. 프로토콜의 내용은 다음과 같다.
//protocol Comparable: Equatable {
//    static func <(lhs: Self, rhs: Self) -> Bool
//    static func <=(lhs: Self, rhs: Self) -> Bool
//    static func >=(lhs: Self, rhs: Self) -> Bool
//    static func >(lhs: Self, rhs: Self) -> Bool
//}
//동등 연산자(==) 외에, Comparable에서는 type에 대한 비교 연산자 <, <=, >, >= 를 overload해야 한다.
//실제로 Standard Library가 ==, < 의 구현을 이용해 <=, >, >= 를 실행할 수 있으므로 일반적으로 Comparable에서는 < 만 구현한다.
extension Record: Comparable {
    static func <(lhs: Record, rhs: Record) -> Bool {
        if lhs.wins == rhs.wins {
            return lhs.losses > rhs.losses
        }
        return lhs.wins < rhs.wins
    }
}
//< 를 구현해 준다. 여기서는 승리 수가 같을 경우 패배를 비교한다.

//“Free” functions
//==와 <는 그 자체로도 유용하지만, Swift Library는 이를 준수하는 type에 대한 많은 "free" 함수와 메서드를 제공한다.
//Array와 같은 모든 collection 에서 Comparable type을 사용하면, Standard Library의 sort()와 같은 메서드에 액세스할 수 있다.
let teamA = Record(wins: 14, losses: 11)
let teamB = Record(wins: 23, losses: 8)
let teamC = Record(wins: 23, losses: 9)
var leagueRecords = [teamA, teamB, teamC]
leagueRecords.sort()
// {wins 14, losses 11}
// {wins 23, losses 9}
// {wins 23, losses 8}
//Record에는 두 value를 비교할 수 있으므로, standard library 는 sort 구현에 필요한 모든 정보를 가지고 있다.
//Comparable 과 Equatable를 구현하면 다음과 같은 다양한 메서드를 활용할 수 있다.
leagueRecords.max() // {wins 23, losses 8}
leagueRecords.min() // {wins 14, losses 11}
leagueRecords.starts(with: [teamA, teamC]) // true
leagueRecords.contains(teamA) // true

//Other useful protocols
//Swift standard library를 모두 아는 것이 중요하지는 않지만, 거의 모든 프로젝트에서 유용하게 사용할 수 있는 몇 가지 주요 프로토콜이 있다.

//Hashable
//Equatable의 subprotocol인 Hashable 프로토콜은 Dictionary의 key로 사용하려는 모든 type은 이를 구현해야 한다.
//Value type(struct, enum)의 경우, 컴파일러는 자동으로 Equatable와 Hashable를 준수하지만, Reference type(class)인 경우에는 직접 이를 구현해야 한다.
//Hash value를 사용하면, Collection에서 요소를 빠르게 찾을 수 있다. 이것이 제대로 작동하기 위해서는 == 연산자로 동등하다고 여겨지는 value는 동일한 hash value를 가져야 한다.
//hash value의 수는 제한적이기 때문에 같지 않은 value가 동일한 hash를 가질 확률도 있다. hash value를 생성하는 세부적인 수학은 매우 복잡하지만, Swift가 이를 처리하도록 할 수 있다.
//== 비교도 hash를 포함하고 있다.
class Student {
    let email: String
    var firstName: String
    var lastName: String
    
    init(email: String, firstName: String, lastName: String) { //email이 중복되지 않는 key가 된다.
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
    }
}

extension Student: Hashable {
    static func ==(lhs: Student, rhs: Student) -> Bool {
        return lhs.email == rhs.email
    }
    
    func hash(into hasher: inout Hasher) { //Hash 구현을 Custom하게 구현하려면 hash(into:)를 구현해 준다.
        hasher.combine(email)
        hasher.combine(firstName)
        hasher.combine(lastName)
    }
}
//동등 비교를 위해, email, firstName, lastName를 사용한다. Hash의 졸은 구현은 전달된 Hasher type을 사용하여 이러한 모든 특성을 결합하여 사용하는 것이다.
//이제 Student type을 Dictionary의 key로 사용할 수 있다.
let john = Student(email: "johnny.appleseed@apple.com", firstName: "Johnny", lastName: "Appleseed")
let lockerMap = [john: "14B"]

//CustomStringConvertible
//CustomStringConvertible은 인스턴스를 출력하고, 디버그하는 데 도움이 되는 매우 유용한 프로토콜이다.
//위의 Student의 인스턴스를 print()로 호출하면, 모호한 설명이 출력된다.
//print(john) // Student
//CustomStringConvertible 프로토콜에는 description 속성만 있다. 이 속성은 인스턴스가 print()와 디버거에 표시되는 방식을 지정한다.
//protocol CustomStringConvertible {
//    var description: String { get }
//}
//Student type에 CustomStringConvertible를 구현하면, 더 쉬운 출력 표현을 제공해 줄 수 있다.
extension Student: CustomStringConvertible { //description을 구현해 주면 된다.
    var description: String {
         "\(firstName) \(lastName)"
    }
}
print(john) // Johnny Appleseed
//CustomStringConvertible와 유사한 CustomDebugStringConvertible 프로토콜도 있다. debugDescription를 정의한다는 점을 제외하면, CustomStringConvertible과 동일하다.
//debug configuration에서만 출력을 하려면 debugPrint()와 함께 CustomDebugStringConvertible를 구현하면 된다.
