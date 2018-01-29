//: Chapter 20: Pattern Matching

let coordinate = (x: 1, y: 0, z: 0)

if (coordinate.y == 0) && (coordinate.z == 0) {
    print("along the x-axis")
}

if case (_, 0, 0) = coordinate { //패턴 매칭. 가독성이 훨씬 나아진다. //와일드카드
    print("along the x-axis")
}

//위의 두 코드는 같은 결과를 반환한다

//if and guard
func process1(point: (x: Int, y: Int, z: Int)) -> String {
    if case (0, 0, 0) = point {
        return "At origin"
    }
    return "Not at origin"
}

let point1 = (x: 0, y: 0, z: 0)
let response1 = process1(point: point1) //At origin

func process2(point: (x: Int, y: Int, z: Int)) -> String {
    guard case (0, 0, 0) = point else { //guard 문을 쓸 수도 있다.
        return "Not at origin"
    }
    return "At origin"
}

let point2 = (x: 0, y: 0, z: 0)
let response2 = process2(point: point2) //At origin

//switch
func process3(point: (x: Int, y: Int, z: Int)) -> String {
    let closeRange = -2...2
    let midRange = -5...5
    
    switch point { //switch는 if보다 더 나은점이 많다. switch는 가능한 모든 값을 확인했음을 보장한다(default)
    case (0, 0, 0):
        return "At origin"
    case (closeRange, closeRange, closeRange) :
        return "Very close to origin"
    case (midRange, midRange, midRange):
        return "Nearby origin"
    default:
        return "Not near origin"
    }
}

let point3 = (x: 15, y:5, z:3)
let response3 = process3(point: point3)

//for
let groupSizes = [1, 5, 4, 6, 2, 1, 3]
for case 1 in groupSizes { //if 대신에 case로 패턴매칭해서 쓸 수도 있다.
    print("Found an individual") //2times
}

//Value-binding pattern
if case (let x, 0, 0) = coordinate {
    print("On the x-axis at \(x)") //Print: 1
}

if case let (x, y, 0) = coordinate { //다중 바인딩
    print("On the x-y plane at (\(x), \(y)") //print 1, 0
}

//Enumeration case pattern
enum Direction {
    case north, south, east, west
}

let heading = Direction.north

if case .north = heading {
    print("Don't forget your jacket")
}

enum Organism {
    case plant
    case animal(leg: Int)
}

let pet = Organism.animal(leg: 4)

switch pet {
    case .animal(let legs):
        print("Petensially cuddly with \(legs) legs") //4
    default:
        print("No chance for cuddles")
}

//Optional pattern
let names: [String?] = ["Michelle", nil, "Brandon", "Christine", nil, "David"]
for case let name? in names { //for loop 안에 if 쓰지 않고 이런 식으로 가능
    print(name)
}

//“Is” type-casting pattern
let array: [Any] = [15, "George", 2.0] //Any로 여러 타입을 한 번에 담을 수 있다.

for element in array {
    switch element {
        case is String: //자료형이 String
            print("Froud a string") // 1 time
        default:
            print("Froud something else") // 2 times
    }
}

//“As” type-casting pattern
for element in array {
    switch element {
        case let text as String: //is에 추가해서 값을 바인딩 한다.
            print("Found a string: \(text)") // 1 time
        default:
            print("Found something else") // 2 times
    }
}

//Qualifying with where
for number in 1...9 {
    switch number {
        case let x where x % 2 == 0:
            print("even") // 4 times
        default:
            print("odd") // 5times
    }
}

enum LevelStatus {
    case complete
    case inProgress(percent: Double)
    case notStarted
}

let levels: [LevelStatus] = [.complete, .inProgress(percent:0.9), .notStarted]

for level in levels {
    switch level {
        case .inProgress(let percent) where percent > 0.8 :
            print("Almost there!")
        case .inProgress(let percent) where percent > 0.5 :
            print("Halfway there!")
        case .inProgress(let percent) where percent > 0.2 :
            print("Made it through the beginning!")
        default:
            break
    }
}

//Chaining with commas
func timeOfDayDescription(hour: Int) -> String {
    switch hour {
        case 0, 1, 2, 3, 4, 5:
            return "Early morning"
        case 6, 7, 8, 9, 10, 11:
            return "Morning"
        case 12, 13, 14, 15, 16:
            return "Afternoon"
        case 17, 18, 19:
            return "Evening"
        case 20, 21, 22, 23:
            return "Late evening"
        default:
            return "INVALID HOUR!"
    }
}
let timeOfDay = timeOfDayDescription(hour: 12) // Afternoon

if case .animal(let legs) = pet, case 2...4 = legs { //case를 이런 식으로 활용할 수도 있다. //여러 조건을 if에서 콤마로 연결해 줄 수 있다.
    print("potentially cuddly")
} else {
    print("no chance for cuddles")
}

//• Simple logical test E.g.: foo == 10 || bar > baz
//• Optional binding E.g.: let foo = maybeFoo
//• Pattern matching E.g.: case .bar(let something) = theValue

enum Number {
    case integerValue(Int)
    case doubleValue(Double)
    case booleanValue(Bool)
}

let a = 5
let b = 6
let c: Number? = .integerValue(7)
let d: Number? = .integerValue(8)

if a != b {
    if let c = c {
        if let d = d {
            if case .integerValue(let cValue) = c {
                if case .integerValue(let dValue) = d {
                    if dValue > cValue {
                        print("a and b are different") // Printed!
                        print("d is greater than c") // Printed!
                        print("sum: \(a + b + cValue + dValue)") // 26
                    }
                }
            }
        }
    }
} //pyramid of doom

if a != b, let c = c, let d = d, case .integerValue(let cValue) = c, case .integerValue(let dValue) = d, dValue > cValue { //한 번에 쓸 수 있다.
    print("a and b are different") // Printed!
    print("d is greater than c") // Printed!
    print("sum: \(a + b + cValue + dValue)") // Printed: 26
}

//Custom tuple
let name = "Bob"
let age = 23

if case ("Bob", 23) = (name, age) { //튜플을 이용해 다른 값을 동시에 조건문에 넣을 수 있다.
    print("Found the right Bob!") // Printed!
}

var username: String?
var password: String?

switch (username, password) {
    case let (username?, password?): //가장 위에 통과되는 조건을 위치하게 한다. 이러면 제대로 들어왔을 시, 다른 조건을 볼 필요 없이 바로 종료되기 때문이다. //옵셔널이기에 ? 넣어줘야.
        print("Success! User: \(username) Pass: \(password)")
    case let (username?, nil):
        print("Password is missing. User: \(username)")
    case let (nil, password?):
        print("Username is missing. Pass: \(password)")
    case (nil, nil):
        print("Both username and password are missing")  // Printed!
}

//Fun with wildcards
for _ in 1...3 { //사용할 필요가 없을 때 와일드 카드로 밑줄을 써줄 수 있다.
    print("hi") // 3 times
}

//Validate that an optional exists
let user: String? = "Bob"
guard let _ = user else {
    print("There is no user.")
    fatalError() //어플을 강제로 종료 시킨다.
}

print("User exists, but identity not needed.") // Printed

guard user != nil else {
    print("There is no user.")
    fatalError()
} //위의 guard와 같다.

//Organize an if-else-if
struct Rectangle {
    let width: Int
    let height: Int
    let color: String
}

let view = Rectangle(width: 15, height: 60, color: "Green")

switch view {
    case _ where view.height < 50:
        print("Shorter than 50 units")
    case _ where view.width > 20:
        print("Over 50 tall, & over 20 wide")
    case _ where view.color == "Green":
        print("Over 50 tall, at most 20 wide, & green") // Printed!
    default:
        print("This view can't be described by this example")
}

//Programming exercises
//패턴 매칭으로 더 쉽게 구현 가능하다.

//Fibonacci
func fibonacci(position: Int) -> Int {
    switch position {
        case let n where n <= 1:
            return 0
        case 2:
            return 1
        case let n:
            return fibonacci(position: n-1) + fibonacci(position: n-2)
    }
}

let fib15 = fibonacci(position: 15) // 377

//FizzBuzz
for i in 1...100 {
    switch (i % 3, i % 5) {
        case (0, 0):
            print("FizzBuzz", terminator: " ") //terminator를 사용하면, 줄바꿈 대신 해당 문자열이 들어간다.
        case (0, _):
            print("Fizz", terminator: " ")
        case (_, 0):
            print("Buzz", terminator: " ")
        case (_, _):
            print(i, terminator: " ")
    }
}

print("")

//Expression pattern
let matched = (1...10 ~= 5) // true
//~= 연산자는 특정 범위에 해당 값이 포함되어 있는지를 검사할 때 쓰는 연산자이다. 보통은 >= && <= 등으로 사용하던 것을 간단히 줄일 수 있다.

 if case 1...10 = 5 { //위의 ~= 와 같은 표현
    print("In the range")
}

//Overloading ~=
let list = [0, 1, 2, 3]
let integer = 2

//let isInArray = (list ~= integer) // Error!

//if case list = integer { // Error!
//    print("The integer is in the array")
//} else {
//    print("The integer is not in the array")
//}
//위의 두 경우는 모두 integer가 list에 속해 있지만 오류가 난다.

func ~=(pattern: [Int], value: Int) -> Bool { //오버로드해서 사용
    for i in pattern {
        if i == value {
            return true
        }
    }
    return false
}

let isInArray = (list ~= integer) // true
if case list = integer {
    print("The integer is in the array") // Printed!
} else {
    print("The integer is not in the array")
}
