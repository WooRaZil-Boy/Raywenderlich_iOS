/*:
 [Previous](@previous)&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Next](@next)
 
 # Builder
 - - - - - - - - - -
 ![Builder Diagram](Builder_Diagram.png)
 
 The builder pattern allows complex objects to be created step-by-step instead of all-at-once via a large initializer.
 
 The builder pattern involves three parts:
 
 (1) The **product** is the complex object to be created.
 
 (2) The **builder** accepts inputs step-by-step and ultimately creates the product.
 
 (3) The **director** supplies the builder with step-by-step inputs and requests the builder create the product once everything has been provided.
 
 ## Code Example
 */
//Builder Pattern을 사용하면, 한 번에 모든 input을 요구하는 복잡한 생성자(initializer) 대신
//단계별로 input을 제공하여 복잡한 객체를 만들 수 있다.
//Builder Pattern는 세 가지 파트가 있다.
// 1. director : input을 받고, builder를 조정한다(coordinate).
//  일반적으로 ViewController 이거나, ViewController의 Helper Class 이다.
// 2. product : 생성될 복잡한 객체이다. 유형에 따라 struct 또는 class가 될 수 있다.
//  일반적으로 product는 Model 이지만, 구성에 따라 모든 유형이 product가 될 수 있다.
// 3. builder : 단계별 input을 수용하고, product 생성을 처리한다.
//  일반적으로 builder는 class 이므로, reference를 사용해 재사용할 수 있다.




//When should you use it?
//일련의 단계를 거쳐 복잡한 객체를 생성려는 경우에 builder pattern을 사용한다.
//builder pattern은 product에 여러 input이 필요한 경우 특히 효과적이다.
//builder는 inputs을 사용하여 product를 생성하는 방법을 추상화하고,
//director가 생성하기 원하는 어떤 순서든 받아들인다.
//ex. hamburger builder에 패티, 토핑, 소스와 같은 inputs이 있다.
//여기에서 product는 hamburger model이 될 수 있다.
//director는 햄버거 제조법을 알고 있는 employee 객체이거나,
//user의 input을 받는 ViewController일 수 있다.
//hamburger builder는 어떤 순서든 패티, 토핑, 소스를 받아, 요청에 따라 hamburger를 만든다.




//Playground example
//Builder Pattern은 복잡한 product를 만들기 때문에 Creational Pattern 중의 하나이다.

import Foundation

//MARK: - Product
public struct Hamburger {
    public let meat: Meat
    public let sauce: Sauces
    public let toppings: Toppings
}
//inputs(Meat, Sauce, Topping)에 대한 속성이 있는 Hamburger를 정의한다.
//각 속성은 let으로 선언된 상수이므로 변경할 수 없다.

extension Hamburger: CustomStringConvertible {
    public var description: String {
        return meat.rawValue + " burger"
    }
}
//CustomStringConvertible를 구현해, print 할 수 있도록 한다.

public enum Meat: String {
    case beef
    case chicken
    case kitten
    case tofu
}
//열거형 선언. 각 Hamburger는 정확히 하나의 Meat를 선택해야 한다.

public struct Sauces: OptionSet {
    public static let mayonnaise = Sauces(rawValue: 1 << 0) //0001
    public static let mustard = Sauces(rawValue: 1 << 1)    //0010
    public static let ketchup = Sauces(rawValue: 1 << 2)    //0100
    public static let secret = Sauces(rawValue: 1 << 3)     //1000
    //단일 비트로 각각의 값을 표현한다(Bitmask).
    
    public let rawValue: Int
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}
//OptionSet으로 정의하면, 여러 구성 요소를 함께 결합할 수 있다.
//OptionSet 프로토콜은 각 비트들이 집합의 요소를 표현하는 비트 집합 타입을 표현한다.
//이 프로토콜을 구현한 사용자 정의 타입에선 요소 검사(해당 요소가 집합에 속하는지),
//합집합, 교집합 연산과 같은 집한 연산들을 수행할 수 있다.
//OptionSet은 타입 선언 부분에 rawValue를 포함시켜야 한다.
//rawValue 속성은 반드시 FixedWidthInteger 프로토콜을 따르고 있는 타입(Int, UInt8 등)이어야 한다.
//다음으로는 정적(static) 변수로 고유한 2의 거듭제곱 값(1, 2, 4, 8, …)을 rawValue로 갖는 옵션들을 생성한다.
//이렇게 2의 거듭제곱 값을 rawValue로 가져야 각각의 옵션들이 단일 비트로 표현 가능하다.
//Enum은 해당 타입의 case를 하나만 나타낼 수 있지만, OptionSet은 여러 case를 하나의 변수로 표현할 수 있다.
//Enum에서 이를 표현하려면, 여러 case에 해당하는 타입을 배열과 같은 Collection으로 표현해야 한다.
//OptionSet은 여러 case를 하나의 변수로 담을 수 있기 때문에 각각의 case는 유일해야 한다.
//따라서 보통 간단하게 비트로 표현한다. 위의 Sauces 에서, 마요네즈와 머스타드 소스를 사용한다면
//.mayonnaise(0001) + .mustard(0010) = (0011)이 된다. 모든 case의 값이 2의 거듭제곱이므로
//0011은 0001과 0010의 조합밖에 나올 수 없다. 이렇게 비트마스크로 값을 표현하면 리스트보다 훨씬 간단하게 표현할 수 있다.
//또한 OptionSet은 집합연산(intersection, union, subtracting, contains 등)을 수행할 수 있다.
//OptionSet을 사용하면, 여러 case를 포함하는 상황에서 적은 코드로 각각의 상황에 대응할 수 있다.
//https://ehdrjsdlzzzz.github.io/2019/03/23/OptionSet/

public struct Toppings: OptionSet {
    public static let cheese = Toppings(rawValue: 1 << 0)
    public static let lettuce = Toppings(rawValue: 1 << 1)
    public static let pickles = Toppings(rawValue: 1 << 2)
    public static let tomatoes = Toppings(rawValue: 1 << 3)
    
    public let rawValue: Int
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

//MARK: - Builder
public class HamburgerBuilder {
    public enum Error: Swift.Error { //오류 유형 선언
        case soldOut
    }
    
    public private(set) var meat: Meat = .beef
    public private(set) var sauces: Sauces = []
    public private(set) var toppings: Toppings = []
    //Hamburger에서 사용될 inputs을 정의한다.
    //private(set)을 설정하면, 해당 블럭 내부에서만 변경 가능하다. 외부에서는 read-only
    
    private var soldOutMeats: [Meat] = [.kitten] //매진된 패티
    //해당 input이 매진인 경우, setMeat(_ :)가 호출될 때마다 오류가 발생한다.
    
    public func addSauces(_ sauce: Sauces) {
        sauces.insert(sauce)
    }
    
    public func removeSauces(_ sauce: Sauces) {
        sauces.remove(sauce)
    }
    
    public func addToppings(_ topping: Toppings) {
        topping.insert(topping)
    }
    
    public func removeToppings(_ topping: Toppings) {
        topping.remove(topping)
    }
    
    public func setMeat(_ meat: Meat) throws {
        guard isAvailable(meat) else { throw Error.soldOut }
        self.meat = meat
    }
    
    public func isAvailable(_ meat: Meat) -> Bool {
        return !soldOutMeats.contains(meat)
    }
    
    //private(set)을 사용해 속성을 선언했기 때문에, 해당 속성들을 변경하는 공용 메서드를 추가해 준다.
    
    public func build() -> Hamburger {
        return Hamburger(meat: meat, sauce: sauces, toppings: toppings)
    }
    //Hamburger 생성
}
//private(set)을 사용했기 때문에, public setter method를 사용해 속성을 변경해야 한다.
//이를 활용해 속성을 설정하기 전에 유효성 검사를 수행할 수 있다.
//ex. meat를 설정하기 전에 남은 패티가 있는지 확인한다.
//유효성 검사코드를 추가해 준다.

//MARK: - Director
public class Employee {
    public func createCombo1() throws -> Hamburger {
        let builder = HamburgerBuilder()
        try builder.setMeat(.beef)
        builder.addSauces(.secret)
        builder.addToppings([.lettuce, .tomatoes, .pickles])
        return builder.build()
    }
    
    public func createKittenSpecial() throws -> Hamburger {
        let builder = HamburgerBuilder()
        try builder.setMeat(.kitten)
        builder.addSauces(.mustard)
        builder.addToppings([.lettuce, .tomatoes])
        return builder.build()
    }
}
//Employee는 Hamburger를 만드는 방법을 알고 있다.

//MARK: - Example
let burgerFlipper = Employee()

if let combo1 = try? burgerFlipper.createCombo1() {
    print("Nom nom " + combo1.description)
}
// Nom nom beef burger

if let kittenBurger = try? burgerFlipper.createKittenSpecial() {
    print("Nom nom nom " + kittenBurger.description)
} else {
    print("Sorry, no kitten burgers here... :[")
}
// Sorry, no kitten burgers here... :[
//soldOutMeats에 포함되어 있으므로 오류가 난다.




//What should you be careful about?
//Builder Pattern은 일련의 단계를 사용하여 여러 input이 필요한 복잡한 product를 생성하는데 적합하다.
//product에 여러 개의 input이 없거나, 단계별로 생성할 필요가 없는 경우 builder Pattern 사용을 재고해 봐야한다.
//이런 경우에는 생성자(initializer)를 사용하는 것이 더 나을 수 있다.
