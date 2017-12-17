//: Chapter 21: Error Handling

//Failable initializers
let value = Int("3") //Optional(3)
let failedValue = Int("nope") //nil

enum PetFood: String {
    case kibble, canned
}

let morning = PetFood(rawValue: "kibble") //Optional(.kibble)
let snack = PetFood(rawValue: "fuuud!") //nil

//failable initializers는 nil을 반환할 수 있다.

struct PetHouse {
    let squareFeet: Int
    
    init?(squreFeet: Int) {
        if squreFeet < 1 {
            return nil
        }
        
        self.squareFeet = squreFeet
    }
}

let tooSmall = PetHouse(squreFeet: 0) //nil
let house = PetHouse(squreFeet: 1) //Optional(Pethouse)

//Optional chaining
class Pet1 {
    var breed: String?
    
    init(breed: String? = nil) { //failable initializer가 아니더라도 이런식으로 default를 nil로 지정해 줄 수 있다.
        self.breed = breed
    }
}

class Person1 {
    let pet: Pet1
    
    init(pet: Pet1) {
        self.pet = pet
    }
}

let delia = Pet1(breed: "pug")
let olive = Pet1()

let janie1 = Person1(pet: olive)
//let dogBreed = janie1.pet.breed! //nil이기 때문에 force unwrap을 하면 오류가 난다.

if let dogBreed = janie1.pet.breed { //optional binding을 통해 unwarp 해준다.
    print("Olive is a \(dogBreed)")
} else {
    print("Olive's breed is unknown.")
}

class Toy {
    enum Kind {
        case ball
        case zombie
        case bone
        case mouse
    }

    enum Sound {
        case squeak
        case bell
    }

    let kind: Kind
    let color: String
    var sound: Sound?

    init(kind: Kind, color: String, sound: Sound? = nil) {
        self.kind = kind
        self.color = color
        self.sound = sound
    }
}

class Pet {
    enum Kind {
        case dog
        case cat
        case guineaPig
    }

    let name: String
    let kind: Kind
    let favoriteToy: Toy?

    init(name: String, kind: Kind, favoriteToy: Toy? = nil) {
        self.name = name
        self.kind = kind
        self.favoriteToy = favoriteToy
    }
}

class Person {
    let pet: Pet?

    init(pet: Pet? = nil) {
        self.pet = pet
    }
}

let janie = Person(pet: Pet(name: "Delia", kind: .dog, favoriteToy: Toy(kind: .ball, color: "Purple", sound: .bell)))
let tammy = Person(pet: Pet(name: "Evil Cat Overlord", kind: .cat, favoriteToy: Toy(kind: .mouse, color: "Orange")))
let felipe = Person()

if let sound = janie.pet?.favoriteToy?.sound { //optional도 chaining해서 쓸 수 있다.
    print("Sound \(sound)")
} else {
    print("No sound.")
}

if let sound = tammy.pet?.favoriteToy?.sound {
    print("Sound \(sound)")
} else {
    print("No sound.")
}

if let sound = felipe.pet?.favoriteToy?.sound { //모든 옵셔널이 통과되어야 값이 할당된다.
    print("Sound \(sound)")
} else {
    print("No sound.")
}

//Map and flatMap
let team = [janie, tammy, felipe]
let petNames = team.map { $0.pet?.name } //for loop를 쓸 수도 있다. //map으로 새로운 array를 생성한다.

for pet in petNames { //warning을 내지만 실행은 된다.
    print(pet)
}

let betterPetNames = team.flatMap{ $0.pet?.name } //flapMap은 map과 비슷하지만 옵셔널을 푼다. 풀수 없는 요소는 버린다. //다차원 배열인 경우 1차원 배열로 만든다.
//따라서 위의 petNames은 [String?]형이지만, betterPetNames은 [String]형이다.
//http://seorenn.blogspot.kr/2015/09/swift-flatmap.html

for pet in betterPetNames {
    print(pet)
}

//Error protocol
class Pastry {
    let flavor: String
    var numberOnHand: Int
    
    init(flavor: String, numberOnHand: Int) {
        self.flavor = flavor
        self.numberOnHand = numberOnHand
    }
}

enum BakeryError: Error { //스위프트에서는 Error 프로토콜을 구현함으로써 Error Handling을 할 수 있다.
    case tooFew(numberOnHand: Int)
    case doNotSell
    case wrongFlavor
}

//Throwing errors
class Bakery {
    var itemsForSale = [
        "Cookie": Pastry(flavor: "ChocolateChip", numberOnHand: 20),
        "PopTart": Pastry(flavor: "WildBerry", numberOnHand: 13),
        "Donut" : Pastry(flavor: "Sprinkles", numberOnHand: 24),
        "HandPie": Pastry(flavor: "Cherry", numberOnHand: 6)
    ]
    
    func orderPastry(item: String, amountRequested: Int, flavor: String) throws -> Int { //오류를 throw하고 직접 처리하지 않는 함수는 throws 키워드를 써줘야 한다.
        guard let pastry = itemsForSale[item] else { //itemsForSale 딕셔너리에 없으면 오류
            throw BakeryError.doNotSell //throw로 오류를 발생시킨다.
        }
        
        guard flavor == pastry.flavor else { //flavor이 일치하지 않으면 오류
            throw BakeryError.wrongFlavor
        }
        
        guard amountRequested <= pastry.numberOnHand else { //재고 수보다 많으면 오류
            throw BakeryError.tooFew(numberOnHand: pastry.numberOnHand)
        }
        
        pastry.numberOnHand -= amountRequested
        
        return pastry.numberOnHand
    }
}

let bakery = Bakery()
//bakery.orderPastry(item: "Albatross", amountRequested: 1, flavor: "AlbatrossFlavor") //오류를 발생시킨다.

//Handling errors
do { //오류를 발생시킬 수 있는 코드는 do 블록 안에 있어야 한다.
    try bakery.orderPastry(item: "Albatross", amountRequested: 1, flavor: "AlbatrossFlavor") //orderPastry함수에서 직접 에러를 처리해 주지 않기때문에 do try로 처리해 줘야 한다.
    //오류를 던지는 위치는 try로 표시되야 한다.
} catch BakeryError.doNotSell {
    print("Sorry, but we don't sell this item")
} catch BakeryError.wrongFlavor {
    print("Sorry, but we don't carry this flavor")
} catch BakeryError.tooFew {
    print("Sorry, we don't have enough items to fulfill your order")
}

//Not looking at the detailed error
let remaining = try? bakery.orderPastry(item: "Albatross", amountRequested: 1, flavor: "AlbatrossFlavor") //오류 세부사항에 신경쓰지 않는다면. try?로 처리할 수 있다.
//이 경우에는 반환값이 함수에서 옵셔널이 아니었더라도 옵셔널이 되고 오류가 발생하게 되면 nil이 반환된다.

//Stoping your program on an error
do {
    try bakery.orderPastry(item: "Cookie", amountRequested: 1, flavor: "ChocolateChip")
} catch {
    fatalError()
} //이와 같이 오류가 발생하지 않는 것이 확실한 경우에는 try!를 쓸 수 있다.

try! bakery.orderPastry(item: "Cookie", amountRequested: 1, flavor:"ChocolateChip") //하지만 try!를 썼는데 오류가 발생할 경우 프로그램이 강제로 종료된다.

//PugBot
enum Direction {
    case left
    case right
    case forward
}

enum PugBotError: Error {
    case invalidMove(found: Direction, expected: Direction)
    case endOfPath
}

class PugBot {
    let name: String
    let correctPath: [Direction]
    private var currentStepInPath = 0
    
    init(name: String, correctPath: [Direction]) {
        self.correctPath = correctPath
        self.name = name
    }
    
    func turnLeft() throws {
        guard currentStepInPath < correctPath.count else { //마지막까지 왔으면 오류를 던지고 종료
            throw PugBotError.endOfPath
        }
        
        let nextDirection = correctPath[currentStepInPath]
        
        guard nextDirection == .left else { //제대로 된 길인 지 확인
            throw PugBotError.invalidMove(found: .left, expected: nextDirection)
        }
        
        currentStepInPath += 1
    }
    
    func turnRight() throws {
        guard currentStepInPath < correctPath.count else {
            throw PugBotError.endOfPath
        }
        
        let nextDirection = correctPath[currentStepInPath]
        
        guard nextDirection == .right else {
            throw PugBotError.invalidMove(found: .right, expected: nextDirection)
        }
        
        currentStepInPath += 1
    }
    
    func moveForward() throws {
        guard currentStepInPath < correctPath.count else {
            throw PugBotError.endOfPath
        }
        
        let nextDirection = correctPath[currentStepInPath]
        
        guard nextDirection == .forward else {
            throw PugBotError.invalidMove(found: .forward, expected: nextDirection)
        }
        
        currentStepInPath += 1
    }
    
    func reset() {
        currentStepInPath = 0
    }
}

let pug = PugBot(name: "Pug", correctPath: [.forward, .left, .forward, .right])

func goHome() throws { //여기서 오류를 처리하지 않고 던지기만 한다
    try pug.moveForward()
    try pug.turnLeft()
    try pug.moveForward()
    try pug.turnRight()
}

do {
    try goHome()
} catch {
    print("PugBot failed to get home.")
}

//Handling multiple errors
func moveSafely(_ movement: () throws -> ()) -> String {
    do {
        try movement()
        return "Completed operation successfully."
    } catch PugBotError.invalidMove(let found, let expected) {
        return "The PugBot was supposed to move \(expected), but moved \(found) instead."
    } catch PugBotError.endOfPath {
        return "The PugBot tried to move past the end of the path."
    } catch { //switch의 default 처럼 써줘야한다. 컴파일러는 이 에러가 PugBotError인지 알 수 없기 때문에.
        return "An unknown error occurred"
    }
}

pug.reset()
moveSafely(goHome)

pug.reset()
moveSafely { //클로저로 쓸 수도 있다.
    try pug.moveForward()
    try pug.turnLeft()
    try pug.moveForward()
    try pug.turnRight()
}

//Rethrows
func perform(times: Int, movement: () throws -> ()) rethrows { //rethrows로 함수 호출자에게 오류처리를 맡긴다. 따라서 이 함수는 전달된 함수(클로저)에 에러를 다시 던진다.
    //파라미터로 전달된 함수(클로저)가 thorows로 선언된 경우에만 사용 가능하다.
    for _ in 1...times {
        try movement()
    } //원래대로 라면 여기서 오류를 처래해야 한다.
}
//https://redsubmarine.github.io/2016/10/21/Swift-3.0-%EC%9D%98-throws,-rethrows-%EC%97%90-%EB%8C%80%ED%95%98%EC%97%AC....html


