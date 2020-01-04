//Chapter13 : Classes

//클래스는 구조체와 매우 유사하다. 둘 모두 속성과 메서드가 있는 named type 이다.
//클래스는 value type과는 대조적인 reference type이며, 구조체와 다른 기능과 이점이 있다.
//종종 구조체로 값(value)를 나타내지만, 일반적으로는 클래스를 사용해 객체를 나타낸다.




//Creating classes
class Person {
    var firstName: String
    var lastName: String
    
    init(firstName: String, lastName: String) {
        //구조체와 달리 memberwise initializer가 자동으로 구현되지 않는다.
        self.firstName = firstName
        self.lastName = lastName
    }
    
    var fullName: String {
        "\(firstName) \(lastName)"
    }
}
let john = Person(firstName: "Johnny", lastName: "Appleseed")
//구조체와 거의 동일하다. class 키워드 다음에 해당 클래스의 이름이 오며, 중괄호 안의 모든 것은 해당 클래스의 멤버가 된다.
//구조체와 다르게 클래스는 memberwise initializer를 자동으로 제공하지 않으므로, 필요한 경우 직접 작성해야 한다.
//위의 경우에는 initializer를 작성하지 않으면, 변수들이 초기화 되지 않으므로 컴파일러가 오류를 표시한다.
//클래스의 초기화 규칙은 구조체와 매우 비슷하다. 클래스의 initializer는 init로 표시된 함수이며, 모든 stored property는 init 함수가 끝나기 전에 초기 값이 할당되어야 한다.




//Reference types
//Swift에서 구조체 인스턴스는 변강할 수 없는 값 타입이지만(immutable value), 클래스 인스턴스는 변경할 수 있는 객체이다(mutable object).
//클래스는 Reference type으로, 클래스 변수는 실제 인스턴스를 저장하지 않는다. 대신 인스턴스를 저장하는 메모리 위치에 대한 참조를 저장한다.
class SimplePersonClass {
    let name: String
    init(name: String) {
        self.name = name
    }
}
var var1 = SimplePersonClass(name: "John")
//이와 같이 클래스 인스턴스를 생성하면, 메모리에서는 해당 객체를 가리키게 된다. p.249
var var2 = var1
//새 변수에 이전 변수를 할당하면, 두 변수는 메모리에서 동일한 위치를 참조한다. p.249
//이와 반대로, value type인 구조체는 실제 value를 저장하여 직접 액세스 한다.
struct SimplePersonStructure {
    let name: String
}
var var3 = SimplePersonStructure(name: "John")
//구조체로 인스턴스를 생성하면, 메모리 위치를 참조하지 않고, value는 var3에만 속한다. p.250
var var4 = var3
//var3을 할당하면, var3의 value를 복사한다. p.250
//value type과 reference type은 각각 고유한 장단점이 있다. 주어진 상황에 맞게 어떤 유형을 사용해야 하는지 고려해야 한다.

//The heap vs. the stack
//클래스와 같은 reference type을 작성하면, 시스템은 실제 인스턴스를 heap이라고 하는 메모리 영역에 저장한다.
//구조체와 같은 value type은 stack이라는 메모리 영역에 존재하게 된다. 구조체가 클래스 인스턴스의 일부인 경우에는 클래스 인스턴스의 나머지 부분과 함께 heap에 저장된다.
//힙과 스택은 프로그램 실행에 필수적인 역할을 한다. 힙과 스택이 무엇이고 어떻게 작동하는지 이해하는 것은 클래스와 구조체의 기능적 차이점을 시각화하는 데 도움을 준다.
// • 시스템은 즉시 실행되는 스레드에 어떤 것이든 저장하기 위해 stack을 사용하며, 이는 CPU에 의해 엄격하게 관리되고 최적화된다.
//  함수가 변수를 생성하면, stack은 해당 변수를 저장한 다음 함수가 종료될 때 이를 삭제한다. stack은 매우 엄밀하게 구성되기 때문에 굉장히 효율적이며 매우 빠르다.
// • 시스템은 heap을 사용하여 참조 유형의 인스턴스를 저장한다. heap은 일반적으로 시스템이 메모리 블록을 요청하고 동적으로 할당할 수 있는 큰 메모리 풀이다.
//  heap의 lifetime은 유연하고 역동적이다.
//힙은 스택처럼 데이터를 자동적으로 삭제하지 않으므로, 이를 위해서 추가적인 작업이 필요하다. 따라서 힙은 스택에서보다 데이터를 작성 제거하는 속도가 느리다. p.251
// • 클래스 인스턴스를 생성할 때, 힙에 메모리 블록을 요청하여 인스턴스 자체를 저장한다. 이후, 스택에 있는 명명된 변수에 해당 메모리 주소를 저장한다.
//  따라서 stack에 있는 변수가 heap에 있는 인스턴스를 참조하게 된다.
// • 구조체 인스턴스(클래스 인스턴스의 일부가 아닌 경우)를 만들면, 인스턴스 자체가 스택에 저장되고, 힙은 이 작업에 아무런 관여도 하지 않는다.

//Working with references
//이전에 살펴 본 것과 같이 구조체를 비롯한 value type을 다룰 때, copy semantic이 포함된다(값이 복사 된다).
struct Location {
    let x: Int
    let y: Int
}

struct DeliveryArea {
    var range: Double
    let center: Location
}

var area1 = DeliveryArea(range: 2.5, center: Location(x: 2, y: 4)) //구조체
var area2 = area1 //area1을 area2에 할당하면, area2는 area1의 사본을 받는다.
print(area1.range) // 2.5
print(area2.range) // 2.5
area1.range = 4 //area1.range에 새 값을 할당해도, area1에만 반영되고, area2는 여전히 원래 값을 가진다(copy semantic).
print(area1.range) // 4.0
print(area2.range) // 2.5
//area1을 area2에 할당하면, area2는 area1의 사본을 받는다.
//area1.range에 새 값을 할당해도, area1에만 반영되고, area2는 여전히 원래 값을 가진다(copy semantic).
//하지만, 클래스는 reference type 이므로 클래스 인스턴스를 변수에 지정하면, 시스템은 인스턴스를 복사하지 않고, 참조만 복사한다.
var homeOwner = john //클래스
john.firstName = "John" // John wants to use his short name!
john.firstName // "John"
homeOwner.firstName // "John"
//구조체에서와 달리, 클래스에서는 john과 homeOwner가 같은 value를 가지게 된다. 이러한 특성은 클래스 인스턴스를 공유해 객체를 전달할 때 새로운 사고 방식을 만들게 된다.
//ex. john 객체가 변경되면, john에 대한 참조를 보유한 모든 항목은 자동으로 업데이트 된다.
//구조체의 경우에는, 각 사본을 개별적으로 업데이트하지 않으면 이전 값인 "Johnny"를 가지게 된다.

//Object identity
//이전 예제에서 john과 homeOwner가 동일한 객체를 가리키고 있음을 쉽게 알 수 있다. 두 변수가 실제 John을 제대로 가리키고 있는지 확인해야 할 수 있다.
//firstName의 value를 비교해 확인할 수 있겠지만, 이는 적절하지 않은 방법이다. 동명 이인 일 수도 있고, John이 이름을 바꿀 수도 있다.
//Swift에서는 === 연산자를 사용해, 한 객체의 identity가 다른 객체의 identity와 같은지 확인할 수 있다.
john === homeOwner // true
//== 연산자가 두 값이 같은지 확인하는 것 처럼, === 연산자는 두 참조의 메모리 주소를 비교해 참조값이 동일한지 여부(heap에서 동일한 데이터를 가리키는 지)를 알려준다.
let imposterJohn = Person(firstName: "Johnny", lastName: "Appleseed")
john === homeOwner // true
john === imposterJohn // false
imposterJohn === homeOwner // false

// Assignment of existing variables changes the instances the variables reference.
homeOwner = imposterJohn
john === homeOwner // false
homeOwner = john
john === homeOwner // true
//기존 변수를 다시 할당하면, 변수가 참조하는 인스턴스가 변경된다.
//=== 연산자는 객체를 비교하고 식별하기 위해 ==를 사용할 수 없을 때 특히 유용하다.
// Create fake, imposter Johns. Use === to see if any of these imposters are our real John.
var imposters = (0...100).map { _ in
  Person(firstName: "John", lastName: "Appleseed")
}
// Equality (==) is not effective when John cannot be identified by his name alone
imposters.contains { $0.firstName == john.firstName && $0.lastName == john.lastName } // true
//identity operator를 사용하면, 참조 자체가 동일한지 확인해 실제 john과 같은지 구분할 수 있다.
// Check to ensure the real John is not found among the imposters.
imposters.contains { $0 === john } // false
// Now hide the "real" John somewhere among the imposters.
imposters.insert(john, at: Int.random(in: 0..<100))
// John can now be found among the imposters.
imposters.contains { $0 === john } // true
// Since `Person` is a reference type, you can use === to grab the real John out of the list of imposters and modify the value.
// The original `john` variable will print the new last name!
if let indexOfJohn = imposters.firstIndex(where:{ $0 === john }) {
    imposters[indexOfJohn].lastName = "Bananapeel"
}
john.fullName // John Bananapeel

//Methods and mutability
//클래스 인스턴스는 변경 가능한 객체(mutable object)인 반면, 구조체 인스턴스는 변경할 수 없는 값이다(immutable value).
struct Grade {
    let letter: String
    let points: Double
    let credits: Double
}

class Student {
    var firstName: String
    var lastName: String
    var grades: [Grade] = []
    var credits = 0.0 //updated
    
    init(firstName: String, lastName: String) {
        self.firstName = firstName
        self.lastName = lastName
    }
    
    func recordGrade(_ grade: Grade) {
        grades.append(grade)
        credits += grade.credits //updated
        //해당 함수를 호출해서, 클래스 인스턴스의 credits를 업데이트한다. 이는 side effect를 불러온다.
    }
}

let jane = Student(firstName: "Jane", lastName: "Appleseed")
let history = Grade(letter: "B", points: 9.0, credits: 3.0)
var math = Grade(letter: "A", points: 16.0, credits: 4.0)
jane.recordGrade(history)
jane.recordGrade(math)
//recordGrade(_:)는 grades 배열의 뒤에 value를 추가해 해당 배열을 변경할 수 있다. 이는 현재 객체의 멤버를 변경시키지만, mutating 키워드가 필요하지 않다.
//구조체에서 같은 함수를 작성했다면, 구조체는 immutable이므로 컴파일러가 오류를 발생시켰을 것이다.
//구조체에서 값을 변경할 때는, 그 값을 수정하는 대신 새로운 값을 만드는 것임을 기억해야 한다.
//mutating 키워드는 현재 값을 새로운 값으로 대체하는 메서드를 표시한다. 클래스를 사용하면 인스턴스 자체가 변경 가능하므로 해당 키워드를 사용하지 않아도 된다.

//Mutability and constants
//상수(constant)를 정의하면, 상수 value는 값을 변경할 수 없다. 참조 유형의 경우, value가 reference 임을 기억해야 한다. //p.255
//참조 유형을 상수로 선언하면, 해당 참조가 상수가 된다. 다른 값을 할당하려 하면, 컴파일 오류가 발생한다.
//jane = Student(firstName: "John", lastName: "Appleseed") // Error: jane is a `let` constant
//jane을 변수로 선언하면, 힙에 다른 Student 인스턴스를 할당할 수 있다.
var jane1 = Student(firstName: "Jane", lastName: "Appleseed")
jane1 = Student(firstName: "John", lastName: "Appleseed") //참조가 새 Student 객체를 가리키도록 업데이트 된다.
//이 때, 원본인 "jane1" 을 참조하는 객체가 없어지므로, 해당 메모리를 다른 곳에서 사용할 수 있다.
//클래스의 모든 개별 멤버는 상수를 사용하여 수정되지 않도록 할 수 있지만, 참조 유형 자체는 value로 처리되지 않으므로 mutation으로부터 전체적으로 보호되진 않는다.
//ex. 참조를 상수로 가지고 있는 것이지, 해당 참조 인스턴스의 멤버 변수의 값까지 변경할 수 없는 것이 아니다.
// 위의 예에서 jane은 상수로 선언 되었기 때문에 다른 인스턴스로 할당할 수 없다. 하지만, jane 인스턴스의 property인 firstName, lastName, grades는 모두 var로 선언되었기 때문에 변경 가능하다.
// jane은 상수이지만, jane.firstName는 변수이므로 jane.firstName = "John" 등 으로 변경할 수 있다. 이런 변경을 막으려면, jane.firstName 를 let으로 선언해야 한다.




//Understanding state and side effects
//클래스는 참조 가능하고(reference) 가변적이라(mutable)는 특성때문에 많은 가능성이 있지만, 우려 또한 존재한다.
//클래스를 새 값으로 업데이트 하면, 해당 인스턴스에 대한 모든 참조에서도 새 값이 표시된다는걸 기억해야 한다.
//이것을 장점으로 사용할 수 있다. Roster 클래스와 Sports 클래스가 모두 학생 클래스의 Grade를 참조하고 있을 때 grade만 업데이트 하면, 모든 인스턴스에서 해당 학생의 성적을 확인할 수 있다.
//이 공유의 결과는 클래스 인스턴스가 state를 가진다는 것이다. 상태의 변화는 때로 명백하지만, 그렇지 않은 경우도 있다.
//이 예를 확인하기 위해 credits 변수를 Student 클래스에 추가하고, recordGrade(_:) 함수를 업데이트 한다.
//recordGrade(_:)에서 인스턴스의 credits를 업데이트하게 되는데 이는 side effect를 불러온다.
//side effect는 명백하지 않은 행동을 초래할 수 있다.
jane.credits // 7
// The teacher made a mistake; math has 5 credits
math = Grade(letter: "A", points: 20.0, credits: 5.0)
jane.recordGrade(math)
jane.credits // 12, not 8!
//recordGrade(_:)가 같은 grade를 두 번 기록되지 않는다고 가정하여 느슨하게 구현되었기 때문이다.
//클래스 인스턴스는 mutable하므로 공유되는 reference에서 이와 같이 예기치 못한 side effect에 유의해야 한다.
//클래스의 크기와 복잡성이 증가함에 따라 mutability와 state를 관리하기가 매우 어려워 질 수 있다.




//Extending a class using an extension
//구조체에서와 같이 extension 키워드를 사용하여 클래스에 method와 computed property를 추가할 수 있다.
extension Student {
    var fullName: String {
        "\(firstName) \(lastName)"
    }
}
//inheritance(상속)을 사용해 클래스에 새로운 기능을 추가할 수도 있다. 상속된 클래스 역시 새로운 computed property를 추가할 수 있다.




//When to use a class versus a struct
//경우에 따라 구조체와 클래스 중 어떤 것을 사용해야 하는지 잘 판단해야 한다.

//Values vs. objects
//엄격하거나 간결한 규칙은 없지만, value와 reference의 semantic에 대해 생각해 봐야 한다. 구조체는 value, 클래스는 identity가 있는 object로 사용한다.
//객체(object)는 참조 유형의 인스턴스이며, 이러한 인스턴스는 모두 객체가 고유하다는 의미를 가진다.
//동일한 state를 갖고 있다 해서, 두 객체가 동일하다고 간주해선 안 된다. === 를 사용해 객체가 동일한 state를 포함한 것이 아니라 실제로 동일한 지 확인해야 한다.
//반대로 value type인 인스턴스(구조체)는 동일한 값인 경우 동일한 것으로 간주한다.
//ex. 위의 Student 예제에서 두 학생이 동일한 이름이 가지고 있다 해서 같다고 판단하지 않는다.

//Speed
//구조체는 Stack을 사용하는 반면, 클래스는 이보다 느린 heap을 사용한다. 많은 인스턴스(수백 개 이상)가 있거나, 이러한 인스턴스가 짧은 시간 동안에만 메모리에 존재하는 경우 구조체를 사용하는 것이 좋다.
//인스턴스의 lifecycle이 길거나 상대적으로 적은 수의 인스턴스를 생성하는 경우, heap을 사용하는 클래스 인스턴스는 오버헤드(overhead)를 많이 발생시키지 않아야 한다.

//Minimalist approach
//또 다른 접근방법은 필요한 것만 사용하는 것이다. 데이터가 변경되지 않거나 간단한 데이터 저장소가 필요한 경우 구조체를 사용한다.
//데이터를 업데이트해야 하고, 자체 state를 업데이트 하는 논리를 포함하는 경우에는 클래스를 사용한다.
//보통 구조체로 시작하는 것이 가장 좋다. 나중에 클래스의 추가 기능이 필요한 경우 구조체를 클래스로 변환하기만 하면 된다.

//Structures vs. classes recap

//구조체
// • value를 나타내는 데 유용하다.
// • 값을 암시적으로 복사한다.
// • let으로 선언하면, 완전히 immutable 하다.
// • 빠른 메모리 할당(stack)

//클래스
// • identity가 있는 object를 나타내는 데 유용하다.
// • 객체를 암시적으로 공유한다.
// • let으로 선언한 경우에도 내부 멤버는 변경 가능하다.
// • 느린 메모리 할당(heap)

