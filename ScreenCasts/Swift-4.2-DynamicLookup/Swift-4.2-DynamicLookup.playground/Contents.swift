import UIKit

// MARK: - Dynamic Member Lookup

//: In Swift 4.1, custom subscript calls to get dynamic members used a square bracket syntax, provided by a subscript method on the class.  In Swift 4.2, you can update the class quickly to support dynamic member lookup

//Swift 4.1에서는 dynamic member를 가져오기 위해 subscript 메서드(대괄호 구문)을 사용했다.

// 1 - Add attribute
@dynamicMemberLookup //@dynamicMemberLookup 키워드를 사용하면, Swift가 프로퍼티에 접근할 때 subscript를 호출할 수 있다.
//subscript(dynamicMember key:) 메서드를 구현해야 하며, 이를 구현하면 dot syntax로 접근할 수 있다(Swift 4.1까지는 직접 subscript를 구현해 []로 가져와야 했다).
//이는 컴파일러가 subscript를 런타임에 동적으로 호출하기 때문에 타입에 안전한 코드를 작성할 수 있게 한다.
//https://zeddios.tistory.com/547
class Person {
  let name: String
  let age: Int
  private let details: [String: String]
  
  init(name: String, age: Int, details: [String: String]) {
    self.name = name
    self.age = age
    self.details = details
  }
  
  //2 - add subscript(dynamicMember:)
  subscript(dynamicMember key: String) -> String {
    switch key {
    case "info":
      return "\(name) is \(age) years old."
    default:
      return details[key] ?? ""
    }
  }
}

//: This allows access to the info and title properties by dot syntax, and doesn't change the access to the name and age properties

let details = ["title": "Author", "instrument": "Guitar"]
let me = Person(name: "Cosmin", age: 32, details: details)
//me["info"]    //this was the old Swift 4.1 access
//me["title"]   //this was the old Swift 4.1 access
me.info //subscript에서 case "info"에 해당하는 부분이 호출된다.
me.title //subscript에서 default에 해당하는 부분이 호출된다.
me.name //subscript이 아닌 프로퍼티에 접근한다.
me.age //subscript이 아닌 프로퍼티에 접근한다.

//: Child classes also get access to their parent's dynamic member lookup capabilities.  For example, if I have a `Vehicle` class defined, I can define a `Car` class that inherits from it.

@dynamicMemberLookup
class Vehicle {
  let brand: String
  let year: Int
  
  init(brand: String, year: Int) {
    self.brand = brand
    self.year = year
  }
  
  subscript(dynamicMember key: String) -> String {
    return "\(brand) made in \(year)."
  }
}

//3 - declare `Car`
class Car: Vehicle {}

let car = Car(brand: "BMW", year: 2018)
car.info //상속 시에도, @dynamicMemberLookup 기능에 액세스할 수 있다.

//: You can also add dynamic member lookup to protocols via protocol extensions.  If I have a `Random` protocol, I can extend it to include a `subscript(dynamicMember:)` method that provides the dynamic member lookup capability, returning a number between 0 and 9

@dynamicMemberLookup
protocol Random {}

extension Random {
    subscript(dynamicMember key: String) -> Int {
        return Int.random(in: 0..<10)
    }
}
//protocol 을 extension해서 @dynamicMemberLookup을 추가해 줄 수도 있다.

//: I can then extend `Int` to give that type the new functionality.

extension Int: Random {}

//: Finally, I can use the dot syntax to generate a random number, convert it to a string, and filter it out from the string version of the original number

let number = 10
let randomDigit = String(number.digit) //난수 생성 후 문자열 변환 //extension에서 구현한 subscript를 사용할 수 있다(꼭 digit가 아닌 임의의 값을 써도 된다).
//store property가 아닌 것으로 dot syntax를 호출하면 알아서 subscript가 호출된다.
let noRandomDigit = String(number).filter{ String($0) != randomDigit } //원래 숫자의 문자열 캐스팅한 값을 필터링한다.
//String이 필터링 되면서 여기서는 각각 1, 0 이 randomDigit의 값과 같지 않은지 비교해 true가 나오는 값만 noRandomDigit에 오게 된다.
