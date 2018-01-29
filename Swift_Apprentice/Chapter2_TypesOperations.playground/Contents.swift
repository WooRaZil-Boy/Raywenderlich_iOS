//: Chapter 2: Types & Operations

//Type conversion

var integer: Int = 100
var decimal: Double = 12.5

integer = Int(decimal) //타입 변환

let hourlyRate: Double = 19.5
let hoursWorked: Int = 10
let totalCost: Double = hourlyRate * Double(hoursWorked) //타입을 맞춰줘야 한다.

//Type inference

let typeInferredInt = 42 //정수는 타입을 지정해 주지 않아도 기본으로 Int
let typeInferredDouble = 3.14159 //소수는 타입을 지정해 주지 않아도 기본으로 Double

let actuallyDouble1 = Double(3)
let actuallyDouble2: Double = 3
let actuallyDouble3 = 3 as Double //타입을 지정하는 방법은 3가지가 있다.

//Characters and strings
let characterA: Character = "a"
let characterDog: Character = "🐶"
let stringDog: String = "Dog" //String이 기본이므로 let stringDog = "Dog"로 써도 된다.

//Concatenation
var message = "Hello" + " my name is"
let name = "Matt"
message += name //"Hello my name is Matt"

let exclamationMark: Character = "!"
message += String(exclamationMark) //"Hello my name is Matt!" //타입 맞춰줘야 한다.

//Interpolation
message = "Hello my name is \(name)!" //"Hello my name is Matt!"

let oneThird = 1.0 / 3.0
let oneThirdLongString = "One third is \(oneThird) as a decimal."

//Multi-line strings
let bigString = """
You can have a string
that contains multiple
lines
by
doing this.
"""
print(bigString)

//Tuples
let coordinates: (Int, Int) = (2, 3) //let coordinates = (2, 3)
let coordinatesDoubles = (2.1, 3.5)
let coordinatesMixed = (2.1, 3)

let x1 = coordinates.0
let y1 = coordinates.1

let coordinatesNamed = (x:2, y:3)
let x2 = coordinatesNamed.x
let y2 = coordinatesNamed.y

let coordinates3D = (x: 2, y: 3, z: 1)
let (x4, y4, _) = coordinates3D //불필요한 부분은 언더스코어로 제외할 수 있다.





