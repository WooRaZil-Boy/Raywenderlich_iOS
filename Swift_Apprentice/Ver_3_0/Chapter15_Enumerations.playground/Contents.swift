//: Chapter 15: Enumerations

//enumeration은 연관된 값들의 집합. Swift에서는 method나 computed property를 사용할 수 있어 더 유용

//Your first enumeration
let months = ["January", "February", "March", "April", "May",
              "June", "July", "August", "September", "October",
              "November", "December"]

func semesterSwitch(for month: String) -> String { //switch로도 작동하지만 오타의 위험이 높다.
    switch month {
    case "August", "September", "October", "November", "December":
        return "Autumn"
    case "January", "February", "March", "April", "May":
        return "Spring"
    default:
        return "Not in the school year"
    }
}

semesterSwitch(for: "April")

//Declaring an enumeration
enum MonthInBasic {
    case january
    case february
    case march
    case april
    case may
    case june
    case july
    case august
    case september
    case october
    case november
    case december
}

enum MonthsInLine { //이렇게 쓸 수도 있다.
    case january, february, march, april, may, june, july, august,
    september, october, november, december
}

//Deciphering an enumeration in a function
func semester(for month: MonthsInLine) -> String {
    switch month { //타입 추정을 하기 때문에 Month.august 대신 그냥 .august로 쓸 수 있다.
        case .august, .september, .october, .november, .december:
            return "Autumn"
        case .january, .february, .march, .april, .may:
            return "Spring"
    case .june, .july: //열거형은 case가 정해져 있으므로, 모든 case를 포함하면, default를 생략할 수 있다.
            //이렇게 default 대신 모든 경우의 case를 포함하는 것이 좋다. 나중에 열거형을 추가하면 충족이 되지 않기 때문에 컴파일 에러가 나서 관리가 쉽다.
            return "Summer"
//        default:
//            return "Not in the school year"
    }
}

var month = MonthsInLine.april
semester(for: month) // "Spring"

month = .september
semester(for: month) // "Autumn"

//Raw values
//C언어와 달리 raw values를 default로 가지고 있지 않는다. enum은 그 자체로 값.
enum Month: Int { //Int로 선언 하면 자동적으로 순차적 raw value를 가진다. //String, Float등 형을 지정할 수 있다.
//    case january = 1, february = 2, march = 3, april = 4, may = 5,
//    june = 6, july = 7, august = 8, september = 9,
//    october = 10, november = 11, december = 12
    case january = 1, february, march, april, may, june, july,
    august, september, october, november, december
}

//Accessing the raw value
func monthsUntilWinterBreak(from month: Month) -> Int {
    return Month.december.rawValue - month.rawValue //.rawValue 접근 가능
}

//Initializing with the raw value
let fifthMonth = Month(rawValue: 5) //이니셜라이저를 사용할 수 있다. //하지만 리턴값은 옵셔널이라 래핑을 해줘야 한다. //rawValue가 있다는 보장이 없으므로
//monthsUntilWinterBreak(from: fifthMonth) // Error: not unwrapped

let fifthMonth2 = Month(rawValue: 5)!
monthsUntilWinterBreak(from: fifthMonth2) //computed property로 간단히 만들 수도 있다.

//String raw values
enum Icon: String { //String에서도 raw values가 있다.
    case music
    case sports
    case weather
    
    var filename: String { //computed property
        return "\(rawValue).png" //String 형이므로 raw value는 enum의 string
    }
}
let icon = Icon.weather
icon.filename // weather.png

//Unordered raw values
enum Coin: Int { //이런 경우에는 자동적으로 증가하는 raw value를 지정해 줄 수 없이 직접 입력.
    case penny = 1
    case nickel = 5
    case dime = 10
    case quarter = 25
} //이런 경우에는 associated value를 유용하게 쓸 수 있다. //An enumeration can have raw values or associated values, but not both.

let coin = Coin.quarter
coin.rawValue

//Associated values : 에러 핸들링에 유용하다.
var balance = 100

enum WithdrawalResult { //an enumeration with associated values //각 케이스는 각각의 value가 필요하다.
    case success(newBalance: Int)
    case error(message: String)
}

func withdraw(amount: Int) -> WithdrawalResult {
    if amount <= balance {
        balance -= amount
        return .success(newBalance: balance)
    } else {
        return .error(message: "Not enough money!")
    }
} //트랜잭션을 보장해 줘야 한다.

let result = withdraw(amount: 99)

switch result {
    case .success(let newBalance): //associated value를 가져오기 위해 let binding //프로퍼티와 같이 단순히 접근할 수 없다.
        print("Your new balance is: \(newBalance)") //여기서는 Int
    case .error(let message):
        print(message) //여기서는 String
}

enum HTTPMethod { //associated values
    case get
    case post(body: String)
}

let request = HTTPMethod.post(body: "Hi there")
guard case .post(let body) = request else { //바인딩 if case 혹은. guard case
    fatalError("No message was posted")
}

print(body)

//Enumeration as state machine
enum TrafficLight { //상태를 나타내는 데 유용하게 쓰일 수 있다.
    case red, yellow, green
}
let trafficLight = TrafficLight.red //동시에 다른 값이 될 수 없기 때문에 상태를 나타내기 적합하다.

//Case-less enumerations
enum Math {
    static func factorial(of number: Int) -> Int {
        return (1...number).reduce(1, *)
    }
}
let factorial = Math.factorial(of: 6) // 720
//let math = Math() // ERROR: No accessible initializers
//구조체나 클래스와 비슷한 경우에서라도 스위프트에서는 열거형으로 디자인하는 것이 더 나은 경우도 있다.
//위의 경우 구조체나 클래스로 구현한 경우, Math()로 인스턴스를 생성하면 전역 함수를 사용할 때 무의미하게 된다.
//하지만 열거형으로 구현하면, 그런 경우 에러가 나서 코드를 효율적으로 관리할 수 있다.

//스위프트에서 열거형은 구조체와 거의 유사하다. 메서드, 이니셜라이저도 가질 수 있으며, 위의 Math()처럼 의미없는 인스턴스가 생성될 수 있는 경우는 열거형으로 선언하는 것이 더 낫다.
//https://outofbedlam.github.io/swift/2016/04/05/EnumBestPractice/

//Optionals
var age: Int? //옵셔널도 사실 열거형(associated value). //.none은 nil, .some은 value
age = 17
age = nil

switch age {
    case .none: //?
        print("No value")
    case .some(let value): //!
        print("Got a value: \(value)")
}

let optionalNil: Int? = .none
optionalNil == nil    // true
optionalNil == .none  // true
