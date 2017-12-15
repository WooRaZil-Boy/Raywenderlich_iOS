//: Chapter 19: Custom Operators, Subscripts and Keypaths

import Foundation

//Precedence and associativity
precedencegroup ExponentiationPrecedence { //precedencegroup를 사용하여 어떤 속성을 가질 것인지 정의
    associativity: right //결합방향 오른쪽
    higherThan: MultiplicationPrecedence //우선순위 곱셉보다 우선
}

//Exponentiation operator
infix operator **: ExponentiationPrecedence //사용자 정의 연산자

func **(base: Int, power: Int) -> Int {
    precondition(power >= 2) //2보다 커야 한다. 제약조건
    
    var result = base
    
    for _ in 2...power {
        result *= base
    }
    
    return result
}

let base = 2
let exponent = 3
let result = base ** exponent

//Compound assignment operator
infix operator **=

func **=(lhs: inout Int, rhs: Int) { //inout 키워드를 써줘야 값을 함수 안에서 변경할 수 있다.
    lhs = lhs ** rhs
} //위의 함수와 달리 return하지 않고 덮어쓴다.

 var number = 2
number **= exponent

//Generic operators
func **<T: BinaryInteger>(base: T, power: Int) -> T { //BinaryInteger형의 제네릭
    precondition(power >= 2)
    
    var result = base
    
    for _ in 2...power {
        result *= base
    }
    
    return result
}

func **=<T: BinaryInteger>(lhs: inout T, rhs: Int) {
    lhs = lhs ** rhs
}

let unsignedBase: UInt = 2
let unsignedResult = unsignedBase ** exponent

let base8: Int8 = 2
let result8 = base8 ** exponent

let unsignedBase8: UInt8 = 2
let unsignedResult8 = unsignedBase8 ** exponent

let base16: Int16 = 2
let result16 = base16 ** exponent

let unsignedBase16: UInt16 = 2
let unsignedResult16 = unsignedBase16 ** exponent

let base32: Int32 = 2
let result32 = base32 ** exponent

let unsignedBase32: UInt32 = 2
let unsignedResult32 = unsignedBase32 ** exponent

let base64: Int64 = 2
let result64 = base64 ** exponent

let unsignedBase64: UInt64 = 2
let unsignedResult64 = unsignedBase64 ** exponent

//파운데이션의 pow(_:_:)를 쓸 수 있다. 하지만 pow(_:_:)는 모든 유형에서 작동하지 않는다. 하지만 그것은 음수나 분수도 처리할 수 있고 O(log)를 가진다.
//위에서 직접 구현한 지수는 O(n)

//Precedence and associativity
//2 * 2 ** 3 ** 2 // Does not compile!
//Precedence(우선순위)와 Associativity(결합방향)을 지정해 주어야 한다.
2 * (2 ** (3 ** 2)) //우선순위와 결합방향을 지정해주지 않고 괄호로 묶어서 나타낼 수도 있다.

2 * 2 ** 3 ** 2

//Subscripts
//밑과 같은 식으로 서브스크립트를 구현해 줄 수 있다.
//subscript(parameterList) -> ReturnType {
//    get {
//        // return someValue of ReturnType
//    }
//    set(newValue) { //setter는 optional
//        // set someValue of ReturnType to newValue
//    }
//}
//그러나 서브스크립트는 inout 또는 default를 쓸 수 없으면 error를 throw할 수 없다.

class Person {
    let name: String
    let age: Int
    
    init(name: String, age: Int) {
        self.name = name
        self.age = age
    }
}

let me = Person(name: "Cosmin", age: 31)

//extension Person {
//    subscript(key: String) -> String? {
//        switch key {
//            case "name":
//                return name
//            case "age":
//                return "\(age)"
//            default:
//                return nil
//        }
//    }
//}
//
//me["name"]
//me["age"]
//me["gender"]

//Subscript parameters
//서브스크립트에 파라미터를 넣어줄 수도 있다.
extension Person {
    subscript(property key: String) -> String? {
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

me[property: "name"]
me[property: "age"]
me[property: "gender"]
//서브스크립트는 쉽게 사용할 수 있지만, 의도를 분명히 알 수 없는 경우가 많으므로 혼란을 일으킬 여지가 있다.

//Keypaths
//키패스로 속성에 대한 참조를 저장할 수 있다.
class Tutorial {
    let title: String
    let author: Person
    let type: String
    let publishDate: Date
    
    init(title: String, author: Person, type: String, publishDate: Date) {
        self.title = title
        self.author = author
        self.type = type
        self.publishDate = publishDate
    }
}

let tutorial = Tutorial(title: "Object Oriented Programming in Swift", author: me, type: "Swift", publishDate: Date())

let title = \Tutorial.title //백 슬래시로 키 패스를 생성한다.
let tutorialTitle = tutorial[keyPath: title] //keyPath (_ :)로 키패스를 사용하여 해당 데이터에 엑서스 할 수 있다.

let authorName = \Tutorial.author.name
var tutorialAuthor = tutorial[keyPath: authorName]

//Appending keypaths
let authorPath = \Tutorial.author
let authorNamePath = authorPath.appending(path: \.name) //위에서와 같은 값을 가져온다.
tutorialAuthor = tutorial[keyPath: authorNamePath]

//Setting properties
class Jukebox {
    var song: String
    
    init(song: String) {
        self.song = song
    }
}

let jukebox = Jukebox(song: "Nothing else matters")

let song = \Jukebox.song
jukebox[keyPath: song] = "Stairway to heaven" //키패스로 프로퍼티의 값을 바꿀 수 있다.
//1. 필요한 속성의 키패스를 만든다.
//2. 키패스 서브 스크립트를 사용해 엑서스한다.

//http://post.naver.com/viewer/postView.nhn?volumeNo=8970029&memberNo=37948224
//http://seorenn.blogspot.kr/2017/07/swift-4-kvo.html
//옵저버 등록(didSet등으로 할 수?), 유저가 잘못된 타이핑을 하는 것을 막을 수 있다. KVO. 동적참조
