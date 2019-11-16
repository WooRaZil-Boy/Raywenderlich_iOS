//: Chapter 11: Properties

import Foundation

struct Car {
    let make: String //문자열 저장 상수
    let color: String
}
//위와 같은 value(make, color)를 property라고 한다. 구조체 Car의 stored property이므로 각 인스턴스에 대한 실제 문자열 값을 저장한다.
//값을 store하지 않고 calculate하는 속성들도 있다. 즉, 메모리에 할당되지 않고, 액세스할 때마다 즉시 계산된다. 이를 computed property라고도 한다.




//Stored properties
//stored property는 일반적으로 흔히 사용하는 속성이다.
struct Contact { //주소록
    var fullName: String
    let emailAddress: String //변경 불가능하게 하려면 let으로 선언하면 된다.
    var relationship = "Friend" //Default values
}
//이 구조체를 반복해 사용하면, 각각의 다른 값을 가진 주소록 배열을 만들 수 있다. fullName, emailAddress는 Stored properties이다.
//초기화 시 각 값을 할당하면, default value를 지정해 주지 않아도 된다. Contact 인스턴스마다 각자 다른 값을 가지게 된다.
//Swift는 구조체에서 정의한 속성으로 자동으로 initializer를 생성한다.
var person = Contact(fullName: "Grace Murray", emailAddress: "grace@navy.mil") //생성자 없이 인스턴스 생성
//각 속성은 dot notation으로 접근한다.
let name = person.fullName
let mail = person.emailAddress
//속성과 속성이 속한 인스턴스가 변수(var)로 선언되어 있으면 값을 할당해 변경할 수 있다.
person.fullName = "Grace Hopper" //var이므로 변경 가능
let grace = person.fullName // Grace Hopper
//속성의 값이 변경되지 않게 하려면, let을 사용하여 상수로 정의하면 된다.
//person.emailAddress = "grace@gmail.com" // Error: cannot assign to a constant
//let으로 선언된 상수 속성의 경우, 인스턴스를 초기화한 이후에는 변경할 수 없다.

//Default values
//초기화될 때 속성 값에 대해 기본값(default value)를 설정해 줄 수 있다.
//Contact 구조체에 relationship 속성을 추가하고, default value를 설정해 준다.
//따로 relationship 매개 변수를 지정해 주지 않는 한, 생성된 모든 Contact의 relationship은 default value인 friend가 된다.
//Swift는 어떤 속성을 기본값으로 설정했는지 확인하고 매개변수를 기본값으로 초기화한다.
person.relationship // friend
var boss = Contact(fullName: "Ray Wenderlich", emailAddress: "ray@raywenderlich.com", relationship: "Boss")
//default value를 설정하고도, 원하는 값을 넣어 생성해 줄 수 있다.




//Computed properties
//Stored property가 일반적이지만, computed 되는 property 도 있다. 값을 반환하기 전에 계산을 수행한다.
//Stored property는 상수(let), 또는 변수(var)이지만, Computed property는 반드시 변수(var)로 선언해야 한다.
//또한, Computed property는 컴파일러가 반환 값을 알아야 하므로, type을 지정해 줘야 한다.
//TV의 크기(대각선)을 측정하는 구조체를 선언한다.
struct TV {
    var height: Double
    var width: Double
    
//    var diagonal: Int { //height와 width는 Double이지만, 일반적으로 inch로 표현하므로 Int로 한다. 형변환 필요.
//        let result = (height * height + width * width).squareRoot().rounded() //피타고라스 정리로 대각선 길이 구한다.
//        //squareRoot()는 루트, rounded()는 반올림
//        return Int(result) //Int로 형변환
//    }
    
    var diagonal: Int { //Computed properties don’t store any values; they simply return values based on calculations
        //구조체의 밖에서 단순히 Stored properties에 접근하듯이 Computed properties를 사용할 수 있다.
        //height와 width는 Double이지만, 일반적으로 inch로 표현하므로 Int로 한다. 형변환 필요.
        //setter와 getter를 함께 써야 하므로 각 코드 블록을 중괄호로 묶는다. 단일 코드 블록은 명시적으로 getter 이다.
        get { //get만 따로 설정해 두면 read only computed property가 된다. //그 때는 get을 쓸 필요 없이 바로 return만 작성
            let result = (height * height + width * width).squareRoot().rounded() //피타고라스 정리로 대각선 길이 구한다.
            //squareRoot()는 루트, rounded()는 반올림
            return Int(result) //Int로 형변환 //read only computed property
        }
        set { //computed property도 setter를 가질 수 있다.
            //computed property가 set될 때, 다른 properties들의 값을 바꿀 수 있다.
            let ratioWidth = 16.0
            let ratioHeight = 9.0
            //computed property는 값을 저장할 곳이 없으므로, 일반적으로 default value를 설정해 준다.
            let ratioDiagonal = (ratioWidth * ratioWidth + ratioHeight * ratioHeight).squareRoot()
            height = Double(newValue) * ratioHeight / ratioDiagonal //newValue 상수를 사용해 전달된 값(diagonal)을 사용한다.
            //newValue(diagonal에 새로 할당된 값)은 Int이므로 형변환이 필요하다.
            width = height * ratioWidth / ratioHeight
            //diagonal에 새 값을 설정하면, 이를 바탕으로 계산해 height와 width를 할당해 준다.
        }
        //setter를 선언한 후에는, height와 width를 직접 설정하는 것 외에도, diagonal를 설정하여 간접적으로 height와 width를 설정할 수 있다.
        //diagonal를 설정하면, 이 값으로 setter가 height와 width를 계산하고 저장한다.
        //setter에는 return이 없으며 다른 stored property만 수정한다.
    }
}
//Computed property는 값이 저장되지 않고 계산에 따라 값을 반환한다. 외부에서 stored property 처럼 computed property에 액세스할 수 있다.
var tv = TV(height: 53.93, width: 95.87)
let size = tv.diagonal // 110
tv.width = tv.height
let diagonal = tv.diagonal // 76
//Computed property는 바뀐 속성 값으로 새 값을 자동으로 계산한다.

//Getter and setter
//위와 같이 return만 할 수 있는 Computed property를 read-only computed property 라 한다. 여기에는 getter 코드 블록만 있다.
//getter 외에도 setter 코드 블록을 설정할 수 있으며, 이런 Computed property를 read-write computed property 라 한다.
//computed property는 값을 저장(store)할 곳이 없으므로, setter는 일반적으로 하나 이상의 stored properties를 간접적으로 사용하게 된다.
//선언된 diagonal를 수정한다. setter와 getter를 함께 써야 하므로 각 코드 블록을 중괄호로 묶는다. 단일 코드 블록은 명시적으로 getter 이다.
//setter를 선언한 후에는, height와 width를 직접 설정하는 것 외에도, diagonal를 설정하여 간접적으로 height와 width를 설정할 수 있다.
//diagonal를 설정하면, 이 값으로 setter가 height와 width를 계산하고 저장한다. setter에는 return이 없으며 다른 stored property만 수정한다.
tv.diagonal = 70
let height = tv.height // 34.32...
let wodth = tv.width // 61.01...




//Type properties
//이전에 사용한 stored property와 computed property는 특정 인스턴스의 속성이다. 각 인스턴스마다 이 속성이 달라질 수 있다.
//하지만, 모든 인스턴스에 공통적인 속성이 필요할 때도 있다. 이런 속성을 type property라 한다.
//레벨 업을 하는 게임을 예시로 구조체를 만든다.
struct Level {
    static var highestLevel = 1 //모든 인스턴스가 동일한 값을 갖는 struct 자체(Level)의 property이다. //type property
    //각 인스턴스에서는 접근할 수 없다. 공통적이거나 동일한 속성값을 어느 인스턴스에서나 접근할 수 있도록 한다.
    let id: Int
    var boss: String
    var unlocked: Bool {
        didSet { //unlocked이 set된 후 실행되는 observer //willSet도 있다.
            //willSet, didSet 옵저버는 stored property에서만 사용할 수 있다.
            //computed property에서 변경 사항을 알아내려면, 단순히 setter에 관련된 코드를 추가하기만 하면 된다.
            //또한, 옵저버는 초기화 중에 해당 속성이 설정되면 호출되지 않는다. 완전히 초기화 된 인스턴스에 새 값이 할당될 때에만 호출된다.
            //let(상수)은 초기화 중에 값이 설정되고 바뀌지 않기 때문에, 옵저버는 var(변수)에 유용하다.
            if unlocked && id > Self.highestLevel {
                //인스턴스 내부에 있더라도, type property에 접근하려면 전체 이름으로 접근해야 한다. ex. Level.highestLevel
                //Level.highestLevel를 Self.highestLevel로 써줄 수도 있다. 구조체의 이름 자체가 변경될 수도 있으므로
                //type의 이름을 직접 써주기 보다는(Level) Self로 써주는 것이 권장된다.
                Self.highestLevel = id
            }
        }
    }
}
let level1 = Level(id: 1, boss: "Chameleon", unlocked: true)
let level2 = Level(id: 2, boss: "Squid", unlocked: false)
let level3 = Level(id: 3, boss: "Chupacabra", unlocked: false)
let level4 = Level(id: 4, boss: "Yeti", unlocked: false)
//유저가 각 레벨을 잠금해제 할 때 type property를 사용하여 게임의 진행 상황을 저장한다.
//let highestLevel = level3.highestLevel  // Error: you can’t access a type property on an instance
//여기서 highLevel은 인스턴스가 아닌 Level 자체의 속성이다. 즉, 인스턴스에서는 이 속성에 액세스할 수 없다.
let highestLevel = Level.highestLevel // 1 //type property는 struct 자체에서 접근해야 한다.
//type property를 사용하면, 앱 또는 알고리즘 코드 어디에서나 동일한 stored property 값에 접근할 수 있다.




//Property observers
//위의 Level 예에서, 유저가 새 레벨을 잠금해제하면, 자동으로 highestLevel을 설정해 주면 좋다.
//이를 구현하기 위해, 속성의 변경 사항을 observe할 수 있는 property observer가 있다.
//willSet 옵저버는 속성이 변경되려 할 때 호출되고, didSet 옵저버는 속성이 변경된 후에 호출된다.
//getter와 setter 구문과 유사하게 사용한다. Level 구조체에 unlocked 속성을 만들고 옵저버를 추가한다.
//인스턴스 내부에 있더라도, type property에 접근하려면 전체 이름으로 접근해야 한다. ex. Level.highestLevel
//Level.highestLevel를 Self.highestLevel로 써줄 수도 있다.
//구조체의 이름 자체가 변경될 수도 있으므로 type의 이름을 직접 써주기 보다는(Level) Self로 써주는 것이 권장된다.
//willSet, didSet 옵저버는 stored property에서만 사용할 수 있다.
//computed property에서 변경 사항을 알아내려면, 단순히 setter에 관련된 코드를 추가하기만 하면 된다.
//또한, 옵저버는 초기화 중에 해당 속성이 설정되면 호출되지 않는다. 완전히 초기화 된 인스턴스에 새 값이 할당될 때에만 호출된다.
//let(상수)은 초기화 중에 값이 설정되고 바뀌지 않기 때문에, 옵저버는 var(변수)에 유용하다.

//Limiting a variable
//property observer를 사용해, 변수의 값을 제한할 수도 있다. 최대 전류가 제한되는 전구의 예시를 구조체로 구현한다.
struct LightBulb {
    static let maxCurrent = 40 //type property
    var current = 0 {
        didSet {
            if current > LightBulb.maxCurrent { //최대값을 초과하면, 이전의 값으로 다시 설정해 준다.
                print("""
                        Current is too high,
                        falling back to previous setting.
                        """)
                current = oldValue //set의 newValue처럼 didSet에서 oldValue를 사용할 수 있다.
            }
        }
    }
}
//set의 newValue처럼 didSet에서 oldValue를 사용할 수 있다. 이를 사용해 변수의 값을 제한할 수 있다.
var light = LightBulb()
light.current = 50
var current = light.current // 0 //maxCurrent를 초과했으므로, 이전 값으로 설정된다.
light.current = 40
current = light.current // 40
//property observer를 getter / setter와 혼동해선 안 된다.
//stored property에는 didSet 또는 willSet 옵저버가 있을 수 있다.
//computed property에는 getter와 setter(optional)가 있다.
//구문은 비슷하지만 완전히 다른 개념이다.




//Lazy properties
//계산하는 데 시간이 걸리는 속성이 있을 때, 실제 속성이 필요할 때 이를 할당해 속도 저하를 방지할 수 있다(사진 다운로드나 긴 계산 시 유용).
//원주율을 계산하는 구조체를 작성한다.
struct Circle {
    lazy var pi = { //stored property //lazy는 반드시 var이어야 한다.
        ((4.0 * atan(1.0 / 5.0)) - atan(1.0 / 239.0)) * 4.0
    }()
    //{}() 패턴은 중괄호 안의 코드를 즉시 실행한다. 하지만, 여기서는 lazy로 속성이 설정되었기 때문에 값이 액세스 될 때 실행된다.
    var radius = 0.0
    var circumference: Double { //computed property
        mutating get { //pi의 값이 변경되므로, circumference의 getter는 mutating 키워드를 추가해 줘야 한다.
            //기본적으로 구조체와 열거형은 값타입이므로 function이 property의 값을 바꿀 수 없다.
            //따라서 mutating이 필요하다. mutating으로 선언되어도 let으로 정의한 값은 바꿀 수 없다.
            pi * radius * 2
        }
    }
    
    init(radius: Double) {
        //pi는 stored property 이므로, radius만 사용해 초기화하려면, custom initializer가 필요하다.
        //struct의 automatic initializer는 모든 properties를 초기화해야 한다.
        //custom initializer를 사용하면 원하는 몇 개의 properties로만 초기화할 수 있다(나머지는 default).
        self.radius = radius
    }
}
var circle = Circle(radius: 5) // got a circle, pi has not been run
//Circle 인스턴스를 생성하지만, pi는 아직 계산하지 않는다.
//pi는 실제 속성이 필요할 때에 값이 할당 된다. 여기서는 둘레(circumference)를 계산할 때 pi가 할당 된다.
let circumference = circle.circumference // 31.42 // also, pi now has a value
//pi에 값이 할당 된다.
//{}() 패턴은 중괄호 안의 코드를 즉시 실행한다. 하지만, 여기서는 lazy로 속성이 설정되었기 때문에 값이 액세스 될 때 실행된다.
//circumference는 computed property이므로 액세스할 때마다 값이 계산된다.
//circumference는 pi * radius * 2 이므로, circumference의 값은 radius가 바뀔될 때 마다 변경된다.
//하지만, pi는 한 번만 값을 구하면, 그 값은 변하지 않는다.
//lazy property는 반드시 변수(var)로 선언되어야 한다.
//처음 초기화 시에, lazy property는 값이 없고, 이후에 코드에서 해당 속성에 액세스하면 값이 계산된다.
//따라서 값이 한 번 이상 바뀌게 되므로 var을 사용해야 한다.
//여기서 주의해야할 두 가지는 다음과 같다.
// • pi의 값이 변경되므로, circumference의 getter는 mutating 키워드를 추가해 줘야 한다.
// • pi는 stored property 이므로, radius만 사용하려면, custom initializer가 필요하다.
