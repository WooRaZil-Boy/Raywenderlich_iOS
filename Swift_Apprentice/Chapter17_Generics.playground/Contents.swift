//: Chapter17: Generics

import Foundation

//Values defined by other values
enum PetKind {
    case cat
    case dog
}

struct KeeperKind { //PetKind의 범위가 KeeperKind의 범위를 결정한다.
    var keeperOf: PetKind
}

let catKeeper = KeeperKind(keeperOf: .cat) //자동으로 형을 찾는다.
let dogKeeper = KeeperKind(keeperOf: .dog)

//이렇게 나누어 정의할 경우, 동물이 추가되더라도 enum에서만 관리하면 된다. 예를 들어 PetKind에 snake를 추가하면 KeeperKind에서는 KeeperKind(keeperOf: .snake)라 하면 된다.

enum EnumKeeperKind { //반대로 이런식으로 정의할 경우, PetKind에 이어 snakeKeeper도 따로 또 정의해줘야 해서 오류의 위험이 커진다.
    case catKeeper
    case dogKeeper
}

//Types defined by other types
class Cat_1 {}

class Dog_1 {}

class KeeperForCats {}
class KeeperForDogs {}
//object-oriented style로 구현한다고 해 보면 이렇게 된다. 이도 EnumKeeperKind와 같은 문제를 가지고 있다.

//Anatomy of generic types
//제네릭을 사용해 이 상황을 개선할 수 있다.
class Keeper_1<Animal> {}

var aCatKeepe = Keeper_1<Cat_1>() //제네릭 자체가 실제 타입이 아니므로 구체적인 유형을 같이 써줘야 한다.
//var aKeeper = Keeper()  //따라서 이렇게 쓰면 compile-time error!
//Animal 자체가 type parameter라고 생각하면 된다. 즉, Keeper<Cat>과 Keeper<Dog>은 다른 타입이다.
//보통 자바 등에서는 Keeper<T>라 쓰는 경우가 많다.

//Using type parameters
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

//Type constraints
protocol Pet {
    var name: String { get } //모든 펫은 이름을 가져야 한다.
}

extension Cat: Pet {}
extension Dog: Pet {}

class Keeper<Animal: Pet> { //Pet의 서브클래스이거나(class), 구현한 protocol이어야 한다. //Keeper에서 제약을 적용할 수 있다.
    var name: String
    var morningCare: Animal
    var afternoonCase: Animal

    init(name: String, morningCare: Animal, afternoonCase: Animal) {
        self.name = name
        self.morningCare = morningCare
        self.afternoonCase = afternoonCase
    }
}

let jason = Keeper(name: "Jason", morningCare: Cat(name: "Whiskers"), afternoonCase: Cat(name: "Sleepy"))

let cats = ["Miss Gray", "Whiskers"].map{ Cat(name: $0) } //이런식으로 인스턴스를 초기화해 배열에 담을 수도 있다.
//map은 클로저로 각 항목들을 반영한 결과물을 가진 새로운 배열을 반환 //cats의 타입은 [Cat]
let dogs = ["Sparky", "Rusty", "Astro"].map{ Dog(name: $0) }
let pets: [Pet] = [Cat(name: "Mittens"), Dog(name: "Yeller")]

func herd(_ pets: [Pet]) { //Pet을 구현하기만 하면 되므로 Dog이든 Cat이든 섞여 있든 상관없이 사용할 수 있다.
    pets.forEach {
        print("Come \($0.name)!")
    }
}

func herd<Animal: Pet>(_ pets: [Animal]) { //Pet을 구현 했으면 사용 가능. 하지만, 모든 요소는 같은 타입이어야 한다.
    //함수 명 뒤에 꺾쇠 괄호로 제네릭 형식을 지정해 줄 수 있다.
    //Animal은 선언한 적 없다. 그냥 명확하게 하기위한 주석 같은 것. Animal 대신 T라 써도 무방하다.
    pets.forEach {
        print("Here \($0.name)!")
    }
}

func herd<Animal: Dog>(_ dogs: [Animal]) { //Dog 타입만 사용 가능하다.
    pets.forEach {
        print("Here \($0.name)! Come here")
    }
}

herd(pets) // Calls 1
herd(cats) // Calls 2
herd(dogs) // Calls 3

extension Array where Element: Cat { //Array 확장. 요소가 Cat인 경우만 적용 //이런 식으로 유형을 제한해 줄 수 도 있다.
    func meow() {
        forEach { print("\($0.name) says meow!") }
    }
}

cats.meow()
//dogs.meow() // error: 'Dog' is not a subtype of 'Cat' //실수를 방지할 수 있다.

//Arrays
let animalAges: [Int] = [2, 5, 7, 9] //let animalAges: Array<Int> = [2,5,7,9] 이것과 완전히 같다. - 이것이 원래의 정의대로 선언하는 방법

//Dictionaries
//struct Dictionary<Key: Hashable, Value> // etc.. //딕셔너리 정의
let intNames: Dictionary<Int, String> = [42: "forty-two"]
let intNames2: [Int: String] = [42: "forty-two", 7: "seven"]
let intNames3 = [42: "forty-two", 7: "seven"]
//Arrays와 같이 간편하게 쓸수 있다.

//Optionals
enum OptionalDate {
    case none
    case some(Date)
}

enum OptionalString {
    case none
    case some(String)
}

struct FormResults {
    var birthday: OptionalDate
    var lastName: OptionalString
}

//enum Optional<Wrapped> {
//    case none
//    case some(Wrapped)
//} //제네릭을 통해 일반화 시킬 수 있다.

var birthdate1: Optional<Date> = .none
if birthdate1 == .none {
    // no birthdate
}

var birthdate2: Date? = nil
if birthdate2 == nil {
    // no birthdate
} //.none 과 nil은 같다. //두 코드는 완전히 같다.

//Generic function parameters
func swapped<T, U>(_ x: T, _ y: U) -> (U, T) { //제네릭으로 특정한 타입을 지정하지 않는 함수를 만든다.
    return (y, x)
}

swapped(33, "Jay")  // returns ("Jay", 33) //제네릭으로 값의 유형에 관계없이 스왑시키는 함수를 작성할 수 있다.

