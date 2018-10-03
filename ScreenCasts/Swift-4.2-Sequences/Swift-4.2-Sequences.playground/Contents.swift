import UIKit


// MARK: - New Sequence Methods

let ages = ["ten", "twelve", "thirteen", "nineteen", "eighteen", "seventeen", "fourteen", "eighteen", "fifteen", "sixteen", "eleven"]

//: Here I have an array of strings that represent ages from 10 to 19.

//: In Swift 4.1, if I wanted to find the first instance of the string that matched a given criteria, I would use the first(where:) method, and if I wanted to find the index of that instance, I would use index(where:).  Also, to find a given instance's first index I could use index(of:).  The latter two have been updated to firstIndex(where:) and firstIndex(of:), respectively.

//Swift 4.1 way

if let firstTeen = ages.first(where: { $0.hasSuffix("teen") }),
    //주어진 조건과 일치하는 문자열의 첫 번째를 찾고 싶다면 first(where:)을 사용해야 한 후
    let firstIndex = ages.index(where: { $0.hasSuffix("teen") }),
    //index(where:)로 해당 인스턴스의 인덱스를 가져와야 했다.
    let firstMajorIndex = ages.index(of: "eighteen") {
    print("Teenager number \(firstIndex + 1) is \(firstTeen) years old.")
    print("Teenager number \(firstMajorIndex + 1) isn't a minor anymore.")
} else {
    print("No teenagers around here.")
}

//Swift 4.2 way

if let firstTeen = ages.first(where: { $0.hasSuffix("teen") }),
    let firstIndex = ages.firstIndex(where: { $0.hasSuffix("teen") }),
    //firstIndex(where:)로 바뀌었다.
    let firstMajorIndex = ages.firstIndex(of: "eighteen") {
    //firstIndex(of:)로 바뀌었다.
    print("Teenager number \(firstIndex + 1) is \(firstTeen) years old.")
    print("Teenager number \(firstMajorIndex + 1) isn't a minor anymore.")
} else {
    print("No teenagers around here.")
}

//둘 다 사용 가능하다.

//: In Swift 4.1, there was no way to do the opposite and find the last element or index of the last element, so a similar set of API were introduced to provide this functionality.

if let lastTeen = ages.last(where: { $0.hasSuffix("teen") }),
    let lastIndex = ages.lastIndex(where: { $0.hasSuffix("teen") }),
    let lastMajorIndex = ages.lastIndex(of: "eighteen") {
    //마지막 요소를 찾는 lastIndex(where:)과 lastIndex(of:) 도 추가되었다.
    print("Teenager number \(lastIndex + 1) is \(lastTeen) years old.")
    print("Teenager number \(lastMajorIndex + 1) isn't a minor anymore.")
} else {
    print("No teenagers around here.")
}

//: Here, along with some updated constant names, I've simply replaced "first" with "last" in the method calls - nothing like a nice balanced API!

// MARK: - Testing Sequence Elements

//: Even though it's hard to believe, Swift 4.1 didn't have a way to check if all elements in a sequence satisfied a certain
//: condition.  Luckily Swift 4.2 introduced the allSatisfy method to Sequence that takes in a closure to check against each of the elements.  If I define an array of values, I can then use allSatisfy to check whether all the number are even

let values = [10, 8, 12, 20]
let allEven = values.allSatisfy { $0 % 2 == 0 }
//시퀀스의 모든 요소가 특정 요소를 만족하는 지 확인하는 allSatisfy() 메서드가 추가되었다.
//contains()와 비슷하게 사용할 수 있다(contains도 클로저를 추가할 수 있음).

print(allEven)




