//: Chapter17: Generics

//이미 Generic을 여러 군데 에서 사용했다(Array를 사용할 때, 제네릭이 사용된다).
//Generic의 관점에서 Swift standard library를 다시 살펴 본다.




//Introducing generics
//애완동물(Pet)과, 애완동물 관리 직원(Keeper)에 대한 모델을 예시로 한다. 각각 다른 value나 type을 사용하여 모델을 만들 수 있다.
//value 대신 type을 사용하면, 컴파일 시간에 Swift가 type을 검사하여 코드를 추론할 수 있다.
//이 경우, 런타임(runtime)이 더 적게 소모되고, value를 사용했을 때 잡아낼 수 없는 여러 문제점을 잡아낼 수 있으며, 코드 또한 더 빨리 실행된다.

//Values defined by other values
//고양이와 개만 분양하는 애완 동물 가게를 운영하며, 그 사업을 모형화 한다고 가정한다. 먼저, 분양하는 두 가지 동물에 해당하는 value를 저장할 수 있는 새로운 유형을 정의한다.
enum PetKind {
    case cat
    case dog
}
//애완동물을 관리하는 직원들 또한 모델링해야 한다. 직원들은 전문 영역이 있어, 고양이나 개 둘 중 하나만 돌본다.
 struct KeeperKind {
    var keeperOf: PetKind
}
//직원 객체를 초기화한다.
let catKeeper = KeeperKind(keeperOf: .cat)
let dogKeeper = KeeperKind(keeperOf: .dog)
//애완동물 가게를 모델링할 때, 두 가지 주목해야 할 점이 있다.
// 1. type의 다른 value를 사용하여, 애완 동물과 keeper를 표현한다. 애완동물의 종류(PetKind)와 직원의 종류(KeeperKind)는 각각 한 가지 type만 있다.
//  KeeperKind type의 value로 구분되는 것 처럼, PetKind 또한 type의 value로 구분할 수 있다.
// 2. 가능한 범위의 value 중 하나가 다른 value의 가능한 범위를 결정한다. 특히, 가능한 KeeperKind의 value 범위는 가능한 PetKind의 value 범위를 반영한다.
//만약, 가게에서 새로운 애완동물 종류인 새를 팔기로 했다면, PetKind 열거형에 .bird 멤버를 추가하고 KeeperKind(keeperOf: .bird)로 새를 관리하는 직원을 초기화할 수 있다.
//수 백 종류의 애완동물을 추가하더라도, 즉시 그 애완동물을 관리하는 직원 객체를 표현할 수 있다.
//이와 대조적으로, KeeperKind를 사용하는 대신 또다른 열거형을 정의할 수 있다.
enum EnumKeeperKind {
    case catKeeper
    case dogKeeper
}
//이 경우에는, PetKind와 EnumKeeperKind를 동기화하는 데 항상 신경써야 한다.
//만약 PetKind.snake를 추가했는데, EnumKeeperKind.snakeKeeper를 추가하는 것을 깜빡한다면, 애완 동물 가게 모델이 엉망이 되어 버릴 것이다.
//요약하면, 다음과 같이 관계를 묘사할 수 있다. //p.323
// PetKind values   KeeperKind values
// .cat             KeeperKind(keeperOf: .cat)
// .dog             KeeperKind(keeperOf: .dog)
// .etc             .etc

//Types defined by other types
//위의 모델은 기본적으로 type의 value를 변경시켜 작동한다. type 자체를 변경하여 다른 방법으로 애완동물-관리직원(pet-to-keeper) 시스템을 모델링할 수도 있다.
//모든 종류의 애완동물을 표현하는 단일 type의 PetKind를 정의하는 대신, 분양하는 모든 종류의 애완동물에 대한 고유한 type을 정의한다.
//객체지향(object-oriented)으로 작업하는 경우, 각 애완동물의 특성을 다른 메서드로 구현하므로 타당한 선택이다.
class Cat0 {}
class Dog0 {}
//그리고 이에 상응하는 관리직원의 객체도 생성해야 한다.
class KeeperForCats {}
class KeeperForDogs {}
//하지만, 이렇게 모델을 구현하는 것은 좋은 방법이 아니다. 이 방법은 KeeperKind를 열거형으로 일일히 정의한 것(EnumKeeperKind)과 동일한 문제를 가지고 있다.
//모든 종류의 애완동물에 대한 관리 직원을 일일히 설정해 줘야 한다. 처음 만들었던 모델과 같이 value를 설정하면, 이와 관련된 관계(relationship)가 선언되도록 구현하는 것이 좋다.
//가능한 모든 애완 동물 type을 선언하면, 해당 동물을 관리하는 직원 type 또한 존재한다는 것을 의미하도록 한다. //p.324
// Pet types        Keeper types
// Cat              Keeper (of Cat...)
// Dot              Keeper (of Dog...)
// etc.             etc.
//가능한 모든 애완동물 type에 대해 해당 관리 직원 type이 정의되어 있는지 확인한다. 하지만 이를 일일이 직접 추가하고 확인하기보다는, 자동으로 정의하는 방법이 필요하다.
//제네릭(Generic)으로 이를 구현할 수 있다.




//Anatomy of generic types
//제네릭은 하나의 type set을 사용하여, 새로운 type set을 정의하는 매커니즘을 제공한다. 다음과 같이 관리 직원의 Generic type을 정의할 수 있다.
class Keeper0<Animal> {}
//이 선언은 원하는 모든 해당 Keeper type을 즉시 정의한다. //p.325
// Pet types        Keeper types
// Cat              Keeper<Cat>
// Dot              Keeper<Dog>
//생성자(initializer)에서 전체 type을 지정하여, 이러한 type의 value를 생성하고 확인할 수 있다.
var aCatKeeper = Keeper0<Cat0>() //Keeper는 Generic type의 이름이다.
//그러나 Generic type은 진짜로 사용하는 type이라기 보다는, 실제(concrete) type을 만들기 위한 recipe와 비슷하다.
//따라서, type을 지정하지 않고 인스턴스화하면 오류가 발생한다.
//var aKeeper = Keeper() // compile-time error!
//컴파일러는 어떤 종류의 Keeper를 원하는지 알 수 없기 때문에 오류를 발생 시킨다. 꺽쇠 괄호 안의 Animal은 관리하는 동물을 지정하는 유형(type) 매개변수이다.
//Keeper<Cat>과 같이 필수 type parameter를 제공하면, Generic Keeper가 새로운 concrete type이 된다.
//동일한 Generic type이지만, Keeper<Cat>과 Keeper<Dog>은 다르다. 이러한 concrete type들을 Generic type의 특수화(specialization)라고 한다.
//요약하자면, Keeper<Animal>과 같은 Generic type을 정의하려면, Generic type의 이름과 type parameter만 설정해 주면 된다.
//type parameter의 이름은 type parameter와 Generic type 사이의 관계를 명확히 해야 한다.
//때때로 T(Type의 약자)와 같은 이름을 사용하기도 하지만, Animal과 같이 명확한 역할이 있는 경우에는 가급적 이러한 type parameter 이름을 피해야 한다.
//generic type인 Keeper<Animal>은 새로운 type의 그룹을 정의한다.
//이 모두는 type parameter인 Animal에 대체할 수 있는 구체적인 type을 적용해, concrete type을 생성하는 Keeper<Animal>의 특수화(specialization)들이다.
//Keeper type은 아무것도 저장(store)하지 않고, 심지어 Animal type도 사용하지 않는다. 본질적으로, Generic은 일련의 type을 체계적으로 정의하는 방법일 뿐이다.

//Using type parameters
//일반적으로, 특정의 작업을 하기 위해 type parameter로 해당 type을 받아온다.
//개별 객체 tracking을 위해 이름과 같은 식별자(identifier)를 포함하도록 type의 정의를 보강할 수 있다. 이를 구현하면, 모든 value는 개별적인 animal이나 keep로 식별할 수 있다.
class Cat {
    var name: String
    init(name: String) {
        self.name = name
    }
}

class Dog {
    var name: String
    init(name: String) {
        self.name = name
    }
}

class Keeper1<Animal> {
    var name: String
    init(name: String) {
        self.name = name
    }
}
//어떤 관리 직원(keeper)이 어떤 동물(animal)을 돌보는지 추적해야 한다. 모든 keeper가 오전(morning)과 오후(afternoon) 각각 한 마리의 동물을 돌본다고 가정한다.
//morning animal과 afternoon animal 속성을 추가하여 이를 표현할 수 있다. 그러나, 이런 속성은 어떤 유형이 되어야 하는지 생각해 봐야 한다.
//어떤 keeper가 개만 관리하는 경우, 속성은 개만 보유해야(hold) 하는 것이 명백하다. 그리고 고양이만을 관리한다면, 속성 또한 고양이만 보유해야 한다.
//일반적으로, 동물을 관리하는 직원이라면 오전과 오후의 동물 속성은 Animal type이어야 한다.
//이를 표현하려면, 유형 매개변수(type parameter)를 사용해, Keeper type을 구별할 수 있게 하면 된다.
class Keeper2<Animal> {
    var name: String
    var morningCare: Animal
    var afternoonCare: Animal
    
    init(name: String, morningCare: Animal, afternoonCare: Animal) {
        self.name = name
        self.morningCare = morningCare
        self.afternoonCare = afternoonCare
    }
}
//Generic 정의 body에 Animal을 사용해서, keeper가 오전과 오후에 돌봐야할 동물을 나타낼 수 있다.
//함수의 매개변수(parameter)가 함수 본문 내에서 상수(constant)로 사용되는 것 처럼, type 정의 전체에서 Animal과 같은 type parameter를 사용할 수 있다.
//type parameter는 stored property 뿐만 아니라 computed property, method signature, nested type 등 Keeper<Animal> 정의 어느 곳에서나 사용할 수 있다.
//이제 Keeper를 인스턴스화 할 때, Swift는 컴파일 시간에 오전(morningCare)과 오후(afternoonCare) type이 일치한지 확인한다.
let jason = Keeper2(name: "Jason", morningCare: Cat(name: "Whiskers"), afternoonCare: Cat(name: "Sleepy"))
//let jason = Keeper(name: "Jason", morningCare: Cat(name: "Whiskers"), afternoonCare: Dog(name: "Sleepy")) //Error: 동일한 type parameter를 사용해야 한다.
//관리 직원 jason는 오전에는 고양이 Whiskers를, 오후에는 고양이 Sleepy를 관리한다. jason 객체의 type은 Keeper<Cat>이다.
//Generic의 정의와 달리, 실제 객체를 인스턴스화 할 때는 Type 뒤에 type parameter의 값을 따로 지정할 필요는 없다
//(let jason = Keeper<Cat>(name: "Jason", morningCare: Cat(name: "Whiskers"), afternoonCare: Cat(name: "Sleepy")) 으로 선언할 필요 없다).
//MorningCare와 afternoonCare의 매개변수로 Cat 인스턴스를 사용하므로, Swift는 jason의 type이 Keeper<Cat>이어야 한다는 것을 알고 있다.

//Type constraints
//Keeper 정의에서 식별자 Animal은 유형 매개변수(type parameter)로 사용되며, 나중에 제공될 실제 type의 자리표시자(placeholder)이다.
//이것은 func feed(cat: Cat) { /* open can, etc... */ } 와 같은 간단한 함수에서 매개변수 cat과 비슷하다.
//이 함수를 호출할 때는 단순히 아무 type을 매개변수로 전달할 수는 없다. Cat type의 값만 전달할 수 있다.
//하지만 Keeper(제네릭)에서는 String이나 Int와 같이 Animal과 아무 관련이 없는 어떤한 type이라도 type parameter로 전달할 수 있다.
//그러나, 어떠한 제한 없이 어떤 type이든 유형 매개변수(type parameter)로 전달할 수 있는 것은 좋은 구현이 아니다.
//Swift에서는 다양한 유형 제약조건(type constraint)을 사용해, type의 종류를 제한 해줄 수 있다.
//간단하게, 유형 매개변수(type parameter)에 유형 제약조건(type constraint)을 직접 적용할 수 있다.
class Keeper<Animal: Pet> { //type parameter에 type constraint를 적용한다.
    //placeholder인 Animal에 할당되는 type은 Pet의 하위 클래스이거나 Pet protocol을 구현해야 한다.
    /* definition body as before */
    var name: String
    var morningCare: Animal
    var afternoonCare: Animal
    
    init(name: String, morningCare: Animal, afternoonCare: Animal) {
        self.name = name
        self.morningCare = morningCare
        self.afternoonCare = afternoonCare
    }
}
//유형 제약조건(type constraint)은 유형 매개변수(type parameter)의 뒤에 : 를 추가한 뒤, type을 적어주면 된다.
//해당 제약 조건 type이 class라면 해당 클래스의 하위 클래스여야 하고, protocol이라면 이를 구현해야 한다.
//ex. 위의 수정된 Keeper에 맞도록, Cat과 다른 동물 클래스를 재정의하여 Pet을 구현하거나, extension을 사용해 protocol 구현을 소급 적용해 줄 수도 있다.
protocol Pet {
    var name: String { get }  // all pets respond to a name
}
extension Cat: Pet {}
extension Dog: Pet {}
//Cat과 Dog은 이미 name 속성이 있기 때문에 extension으로 Pet protocol 구현을 명시해 주기만 하면 된다.
//더 복잡하고 일반적인 유형 제약조건(type constraint)을 사용하려면 Generic뒤에 where 절을 추가한다.
//또한, where 절을 extension에 추가해 줄 수도 있다. 이를 위해 모든 Cat 배열(Array)에 meow() 메서드를 추가한다고 가정한다.
//extension을 사용해, Array의 요소가 Cat일때 배열이 meow() 메서드를 지원하도록 지정해 줄 수 있다.
extension Array where Element: Cat {
    func meow() {
        forEach { print("\($0.name) says meow!") }
    }
}
//특정 제약 조건을 충족하는 경우에만, 해당 type이 protocol을 준수하도록 지정할 수도 있다. 야옹(meow)울음 소리를 낼 수 있다면, 모두 Meowable이라고 가정한다.
//모든 요소가 Meowable이라면, Array가 Meowable이라고 쓸 수 있다.
protocol Meowable {
    func meow()
}

extension Cat: Meowable {
    func meow() {
        print("\(self.name) says meow!")
    }
}

extension Array: Meowable where Element: Meowable {
    func meow() {
        forEach { $0.meow() }
    }
}
//이런 미묘하지만 강력한 구성 매커니즘을 조건부 적합성(conditional conformance)이라고 한다.




//Arrays
//본래의 Keeper type은 아무런 변수나 유형 매개변수(type parameter)가 없는 Generic type이었지만, 일반적으로 Generic 유형은 값을 저장하고, 유형 매개변수(type parameter)를 사용한다.
//그리고 가장 대표적으로 Generic type을 사용하는 예시는 Array이다. 제네릭 배열(Generic Array)의 필요성이 Generic type 개발의 동기가 된 측면이 있다.
//많은 프로그램에서 요소의 type이 같은(homogeneous) 배열을 사용하기 때문에, Generic 배열을 사용하면 코드를 더 안전하게 관리할 수 있다.
//컴파일러가 코드의 한 지점에서 Array의 요소를 유추할 수 있다면, 프로그램이 실행되기 전에 코드의 다른 지점에서 이를 활용할 수 있다.
//지금까지 Array를 선언할 때, 간편한 문법(syntactic sugar, Array<Element> 대신 [Element]로 표현)으로 Array를 자주 사용했다.
let animalAges: [Int] = [2, 5, 7, 9] //let animalAges: Array<Int> = [2,5,7,9]와 같다.
//Array<Element> 와 [Element]는 호환이 되므로 Array<Int>() 대신 [Int]() 로 배열을 생성할 수 있다.
//Swift Array는 일련의 요소를 index로 간편하게 액세스할 수 있기 때문에 요소(Element) type에 대한 추가적인 요구사항은 없다. 하지만 항상 그런 것은 아니다.




//Dictionaries
//Swift Generic을 사용하면, 여러 유형의 매개변수(type parameter)와 복잡한 제약 조건을 사용할 수 있다.
//이를 사용해, 복잡한 알고리즘과 자료구조를 모델링할 때, Generic type과 associated type의 protocol을 사용할 수 있다.
//Dictionary가 대표적인 예시이다.
//Dictionary는 쉼표로 구분된 Generic 매개 변수 목록에 꺽쇠 괄호 사이에 있는 두 가지 type parameter가 있다. Dictionary의 선언을 살펴보면 다음과 같다.
// struct Dictionary<Key: Hashable, Value> // etc..
//Key와 Value는 Dictionary의 keys와 values를 나타낸다. 유형 제약조건(type constraint)인 Key: Hashable 은 Dictionary의 key가 Hashable 이어야 함을 나타낸다.
//Dictionary는 해쉬맵(hash map)이고, 빠른 조회(lookup)를 구현하려면, key가 hash여야 하기 때문이다.
//Dictionary와 같이 초기화 할 때, 여러 type parameter가 필요한 type은 쉼표로 구분된 매개변수 목록을 사용한다.
let intNames: Dictionary<Int, String> = [42: "forty-two"]
//Array와 마찬가지로 Dictionary는 이미 framework에 내장된 Collection이므로, [Key: Value] 처럼 간단하게 선언할 수 있고 type 추론도 가능하다.
let intNames2: [Int: String] = [42: "forty-two", 7: "seven"] //shorthand notation
//Dictionary<Int, String> 대신 [Int: String]로 표기할 수 있다.
let intNames3 = [42: "forty-two", 7: "seven"] //type inference




//Optionals
//Optional도 Generic을 사용한다. optaional은 enum으로 구현되지만, 사용자가 새로 정의할 수 있는 generic type이기도 하다.
//생년월일 양식을 입력하는 앱을 만들때, 생년월일이 필수적인 정보가 아니라 한다면, 다음과 같이 열거형(enum)을 사용하는 것이 편리하다.
import Foundation

enum OptionalDate {
    case none
    case some(Date)
}
//마찬가지로, 이름의 성(last name)을 입력 받을 때, 필수 항목이 아니라면 다음과 같이 정의할 수 있다.
enum OptionalString {
    case none
    case some(String)
}
//그런 다음, 사용자가 입력한 모든 정보를 구조체로 만들어 관리한다.
struct FormResults {
    // other properties here
    var birthday: OptionalDate
    var lastName: OptionalString
}
//만약, 위와 같이 optional 입력 정보들을 반복적으로 생성해야 한다면 "값이 있을 수도, 없을 수도 있음"이라는 개념을 나타내는 generic type으로 일반화 할 수 있다.
enum Optional<Wrapped> {
    case none
    case some(Wrapped)
}
//위의 type은 Swift 자체의 Optional<Wrapped>과 비슷하게 사용 된다. 실제 Swif Standard Library의 Optaional은 이와 매우 유사하게 정의되어 있다.
//다른 점은 Swift 자체의 Optaional과 달리, type을 선언하고 사용할 때 축약형 없이 항상 완전한 형태로 명시해 줘야 한다는 점이다.
var birthdate1: Optional<Date> = .none
//if birthdate1 == .none {
//    // no birthdate
//}
//물론 다음과 같이 쓰는 것이 더 일반적이다.
var birthdate2: Date? = nil
if birthdate2 == nil {
    // no birthdate
}
//실제로 위 두 코드 블록은 정확히 같다. Optional에 지원되는 특수한 선언형을 사용한다(Optional<Wrapped> 를 Wrapped? 로 사용, Optional<Wrapped>.none 을 nil 로 사용).
//Array, Dictionary와 마찬가지로, Optional은 좀 더 간결한 구문을 사용할 수 있다. 이런 문법들은 Generic Enumeration type에 접근할 수 있는 더 편리한 방법을 제공한다.




//Generic function parameters
//함수도 Generic을 사용할 수 있다. 함수의 type parameter list는 함수 이름 뒤에 온다. 그런 다음 정의의 나머지 부분에서 generic parameter를 사용할 수 있다.
func swapped<T, U>(_ x: T, _ y: U) -> (U, T) { //두 개의 인수를 받아 순서를 바꾼다.
    (y, x)
}
swapped(33, "Jay")  // returns ("Jay", 33)
//Generic 함수 정의에는 generic parameter list에 유형 매개변수(type parameter) <T, U>가 있다.
//또한, function parameter list로 (_ x: T, _ y: U)가 있다.
//type parameter를 컴파일러에 대한 인수로 여겨, 함수를 정의하는 데 사용되는 것으로 생각할 수 있다.
//위의 애완동물 가게에서 제네릭(generic) Keeper type으로 고양이를 관리하는 직원(cat keeper), 개를 관리하는 직원(dog keeper) 등 어떤 종류의 keeper를  만들 수 있었던 것처럼
//컴파일러는 두 개의 입렵된 type을 사용하는 특수 swap 함수를 만든다.
