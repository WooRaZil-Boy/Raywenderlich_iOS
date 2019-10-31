//Type conversion
var integer: Int = 100
var decimal: Double = 12.5
//integer = decimal //Cannot assign value of type 'Double' to type 'Int'
//어떤 프로그래밍 언어들은 위와 같은 변환이 가능하지만, 스위프트는 형 변환에 엄격하다. 위와 같은 자동 변환은 버그와 성능 저하의 주요 원인이 된다.
integer = Int(decimal)
//Swift에서는 단순히 할당하는 대신 유형을 변환한다고 명시해야 한다. 이 경우에는 Double이 Int로 변환되면서 12로 되어 값이 손실됨에 유의해야 한다.

//Operators with mixed types
let hourlyRate: Double = 19.5
let hoursWorked: Int = 10
//let totalCost: Double = hourlyRate * hoursWorked //Binary operator '*' cannot be applied to operands of type 'Double' and 'Int'
//산술 연산자들은 혼합된 type을 계산할 수 없다(산술 연산자 외에 혼합된 type 연산이 가능한 다른 연산자들이 있다).
let totalCost: Double = hourlyRate * Double(hoursWorked)
//Int로 변환하여 계산할 수도 있지만, 값이 손실된다.

//Type inference
//Swift 컴파일러는 Type을 추론할 수 있다.
let typeInferredInt = 42 //Int
let typeInferredDouble = 3.14159 //Double
//Option 키를 누른 상태에서 변수 또는 상수의 이름을 클릭하면, Type을 확인해 볼 수 있다.
//모든 Type을 컴파일러가 추론할 수 있는 것은 아니다. Custom class 등은 추론할 수 없다.
let wantADouble = 3 //Int
let actuallyDouble = Double(3) //Double
let actuallyDouble1: Double = 3 //Double
let actuallyDouble2 = 3 as Double //Double
//이렇게 명시적으로 선언하면, 3.0인 Double이 된다.
//위에서 보듯이 3이라는 literal은 Int나 Float, Double로 쓸 수 있고 자체에는 Type이 없다. Swift가 일반적인 Type을 추론해서 할당할 뿐이다.
//그러나 literal 3.0은 Float이나 Double이 될뿐, Int가 될 수 없다.




//Strings
//대부분의 컴퓨터 프로그래밍 언어는 문자열을 하나의 고유한 데이터 유형으로 두고 있다.

//How computers represent strings
//컴퓨터는 문자열을 개별 문자의 모음(character set)중 하나로 판단한다. 프로그래밍 언어는 모든 코드를 원시 숫자로 변환할 수 있다.
//키보드의 문자를 입력하면, 실제로는 문자에 매핑된 개별 문자의 숫자가 전달되고, 응용 프로그램은 그 숫자를 문자로 변환하여 보여준다.

//Unicode
//공통 문자 집합의 표준. p.62. emoji도 유니코드에 있다("emoji"는 일본어로, "e"는 그림을 의미하고 "moji"는 문자를 의미한다).
//한자나 이모지와 같은 Unicode는 영어와 달리 매우 큰 code point를 가지지만, 하나의 character로 간주한다.




//Strings in Swift
//스위프트에는 Character와 String이 있다.

//Characters and strings
//Character Type은 단일 문자를 저장한다.
let characterA: Character = "a"
let characterDog: Character = "🐶" //이모지도 저장할 수 있다.
//String Type은 다중 문자열을 저장한다.
let stringDog: String = "Dog" //이렇게 문자열을 직접 할당한 변수(상수)를 Literal 이라고 한다. //Type inference를 적용해 Type 없어 선언해 줄 수 있다.
//Swift에서는 단일 문자를 할당하더라도, Type inference에서는 String을 할당한다. Character로 사용하려면 명시적으로 지정해 줘야 한다.

//Concatenation
//Swift에서 + 연산자로 문자열을 합칠 수 있다.
var message = "Hello" + " my name is "
let name = "Matt"
message += name // "Hello my name is Matt" //수정하려면 변수로 선언해야 한다.
let exclamationMark: Character = "!"
message += String(exclamationMark) // "Hello my name is Matt!"
//String에 Character을 추가해 줄 수도 있다. 하지만, Swift는 Type에 엄격하기 때문에 Character를 형 변환해줘야 한다.

//Interpolation
//보간(interpolation)을 사용해 문자열을 만들 수도 있다. Swift의 특수 구문으로 문자열을 쉽게 읽을 수 있게 만든다.
message = "Hello my name is \(name)!" // "Hello my name is Matt!"
//문자열의 특정 부분을 해당 값으로 대체한다. 이전 코드와 비교해 훨씬 읽기 쉽다.
let oneThird = 1.0 / 3.0
let oneThirdLongString = "One third is \(oneThird) as a decimal."
//One third is 0.3333333333333333 as a decimal.
//다른 Type을 사용해 간단히 String을 만들 수 있다.
//Double을 Interpolation에 적용하면, 문자열의 정밀도를 제어할 수 없다.

//Multi-line strings
//코드에 매우 긴 문자열을 넣어야 할 때 유용하게 사용할 수 있다.
let bigString = """
    You can have a string
    that contains multiple
    lines
    by
    doing this.
    """
print(bigString)
//세 개의 큰 따옴표로 multi-line string을 만든다. 첫 줄과 마지막 줄은 문자열의 일부가 되지 않는다. 들여쓰기로 String을 만들 때 유용하다.




//Tuples
//좌표와 같이 쌍으로 된 데이터를 나타낼 때, 튜플을 사용해 간단히 표현할 수 있다. 튜플은 여러 유형의 둘 이상의 값으로 구성된 데이터를 나타내는 유형이다.
//튜플에 포함되는 값의 수는 제한이 없다. 원하는 만큼 많은 값을 가질 수 있다.
let coordinates: (Int, Int) = (2, 3) //Type은 (Int, Int)가 된다. //let coordinates = (2, 3) //튜플도 Type inference로 간단히 쓸 수 있다.
 let coordinatesDoubles = (2.1, 3.5) //(Double, Double)
let coordinatesMixed = (2.1, 3) //Type은 (Double, Int)가 된다. //튜플을 구성하는 유형을 혼합해서 선언해 줄 수도 있다.
//튜플의 데이터에는 .(dot)을 이용해 접근한다.
let x1 = coordinates.0 //zero indexing //컴퓨터 프로그래밍에서 index는 0으로 시작하는 것이 일반적이다.
let y1 = coordinates.1
//하지만 이와 같이 접근하면, 인덱스 0의 값이 x 좌표인지 즉시 알 수 없다. 이를 피하기 위해 튜플 내 변수 이름을 지정하는 것이 좋다.
let coordinatesNamed = (x: 2, y: 3) //Type은 (x: Int, y: Int)
//이름을 지정했으면 그 이름을 사용해 데이터에 접근할 수 있다.
let x2 = coordinatesNamed.x
let y2 = coordinatesNamed.y
//튜플의 여러 부분에 액세스하려는 다음과 같이 더 쉽게 만들 수 있다.
let coordinates3D = (x: 2, y: 3, z: 1)
let (x3, y3, z3) = coordinates3D
//새로운 상수 x3, y3, z3을 선언하고 튜플의 각 부분을 차례대로 할당한다.
//let coordinates3D = (x: 2, y: 3, z: 1)
//let x3 = coordinates3D.x
//let y3 = coordinates3D.y
//let z3 = coordinates3D.z
//이를 풀어 쓴 것과 같다.
//튜플의 특정 요소를 무시하려면, under score로 선언해 줄 수 있다(wild card).
let (x4, y4, _) = coordinates3D
//x4와, y4만 선언한다.




//A whole lot of number types
//Int는 대부분의 현대 컴퓨터에서 64비트로 표현된다(구형 시스템에서는 32비트 였다). Swift에서는 각 비트에 맞춘 Type을 선언해 줄 수 있다.
//ex. Int8, Int16, Int32, Int64. 각각 1, 2, 4, 8 바이트의 공간을 사용한다.
//이러한 Type에서 1비트는 부호를 나타내는 데 사용한다(signed). 음수가 아닌 양의 값만 처리하는 경우, 부호가 없는 Unsigned 유형을 사용할 수 있다.
//음수 값을 표현할 수 없지만, 추가적인 1비트를 값의 표현에 사용하여 표현할 수 있는 양의 범위가 2배로 늘어난다.
//ex. UInt8, UInt16, UInt32, UInt64
//코드가 다른 소프트웨어와 상호작용해야 할 때나, 메모리를 최적화해야 되는 특수한 경우를 제외한 대부분의 경우에는 Int를 사용하는 것을 권장한다. 각 유형과 그 크기에 대한 정보는 p.70
//Double보다 작은 범위와 정밀도를 가진 Float 형이 있지만, 최신 하드웨어는 Double에 최적화되어 있기 때문에 Double을 사용하는 것을 권장한다. p.70
let a: Int16 = 12
let b: UInt8 = 255
let c: Int32 = -100000
let answer = Int(a) + Int(b) + Int(c)  // answer is an Int




//Type aliases
//Swift에서는 별칭을 사용해 커스텀 Type을 생성할 수 있다. 더 적절한 Type 이름을 지정해 줄 수 있다.
typealias Animal = String //Animal이라는 새 Type을 만든다. 컴파일러는 단순히 String과 같은 Type으로 취급한다.
let myPet: Animal = "Dog"
//Type이 복잡해 지면, 별칭을 사용해 간단하고 명시적인 이름을 지정할 수 있다.
typealias Coordinates = (Int, Int)
let xy: Coordinates = (2, 4) //(Int, Int)




//A peek behind the curtains: Protocols
//Swift의 훌륭한 특징 중 하나는 Protocol을 사용하여 Type의 공통성을 유지한다는 것이다. p.71
//Swift는 최초의 Protocol-based language 이다. Protocol을 이해하면, 다른 언어에서는 불가능한 방식으로 시스템을 활용할 수 있다.
