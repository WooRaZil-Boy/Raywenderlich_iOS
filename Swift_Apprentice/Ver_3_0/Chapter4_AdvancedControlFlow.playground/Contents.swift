//: Chapter 4: Advanced Control Flow

//Countable Ranges
let closedRange = 0...5 //0, 1, 2, 3, 4, 5
let halfOpenRange = 0..<5 //0, 1, 2, 3, 4

//For loops
let count = 10
var sum = 0
for i in  1...count {
    sum += i
}

sum = 1
var lastSum = 0

for _ in 0..<count { //index를 사용하지 않는 경우 언더스코어로 생략가능
    let temp = sum
    sum = sum + lastSum
    lastSum = temp
}


sum = 0
for i in 1...count where i % 2 == 1 { //where을 써서 조건을 간단하게 표현할 수 있다. //stride(from: , to: , by: )로 표현할 수도 있다.
    sum += i
}

sum = 0
for row in 0..<8 {
    if row % 2 == 0 {
        continue
    }
    
    for column in 0..<8 {
        sum += row * column
    }
}

sum = 0
rowLoop: for row in 0..<8 { //labeled statements
    columnLoop: for column in 0..<8 {
        if row == column {
            continue rowLoop //labeled statements //사실 이 경우에서는 break와 똑같다.
        }
        sum += row * column
    }
}

//Switch statements
let number = 10
switch number {
case 0:
    print("Zero")
default:
    print("Non-zero")
}

switch number {
case 10:
    print("It's ten!")
default:
    break //아무런 것도 하지 않을 때는 break를 써준다.
}

let string = "Dog" //Bool이나 Int가 아니어도 switch에서 사용할 수 있다.
switch string {
case "Cat", "Dog": //여러 경우
    print("Animal is a house pet.")
default:
    print("Animal is not a house pet.")
}

//Advanced switch statements
let hourOfDay = 12
let timeOfDay: String //상수로 선언 후 대입.
switch hourOfDay {
case 0, 1, 2, 3, 4, 5:
    timeOfDay = "Early morning"
case 6, 7, 8, 9, 10, 11:
    timeOfDay = "Morning"
case 12, 13, 14, 15, 16:
    timeOfDay = "Afternoon"
case 17, 18, 19:
    timeOfDay = "Evening"
case 20, 21, 22, 23:
    timeOfDay = "Late evening"
default:
    timeOfDay = "INVALID HOUR!"
}
print(timeOfDay)
//다른 언어에서와 달리 해당하는 하나의 case만 실행한다. - 스위프트에서는 switch가 if보다 더 깔끔하고 직관적인 경우가 많다.

let timeOfDay1: String
switch hourOfDay { //range로 만들 수도 있다.
case 0...5:
    timeOfDay1 = "Early morning"
case 6...11:
    timeOfDay1 = "Morning"
case 12...16:
    timeOfDay1 = "Afternoon"
case 17...19:
    timeOfDay1 = "Evening"
case 20..<24:
    timeOfDay1 = "Late evening"
default:
    timeOfDay1 = "INVALID HOUR!"
}

switch number {
case let x where x % 2 == 0: //let where. 특정 조건이. true인 경우에만 바인딩한다. //x는 여기서는 단순히 number의 다른 이름
    print("Even")
default:
    print("Odd")
}

switch number {
case _ where number % 2 == 0: //언더 스코어를 사용할 수도 있다.
    print("Even")
default:
    print("Odd")
}

//Partial matching
let coordinates = (x: 3, y: 2, z: 5)

switch coordinates {
case (0, 0, 0):
    print("Origin")
case (_, 0, 0):
    print("On the x-axis.")
case (0, _, 0):
    print("On the y-axis.")
case (0, 0, _):
    print("On the z-axis.")
default:
    print("Somewhere in space")
}

switch coordinates { //특정 경우 바인딩
case (0, 0, 0):
    print("Origin")
case (let x, 0, 0):
    print("On the x-axis at x = \(x)")
case (0, let y, 0):
    print("On the y-axis at y = \(y)")
case (0, 0, let z):
    print("On the z-axis at z = \(z)")
case let (x, y, z): //default를 대신한 case //same as (let x, let y, let z)
    print("Somewhere in space at x = \(x), y = \(y), z = \(z)")
}

switch coordinates {
case let (x, y, _) where y == x:
    print("Along the y = x line.")
case let (x, y, _) where y == x * x:
    print("Along the y = x^2 line.")
default:
    break
}





