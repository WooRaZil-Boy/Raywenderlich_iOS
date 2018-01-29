//: Chapter14: Advanced Classes

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
    
    deinit { //deinitializer. ARC에 의해 카운트가 0이 되면 삭제되기 전 호출된다.
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

//Introducing inheritance
//상속으로 중복되는 부분을 간결하게 줄일 수 있다.
class Student: Person { //상속함으로써 Person의 프로퍼티와 메서드들을 자동으로 가져온다. //Student "is-a" Person
    var grades: [Grade] = []
    
    func recordGrade(_ grade: Grade) {
        grades.append(grade)
    }
}

let john = Person(firstName: "Johnny", lastName: "Appleseed")
let jane = Student(firstName: "Jane", lastName: "Appleseed")

john.firstName
jane.firstName

let history = Grade(letter: "B", points: 9.0, credits: 3.0)
jane.recordGrade(history)
// john.recordGrade(history) // john is not a student!

//스위프트에서는 오직 한 클래스만 상속할 수 있다.
//서브 클래스의 depth에는 제한이 없다.
class BandMember: Student {
    var minimumPracticeTime = 2
}

class OboePlayer: BandMember {
    override var minimumPracticeTime: Int {
        get {
            return super.minimumPracticeTime * 2
        }
        
        set {
            super.minimumPracticeTime = newValue / 2
        }
    }
}

//Polymorphism
func phonebookName(_ person: Person) -> String { //다형성. 단, 하위 클래스라 하더라도 이런 경우에는 Person 클래스에 정의된 요소만 사용할 수 있다.
    return "\(person.lastName), \(person.firstName)"
}

let person = Person(firstName: "Johnny", lastName: "Appleseed")
let oboePlayer = OboePlayer(firstName: "Jane", lastName: "Appleseed")


phonebookName(person)
phonebookName(oboePlayer)

//Runtime hierarchy checks
var hallMonitor = Student(firstName: "Jill", lastName: "Bananapeel")
hallMonitor = oboePlayer //대입

oboePlayer as Student
//(oboePlayer as Student).minimumPracticeTime // ERROR: No longer a band member!

hallMonitor as? BandMember
(hallMonitor as? BandMember)?.minimumPracticeTime // 4 (optional) //OboePlayer로 생성했기 때문에. //BandMember의 minimumPracticeTime default가 2일 뿐

hallMonitor as! BandMember // Careful! Failure would lead to a runtime crash.
(hallMonitor as! BandMember).minimumPracticeTime // 4 (force unwrapped)

if let hallMonitor = hallMonitor as? BandMember { //nil이 아닌 경우에만 할당되고 if문으로 들어간다.
    print("This hall monitor is a band member and practices at least \(hallMonitor.minimumPracticeTime) hours per week.")
}

func afterClassActivity(for student: Student) -> String {
    return "Goes home!"
}

func afterClassActivity(for student: BandMember) -> String {
    return "Goes to practice!"
}

afterClassActivity(for: oboePlayer) // Goes to practice!
afterClassActivity(for: oboePlayer as Student) // Goes home!

//Inheritance, methods and overrides
class StudentAthlete: Student {
    var failedClassed: [Grade] = []
    
    override func recordGrade(_ grade: Grade) { //override로 부모 클래스의 메서드를 재정의할 수 있다.
        //override 없이 상위 클래스의 함수와 동일한 함수를 사용하면 에러
        super.recordGrade(grade) //super를 먼저 호출하는 것이 좋다. 로직을 바꿔 super를 뒤에서 호출하게 되면, 제대로 업데이트 되지 않은 값으로 진행될 수 있기 때문에.
        
        if grade.letter == "F" {
            failedClassed.append(grade)
        }
    }
    
    var isEligible: Bool { //computed property
        return failedClassed.count < 3
    }
}

//Preventing inheritance
final class FinalStudent: Person {} //final 키워드를 붙이면 상속을 막을 수 있다.
//class FinalStudentAthlete: FinalStudent {} // Build error!

class AnotherStudent: Person {
    final func recordGrade(_ grade: Grade) {} //메서드에 final 키워드를 붙이면 상속은 되지만 오버라이드가 되지 않는다.
}
class AnotherStudentAthlete: AnotherStudent {
//    override func recordGrade(_ grade: Grade) {} // Build error!
}

//Inheritance and class initialization
class NewStudent {
    let firstName: String
    let lastName: String
    var grades: [Grade] = []
    
    required init(firstName: String, lastName: String) { //하위 클래스가 이 initializer를 구현하도록 required 키워드로 강제
        self.firstName = firstName
        self.lastName = lastName
    }
    
    convenience init(transfer: NewStudent) { //convenience 키워드는 보조적인 생성자. 반드시 이 클래스 내의 다른 생성자를 호출해야 하며 그 호출된 생성자가 초기화를 완료해야 한다.
        //non-convenience initializer는 designed initializer라 하며 기본적인 생성자다. 디자인드 생성자는 2단계 초기화를 적용받는다.
        self.init(firstName: transfer.firstName, lastName: transfer.lastName)
    }
    
    func recordGrade(_ grade: Grade) {
        grades.append(grade)
    }
}

class NewStudentAthlete: NewStudent {
    var failedClasses: [Grade] = []
    var sports: [String]
    
    init(firstName: String, lastName: String, sports: [String]) { //서브 클래스의 initializer는 반드시 super.init를 호출해야 한다. 슈퍼 클래스가 없으면 슈퍼 클래스는 모든 저장된 속성의 초기상태를 제공할 수 없기 때문이다.
        self.sports = sports
        let passGrade = Grade(letter: "P", points: 0.0, credits: 0.0)
        super.init(firstName: firstName, lastName: lastName) //super를 반드시 호출해야 한다. 그래야 상속받은 프로퍼티들이 초기화 된다.
        //초기화할때 이 클래스의 고유한 프로퍼티들을 먼저 초기화 한 후에 super.init를 해야 한다.(강제적) 고유 프로퍼티들이 없는 경우에는. super를 먼저 호출하고 로직을 작성하는 것이 좋다. //1단계 초기화 완료
        recordGrade(passGrade) //2단계 초기화
    }
    
    required init(firstName: String, lastName: String) { //부모 클래스에서 required로 강제된 생성자는 반드시 구현해야 한다. //required 된 이니션라이저는 override 대신 required 키워드를 쓴다.
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
        return failedClasses.count < 3
    }
}

//Two-phase initialization
//모든 stored properties는 초기화되어야 하기 때문에, 하위 클래스의 생성자에서는 2단계로 초기화해야 한다.
//Phase One : stored properties는 맨 아래 자식 클래스에서 맨 위 부모 클래스로 초기화한다. 이 단계가 완료될때 까지 속성과 메서드를 사용할 수 없다.
//Phase Two : 속성과 메서드를 사용가능하고, self를 사용한다.

//1. A designated initializer must call a designated initializer from its immediate superclass.
//2. A convenience initializer must call another initializer from the same class.
//3. A convenience initializer must ultimately call a designated initializer.

//Single responsibility
//모든 클래스가 단일 책임을 가져야 한다. - Student에서 sports 배열을 만들고 선수들에게만 채우고, 나머지는 nil로 해도 되지만, 상속하면서 클래스 별로 단일 책임을 가지게 하는 것이 더 나은 설계이다.

//Strong types
class Team {
    var players: [StudentAthlete] = []
    
    var isEligible: Bool { //학생 선수만 담아야 하므로, 일반 학생이 들어오는 것을 막을 수 있다.
        for player in players {
            if !player.isEligible {
                return false
            }
        }
        return true
    }
}

//Shared base classes
class Button { //공통의 요소만을 골라낸다.
    func press() {}
}

class Image {}

class ImageButton: Button { //버튼을 상속하지만 세부적인 내용은 텍스트 버튼과 다르다.
    var image: Image
    
    init(image: Image) {
        self.image = image
    }
}

class TextButton: Button { //버튼을 상속하지만 세부적인 내용은 이미지 버튼과 다르다.
    var text: String
    
    init(text: String) {
        self.text = text
    }
}

//서브클래싱과 확장 중 어느 것을 선택해야 될지 상황에 따라 생각해봐야 한다.

//Understanding the class lifecycle
//힙은 스택과 달리 자동 삭제되지 않는다. (C언어 생각). 스위프트에서는 참조 카운팅을 통해 메모리를 해제한다.(ARC)
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
someone = Person(firstName: "Johnny", lastName: "Appleseed")
// Reference count 0 for the original Person object!
// Variable someone now references a new object

//Retain cycles and weak references
class PartnerStudent: Person {
    weak var partner: PartnerStudent? //weak 키워드로 메모리 누수를 해결해 준다. //weak 키워드를 쓰면, 이 변수가 참조 카운팅에 포함되지 않는다.
    // original code
    deinit {
        print("\(firstName) is being deallocated!")
    }
}
var alice: PartnerStudent? = PartnerStudent(firstName: "Alice",
                              lastName: "Appleseed")
var bob: PartnerStudent? = PartnerStudent(firstName: "Bob",
                            lastName: "Appleseed")
alice?.partner = bob
bob?.partner = alice

alice = nil
bob = nil
//weak를 쓰지 않으면 디이니셜라이저가 실행되지 않는다수 메모리 누수. //서로 참조하기 때문에 영원히 카운터가 0이 되지 않는다.
