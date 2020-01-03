//Chapter14: AdvancedClasses

//클래스는 참조 유형이며 객체 지향 프로그래밍에 사용할 수 있다. 클래스는 상속(inheritance), 재정의(overriding), 다형성(polymorphism) 의 특징이 있기 때문에 이런 목적에 적합하다.
//이러한 기능을 사용하려면, 초기화(initialization), 클래스 계층 구조(hierarchy) 및 메모리 lifecycle을 고려해야 한다.




//Introducing inheritance
struct Grade {
    var letter: Character
    var points: Double
    var credits: Double
}

class Person {
    var firstName: String
    var lastName: String
    
    init(firstName: String, lastName: String) {
        self.firstName = firstName
        self.lastName = lastName
    }
    
    deinit { //initialization를 처리하는 특수 메서드 init와 마찬가지로 deinit는 deinitialization를 처리하는 특수 메서드이다.
        //init와 달리, deinit는 반드시 구현해야 하는 것은 아니며, Swift가 자동으로 호출한다.
        //required, override, super를 호출할 필요가 없으며, 각 클래스 단위에서 deinit를 구현해야 한다.
        print("\(firstName) \(lastName) is being removed from memory!")
    }
}

//class Student {
//    var firstName: String
//    var lastName: String
//    var grades: [Grade] = []
//
//    init(firstName: String, lastName: String) {
//        self.firstName = firstName
//        self.lastName = lastName
//    }
//
//    func recordGrade(_ grade: Grade) {
//        grades.append(grade)
//    }
//}
//Person과 Student 클래스 간에 중복이 있음을 쉽게 확인할 수 있다. a Student is a Person.
//Student를 Person으로 생각할 수 있는 현실 세계와 마찬가지로, Student 클래스의 구현을 다음과 같이 대체해 동일한 관계를 나타낼 수 있다.
class Student: Person { //Person을 상속한다.
    var grades: [Grade] = []
//    var partner: Student?
    weak var partner: Student? //weak으로 선언해야 retain cycle이 되지 않는다.
    
    func recordGrade(_ grade: Grade) {
        grades.append(grade)
    }
    
    deinit {
        print("\(firstName) is being deallocated!")
    }
}
//클래스 이름 뒤에 :을 사용하고 상속할 클래스(여기서는 Person)을 지정해 주면 된다. 상속을 통해 Student는 Person 클래스에 선언된 속성과 메서드를 자동으로 가져온다.
//상속한 클래스와 is 관계가 성립해야 한다(Student is-a Person). 코드의 중복이 줄고, Person의 모든 속성과 메서드를 가진 Student 객체를 만들 수 있다.
let john = Person(firstName: "Johnny", lastName: "Appleseed")
let jane = Student(firstName: "Jane", lastName: "Appleseed")
john.firstName // "John"
jane.firstName // "Jane"
//Student에 정의된 모든 속성과 메서드는 Student 객체에만 존재한다.
 let history = Grade(letter: "B", points: 9.0, credits: 3.0)
jane.recordGrade(history)
// john.recordGrade(history) // john is not a student! //john은 Student의 상위 클래스인 Person 객체이다.
//다른 클래스에 상속된 클래스랄 하위 클래스(subclass) 또는 파생 클래스(derived class)라고 하며, 이 클래스가 상속하는 클래스를 슈퍼 클래스(superclass) 혹은 기본 클래스(base class)라고 한다.
//서브 클래싱 규칙은 매우 간단하다.
// • Swift 클래스는 단일 상속(하나의 클래스만 상속)만 가능하다.
// • 서브 클래싱의 깊이는 제한이 없다(하위 클래스를 슈퍼 클래스로 해서 다시 다른 클래스를 상속할 수 있다).
class BandMember: Student {
    var minimumPracticeTime = 2
}

class OboePlayer: BandMember {
    // This is an example of an override, which we’ll cover soon.
    override var minimumPracticeTime: Int {
        get {
            super.minimumPracticeTime * 2
        } set {
            super.minimumPracticeTime = newValue / 2
        }
    }
}
//이러한 서브 클래스 체인을 클래스 계층 구조라고 한다. 여기서 계층은  OboePlayer-> BandMember-> Student-> Person 이다.
//클래스 계층은 가계도와 유사하다. 이러한 비유 때문에, 슈퍼 클래스는 자식 클래스(child class)의 부모 클래스(parent class)라고도 한다.

//Polymorphism
//Student / Person의 관계는 컴퓨터 과학에서 다형성으로 알려진 개념을 보여준다. 간단히 말해, 다형성은 프로그래밍 언어가 상황에 따라 객체를 다르게 처리하는 능력이다.
//OboePlayer는 Person 이기도 하다. Person 객체를 사용하는 모든 곳에서 OboePlayer 객체를 사용할 수 있다.
func phonebookName(_ person: Person) -> String {
    "\(person.lastName), \(person.firstName)"
}
let person = Person(firstName: "Johnny", lastName: "Appleseed")
let oboePlayer = OboePlayer(firstName: "Jane", lastName: "Appleseed")
phonebookName(person) // Appleseed, Johnny
phonebookName(oboePlayer) // Appleseed, Jane
//OboePlayer는 Person에서 파생된 클래스이므로, phonebookName(_ :)의 매개 변수로 사용할 수 있다. 중요한 점은, 함수는 매개변수로 전달된 객체가 Person 이라고 인식한다는 것이다.
//따라서, OboePlayer를 Person 매개변수로 사용할 수 있어도, Person 기본 클래스에 정의된 OboePlayer의 요소만 사용할 수 있다.
//클래스 상속의 다형성 특성으로, Swift는 oboePlayer 객체의 컨텍스트를 다르게 처리할 수 있다. 이는 클래스 계층구조가 다양하지만, 공통 유형 또는 기본 클래스에서 작동하는 코드를 작성할 때 유용하다.

//Runtime hierarchy checks
//다형성을 사용하면, 변수의 특정 type이 다른 상황이 있을 수 있다.
var hallMonitor = Student(firstName: "Jill", lastName: "Bananapeel")
hallMonitor = oboePlayer //다형성을 이용해 oboePlayer를 할당한다.
//hallMonitor는 Student로 정의되었기 때문에, oboePlayer를 할당했더라도 파생된 클래스의 속성이나 메서드를 호출할 수 없다.
//Swift에는 속성이나 변수를 다른 유형으로 처리하는 as 연산자가 있다.
// • as : supertype으로 캐스팅하는 것과 같이 컴파일시 캐스팅이 성공하는 것으로 알려진 특정 유형으로 캐스팅한다.
// • as? : optaional downcast. subtype으로 캐스팅한다. 실패 하면 nil이 된다.
// • as! : forced downcast. subtype으로 캐스팅한다. 캐스팅 실패시, 프로그램이 중단된다. 캐스팅이 실패하지 않을 때에만 드물게 사용해야 한다.
//다양한 상황에서 hallMonitor를 BandMember나 그 상위 클래스인 Student로 캐스팅 할 수 있다.
oboePlayer as Student
//(oboePlayer as Student).minimumPracticeTime // ERROR: No longer a band member!
hallMonitor as? BandMember
(hallMonitor as? BandMember)?.minimumPracticeTime // 4 (optional)
hallMonitor as! BandMember // Careful! Failure would lead to a runtime crash.
(hallMonitor as! BandMember).minimumPracticeTime // 4 (force unwrapped)
//downcast의 as? 는 if let 혹은 guard에서 특히 유용하다.
if let hallMonitor = hallMonitor as? BandMember {
    print("This hall monitor is a band member and practices at least \(hallMonitor.minimumPracticeTime) hours per week.")
}
//모든 객체에는 부모 클래스의 모든 속성과 메서드가 포함되어 있으므로 downcast가 무의미한 작업처럼 생각될 수도 있다.
//하지만, Swift는 strong type system이며, 특정 type에 대한 해석은 static dispatch(컴파일 시 어떤 연산을 사용할지 결정하는 과정)에 영향을 미칠 수 있다.
func afterClassActivity(for student: Student) -> String {
    "Goes home!"
}
func afterClassActivity(for student: BandMember) -> String {
    "Goes to practice!"
}
//동일한 함수명과 매개변수 명을 가지고 있지만, 매개변수의 type이 다르다.
//AfterClassActivity에 oboePlayer 매개변수를 사용한다면 BandMember 매개변수를 사용하는 함수가 호출 될 것이다.
//하지만, oboePlayer를 사용하더라도 Student로 캐스팅하는 경우에는 Student 매개변수를 사용하는 함수가 호출된다.
afterClassActivity(for: oboePlayer) // Goes to practice!
afterClassActivity(for: oboePlayer as Student) // Goes home!

//Inheritance, methods and overrides
//서브 클래스는 슈퍼 클래스에 정의된 모든 속성 및 메서드와 서브 클래스에서 자체적으로 정의한 추가 속성 및 메서드를 사용할 수 있다. 그런 의미에서 서브 클래스는 추가적이다.
//ex. Student 클래스에 성적 처리를 위한 추가 속성 및 메서드를 추가할 수 있다. 이 속성과 메서드는 Student의 하위 클래스에서도 사용할 수 있다.
//서브 클래스는 자체 메서드를 작성하는 것 외에도, 슈퍼 클래스에 정의된 메서드를 대체할 수 있다.
class StudentAthlete: Student {
    var failedClasses: [Grade] = []
    
    override func recordGrade(_ grade: Grade) { //recordGrade(_:)를 재정의한다.
        super.recordGrade(grade) //Student의 recordGrade(_:)를 호출한다.

        if grade.letter == "F" {
            failedClasses.append(grade)
        }
    }
    
//    override func recordGrade(_ grade: Grade) {
//        var newFailedClasses: [Grade] = []
//        for grade in grades {
//            if grade.letter == "F" { //grade가 기록될 때 마다, 낙제한 과목을 다시 기록한다.
//                newFailedClasses.append(grade)
//            }
//        }
//        failedClasses = newFailedClasses
//
//        super.recordGrade(grade) //이전 recordGrade(_:)와 달리, super 메서드를 나중에 호출한다. 따라서 새로 추가되는 grade가 F인 경우, failedClasses를 제대로 업데이트 하지 못한다.
//    }
    
    var isEligible: Bool { //computed property
        failedClasses.count < 3 //3개 이상의 과목에서 낙제하는 경우, 선수로 뛸 수 없다.
    }
}
//메서드를 재정의할 때에 override 키워드를 사용해야 한다. 서브 클래스가 슈퍼 클래스와 동일한 메서드 선언을 하면서 override 키워드를 생략하면, 컴파일러가 오류를 발생시킨다.
//override 키워드는 해당 메서드가 기존 메서드를 대체하는지 여부를 명확하게 나타내 준다.

//Introducing super
//super 키워드는 self와 유사하지만, 자신이 아닌 가장 가까운 슈퍼 클래스를 호출한다.
//여기에서 super는 Student 클래스이며, super.recordGrade(grade)는 Student 클래스의 recordGrade(_:)를 호출해 실행한다.
//상속으로 하위 클래스에서 상위 클래스의 속성을 반복하지 않는 것과 마찬가지로, 하위 클래스에서 상위 클래스의 메서드를 필요에 따라 호출할 수 있다.
//항상 필요한 것은 아니지만, Swift에서는 메서드를 재정의할 때, super 키워드를 사용해 상위 클래스의 메서드를 호출하는 것이 중요하다.
//여기서의 super 메서드(Student의 recordGrade(_:)) 기능은 grade를 Array에 기록하는 것인데, 단순히 override 키워드를 사용한다고 해서 상위 클래스 메서드가 호출되는 것은 아니기 때문이다.
//따라서 super를 호출해, 필요한 기능을 구현하고 중복되는 코드를 줄일 수 있다.

//When to call super
//언제 super를 호출하느냐에 따라, override 메서드에 큰 영향을 줄 수 있다. recordGrade(_:)를 수정한다(override 메서드는 extension에서 구현할 수 없다).
//수정한, recordGrade(_:)는, super메서드의 호출이 마지막에 있다. 따라서 새로 추가되는 grade가 F인 경우, failedClasses를 제대로 업데이트 하지 못한다.
//override 하는 경우, super 메서드를 먼저 호출하는 것이 가장 좋다.
//그러면, superclass는 subclass에서 야기되는 side effect에서 자유로울 수 있으며, subclass는 superclass의 세부 구현 사항을 알 필요가 없다.

//Preventing inheritance
//때로 특정 클래스의 하위 클래스를 허용하지 않으려 할 수 있다. Swift에서는 해당 클래스가 subclass를 얻지 못하도록 보장하는 final 키워드를 사용한다(해당 클래스를 상속할 수 없다).
final class FinalStudent: Person {}
//class FinalStudentAthlete: FinalStudent {} // Build error!
//final 키워드를 사용하면, 해당 클래스가 상속되지 않도록 컴파일러에게 알려준다.
//또한, 클래스 상속은 허용하지만, 개별 메서드가 재정의(override) 되는 것을 방지하기 위해 final 키워드를 사용할 수도 있다.
class AnotherStudent: Person {
    final func recordGrade(_ grade: Grade) {}
}
class AnotherStudentAthlete: AnotherStudent {
//    override func recordGrade(_ grade: Grade) {} // Build error!
}
//클래스에 final 키워드를 사용하면, 컴파일러가 더 이상 서브 클래스를 찾을 필요가 없어 컴파일 시간이 단축되는 이점이 있다.




//Inheritance and class initialization
//서브 클래스에서 인스턴스 초기화 설정 방법과 관련해 몇 가지 추가적인 고려사항들이 있다. Student와 StudentAthlete에 새로운 변수를 추가한다.
//NewStudent, NewStudentAthlete는 Student, StudentAthlete과 기본적으로 동일하다. 이전 버전을 유지하기 위해 새로 구현한다.
class NewStudent {
    let firstName: String
    let lastName: String
    var grades: [Grade] = []
    
    required init(firstName: String, lastName: String) { //모든 서브 클래스에서 사용하는 중요한 initializer는 required 키워드를 사용해 정의한다.
        //required initializer는 NewStudent의 모든 서브 클래스가 해당 initializer를 구현해야 한다.
        self.firstName = firstName
        self.lastName = lastName
    }
    
    convenience init(transfer: NewStudent) { //다른 NewStudent로 새로운 NewStudent 객체를 만든다.
        //NewStudent의 서브 클래스가 해당 initializer를 사용할 수 있다. 그러면, 서브 클래스는 firstName과 lastName을 사용해 초기화하는 메서드를 사용하지 않을 수도 있다.
        self.init(firstName: transfer.firstName, lastName: transfer.lastName)
    }
    
    func recordGrade(_ grade: Grade) {
        grades.append(grade)
    }
}

class NewStudentAthlete: NewStudent {
    var failedClasses: [Grade] = []
    var sports: [String] //추가
    
//    init(sports: [String]) { //sports는 초기값이 없으므로, initializer가 있어야 한다.
//        self.sports = sports
//        // Build error - super.init isn’t called before
//        // returning from initializer
//
//        //상속하는 상위 클래스의 super.init를 호출해야 한다.
//        //super.init가 없으면 슈퍼 클래스의 stored property(여기에서는 firstName 및 lastName)를 초기화할 수 없기 때문이다.
//    }
    
    init(firstName: String, lastName: String, sports: [String]) { //Two-phase initialization
        self.sports = sports //NewStudentAthlete의 sports 속성을 초기화 한다.
        //first phase의 일부이며, 슈퍼 클래스의 initializer를 호출하기 전에 초기화를 수행해야 한다.
        let passGrade = Grade(letter: "P", points: 0.0, credits: 0.0)
        //local variable을 만들 수 있지만, 아직, first phase이므로, recordGrade(_:)를 호출할 수는 없다.
        super.init(firstName: firstName, lastName: lastName) //super.init를 사용해, firstName와 lastName를 초기화할 수 있다.
        //반드시 sports 속성을 초기화 한 후, super.init를 호출해야 한다.
        //여기에서는 super.init가 반환되면, 모든 계층의 변수가 초기화 된 것이다. first phase가 완료된다.
        recordGrade(passGrade) //super.init가 반환된 이후부터는 second phase이므로, recordGrade(_:)를 호출할 수 있다.
    }
    
    // Now required by the compiler!
    required init(firstName: String, lastName: String) {
        //required initializer에는 override 키워드가 필요하지 않다.
        self.sports = []
        super.init(firstName: firstName, lastName: lastName)
    }
    
    override func recordGrade(_ grade: Grade) {
        super.recordGrade(grade)
        
        if grade.letter == "F" {
            failedClasses.append(grade)
        }
    }
    
    var isEligible: Bool {
        failedClasses.count < 3
    }
}
//새로운 변수 sports를 추가한다. sports는 초기값이 없으므로, initializer가 있어야 한다. 하지만, 이전과 같이 단순히 값을 지정해 주면 오류가 발생한다.
//해당 클래스가 하위 클래스이기 때문인데, 이 경우에는 상속하는 상위 클래스의 super.init를 호출해야 한다.
//super.init가 없으면 슈퍼 클래스의 stored property(여기에서는 firstName 및 lastName)를 초기화할 수 없기 때문이다.
//반드시, 해당 클래스의 속성들을 먼저 초기화한 후에, super.init를 호출해야 한다. 이는 규칙이다.

//Two-phase initialization
//Swift는 모든 stored property에 초기값이 있어야 하므로, 하위 클래스의 initializer는 2단계 초기화 규칙을 준수해야 한다.
// • Phase one : 클래스 계층 구조의 가장 아래에서 부터 맨 위까지 인스턴스의 모든 stored property를 초기화 한다. 1단계가 완료될 때까지 속성과 메서드를 사용할 수 없다.
// • Phase two : self를 사용하는 initializer 뿐만 아니라 속성과 메서드를 사용할 수 있다.
//2단계 초기화 없이, 클래스의 메서드와 연산은 초기화 되기 전 속성과 상호작용 할 수 있다.
//1단계에서 2단계로의 전환은 클래스 계층의 기본 클래스에서 모든 stored property를 초기화 한 후에 수행된다.
//이는 subclass initializer의 범위에서 super.init의 호출 이후에 오는 것으로 생각할 수 있다. p.274

//Required and convenience initializers
//클래스에는 여러 개의 initializer가 있을 수 있다. 잠재적으로 서브 클래스에서 해당 initializer를 호출할 수 있다.
//서브 클래스에서 반드시 구현해야 하는 initializer를 required 키워드를 붙여 정의할 수 있다.
//NewStudent에 required initializer를 추가했으므로, NewStudentAthlete가 이를 구현해야 한다.
//또한, convenient initializer가 있을 수 있다.
//convenience initializer는 컴파일러가 stored property의 초기화를 처리하는 대신, convenience initializer가 non-convenience initializer를 호출하도록 한다.
//non-convenience initializer를 designated initializer라고 하며, two-phase initialization의 규칙이 적용된다.
//객체를 초기화하는 방법으로 해당 initializer를 사용하지만, 해당 initializer가 designated initializer 중 하나를 활용하기를 원하는 경우, convenience로 지정해 줄 수 있다.
//designated initializer와 convenience initializer를 사용하는 규칙과 요약은 다음과 같다.
// 1. designated initializer는 즉시 슈퍼 클래스의 designated initializer를 호출해야 한다.
// 2. convenience initializer는 동일한 클래스의 다른 initializer를 호출해야 한다.
// 3. convenience initializer는 궁극적으로 designated initializer를 호출해야 한다.
//https://zeddios.tistory.com/141




//When and why to subclass
//하위 클래스를 언제 작성해야 하는지는 옭고 그른 정답이 있는 경우가 드물기 때문에, 특정 사례에 근거해 결정을 내릴 수 있어야 한다.
//예를 들어, Student 및 StudentAthlete 클래스를 사용한다면, StudentAthlete의 모든 특성을 단순히 Student에 포함하도록 할 수 있다.
//class Student: Person {
//    var grades: [Grade]
//    var sports: [Sport]
//    // original code
//}
//실제로 위와 같이 정의하면, 지금까지 예제의 모든 경우를 해결할 수 있다. StudentAthlete가 아니라면 빈 sports Array를 가지게 되며, 하위 클래스의 복잡성을 피할 수 있다.
//하지만, 실제로는 이렇게 구현하면, 단일 책임 원칙을 위배하게 된다.

//Single responsibility
//소프트웨어 개발에서 단일 책임 원칙(single responsibility principle)은 어떤 클래스든 하나의 책임만을 가져야 한다는 것이다.
//따라서, Student/StudentAthlete에서, StudentAthlete 클래스에서만 유효한 책임을 Student 클래스에서 캡슐화 하는 것은 적절한 작업이 아니다.

//Strong types
//서브 클래싱은 추가적인 type을 만든다. Swift의 type 시스템을 사용해, 일반 Student가 아닌 StudentAthlete 객체를 기반으로 하는 속성 또는 행동을 선언해 줄 수 있다.
class Team {
    var players: [StudentAthlete] = []
  
    var isEligible: Bool {
        for player in players {
            if !player.isEligible {
                return false
            }
        }
        return true
    }
}
//Team에는 [StudentAthlete]가 있다. players에 일반 Student 객체를 추가하려 하면, type system에서 이를 허용하지 않는다.
//컴파일러가 시스템의 논리 및 요구 사항을 적용하는 하므로 유용하게 사용할 수 있다.

//Shared base classes
//기본 클래스를 상호 배타적인 동작이 있는 클래스로 여러 번 서브 클래싱 할 수 있다.
// A button that can be pressed.
class Button {
    func press() {}
}

class Image {} // An image that can be rendered on a button

class ImageButton: Button { // A button that is composed entirely of an image.
    var image: Image
    
    init(image: Image) {
        self.image = image
    }
}

class TextButton: Button { // A button that renders as text.
    var text: String
  
    init(text: String) {
        self.text = text
    }
}
//이 예제에서 Button의 여러 하위 클래스는 press()만 공유한다. ImageButton과 TextButton 클래스는 Button을 렌더링하기 위해 다른 메커니즘을 사용한다.
//press()를 구현하기 위해 자체적인 구현이 필요할 수도 있다. 따라서 Button 클래스에 image와 text 속성을 추가해 저장하는 것이 얼마나 비실용적인지 알 수 있다.
//Button은 모든 서브 클래스에서 공통적인 press()의 구현에만 신경쓰고, 각 subclass에서는 해당 클래스에 맞는 구현을 하는 것이 타당하다.

//Extensibility
//때로는 소유하지 않은 코드를 확장해야 할 때가 있다. 위의 예시에서, Button이 사용 중인 Framework의 일부인 경우, 특정 사례에 맞게 소스 코드를 수정하거나 확장할 수 있는 방법은 없다.
//그러나, Button의 하위 클래스를 만들어 필요한 코드를 추가할 수 있다.

//Identity
//마지막으로, 클래스 및 클래스 계층구조는 객체가 무엇인지 모델링 한다. 만약 type 간에 행동(객체가 할 수 있는 것)을 공유하는 것이 목표라면, 서브 클래싱 보다 protocol이 더 적합하다.




//Understanding the class lifecycle
//클래스 객체는 메모리에서 생성되어 heap에 저장된다. heap은 단순히 거대한 메모리 풀이기 때문에, 더 이상 참조가 없더라도 heap의 객체가 자동으로 처리되지 않는다.
//call stack을 사용하지 않는다면, 더 이상 해당 메모리를 사용되지 않는다는 것을 프로세스가 자동으로 알 수 있는 방법은 없다.
//Swift에서는 heap에서 사용하지 않는 객체를 정리하기 위한 메커니즘으로 reference counting을 사용한다.
//각 객체는 해당 객체가 변수 또는 상수로 참조될 때 증가되고, 참조가 제거될 때마다 감소되는 reference count(retain count라고 하기도 한다)를 가지고 있다.
//reference count가 0이 되면, 시스템의 어느 것도 해당 참조를 보유하지 않기 때문에 객체가 제거된다. 이때, Swift는 객체를 정리한다.
var someone = Person(firstName: "Johnny", lastName: "Appleseed")
// Person object has a reference count of 1 (someone variable)
var anotherSomeone: Person? = someone
// Reference count 2 (someone, anotherSomeone)
var lotsOfPeople = [someone, someone, anotherSomeone, someone]
// Reference count 6 (someone, anotherSomeone, 4 references in lotsOfPeople)
anotherSomeone = nil
// Reference count 5 (someone, 4 references in lotsOfPeople)
lotsOfPeople = []
// Reference count 1 (someone)
//하나의 실제 객체만 만들었지만, 하나의 객체에 많은 참조가 있다. 이제 다른 객체를 만들고 해당 참조로 바꾼다.
someone = Person(firstName: "Johnny", lastName: "Appleseed")
// Reference count 0 for the original Person object!
// Variable someone now references a new object
//Swift에는 automatic reference counting(ARC)라는 기능이 있기 때문에, 객체의 참조를 늘리거나 줄이기 위해 직접 작업할 필요 없다.
//일부 오래된 프로그래밍 언어에서는 참조 횟수를 직접 늘리고 줄여야 하지만, Swift 컴파일러는 컴파일 시에 이러한 호출을 자동으로 추가한다.
//C와 같은 저수준 언어를 사용하는 경우, 더 이상 사용하지 않는 메모리를 수동으로 비워야 한다.
//Java, C#과 같은 고급언어에서는 garbage collection을 사용한다. 이 경우, 런타임 시, 더 이상 사용하지 않는 객체를 정리하기 전에 프로세스에서 객체에 대한 참조를 검색한다.
//garbage collection은 ARC보다 강력하지만, 메모리 활용과 성능에 그만큼 더 큰 비용을 사용하게 된다. Apple은 이것이 모바일 기기나 일반 시스템 언어에 적합하지 않다고 판단했다.

//Deinitialization
//객체의 reference count가 0이 되면, Swift는 객체를 메모리에서 제거하고 해당 메모리를 사용 가능한 것으로 표시한다.
//deinitializer는 객체의 reference count가 0이 될 때, Swift가 메모리에서 객체를 제거하기 전에 실행되는 클래스의 특수 메서드 이다(deinit는 extension으로 추가할 수 없다).
//Person 클래스에 deinit를 추가한다.
//initialization를 처리하는 특수 메서드 init와 마찬가지로 deinit는 deinitialization를 처리하는 특수 메서드이다.
//init와 달리, deinit는 반드시 구현해야 하는 것은 아니며, Swift가 자동으로 호출한다.
//required, override, super를 호출할 필요가 없으며, 각 클래스 단위에서 deinit를 구현해야 한다.
//deinitializer는 리소스를 정리, 디스크에 state를 저장, 객체 할당 해제시 원하는 논리를 실행 등에 사용할 수 있다.

//Retain cycles and weak references
//Swift는 메모리에서 클래스를 제거할 때, reference count에 의존하기 때문에 retain cycle 개념을 이해하는 것이 중요하다. Student 객체에 partner 변수를 추가한다.
var alice: Student? = Student(firstName: "Alice", lastName: "Appleseed")
var bob: Student? = Student(firstName: "Bob", lastName: "Appleseed")
alice?.partner = bob
bob?.partner = alice
alice = nil //해제
bob = nil //해제
//하지만 이를 실행하면, deinit가 호출되지 않는다. alice와 bob은 서로에 대한 참조를 가지고 있으므로, reference count는 결코 0이 되지 않는다.
//더불어, alice와 bob에 nil을 할당해 더 이상 객체에 대한 참조가 없어짐에도 reference count는 0이 되지 않는다.
//이는 reference count의 전형적인 사례이며, 메모리 누수(memory leak)로 알려진 소프트웨어 버그로 이어진다.
//메모리 누수로 인해, 실제 life cycle이 끝났음에도 메모리가 해제되지 않는다. Retain cycle은 메모리 누수의 가장 일반적인 원인이다.
//다행히도 해당 객체(여기서는 Student)가 cycle을 유지하지 않고 다른 객체를 참조할 수 있는 방법이 있다. 참조를 weak으로 만들면 된다.
//weak으로 해당 변수를 선언하면, 이 변수의 참조는 reference count에 포함되지 않는다. 참조가 weak이 아닌 경우는 Swift의 기본값인 strong reference가 된다.
//weak reference는 참조하는 객체가 해제될 때 자동으로 nil이 되도록 optional로 선언해야 한다.
