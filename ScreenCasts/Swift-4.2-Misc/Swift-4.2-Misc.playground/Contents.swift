import UIKit

//: The Hashable protocol has been updated with a hash(into:) method that takes care of the hashing, instead of you rolling your own hashing calculation.

//Hashable 프로토콜을 구현할 때, 직접 해시 계산을 해주어야 했지만, Swift 4.2에서 hash(into:) 메서드로 구현 가능하다.
//좋은 Hash값을 사용해야 조회, 삽입, 삭제 등의 시간을 줄일 수 있다. Swift 4.2에서는 표준 라이브러리의 Hash 함수를 나타내는 Hasher 타입으로 이를 구현해 줄 수 있다.
//https://zeddios.tistory.com/547

class Country: Hashable {
  let name: String
  let capital: String
  
  init(name: String, capital: String) {
    self.name = name
    self.capital = capital
  }
    
    static func ==(lhs: Country, rhs: Country) -> Bool {
        return lhs.name == rhs.name && lhs.capital == rhs.capital
    }
    
    func hash(into hasher: inout Hasher) { //Swift 4.1에서 까지 사용하던 hashValue 프로퍼티를 대체한다.
        //Hashable 프로토콜을 구현한다. Set, Dictionary 등에 해당 Class 인스턴스를 추가할 수 있다.
        hasher.combine(name)
        hasher.combine(capital)
        //combine으로 지정된 값을 Hasher에 추가해 믹싱한다. Hasher의 combine을 사용하면 Hash에 대해 최적화된다.
        //프로퍼티를 combine하는 순서도 완성된 hashValue에 영향을 미친다.
    }
}

//:Now with the Country class fully adopting the Hashable protocol, instances of that class can be added into Sets and Dictionaries.  I can define a few countries and add them to a set and dictionary.

let france = Country(name: "France", capital: "Paris")
let germany = Country(name: "Germany", capital: "Berlin")
let countries: Set = [france, germany]
let countryGreetings = [france: "Bonjour", germany: "Guten Tag"]

//Hashable을 구현하면, Set, Dictionary 등에 해당 Class 인스턴스를 추가할 수 있다.

// MARK: - Enumeration Cases Collection

//: I've got an Enum of the seasons here, as well as an enum of SeasonTypes, and I'm looping through them in a for loop.
//: Before CaseIterable, I had to explcitly define my cases before I loop - and that isn't good if the cases may change later in development.

//Swift 4.2 에서는 enum의 case도 iterable되게 구현할 수 있다. loop를 돌 수 있다.

enum Seasons: String, CaseIterable {
    //CaseIterable을 구현하는 형식은 일반적으로 associated value가 없는 enum 이다.
    //CaseIterable을 구현하면, allCase 속성을 사용해 모든 case에 액세스할 수 있다.
  case spring = "Spring", summer = "Summer", autumn = "Autumn", winter = "Winter"
}

enum SeasonType {
  case equinox
  case solstice
}

//: Here allCases is automatically generated at runtime

let seasons = [Seasons.spring, .summer, .autumn, .winter]

for (index, season) in seasons.enumerated() { //Swift 4.1에서는 따로 배열을 생성해서 enumerated로 loop를 해야 했다.
  let seasonType = index % 2 == 0 ? SeasonType.equinox : .solstice
  print("\(season.rawValue) \(seasonType).")
}

for (index, season) in Seasons.allCases.enumerated() { //CaseIterable을 구현해 allCases 속성으로 모든 case를 가져올 수 있다.
    let seasonType = index % 2 == 0 ? SeasonType.equinox : .solstice
    print("\(season.rawValue) \(seasonType).")
}
//CaseIterable을 구현하면 뒤에서 처럼 따로 배열로 저장할 필요 없다. allCases 속성으로 접근한다.

//: You can also specify that only certain cases get returned by overriding allCases.  I've got an Enum of months here, and I only want to specify certain ones, and to do that I'll define my own allCases array

enum Months: CaseIterable {
  case january, february, march, april, may, june, july, august, september, october, november, december
  
  //override allCases here
    static var allCases: [Months] {
        return [.june, .july, .august]
    }
    //allCases를 재정의 해서 특정 case만 반환하도록 할 수도 있다. 특정 case의 배열을 반환해 주면 된다.
}

//: Finally, you can even specify that cases with associated values get added - or not! - to the allCases array
enum BlogPost: CaseIterable {
  case article
  case tutorial(updated: Bool) //associated value
  
  //add allCases here with allowed associated value entries, be sure to make CaseIterable
    static var allCases: [BlogPost] {
        return [.article, .tutorial(updated: true), .tutorial(updated: false)]
    }
    //enum의 case 중에 associated value가 있다면, 단순히 CaseIterable를 추가한다고 해서 프로토콜이 준수 되지 않는다.
    //이런 경우 allCases를 재정의해서 associated value의 값을 지정해 주거나, 아예 빼줄 수 있다.
}

// MARK: - Removing Elements from Collections

//: Swift 4.2 now includes a removeAll method that takes in a closure, removing all elements from a Collection.  I have an array of things to say at the start or end of conversation.  If I want to keep things brief, I can remove all of the items whose length is greater than 3.

//Collection에서 removeAll 메서드를 사용해 요소를 삭제할 수 있다.
//removeAll()로 모든 요소를 삭제하거나 클로저로 특정 요소만을 삭제할 수 있다. filter를 이용해서 똑같은 구현을 해 줄 수 있지만, 가독성에 문제가 있고 단순 제거의 경우 메모리가 낭비된다.

var greetings = ["Hello", "Hi", "Goodbye", "Bye"]
greetings.removeAll { $0.count > 3 }

// MARK: - Toggling Boolean States

//: Finally, if I have a boolean in my code and I want to quickly change its state, all I have to do is call toggle() on the boolean

var isOn = true

isOn = !isOn //Swift 4.1 까지는 이렇게 토글해야 했다. view.isHidden = !view.isHidden 이런 식의 코드를 자주 사용했다.

isOn.toggle() //toggle()로 Bool 값을 간단히 토글할 수 있다.


