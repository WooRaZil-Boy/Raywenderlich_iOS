//Countable ranges
//Countable Range 유형을 사용하면 셀 수 있는 정수 시퀀스를 나타낼 수 있다.
let closedRange = 0...5 //countable closed range (0, 1, 2, 3, 4, 5)
//세 개의 점(...)은 범위가 닫혀 있음을 나타낸다.
let halfOpenRange = 0..<5 //countable half-open range (0, 1, 2, 3, 4)
//이는 범위가 열려 있음을 나타낸다.

//A Random Interlude
//arc4random() 대신 Swift 고유의 난수 생성 메서드가 Swift 4.2 에 추가됐다.
while Int.random(in: 1...6) != 6 {
    print("Not a six")
}




//For loops
//For 루프가 가장 보편적으로 사용되는 loop이다.

//for <CONSTANT> in <COUNTABLE RANGE> {
//    <LOOP CODE>
//}

let count = 10
var sum = 0

for i in 1...count {
    sum += i
    //범위 동안 반복해서 + 한다.
}
//Playground에서 loop를 시각화할 수 있다. result 창에서 커서를 가져다 대고 있으면 아이콘이 활성화 되어 확인할 수 있다.

//underscore를 사용해서, indicator를 생략할 수 있다. loop만 사용할 뿐, indicator가 불필요한 경우 사용할 수 있다.
sum = 1
var lastSum = 0

for _ in 0..<count { //일반적으로 loop에서 halfOpenRange를 사용하는 경우가 많다.
    let temp = sum
    sum = sum + lastSum
    lastSum = temp
}

//특정 조건에서 반복되는 for loop를 만들 수 있다.
sum = 0
for i in 1...count where i % 2 == 1 { //홀수 에서만 실행
    sum += i
}

//where절이 true일 때만 코드 블록을 실행한다.

//Continue and labeled statements
//loop를 완전히 벗어나지 않고 특정 부분에만 루프를 건너 뛰고 싶을 경우 continue를 사용할 수 있다.
//위에서 처럼 where을 사용하는 것이 간단하지만, continue문을 사용하면 건너뛸 코드의 부분을 결정할 수 있으므로 더 높은 수준의 제어가 가능하다.

sum = 0
for row in 0..<8 {
    if row % 2 == 0 { //짝수 행을 제외한다.
        continue
    }

    for column in 0..<8 {
        sum += row * column
    }
}
//p.89 참고

//break와 continue는 while과 for에서 모두 사용 가능하다.

sum = 0
rowLoop: for row in 0..<8 {
    columnLoop: for column in 0..<8 {
        if row == column {
            continue rowLoop //이 경우에는 break와 같다.
        }

        sum += row * column
    }
}
//p.90 참고
//루프에 레이블을 지정해 줄 수 있다. 이 레이블을 continue와 결합해 사용할 수 있다.




//Switch statements
//switch는 변수나 상수 값에 따라 다른 코드를 실행한다.
let number = 10

switch number {
case 0:
    print("Zero")
default:
    print("Non-zero")
}
//특정 case를 제외한 다른 경우는 default의 코드를 실행하게 된다.

switch number {
case 10:
    print("It's ten!")
default:
    break
}
//각 case(default 포함)에서 아무 일이 일어나지 않도록 하려면 break를 써주면 된다.

let string = "Dog"

switch string {
case "Cat", "Dog": //두 가지 case에 동시에 적용된다.
    print("Animal is a house pet.")
default:
    print("Animal is not a house pet.")
}
//String으로도 switch를 만들 수 있다.

//Advanced switch statements
let hourOfDay = 12
var timeOfDay = ""

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
//if-else 를 switch로 쓸 수도 있다. 둘 이상의 case도 함께 쓸 수 있다.

switch hourOfDay {
case 0...5:
    timeOfDay = "Early morning"
case 6...11:
    timeOfDay = "Morning"
case 12...16:
    timeOfDay = "Afternoon"
case 17...19:
    timeOfDay = "Evening"
case 20..<24:
    timeOfDay = "Late evening"
default:
    timeOfDay = "INVALID HOUR!"
}
//range를 사용해, switch 문을 단순화 시킬 수 있다. 모든 경우를 나열하는 것보다 간결하다.
//여러 case의 조건에 만족하는 경우, 일치하는 첫 case에서만 실행된다.

switch number {
case let x where x % 2 == 0: //여기서 x는 단순히 number의 다른 이름
    print("Even")
default:
    print("Odd")
}
//let where를 사용해 pattern matching 해 줄 수 있다. 조건이 true인 경우만 바인딩한다.

switch number {
case let _ where number % 2 == 0: //해당 값을 사용하지 않는 다면 underscore를 사용해 줄 수 있다.
    print("Even")
default:
    print("Odd")
}
//pattern matching한 결과값을 활용하지 않는 경우 생략해 줄 수 있다.

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
//partial matching를 사용해 복잡한 경우를 단순화 해 줄 수 있다.
//underscore를 사용해, 해당 값에 대해 신경 쓰지 않아도 된다.

switch coordinates {
case (0, 0, 0):
    print("Origin")
case (let x, 0, 0):
    print("On the x-axis at x = \(x)")
case (0, let y, 0):
    print("On the y-axis at y = \(y)")
case (0, 0, let z):
    print("On the z-axis at z = \(z)")
case let (x, y, z): //default 역할을 한다.
    print("Somewhere in space at x = \(x), y = \(y), z = \(z)")
}
//값을 사용해야 할 경우 underscore 대신 바인딩해서 활용할 수 있다.
//switch 문이 가능한 모든 값을 case에 할당했다면, default를 사용하지 않아도 된다.

switch coordinates {
case let (x, y, _) where y == x:
    print("Along the y = x line.")
case let (x, y, _) where y == x * x:
    print("Along the y = x^2 line.")
default:
    break
}
//let where을 결합해 복잡한 구문을 바인딩해 쉽게 처리할 수 있다.
