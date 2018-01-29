//: Chapter 11: Properties

import Foundation

//Stored properties
struct Contact {
    var fullName: String
    let emailAddress: String //변경 불가능하게 하려면 let으로 선언하면 된다.
    var type = "Friend" //Default values
}

var person = Contact(fullName: "Grace Murray", emailAddress: "grace@navy.mil", type: "Friend") //생성자 없이 인스턴스 생성가능
//automatic initializer가 default value을 알아채지 못하기 때문에 사용자 정의로 initializer를 만들지 않으면 default를 설정했더라도 각 속성에 값을 넣어야 한다.
let name = person.fullName
let mail = person.emailAddress

person.fullName = "Grace Hopper" //var이므로 변경 가능
let grace = person.fullName

//Computed properties
//값을 계산해서 리턴한다. Computed properties는 반드시 var로 선언해야 하고 타입을 선언해 줘야 한다.

struct TV {
    var height: Double
    var width: Double
    
    var diagonal: Int {//Computed properties don’t store any values; they simply return values based on calculations
        //구조체의 밖에서 단순히 Stored properties에 접근하듯이 Computed properties를 사용할 수 있다.
        get { //get만 따로 설정해 두면 read only computed property가 된다. //그 때는 get을 쓸 필요 없이 바로 return만 작성
            let result = (height * height + width * width).squareRoot().rounded() //반올림
            return Int(result) //형변환 //read only computed property
        }
        set { //computed properties도 setter를 가질 수 있다.
            //computed properties가 set될 때, 다른 properties들의 값을 바꿀 수 있다.
            let ratioWidth = 16.0
            let ratioHeight = 9.0
            let ratioDiagonal = (ratioWidth * ratioWidth + ratioHeight * ratioHeight).squareRoot()
            
            height = Double(newValue) * ratioHeight / ratioDiagonal //newValue 상수를 사용하면 전달된 값을 사용할 수 있다.
            width = height * ratioWidth / ratioHeight
        }
    }
}

var tv = TV(height: 53.93, width: 95.87)
let size = tv.diagonal

tv.width = tv.height
let diagonal = tv.diagonal

tv.diagonal = 70
let height = tv.height
let wodth = tv.width

//Type properties
struct Level {
    static var highestLevel = 1 //struct 자체의 property이다. 각 인스턴스에서는 접근할 수 없다. //type property
    //공통적이거나 동일한 속성값을 어디에서나 접근할 수 있도록 해준다.
    let id: Int
    var boss: String
    var unlocked: Bool {
        didSet { //unlocked이 set된 후 실행되는 observer //willSet도 있다.
            //Observer는 오직 stored properties에서만 사용할 수 있다.
            //computed properties에서 비슷한 설정을 하고 싶다면 setter를 사용하면 된다.
            //이니셜라이저에서 시행되지 않고, 초기화된 인스턴스에 새 값이 할당될 때에만 시행된다.
            //let은 초기화 중에 값이 설정되고 바뀌지 않기 때문에, 옵저버는 var에 유용하다.
            if unlocked && id > Level.highestLevel {
                Level.highestLevel = id
            }
        }
    }
}

let level1 = Level(id: 1, boss: "Chameleon", unlocked: true)
let level2 = Level(id: 2, boss: "Squid", unlocked: false)
let level3 = Level(id: 3, boss: "Chupacabra", unlocked: false)
let level4 = Level(id: 4, boss: "Yeti", unlocked: false)

let highestLevel = Level.highestLevel //type property는 struct 자체에서 접근해야 한다.

//Limiting a variable
struct LightBulb {
    static let maxCurrent = 40 //type property
    var current = 0 {
        didSet {
            if current > LightBulb.maxCurrent {
                print("Current too high, falling back to previous setting")
                current = oldValue //set의 newValue처럼 didSet에서 oldValue를 사용할 수 있다.
            }
        }
    }
}

var light = LightBulb()
light.current = 50
var current = light.current //0

light.current = 40
current = light.current //40

// A stored property can have a didSet and/or a willSet observer. A computed property has a getter and optionally a setter.

//Lazy properties
//계산하는 데 시간이 걸리는 속성을 사용할 때 할당하는 방법(사진 다운로드나 긴 계산 시 유용)
struct Circle {
    lazy var pi = { //stored property //lazy는 반드시 var이어야 한다.
        return ((4.0 * atan(1.0 / 5.0)) - atan(1.0 / 239.0)) * 4.0
    }() //클로저. trailing. //trailing closure를 실행한다. 단, lazy이므로 값이 엑서스될 때 실행된다.
    var radius = 0.0
    var circumference: Double { //computed property
        mutating get { //pi의 값이 변경되므로 mutating이 되어야 한다. //기본적으로 구조체와 열거형은 값타입이므로 function이 property의 값을 바꿀 수 없다. 따라서 mutating이 필요. mutating이 선언되어도 let으로 정의한 값은 바꿀 수 없다.
            return pi * radius * 2
        }
    }
    init(radius: Double) { //automatic initializer는 모든 properties를 초기화해야 한다.
        //이 custom initializer는 몇개의 properties만 초기화할 수 있다. (나머지는 default)
        self.radius = radius
    }
}

var circle = Circle(radius: 5) // got a circle, pi has not been run
let circumference = circle.circumference // 31.42 // also, pi now has a value
