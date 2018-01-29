//: Chpter 13: Classes
//class는 reference 타입, struct는 value 타입

import Foundation

//Creating classes
class Person {
    var firstName: String
    var lastName: String
    
    init(firstName: String, lastName: String) { //Unlike a struct, a class doesn’t provide a memberwise initializer automatically — which means you must provide it yourself if you need it.
        //init없으면 에러. //모든 stored properties가 초기화되어야 한다.
        self.firstName = firstName
        self.lastName = lastName
    }
    
    var fullNmae: String {
        return "\(firstName) \(lastName)"
    }
}

let john = Person(firstName: "Johnny", lastName: "Appleseed")

//Reference types
class SimplePerson {
    let name: String
    
    init(name: String) {
        self.name = name
    }
}

var var1 = SimplePerson(name: "John")
var var2 = var1 //class는 같은 reference를 가진다. //struct였다면 카피한 값을 가지게 될 것이다.

//The heap vs. the stack
//클래스는 힙, 구조체는 스택에 저장된다.
//스택은 시스템에 관리되고 최적화. 효율적이고 빠르지만 엄격하게 관리 된다. 자동으로 변수 제거.
//힙은 동적으로 할당. 유연하지만 스택에 비해 속도가 느리다. 자동으로 변수 제거 되지 않는다.
//클래스를 생성하면 시스템에 힙 메모리 블락을 요청해 받아낸 후 그곳에 저장한다.
//구조체를 생성하면 스택에 저장된다. 힙과는 관련이 없다.

//Working with references
struct Location {
    let x: Int
    let y: Int }
struct DeliveryArea {
    var range: Double
    let center: Location
}
var area1 = DeliveryArea(range: 2.5, center: Location(x: 2, y: 4))
var area2 = area1
print(area1.range) // 2.5
print(area2.range) // 2.5

area1.range = 4
print(area1.range) // 4.0
print(area2.range) // 2.5

//cf. class
var homeOwner = john
john.firstName = "John" // John wants to use his short name!
john.firstName // "John"
homeOwner.firstName // "John"
//구조체의 경우에는 각 복사본을 개별적으로 업데이트해야 한다.

//Object identity
//=== 연산자를 사용해 한 객체의 ID가 다른 객체의 ID와 동일한 지 확인할 수 있다.
john === homeOwner
//== 연산자는 단순히 값의 여부가 같은지를 체크한다.

let imposterJohn = Person(firstName: "Johnny", lastName: "Appleseed")
john === homeOwner // true
john === imposterJohn // false
imposterJohn === homeOwner // false

// Assignment of existing variables changes the instances the variables reference.
homeOwner = imposterJohn
john === homeOwner // false
homeOwner = john
john === homeOwner // true

var imposters = (0...100).map { _ in //imposters는 배열
    Person(firstName: "John", lastName: "Appleseed")
}

imposters.contains {
    $0.firstName == john.firstName && $0.lastName == john.lastName
} //단순 값만 비교하기 때문에 true

imposters.contains {
    $0 === john
} //메모리 주소를 비교하기 때문에 false

imposters.insert(john, at: Int(arc4random_uniform(100))) //랜덤 위치에 insert

imposters.contains {
    $0 === john
} //true

if let indexOfJohn = imposters.index(where: { $0 === john }) {
    imposters[indexOfJohn].lastName = "Bananapeel"
}

john.lastName

//Methods and mutability
struct Grade {
    let letter: String
    let points: Double
    let credits: Double
}

class Student {
    var firstName: String
    var lastName: String
    var grades: [Grade] = []
    var credits = 0.0
    
    init(firstName: String, lastName: String) {
        self.firstName = firstName
        self.lastName = lastName
    }
    
    func recordGrade(_ grade: Grade) { //struct와 달리 mutating 키워드를 쓸 필요없다. //struct는 immutable
        grades.append(grade)
        credits += grade.credits
    }
}

let jane = Student(firstName: "Jane", lastName: "Appleseed") //let으로 선언했으면 값을 바꿀 수 없다.
let history = Grade(letter: "B", points: 9.0, credits: 3.0)
var math = Grade(letter: "A", points: 16.0, credits: 4.0)

jane.recordGrade(history)
jane.recordGrade(math)

//Mutability and constants
var janny = Student(firstName: "Jane", lastName: "Appleseed")
janny = Student(firstName: "John", lastName: "Appleseed") //var로 선언했으면 reference를 바꿀 수 있다.
//이전 레퍼런스는 참조하는 객체가 없어지므로 가비지 컬렉터에 의해 삭제된다.

//Extending a class using an extension
extension Student { //methods와 computed properties를 추가할 수 있다. //상속을 통해서 stored properties를 추가할 수 있다.
    var fullName: String {
        return "\(firstName) \(lastName)"
    }
}

//When to use a class versus a struct
//1. 값과 객체. 피자 배달 범위는 값으로 구조체로 구현한다. 학생은 클래스로 구현한다.(구조체로 구현 시 학생의 이름이 같을 시 같아질 수 있다.)
//2. 속도. 구조체가 더 빠르다. 많은 인스턴스가 생성되거나 매우 짧은 시간동안 메모리에 존재할 경우 일반적으로 구조체. 인스턴스 수명이 길거나 인스턴스를 적게 생성하는 경우는 클래스가 유리.
// Location은 구조체로(웨이 포인트 사용하여 실행중 거리를 계산하고 많은 웨이포인트를 생성하고 수정하면서 빠르게 생성되고 삭제 된다.), 사용자는 클래스로.
//3. 데이터가 변경되지 않거나 간단한 데이터 저장소가 필요한 경우 구조체. 데이터를 업데이트해야하고 그 논리를 포함하는 경우 클래스.
//구조체로 시작해라. 클래스의 추가된 기능이 필요할 때 클래스로 변경.

//Structures vs. classes recap

//Structures
//• Useful for representing values
//• Implicit copying of values
//• Becomes completely immutable when declared with let
//• Fast memory allocation (stack)

//Classes
//• Useful for representing objects with identity
//• Implicit sharing of objects
//• Internals can remain mutable even when declared with let
//• Slower memory allocation (heap)

