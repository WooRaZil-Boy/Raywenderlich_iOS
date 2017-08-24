//: Playground - noun: a place where people can play

import UIKit

print("Hello, Swift Apprentice reader!")

var number = 1_000_000

let doesOneEqualTwo = (1 == 2)

let stringA = "cafe\u{0301}"

let count = 10
var sum = 0
for i in 1...count where i % 2 == 1 {
    sum += i
}

sum = 0
rowLoop: for row in 0..<8 {
    columnLoop: for column in 0..<8 {
        if row == column {
            continue rowLoop
        }
        sum += row * column
    }
}

//스위치 문에서 case, default는 반드시 코드를 포함해야 한다. 아무것도 쓰지 않으려면 그냥 break라도 써야.

number = 10
switch number {
case _ where number % 2 == 0:
    print("Even")
default:
    print("Odd")
}

//함수 안에서 인자 값을 변경해야 할 때는 inout 키워드.
func incrementAndPrint(_ value: inout Int) {
    value += 1
    print(value)
}

//함수 호출 시에는 인자 앞에 &붙여줘야 한다. - 값을 복사해서 쓰는 것이 아니라 메모리 주소를 가져와 쓰는 것이기 때문에
var value = 5
incrementAndPrint(&value)
print(value)

//제어를 반환하지 않는 형태의 함수. Never 키워드 사용 :: 무한 루프, fatalError, exit(1) 등 제어를 반환하지 않는 형태의 코드가 와야 한다. - 그냥 컴파일러가 최적화 하는 데 도움?
func infiniteLoop() -> Never {
    while true {
        
    }
}

let allZeros = [Int](repeating: 0, count: 5)

func sum(of numbers: Int...) -> Int {
    var total = 0
    for number in numbers {
        total += number
    }
    return total
}

sum(of: 1, 6, 2, -3)

var prices = [1.5, 10, 4.99, 2.30, 8.19]
prices.dropFirst()
prices.dropLast()
//remove 메서드와 달리 filter, reduce 등과 같은 클로저. 반환값이 배열

prices.prefix(1)
prices.suffix(2)
//클로저. 반환값이 배열

//CustomStringConvertible //문자열 리턴하는 프로토콜 - description 프로퍼티 구현해야.

//구조체에서 사용자 정의 이니셜라이저를 생성하면 멤버와이즈 이니셜라이저를 사용할 수 없다.
//그런데 extension에서 사용자 정의 이니셜라이저를 만들면 둘 다 사용 가능하다. 

struct Location {
    var x: Int
    var y: Int
}

extension Location {
    init() {
        self.x = 10
        self.y = 10
    }
}

let a = Location()
let b = Location(x: 20, y: 30)

a.x
b.x

//==는 값 비교, ===는 메모리 주소 비교

//require init 는 상속하는 다른 클래스들이 모두 구현해야 하는 생성자

//<Swift가 정한 3가지 규칙 - 무조건 해야 함. 필수>
//1. 지정 이니셜라이저 안에서, 바로 위 슈퍼클래스의 지정 이니셜라이저를 호출
//2. 편의 이니셜라이저 안에서, 같은 클래스 내의 지정 이니셜라이저를 호출
//3. 편의 이니셜라이저 안에서, 지정 이니셜라이저를 호출

//weak 프로퍼티는 참조하는 객체가 nil이 되면 자동으로 해제한다. 따라서 항상 옵셔널로 선언되어야 한다.

protocol Account {
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
//Type은 타입 자체를 가져오는 것인 듯?

//프로토콜에 associatedtype을 명시해서 타입 값을 명시해 줄 수 있다. - 이런 식으로 연관되어 있는 값이 있는 경우에는 인스턴스로 만들 때 연결된 값을 지정못하므로 바로 만들 수 없다.
protocol WeightCalculatable {
    associatedtype WeightType
    func calculateWeight() -> WeightType
}

class HeavyThing: WeightCalculatable {
    // This heavy thing only needs integer accuracy
    typealias WeightType = Int
    
    func calculateWeight() -> Int {
        return 100
    }
}

class LightThing: WeightCalculatable {
    // This light thing needs decimal places
    typealias WeightType = Double
    
    func calculateWeight() -> Double {
        return 0.0025
    }
}

//배열에서 forEach 메서드
var temp = [1,2,3,4,5]

temp.forEach({
    print("\($0)")
})

//WeightCalculatable 타입만을 가지고 있는 어레이에서
extension Array where Element: WeightCalculatable {

}

class Temp {
    var value = 1
}

var tempArray = Array(repeating: Temp(), count: 10)
tempArray.count

extension Array where Element: Temp {
    func wow() {
        forEach({ _ in
            print("Hello")
        })
    }
}

tempArray.wow()

//open : 모듈 외부에서 접근할 수 있는 가장 느슨한 접근한정자 (신규)
//public : 모듈 외부에서 접근할 수 있지만 상속은 되지 않고 override할수 없다
//internal : 모듈일 경우 접근이 가능하고 아무것도 쓰지 않는 경우 기본 설정되는 접근한정자이다.
//fileprivate : 단어 그대로 파일일 경우 접근할 수 있는 접근한정자이다. (신규)
//private: 클래스 등이 선언된 영역내에서만 접근이 가능하다.

//infix 연산자를 선언할 때 

precedencegroup ExponentiationPrecedence { //연산자 설정
    associativity: left //결합방향
    higherThan: MultiplicationPrecedence //우선 순위
}

infix operator **: ExponentiationPrecedence

func **<T: Integer>(lhs: T, rhs: Int) -> T {
    var result = lhs
    for _ in 2...rhs {
        result *= lhs
    }
    return result
}

2 * 2 ** 3

class Person {
    let name: String
    let age: Int

    init(name: String, age: Int) {
        self.name = name
        self.age = age
    }
}

let me = Person(name: "Cosmin", age: 30)

extension Person {
    subscript(key: String) -> String? {
        switch key {
            case "name":
                return name
            case "age":
                return "\(age)"
            default:
                return nil
        }
    }
}

//if case, guard case 로 패턴 매칭
let coordinate = (x: 1, y: 0, z: 0)

if (coordinate.y == 0) && (coordinate.z == 0) {
    print("along the x-axis")
}

if case (_, 0, 0) = coordinate {
    print("along the x-axis")
}

//for case 패턴 매칭
let groupSizes = [1, 5, 4, 6, 2, 1, 3]
for case 1 in groupSizes {
    print("Found an individual") // 2 times
}

//옵셔널 패턴 매칭
let names: [String?] = ["Michelle", nil, "Brandon", "Christine", nil, "David"]

for case let name? in names {
    print(name) // 4 times
}

for case let name in names {
    print(name)
}

let array: [Any] = [15, "George", 2.0]

//is 바인딩
for element in array {
    switch element {
    case is String:
        print("Found a string") // 1 time
    default:
        print("Found something else") // 2 times
    }
}

//as 바인딩
for element in array {
    switch element {
    case let text as String:
        print("Found a string: \(text)") // 1 time
    default:
        print("Found something else") // 2 times
    }
}

//콤마로 연달아 할 수 있다. leg를 value와 바인딩 한 다음 바로 다음 case 2...4에서 레그를 판단
//if case .animal(let legs) = pet, case 2...4 = legs {
//    print("potentially cuddly") // Printed!
//} else {
//    print("no chance for cuddles")
//}

//user != nil
//let _ = user

//terminator를 쓰면 행 바꿈을 하지 않고 뒤에 붙일 문자를 결정한다.
print("Buzz", terminator: " ")

//범위 안에 5가 있는 지 확인. ... 연산자가 비교 연산 할 수 없기에. ~= 매칭 되는지 여부 확인. 일반적인 배열에서는 contains를 써야 한다.
let matched = (1...10 ~= 5) // true

if case 1...10 = 5 {
    print("In the range")
}

enum PetFood: String {
    case kibble, canned
}

let team: [String?] = ["janie", "tammy", nil]

let petNames = team.map { $0 } //map을 쓰면 nil도 포함
let betterPetNames = team.flatMap { $0 } //flatMap을 쓰면 nil 제외

//try! bakery.orderPastry(item: "Cookie", amountRequested: 1, flavor: "ChocolateChip") //do try catch 쓰지 않는 경우. 에러 나면 그냥 nil 반환. 어디서 오류 났는지 알 수 없게 된다.
//try! bakery.orderPastry(item: "Cookie", amountRequested: 1, flavor: "ChocolateChip") //do try catch 쓰지 않는 경우. 이 경우 에러나면 크래쉬

//rethrows 키워드는 함수에 파라미터로 전달된 클로저가 throws로 선언된 경우에만 오류를 던질 수 있게 만듭니다.
//파라미터에 값을 전달할 수 있다는 것도 기억하기 바라며 메소드의 인수에 오류가 발생할 수 있는 클로저를 사용할 경우 그대로 오류를 리턴해주고 싶은 경우가 있습니다. 이런 경우에는 throws 대신 rethrows를 정의해서 사용할 수 있지만 주의해야할 점은 rethrows를 지정하면 해당 메소드 내에서 새로운 오류를 보낼 수 없게 되므로 주의해야 합니다.

//weak과 unowned 차이는 nil이 될 수 있는 지 없는 지 여부.

//캡쳐리스트. 클로저가 값을 카피하기 때문에 원본 변수의 값을 사용하고자 할 때는 대괄호로 변수를 감싸면 된다.
//[unowned self]를 사용하면 클로저에서 값을 캡쳐해도 순환참조를 끊을 수 있다. - weak의 경우는 옵셔널이기 때문에 unowned
//var counter = 0
//var closure = { print(counter) }
//counter = 1
//closure()

//counter = 0
//closure = { [counter] in print(counter) }
//counter = 1
//closure()

//GCD
func log(message: String) {
    let thread = Thread.current.isMainThread ? "Main" : "Background"
    print("\(thread) thread: \(message)")
}

func addNumbers(range: Int) -> Int {
    log(message: "Adding numbers...")
    return (1...range).reduce(0, +)
}

let queue = DispatchQueue(label: "queue") //created a serial queue

//escape 키워드를 써준다. 클로저는 기본이 Non-escape. 반환 시 다시 사용되지 않는 것이 Non-escape. @nonescape :: 이렇게 하면 함수에 전달된 클로저를 이 함수 본문 밖에서는 사용할 수 없도록 컴파일러에게 지시합니다. 스위프트의 클로저는 일등시민(first-class citizen)이므로 클로저를 다른 변수에 담아두면 언제 어디서든지 원할 때 호출할 수 있습니다. 함수에 전달된 클로저에 @noescape 표시를 함으로써, 컴파일러에게 내가 전달하는 이 클로저를 여기서만 실행한 후에 바로 파기하라고 지시하는 것입니다. 추가로 얻게 되는 장점은 @noescape을 지정하면 컴파일러가 해당 클로저에 대해 더 나은 최적화를 할 수 있게 됩니다. @noescape를 지정한 클로저의 또 다른 장점은 self를 명시적인 weak self 를 통해 캡쳐할 필요가 없다는 점입니다. 이 클로저는 함수 본문 중에서 실행되고 함수가 끝나는 시점에 소멸될 것이기 때문에 환경 캡쳐에 따른 복잡한 상황에 대해 고민할 필요가 없게 됩니다.
func excute<T>(backgroundWork: @escaping () -> T, mainWork: @escaping (T) -> ()) {
    //새로 만든 큐에서 비동기로 실행
    queue.async {
        let result = backgroundWork()
        //메인 큐에서 비동기로 실행
        DispatchQueue.main.async {
            mainWork(result)
        }
    }
}

//PlaygroundPage.current.needsIndefiniteExecution = true //플레이 그라운드가 Async를 기본으로 막아 두기 때문에 해제.

//비동기 중에는 unowned로 self를 캡쳐할 수 없다. nil이 될 수도 있기 때문에. - 임의로 강한 참조를 만들어야 할 때도 있다.
//p.350
//func editTutorial() {
//    queue.async() {
//        [weak self] in //nil이 될 수도 있으므로 weak
//        
//        guard let strongSelf = self else { //이 큐가 실행 될 때 self가 nil이라면 리턴
//            return
//        }
//        DispatchQueue.main.async { //self가 보장
//            print(strongSelf.feedback)
//        }
//    }
//}






struct Color: CustomStringConvertible {
    var red, green, blue: Double
    
    var description: String {
        return "r: \(red) g: \(green) b: \(blue)"
    }
}

extension Color {
    static var black = Color(red: 0, green: 0, blue: 0)
    static var white = Color(red: 1, green: 1, blue: 1)
    static var blue  = Color(red: 0, green: 0, blue: 1)
    static var green = Color(red: 0, green: 1, blue: 0)
}

class Bucket {
    init(color: Color) {
        self.color = color
    }
    
    var color: Color
    var isRefilled = false
    func refill() {
        isRefilled = true
    }
}

struct PaintingPlan // a value type, containing ...
{
    var accent = Color.white
    private var bucket = Bucket(color: .blue)
    
    var bucketColor: Color {
        get {
            return bucket.color
        }
        set {
            bucket = Bucket(color: newValue)
        }
    }
}

var artPlan = PaintingPlan()
var housePlan = artPlan
housePlan.bucketColor = Color.green //private로 선언되어 있기 때문에 외부에서 바꿀 수 없다.
artPlan.bucketColor // blue. better!

//copy-on-write (COW) :: private로 class 인스턴스를 할당해서 외부에서 접근 불가능 하게. 레퍼런스 타입이지만 값타입 처럼 사용할 수 있다. - 성능 향상. 인스턴스 지만 스토리지 처럼. 다른 곳에 공유되지 않을 때.
//COW는 어떤 프로그래밍 언어(예를들어 스위프트)에서는 자료구조 복사시에 사용합니다. array를 복사하면 처음에는 실제로 복사가 일어나지 않지만, 한 쪽 array의 값을 변경하는 순간 실제로 메모리 복사가 발생하는거져.

//isKnownUniquelyReferenced :: COW로 된 백업 저장소를 참조할 수 있는 라이브러리. - 유일한 접근인지 확인


//struct PaintingPlan // a value type, containing ...
//{
//    // a value type
//    var accent = Color.white
//    // a private reference type, for "deep storage"
//    private var bucket = Bucket(color: .blue)
//    
//    // a computed property facade over deep storage
//    // with copy-on-write and in-place mutation when possible
//    var bucketColor: Color {
//        get {
//            return bucket.color
//        }
//        set {
//            if isKnownUniquelyReferenced(&bucket) { //직접 대입해 접근 시
//                bucket.color = bucketColor
//            } else { //복사하여 접근 시
//                bucket = Bucket(color: newValue)
//            }
//        }
//    }
//}

//var artPlan = PaintingPlan()
//var housePlan = artPlan
//housePlan.bucketColor = Color.green // else
//artPlan.bucketColor = Color.green // isKnownUniquelyReferenced














