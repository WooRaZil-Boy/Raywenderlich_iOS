//Comparison operators
//true, false를 나타내는 Boolean 연산자가 있다.
let yes: Bool = true
let no: Bool = false
//Type inference을 하므로, Type(Bool) 없이 선언해 줄 수 있다.

//Boolean operators
//Bool은 값을 비교해 t/f 값을 알아내는데 사용된다. ==(항등 연산자)로 이를 수행한다.
let doesOneEqualTwo = (1 == 2) //false
//!= 연산자로 같지 않은지를 알아낼 수 있다.
let doesOneNotEqualTwo = (1 != 2) //true
//!(not-operator)는 Bool의 진리값을 toggle한다. 위의 코드는 아래와 같이 쓸 수도 있다.
let alsoTrue = !(1 == 2)

let isOneGreaterThanTwo = (1 > 2)
let isOneLessThanTwo = (1 < 2)
//비슷하게, >= 와 <= 도 사용할 수 있다.

//Boolean logic
//하나의 조건이 아닌 다중 조건도 AND와 OR을 사용해 검사할 수 있다.
let and = true && true //AND
let or = true || false //OR
//일반적으로 두 조건 모두 참인 경우를 판단해야 하는 경우 AND, 하나만이라도 만족하는 경우 OR을 사용한다.
let andOr = (1 < 2 && 3 > 4) || 1 < 4
//위와 같이 복잡한 표현식도 쓸 수 있다. 이런 경우 괄호를 사용해 보기 좋게 묶에 주는 것이 관리하기 편하다.

//String equality
//문자열의 동등 비교도 ==로 할 수 있다.
let guess = "dog"
let dogEqualsCat = guess == "cat"
let order = "cat" < "dog" //true. 알파벳 순서로 대소 비교를 할 수도 있다.

//Toggling a Bool
var switchState = true
switchState.toggle() // switchState = false
switchState.toggle() // switchState = true
//switchState = !switchState 로도 토글할 수 있다.




//The if statement
//흐름 제어의 가장 일반적인 방법은 if 문을 사용하는 것이다.
if 2 > 1 {
    print("Yes, 2 is greater than 1.")
}

//else 절을 추가해 if 문을 확장해 줄 수 있다.
let animal = "Fox"
if animal == "Cat" || animal == "Dog" {
    print("Animal is a house pet.")
} else {
    print("Animal is not a house pet.")
}

//else if 절을 사용해 if 문을 확장해 줄 수 있다. else if 는 중첩이 가능하다.
let hourOfDay = 12
var timeOfDay = ""
if hourOfDay < 6 {
    timeOfDay = "Early morning"
} else if hourOfDay < 12 {
    timeOfDay = "Morning"
} else if hourOfDay < 17 {
    timeOfDay = "Afternoon"
} else if hourOfDay < 20 {
    timeOfDay = "Evening"
} else if hourOfDay < 24 {
    timeOfDay = "Late evening"
} else {
    timeOfDay = "INVALID HOUR!"
}
print(timeOfDay)
//여기서 else 절은 생략할 수 있으며, 조건이 true가 되는 첫 번째 블록만 실행한다.

//Short circuiting
//if 문에서 AND(&&) 또는 OR(||)로 구분된 여러 Bool 조건이 있을 때 Short circuiting이 발생한다.

let name = "Matt Galloway"
if 1 > 2 && name == "Matt Galloway" {
    // ...
}
//위의 if 문에서 첫 조건인 1 > 2 가 false 이므로 전체 조건은 무조건 false가 된다. 따라서 두 번째 조건을 체크하지 않고 skip하게 된다.

if 1 < 2 || name == "Matt Galloway" {
    // ...
}
//위의 if 문에서 첫 조건인 1 < 2 가 true 이므로 전체 조건은 무조건 true가 된다. 따라서 두 번째 조건을 체크하지 않고 skip하게 된다.

//Encapsulating variables
//if 문으로 중괄호를 사용하면 변수를 캡슐화 한다.

var hoursWorked = 45
var price = 0
if hoursWorked > 40 {
    let hoursOver40 = hoursWorked - 40
    price += hoursOver40 * 50 //250
    hoursWorked -= hoursOver40 //40
}
price += hoursWorked * 25 //250 + 1000
print(price)

//print(hoursOver40) //Use of unresolved identifier 'hoursOver40'
//if 문으로 둘러쌓인 중괄호를 벗어나 hoursOver40 상수를 사용하려 하면 오류가 발생한다.

//The ternary conditional operator
//ternary conditional operator을 삼항 연산자라고 한다. (<CONDITION>) ? <TRUE VALUE> : <FALSE VALUE>

let a = 5
let b = 10

let min: Int
if a < b {
    min = a
} else {
    min = b
}

let max: Int
if a > b {
    max = a
} else {
    max = b
}
//위의 식을 다음과 같이 각각 줄일 수 있다.
let min1 = a < b ? a : b
let max1 = a > b ? a : b

//사실 위와 같이 비교할 필요 없이 min, max function은 Swift Standard Library에 있다.




//Loops
//루프는 코드를 여러 번 실행한다.

//While loops
//while loop는 조건이 참일 때 코드 블록을 반복한다. 다음과 같이 만든다.

//while <CONDITION> {
//  <LOOP CODE>
//}

//루프는 모든 반복에 대한 조건을 확인한다. true이면 루프가 실행되고, false이면 루프가 중지된다.
//무한 루프(infinite loop)는 다음과 같이 생성할 수 있다. while true { }

var sum = 1
while sum < 1000 {
    sum = sum + (sum + 1)
}
//위 코드는 sum이 1000보다 커지기 전까지 반복된다.

//Repeat-while loops
//while loop의 변형으로, 처음이 아닌 끝에서 조건을 검사한다. 다음과 같이 만든다.

//repeat {
//  <LOOP CODE>
//} while <CONDITION>

sum = 1
repeat {
    sum = sum + (sum + 1)
} while sum < 1000
//이 loop 문은 결과가 이전의 while 과 같지만, 코드에 따라 다른 경우도 있다.

sum = 1
while sum < 1 {
    sum = sum + (sum + 1)
}
//이 코드 sum 1보다 작기 때문에 loop가 아예 실행 되지 않는다.

repeat {
    sum = sum + (sum + 1)
} while sum < 1
//하지만 이 코드의 경우, 조건 검사가 loop의 끝에서 이루어 지므로 한번은 실행되어 값이 달라진다.

//Breaking out of a loop
//break문을 사용하면 loop의 실행을 즉시 중지하고, 루프 뒤의 코드로 진행할 수 있다.

sum = 1
while true {
    sum = sum + (sum + 1)
    if sum >= 1000 {
        break
    }
}
