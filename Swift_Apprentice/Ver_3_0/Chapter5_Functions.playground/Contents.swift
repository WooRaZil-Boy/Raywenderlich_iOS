//: Chapter 5: Functions

//Function basics
func printMyName() {
    print("My name is Matt Galloway.")
}
printMyName()

//Function parameters
func printMultipleOfFive(value: Int) {
    print("\(value) * 5 = \(value * 5)")
}
printMultipleOfFive(value: 10)

func printMultipleOf(multiplier: Int, andValue: Int) {
    print("\(multiplier) * \(andValue) = \(multiplier * andValue)")
}
printMultipleOf(multiplier: 4, andValue: 2)

func printMultipleOf(multiplier: Int, and value: Int) { //and가 함수 호출시, value가 함수 내부에서
    print("\(multiplier) * \(value) = \(multiplier * value)")
}
printMultipleOf(multiplier: 4, and: 2)

func printMultipleOf(_ multiplier: Int, and value: Int) { //언더 스코어로 다른 언어들 함수 부르듯이 만들어 줄 수 있다.
    print("\(multiplier) * \(value) = \(multiplier * value)")
}
printMultipleOf(4, and: 2)

func printMultipleOf(_ multiplier: Int, _ value: Int = 1) { //default
    print("\(multiplier) * \(value) = \(multiplier * value)")
}
printMultipleOf(4)

//Return values
func multiply(_ number: Int, by multiplier: Int) -> Int {
    return number * multiplier
}
let result = multiply(4, by: 2)

func multiplyAndDivide(_ number: Int, by factor: Int) -> (product: Int, quotient: Int) {
    return (number * factor, number / factor)
}
let results = multiplyAndDivide(4, by: 2) //튜플
let product = results.product
let quotient = results.quotient

//Advanced parameter handling
func incrementAndPrint(_ value: inout Int) { //함수의 파라미터들은 상수가 기본. 즉 기본적으로는 수정할 수 없다. //inout 키워드를 추가해 수정할 수 있다. 
    value += 1
    print(value)
}

var value = 5
incrementAndPrint(&value)
print(value) //inout은 call by reference. 따라서 함수 호출시에 &가 필요하다. //함수 호출 이후 값이 바뀐다. //실제로는 값을 복사해서 함수 안에 사용한 뒤 다시 그 값을 return. //copy in, copy out

//Overloading
//같은 이름의 함수를 매개변수만 다르게 해서 여러 개 - 실질적으로 이름이 같아도 매개변수가 다르면 다른 함수 //매개변수 수, 매개변수 타입, 매개변수 이름, 반환형
func getValue() -> Int {
    return 31
}

func getValue() -> String {
    return "Matt Galloway"
}

let valueInt: Int = getValue()
let valueString: String = getValue() //이 경우에는 타입을 명시하지 않으면 반환형을 유추할 수 없으므로 에러가 난다.

//Functions as variables
func add(_ a: Int, _ b: Int) -> Int {
    return a + b
}
var function = add //함수가 그 자체로 type이 될 수 있다. (Int, Int) -> Int 형
function(4, 2)

func subtract(_ a: Int, _ b: Int) -> Int {
    return a - b
}

function = subtract //(Int, Int) -> Int 형 으로 같으므로 바꿀 수 있다.
function(4, 2)

func printResult(_ function: (Int, Int) -> Int, _ a: Int, _ b: Int) { //(Int, Int) -> Int,  Int, Int로 매개변수 3개
    let result = function(a, b)
    print(result)
}
printResult(add, 4, 2)
printResult(subtract, 4, 2)

//The land of no return
func infiniteLoop() -> Never { //Never 키워드로 함수가 반환되지 않는다는 것을 나타낸다. //컴파일러 성능 향상을 위한 키워드
    while true {
    }
}

