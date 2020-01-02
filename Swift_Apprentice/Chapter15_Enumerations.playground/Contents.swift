//Chapter 15: Enumerations

//지도 앱을 만든다고 가정할 때, 코드 작성시 기본 방향을 int 변수로 나타낼 수 있다.
//ex. North: 1, South: 2, East: 3, West: 4
//하지만, 명확한 관계가 없는 변수이므로 코드 작성시 혼란스러울 수 있다. 이를 완화하기 위해 int 대신 string으로 표시할 수 있다.
//ex. North: "north", South: "south", East: "east", West: "west"
//문자열의 변수의 문제점은 임의의 어떤 문자열도 value를 가진다는 것이다. "north" 대신 "up"을 사용하거나, "nrth"와 같이 오타를 입력하는 경우도 흔하다.
//열거형(enumeration)을 사용해, 이와 같은 문제점을 해결할 수 있다. 열거형을 사용해 컴파일러에서 확인된 value들의 모음을 만들 수 있다.
//열거형은 공통 type을 정의하고, value를 안전하게 입력할 수 있는 관련 값 목록이다.
//위의 예제에서 4방향의 열거형 Direction을 사용할 때, 10.7, "Souuth" 등과 같이 잘못된 value를 입력한다면, 컴파일러에서 오류를 잡아낸다.
//ex. colors(black, red, blue), card suits(hearts, spades, clubs, diamonds), roles(administrator, editor, reader)
//Swift의 열거형은 C나 Objective-C와 같은 다른 언어들보다 강력한 기능을 가지고 있다.
//Swift에서 열거형은 오히려 구조체나 클래스와 비슷하다. 메서드나 computed property를 가질 수 있다.




//Your first enumeration
//해당 월을 기준으로 학기를 알려주는 함수를 만든다. 한 가지 간단한 해결 방법은 문자열 Array과 switch를 사용하는 것이다.
let months = ["January", "February", "March", "April", "May",
              "June", "July", "August", "September", "October",
              "November", "December"]
func semester(for month: String) -> String {
    switch month {
    case "August", "September", "October", "November", "December":
        return "Autumn"
    case "January", "February", "March", "April", "May":
        return "Spring"
    default:
        return "Not in the school year"
    }
}
semester(for: "April") // Spring
//하지만, 이렇게 문자열을 사용하는 방법은 오타를 입력하기 쉽기 때문에 열거형을 사용하는 것이 좋다.

//Declaring an enumeration
//열거형은 모든 멤버 value를 case로 선언해 주면 된다.
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
//12개의 멤버 value로 MonthInBasic라는 열거형을 만든다. 일반적인 변수 사용과 마찬가지로, 멤버 value의 시작은 소문자로 하는 것이 권장된다.
//각 case를 쉼표로 구분하여 한 줄로 축소해 줄 수도 있다.
enum MonthsInLine {
    case january, february, march, april, may, june, july, august,
    september, october, november, december
}

//Deciphering an enumeration in a function
//위에서 사용한 함수를 문자열 대신 열거형을 매개변수로 사용하도록 변경한다.
func semester(for month: MonthInBasic) -> String {
    switch month {
//    case MonthInBasic.august, MonthInBasic.september, MonthInBasic.october, MonthInBasic.november, MonthInBasic.december:
    case .august, .september, .october, .november, .december: //위의 표현을 단순화 할 수 있다.
        return "Autumn"
//    case MonthInBasic.january, MonthInBasic.february, MonthInBasic.march, MonthInBasic.april, MonthInBasic.may:
    case .january, .february, .march, .april, .may: //위의 표현을 단순화 할 수 있다.
        return "Spring"
    case .june, .july:
        return "Summer"
//    default:
//        return "Not in the school year"
        //열거형을 switch에서 사용하는 경우 모든 case를 작성하면, default를 제거해 줄 수 있다.
    }
}
//Swift는 type에 엄격하고, type inference를 할 수 있기 때문에 컴파일러에서 type을 이미 알고 있는 경우 이를 단순화할 수 있다.
//위에서는 Month 열거형이 매개변수임을 컴파일러가 이미 알고 있기 때문에 이를 생략해 줄 수 있다.
//switch는 해당 열거형의 case를 모두 구현해야 한다. 그렇지 않은 경우, 컴파일러에서 경고 메시지를 출력한다.
//switch에서 판단하는 value가 문자열인 경우, 모든 일치하는 case를 작성해 줄 수 없기 때문에 default가 필요하다.
//하지만, 열거형을 사용하면 case가 정해져 있기 때문에 모든 case를 작성하면, default를 제거해 줄 수 있다. 코드가 훨씬 간결해 진다.
//default를 제거해서 얻을 수 있는 또 다른 장점은 차후에 또 다른 case를 추가하는 경우, 컴파일러가 누락된 case에 대한 경고를 해 줄 수 있다.
var month = MonthInBasic.april //열거형 이름을 사용해 선언해 줄 수 있다.
semester(for: month) // "Spring"
month = .september //컴파일러가, MonthInBasic type 임을 알고 있으므로, 열거형을 생략하고 바로 멤버를 지정해 선언해 줄 수 있다.
semester(for: month) // "Autumn"
//열거형 변수 선언에도 type inference를 사용할 수 있다.

//Code completion prevents typos
//문자열 대신 열거형을 사용할 때의 또 다른 장점은 멤버 value에 오타가 없다는 것이다. Xcode 코드 완성을 사용할 수 있다.
//열거형 멤버 value의 철자가 틀리면 컴파일러에서 오류를 발생한다.




//Raw values
//C의 열거형과 달리 Swift 열거형은 기본적으로 정수값이 할당되지 않는다. 위의 열거형에서, january는 자체 값일 뿐이다.
//그러나, 열거형 선언에서 raw value를 선언하면 열거형 멤버에 정수 값을 연결해 줄 수 있다.
enum Month: Int { //열거형에 String, Float, Character 등의 type을 지정해 줄 수 있다.
//    case january = 1, february = 2, march = 3, april = 4, may = 5,
//    june = 6, july = 7, august = 8, september = 9,
//    october = 10, november = 11, december = 12
    case january = 1, february, march, april, may, june, july,
    august, september, october, november, december
    //첫 번째 값만 raw value를 적용하고 나머지를 생략하면, 컴파일러가 자동으로 raw value를 증가 시키면서 할당한다.
}
//C에서와 같이, Int를 사용하고 value를 지정해 주지 않으면, Swift가 자동으로 0, 1, 2 순으로 raw value를 할당한다.
//첫 번째 값만 raw value를 적용하고 나머지를 생략하면, 컴파일러가 자동으로 raw value를 증가 시키면서 할당한다.
//raw value를 필수적으로 할당해야 하는 것은 아니다. 열거형 값만 사용해야 할 경우에는 raw value를 할당하지 않는다.

//Accessing the raw value
//위의 예제에서 rawValue 속성을 사용해 방학까지 남은 개월 수를 계산 하는 함수를 만들 수 있다.
func monthsUntilWinterBreak(from month: Month) -> Int {
    Month.december.rawValue - month.rawValue
}
monthsUntilWinterBreak(from: .april) // 8

//Initializing with the raw value
//rawValue를 사용하는 initializer로 열거형 변수를 인스터스화 할 수 있다. init(rawValue:)로 이를 사용할 수 있지만, 오류가 발생한다.
let fifthMonthOptional = Month(rawValue: 5)
//monthsUntilWinterBreak(from: fifthMonthOptional) // Error: not unwrapped
//파라미터로 사용한 rawValue 값이 열거형에 있다고 보장할 수 없으므로 initializer는 optional을 반환한다.
//rawValue를 사용하는 열거형의 initializer는 failable initializer이다. 즉, 문제가 발생하면 nil을 반환한다.
//따라서 raw value가 확실하지 않다면, nil을 확인하거나 optional binding을 사용해야 한다.
let fifthMonth = Month(rawValue: 5)! //여기서는 force unwrapping을 사용했다.
monthsUntilWinterBreak(from: fifthMonth) // 7
//optional을 unwrapping 했기 때문에 이제는 오류가 발생하지 않는다.

//String raw values
//Int rawValue와 비슷하게 String을 raw value type으로 지정해 주면, 자동변환을 사용할 수 있다.
//각 세션에 대한 탭이 있는 뉴스 앱을 만든다 가정한다. 각 세션에는 아이콘이 있고, 이는 제한된 세트이므로 열거형을 사용하기 좋다.
enum Icon: String { //raw value type으로 String을 사용한다.
    case music
    case sports
    case weather
    
    var filename: String { //computed property
        "\(rawValue).png" //rawValue로 해당 raw value를 가져올 수 있다. //self.rawValue와 같다.
        //여기서는 rawValue가 String 이므로 파일 이름을 작성해 줄 수 있다.
    }
}
let icon = Icon.weather
icon.filename // weather.png
//rawValue를 사용하면, 이런 경우에는 각 멤버 value에 대해 문자열을 따로 지정해 줄 필요가 없다.
//열거형의 rawValue type을 String으로 설정하고, 따로 rawValue를 지정하지 않으면 컴파일러는 열거형의 case 이름을 rawValue로 사용한다.

//Unordered raw values
//Int를 rawValue로 사용하는 경우, 정수가 반드시 순서를 나타낼 필요는 없다.
enum Coin: Int {
    case penny = 1
    case nickel = 5
    case dime = 10
    case quarter = 25
}
let coin = Coin.quarter
coin.rawValue // 25




//Associated values
//Associated value를 사용해, 더 다양하게 열거형을 표현할 수 있다. Associated value는 각 열거형 멤버 값에 사용자 지정 값을 연결한다.
//Associated value의 고유한 특성은 다음과 같다.
//  1. 각 열거 case에는 0개 이상의 associated value가 있다.
//  2. 각 열거 case에 대한 associated value에는 고유한 데이터 type이 있다.
//  3. 함수의 매개변수와 같이 label name으로 associated value를 정의할 수 있다.
//열거형은 raw value 혹은 associated value를 가질 수 있지만, 동시에 둘을 가질 수는 없다.
//위의 coin 예제에서 은행에서 돈을 입금하고, ATM기에서 인출하는 것을 가정한다.
var balance = 100
//func withdraw(amount: Int) {
//    balance -= amount
//}
//잔액보다 더 많은 금액을 인출할 수 없으므로 거래 성공 여부를 알려줄 방법이 있어야 한다. 이를 Associated value로 구현할 수 있다.
enum WithdrawalResult { //an enumeration with associated values //각 케이스는 각각의 value가 필요하다.
    case success(newBalance: Int) //Associated value는 새 잔액을 나타낸다.
    case error(message: String) //Associated value는 오류 메시지를 나타낸다.
}
//각 case에 맞는 value가 있다. success의 경우에는 Int type의 associated value로 잔액을 표시한다.
//error의 경우에는 String type의 associated value로 오류 메시지를 표시한다. 이를 활용한 withdraw 함수를 재정의한다.
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
        print("Your new balance is: \(newBalance)") //Int
    case .error(let message):
        print(message) //String
}
//associated value는 자유롭게 액세스할 수 있는 속성이 아니므로, binding을 해줘야 한다.
//일반적으로 associated value와 binding 상수를 동일한 이름으로 사용하지만, 꼭 그럴 필요는 없다.
//다수의 context는 열거형의 Associated value에 접근해서 사용한다.
//ex. 인터넷 서버는 request 유형을 구별하기 위해 열거형을 사용한다.
enum HTTPMethod {
    case get
    case post(body: String)
}
//위의 은행 계좌 예에서는 열거형에서 확인해야 할 여러 value가 있었다. 하지만, 하나만 확인하는 경우에는 pattern matching(위에서는 switch) 대신 if case 혹은 guard case를 사용할 수 있다.
let request = HTTPMethod.post(body: "Hi there")
guard case .post(let body) = request else { //request에 해당 case가 포함되어 있는 지 확인해 binding한다.
    fatalError("No message was posted")
}
print(body)
//이 코드에서는 request에 해당 case가 포함되어 있는 지 확인하고, Associated value를 binding한다.
//Error Handling에서도 열거형을 사용할 수 있다. 위의 WithdrawalResult 예에서 간단히 사용했지만, 이 경우에는 하나의 오류와 이에 관련된 문자열만을 가지고 있었다.
//여러 개별 오류 조건을 다루는 열거형을 만들 수도 있다.




//Enumeration as state machine
//열거형은 state machine의 예이다. 즉, 한 번에 하나의 열거값이 될 수 있으며, 그 이상은 될 수 없다. //ex. 신호등
//https://ko.wikipedia.org/wiki/%EC%9C%A0%ED%95%9C_%EC%83%81%ED%83%9C_%EA%B8%B0%EA%B3%84
enum TrafficLight { //상태를 나타내는 데 유용하게 쓰일 수 있다.
    case red, yellow, green
}
let trafficLight = TrafficLight.red //동시에 다른 값이 될 수 없기 때문에 상태를 나타내기 적합하다.
//신호등은 동시에 다른 색이 되지 않는다. 일련의 이벤트에 응답하여 미리 정해진 일련의 행동을 따르는 현대적인 장치에서 state machine의 동작을 확인할 수 있다.
//state machine의 예
// • 적정 금액을 투입해 해당 음료를 판매하는 자동 자판기
// • 내려가기 전에 상층에서 탑승자를 내리는 엘리베이터
// • 올바른 순서의 조합 번호가 필요한 잠금장치
//예상된 동작을 하기 위해 이런 장치들은 한 번에 하나의 상태만 될 수 있으며, 열거형이 이를 보장할 수 있다.




//Iterating through all cases
//열거형의 모든 case를 반복하는 것은 쉽다.
enum Pet: CaseIterable { //CaseIterable 프로토콜 구현
    case cat, dog, bird, turtle, fish, hamster
}
for pet in Pet.allCases {
    print(pet)
    // cat
    // dog
    // bird
    // turtle
    // fish
    // hamster
}
//CaseIterable 프로토콜을 준수하면, allCases라는 클래스 메서드를 사용해 각 case를 반복할 수 있다.




//Enumerations without any cases
//구조체(클래스)에서 정적 메서드를 생성할 수 있다.
struct MathStruct {
    static func factorial(of number: Int) -> Int {
        (1...number).reduce(1, *)
    }
}
let factorialStruct = MathStruct.factorial(of: 6) // 720
//그리고, 구조체(클래스)는 인스턴스를 생성할 수도 있다.
let mathStruct = MathStruct()
//위에서 보듯이 구조체가 비어 있기 때문에 인스턴스를 생성할 수는 있지만, 특정 목적을 가지고 인스턴스를 사용하지는 않는다.
//더 나은 구현 방법은 Math를 열거형으로 생성하는 것이다.
enum Math {
    static func factorial(of number: Int) -> Int {
        (1...number).reduce(1, *)
    }
}
let factorialEnum = Math.factorial(of: 6) // 720
//let math = Math() // ERROR: No accessible initializers
//하지만, 열거형은 인스턴스를 생성하면 오류가 발생한다. 멤버 case가 없는 열거형을 uninhabited types 또는 bottom types라고 하기도 한다.
//Swift의 열거형은 다른 언어에 비해 강력하다. initializer, computed property, method 등을 포함할 수 있어서 구조체가 할 수 있는 거의 모든 것을 구현할 수 있다.
//단, 열거형 인스턴스를 생성하려면, 멤버 value를 state로 할당해야 한다. 멤버 값이 없으면 인스턴스를 만들 수 없다.
//Math의 경우에는 case가 따로 없기 때문에 인스턴스를 생성할 수 없지만, 이는 인스턴스를 생성할 필요가 없으므로 의도된 것이다.
//다른 개발자가 실수로 인스턴스를 생성해도 오류를 발생시키므로 처음 디자인 패턴대로 사용하도록 강제할 수 있다.
//value가 없는 인스턴스를 생성할 때, 혼동의 여지가 있다면 case 멤버가 없는 열거형을 사용하는 것이 좋다.




//Optionals
//Swift의 Optional도 사실은 열거형이다. Optional은 내부에 무언가 있거나 혹은 아무것도 없는 컨테이너와 같은 역할을 한다.
var age: Int?
age = 17
age = nil
//Optional에는 두 가지 case가 있다.
//  1. .none은 value가 없다는 것을 의미한다.
//  2. .some은 어떤 value가 있다는 뜻이며 이는 해당 case의 associated value와 연결된다.
//위에서 살펴본 대로 switch 구문을 사용해 associated value를 추출해 낼 수 있다.
switch age {
    case .none: //?
        print("No value")
    case .some(let value): //!
        print("Got a value: \(value)")
}
//Optional은 실제로 열거형으로 구현되어 있지만, optional binding, ?, ! 연산자, nil 키워드로 세부 구현사항을 숨긴다.
let optionalNil: Int? = .none
optionalNil == nil    // true
optionalNil == .none  // true
//nil과 .none 이 동일하다는 것을 알 수 있다.
