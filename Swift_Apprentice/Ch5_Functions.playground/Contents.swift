//함수를 사용하면 작업을 수행하는 코드 블록을 정의 할 수 있다. 해당 작업을 실행해야 할 때마다 동일한 코드를 복사 붙여 넣는 대신 function을 실행할 수 있다.

//Function basics
func printMyName() {
    print("My name is Matt Galloway.")
}
//func 키워드를 사용해 함수를 정의한다. 그 후 함수의 이름이 오고 괄호가 온다. 괄호 뒤에 중괄호가 오고 그 뒤에 실행할 코드와 닫는 중괄호가 온다.
//함수가 선언되면 다음과 같이 사용한다.
printMyName()

//흔히 사용한 print()도 함수이다.

//Function parameters
//매개 변수(parameter)로 데이터를 전달해 줄 수 있다.
func printMultipleOfFive(value: Int) {
    print("\(value) * 5 = \(value * 5)")
}
printMultipleOfFive(value: 10)
//괄호 안에는 매개변수 목록이 있다. 각 매개변수의 이름과 type을 써준다. 매개변수가 없더라도 괄호 자체는 써줘야 한다.
//parameter(매개 변수) 와 argument(인수)를 혼동해선 안 된다. 함수 선언시 함께 선언되는 것이 매개 변수, 함수 호출 시 매개변수로 전달되는 값이 인수이다.

func printMultipleOf(multiplier: Int, andValue: Int) {
    print("\(multiplier) * \(andValue) = \(multiplier * andValue)")
}
printMultipleOf(multiplier: 4, andValue: 2)
//매개 변수를 여러 개 선언해 줄 수 있다. 함수의 이름과 매개변수 명은 문장을 읽도록 자연스럽게 되도록 선언해야 한다(Print multiple of multiplier 4 and value 2).

func printMultipleOf(multiplier: Int, and value: Int) {
    print("\(multiplier) * \(value) = \(multiplier * value)")
}
printMultipleOf(multiplier: 4, and: 2)
//외부 이름을 내부 이름 앞에 쓴다. 이렇게 외부 이름과 내부 이름을 다르게 선언해 줄 줘서 더 읽기 쉽고, 코드 작성을 유연하게 할 수 있다(Print multiple of multiplier 4 and 2).

func printMultipleOf(_ multiplier: Int, and value: Int) {
    print("\(multiplier) * \(value) = \(multiplier * value)")
}
printMultipleOf(4, and: 2)
//외부 이름을 사용하지 않으려면 underscore를 사용하면 된다(Print multiple of 4 and 2).

func printMultipleOf(_ multiplier: Int, _ value: Int = 1) { //default value
    print("\(multiplier) * \(value) = \(multiplier * value)")
}
printMultipleOf(4)
//모든 매개 변수에 underscore를 써 줄 수도 있다. 매개 변수가 많아지고, 함수명을 읽기 힘들어지면 적절하게 underscore를 사용하는 것이 좋다.
//default value를 지정해 줄 수 있다. 두 번째 매개변수에 값이 지정되지 않으면 기본값은 1이 된다.
//매개변수가 대부분 특정값으로 된다면, default value를 지정해 주는 것이 유용하며 함수 호출 시 코드를 단순화한다.

//Return values
//함수는 값을 반환할 수도 있다. 즉, 함수를 사용하여 데이터를 조작할 수 있다. 매개변수로 데이터를 가져와 조작한 다음 반환한다.
func multiply(_ number: Int, by multiplier: Int) -> Int {
    return number * multiplier
}
let result = multiply(4, by: 2)
//함수값 반환을 선언하려면 괄호 뒤에 -> 반환 Type을 추가해야 한다.

func multiplyAndDivide(_ number: Int, by factor: Int)
    -> (product: Int, quotient: Int) {
        return (number * factor, number / factor)
}
let results = multiplyAndDivide(4, by: 2)
let product = results.product
let quotient = results.quotient
//튜플을 사용해 여러 값을 반환할 수도 있다.

//Advanced parameter handling
//함수의 매개변수는 기본적으로 상수이기때문에 수정할 수 없다.

func incrementAndPrint(_ value: Int) {
//    value += 1 //Left side of mutating operator isn't mutable: 'value' is a 'let' constant
    print(value)
}
//매개변수 값은 let으로 선언된 상수와 같다. 매개변수의 값이 변경되면, 잘못된 작업으로 데이터가 의도치 않게 변경될 수 있기 때문이다.
//Swift는 값을 함수에 전달하기 전에 복사하는 데 이를 pass-by-value라 한다(Structure. Class와는 다르다).

func incrementAndPrint(_ value: inout Int) {
    value += 1
    print(value)
}
//하지만, 이렇게 inout 키워드를 써주면, 매개변수를 변경할 수 있다. 이를 copy-in copy-out 혹은 call by value result라고 한다.
//inout은 매개 변수 type 앞에 써서, 해당 매개변수를 복사해야 함을 나타낸다. 함수 내에서 사용된 로컬 사본을 반환하고 함수가 반환될 때 다시 복사된다.
//이 함수를 호출하려면, 인수 앞에 앰퍼샌드(&)를 추가해 copy-in copy-out을 사용하고 있음을 알려줘야 한다.

var value = 5
incrementAndPrint(&value) //inout 키워드를 쓴 매개변수를 수정하는 함수는 인자에 &를 앞에 붙여 호출해야 한다.
print(value)
//inout 함수이므로, 함수가 완료된 후 함수 내부에서 수정된 인자의 값이 유지된다. copy-in copy-out는 특정 조건에서 pass-by-reference 로 할 수 있다.
//인수 값은 매개 변수로 복사되지 않는다. 대신 매개 변수는 원래 값의 메모리에 대한 참조를 보유한다. 이 최적화는 사본의 필요성을 제거하면서 copy-in copy-out의 모든 요구사항을 충족시킨다.

//Overloading
//앞의 Function parameters 예제에서 사용한 함수들
//func printMultipleOf(multiplier: Int, andValue: Int)
//func printMultipleOf(multiplier: Int, and value: Int)
//func printMultipleOf(_ multiplier: Int, and value: Int)
//func printMultipleOf(_ multiplier: Int, _ value: Int)
//은 함수명이 같지만, 매개변수가 다르다. 이를 overloading이라고 하며, 유사한 함수를 정의할 수 있다.
//호출하는 함수가 명확해야 하며 대개 매개 변수 목록의 차이로 알 수 있다.
// • 다른 매개변수 수
// • 다른 매개변수 유형
// • 다른 외부 매개변수 이름

func getValue() -> Int {
    return 31
}
func getValue() -> String {
    return "Matt Galloway"
}
//그리고 이렇게 다른 반환 유형으로도 오버로딩할 수 있다. 하지만 이 경우에 문제가 있을 수 있다.

//let value = getValue() //error: ambiguous use of 'getValue()'
//Swift는 어떤 getValue()를 호출해야 하는지 알 수 없기 때문이다.

let valueInt: Int = getValue()
let valueString: String = getValue()
//이 문제를 해결하기 위해 위와 같이 원하는 값을 선언해 줘야 한다.
//오버로딩은 주의해서 사용해야 한다. 관련성이 높고 유사한 함수에 대해서만 사용해야 한다. 위의 예제처럼 반환 형식만 다른 경우에는 권장되지 않는다.




//Functions as variables
//Swift에서 함수는 그 자체로 데이터 유형이기도 하다. Int나 String과 같은 다른 type처럼 변수 및 상수에 값을 지정할 수 있다.

func add(_ a: Int, _ b: Int) -> Int {
    return a + b
}

var function = add //이런식으로 변수에 함수를 할당할 수 있다.
//type은 (Int, Int) -> Int 이 된다.

function(4, 2)
//할당된 변수를 이와 같이 사용할 수 있다.

func subtract(_ a: Int, _ b: Int) -> Int {
    return a - b
}

function = subtract
function(4, 2)
//type이 (Int, Int) -> Int 로 같기 때문에 변수에 새 함수를 할당할 수 있다.

func printResult(_ function: (Int, Int) -> Int, _ a: Int, _ b: Int) { //(Int, Int) -> Int type의 매개변수를 받는다. //매개변수가 3개 이다.
    let result = function(a, b)
    print(result)
}
printResult(add, 4, 2)
//함수에 다른 함수를 매개변수로 전달해 줄 수도 있다. 이렇게 다른 함수로 함수를 전달하는 것은 매우 유용하며 재사용 가능한 코드를 작성하는 데 도움이 된다. 또한 코드 실행의 유연성을 확보할 수 있다.

//The land of no return
//일부 함수는 호출자에게 제어를 반환하지 않는다(ex. 앱을 중단시키도록 설계된 함수, 이벤트 루프(UIApplicationMain)).

//func noReturn() -> Never {
//    //Function with uninhabited return type 'Never' is missing call to another never-returning function on all paths
//}
//Swift에서는 제어를 반환하지 않는 함수에 대해 위와 같이 써줄 수 있다. 이런 함수는 제어가 반환되지 않도록 코드를 써줘야 한다.

func infiniteLoop() -> Never {
    while true {
        
    }
}
//이 함수는 무한 루프가 되기 때문에 제어가 반환되지 않아 Never에 만족한다. Never를 명시적으로 써주면, 컴파일러가 함수가 반환되지 않는다는 것을 알기 때문에 성능을 최적화할 수 있다.

//Writing good functions
//이름을 보고 쉽게 추론할 수 있게 함수를 선언하고, 같은 입력에는 같은 값을 반환하는 반복되는 작업을 코드로 써준다.





