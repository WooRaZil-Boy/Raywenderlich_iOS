//함수를 사용하면 작업을 수행하는 코드 블록을 정의 할 수 있다. 해당 작업을 실행해야 할 때마다 동일한 코드를 복사 붙여 넣는 대신 function을 실행할 수 있다.




//Function basics
func printMyName() {
    print("My name is Matt Galloway.")
}
//func 키워드를 사용해 함수를 정의한다. 그 후 함수의 이름이 오고 괄호가 온다. 괄호 뒤에 중괄호가 오고 그 뒤에 실행할 코드와 닫는 중괄호가 온다.
//함수가 선언되면 다음과 같이 사용한다.
printMyName() // My name is Matt Galloway.
//흔히 사용한 print()도 함수이다.

//Function parameters
//매개 변수(parameter)로 데이터를 전달해 줄 수 있다.
func printMultipleOfFive(value: Int) {
    print("\(value) * 5 = \(value * 5)")
}
printMultipleOfFive(value: 10)
//괄호 안에는 매개변수 목록이 있다. 각 매개변수의 이름과 type을 써준다. 매개변수가 없더라도 괄호 자체는 써줘야 한다.
//parameter(매개 변수)와 argument(인수)를 혼동해선 안 된다. 함수 선언시 함께 선언되는 것이 매개 변수, 함수 호출 시 매개변수로 전달되는 값이 인수이다.
func printMultipleOf(multiplier: Int, andValue: Int) {
    print("\(multiplier) * \(andValue) = \(multiplier * andValue)")
}
printMultipleOf(multiplier: 4, andValue: 2)
//매개 변수를 여러 개 선언해 줄 수 있다. 함수의 이름과 매개변수 명은 문장을 읽도록 자연스럽게 되도록 선언해야 한다(Print multiple of multiplier 4 and value 2).
func printMultipleOf(multiplier: Int, and value: Int) {
    print("\(multiplier) * \(value) = \(multiplier * value)")
}
printMultipleOf(multiplier: 4, and: 2)
//매개변수에 외부 이름(external name)을 지정하여 더 명확하게 선언해 줄 수 있다.
//외부 이름을 내부 이름 앞에 쓴다. 이렇게 외부 이름과 내부 이름을 다르게 선언해 더 읽기 쉽고, 코드 작성을 유연하게 할 수 있다(Print multiple of multiplier 4 and 2).
//좀 더 읽기 쉽게 func printMultipleOf(multiplier: Int, and: Int) 이렇게 선언해 줄 수도 있다.
//하지만, 이 선언은 함수 내부에서 사용하는 매개 변수의 이름도 and로 사용해야 한다. 이렇게 일반적인 변수명(and)을 사용하면 혼란스러워 지기 때문에 권장되진 않는다.
func printMultipleOf(_ multiplier: Int, and value: Int) {
    print("\(multiplier) * \(value) = \(multiplier * value)")
}
printMultipleOf(4, and: 2)
//외부 이름을 아예 사용하지 않으려면 underscore를 사용하면 된다(Print multiple of 4 and 2).
func printMultipleOf(_ multiplier: Int, _ value: Int = 1) { //default value
    print("\(multiplier) * \(value) = \(multiplier * value)")
}
printMultipleOf(4)
//모든 매개 변수에 underscore를 써 줄 수도 있다. 매개 변수가 많아지고, 함수명을 읽기 힘들어지면 적절하게 underscore를 사용하는 것이 좋다.
//default value를 지정해 줄 수 있다. 두 번째 매개변수에 값이 지정되지 않으면 기본값은 1이 된다.
//매개변수가 대부분 특정값으로 된다면, default value를 지정해 주는 것이 유용하며 함수 호출 시 코드를 단순화한다.

//Return values
//함수는 값을 반환할 수도 있다. 함수를 호출하고 반환값을 변수나 상수에 할당하거나 표현식에서 직접 사용할 수 있다.
//즉, 함수를 사용하여 데이터를 조작할 수 있다. 매개변수로 데이터를 가져와 조작한 다음 반환한다.
func multiply(_ number: Int, by multiplier: Int) -> Int { //Int 값 반환
    return number * multiplier
}
let result = multiply(4, by: 2)
//함수값 반환을 선언하려면 괄호 뒤에 -> 반환 Type을 추가한다.
func multiplyAndDivide(_ number: Int, by factor: Int) -> (product: Int, quotient: Int) {
    return (number * factor, number / factor)
}
let results = multiplyAndDivide(4, by: 2)
let product = results.product
let quotient = results.quotient
//튜플을 사용해 여러 값을 반환할 수도 있다.
//위에서 사용한 함수를 다음과 같이 반환값을 제거하여 더 단순하게 만들 수 있다.
//func multiply(_ number: Int, by multiplier: Int) -> Int {
//    number * multiplier
//}
//func multiplyAndDivide(_ number: Int, by factor: Int) -> (product: Int, quotient: Int) {
//    (number * factor, number / factor)
//}
//함수는 단일 명령문(single statement)이기 때문에 해당 코드를 수행할 수 있다. 2줄 이상의 코드로 된 함수에서는 이와 같이 줄일 수 없고, return을 써줘야 한다.
//1줄로 된 단순한 함수의 경우에는 return을 제거하는 것이 가독성을 높여줄 수 있다.

//Advanced parameter handling
//함수의 매개변수는 기본적으로 상수이기때문에 수정할 수 없다.
func incrementAndPrint(_ value: Int) {
//    value += 1 //Left side of mutating operator isn't mutable: 'value' is a 'let' constant
    print(value)
}
//매개변수 값은 let으로 선언된 상수와 같다. 매개변수의 값이 변경되면, 잘못된 작업으로 데이터가 의도치 않게 변경될 수 있기 때문이다.
//Swift는 값을 함수에 전달하기 전에 이를 복사하는데 pass-by-value라 한다(Structure. Class와는 다르다).
//일반적으로는 매개변수의 값을 변경하지 않는 것이 좋지만, 직접 변경해야 하는 경우가 있을 수 있다.
func incrementAndPrint(_ value: inout Int) {
    value += 1
    print(value)
}
//이렇게 inout 키워드를 써주면, 매개변수를 변경할 수 있다. 이를 copy-in copy-out 혹은 call by value result라고 한다.
//inout은 매개 변수 type 앞에 써서, 해당 매개변수를 복사해야 함을 나타낸다. 해당 local copy가 함수 내에서 사용되고, 함수가 반환될 때 다시 복사된다.
//이 함수를 호출하려면, 인수 앞에 앰퍼샌드(&)를 추가해 copy-in copy-out을 사용하고 있음을 알려줘야 한다(포인터를 사용한다는 느낌으로).
var value = 5
incrementAndPrint(&value) //inout 키워드를 쓴 매개변수를 수정하는 함수는 인자에 &를 앞에 붙여 호출해야 한다.
print(value) //6
//inout 함수이므로, 함수가 완료된 후 함수 내부에서 수정된 값이 유지된다. 함수로 들어가고(in), 다시 나오므로(out) inout이라는 키워드를 쓴다.
//copy-in copy-out는 특정 조건에서 pass-by-reference 로 할 수 있다.
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
    31
}
func getValue() -> String {
    "Matt Galloway"
}
//그리고 이렇게 다른 반환 유형으로도 오버로딩할 수 있다. 하지만 이 경우에 문제가 있을 수 있다.
//let value = getValue() //error: ambiguous use of 'getValue()'
//Swift는 어떤 getValue()를 호출해야 하는지 알 수 없기 때문이다.
let valueInt: Int = getValue()
let valueString: String = getValue()
//이 문제를 해결하기 위해 위와 같이 원하는 값을 선언해 줘야 한다.
//오버로딩은 주의해서 사용해야 한다. 관련성이 높고 유사한 함수에 대해서만 사용해야 한다. 위의 예제처럼 반환 형식만 다른 경우에는 권장되지 않는다.




//Functions as variables
//Swift에서 함수는 그 자체로 데이터 유형이기도 하다. Int나 String과 같은 다른 type처럼 변수 및 상수에 값을 할당할 수 있다.
func add(_ a: Int, _ b: Int) -> Int {
    a + b
}
var function = add //이런식으로 변수에 함수를 할당할 수 있다. //type은 (Int, Int) -> Int 이 된다.
function(4, 2) //6 //할당된 변수를 이와 같이 사용할 수 있다.
func subtract(_ a: Int, _ b: Int) -> Int {
    a - b
}
//(Int, Int) -> Int type의 다른 함수를 선언한다.
function = subtract
function(4, 2) //2
//type이 (Int, Int) -> Int 로 같기 때문에 변수에 새 함수를 할당할 수 있다.
//변수에 함수를 할당할 수 있으며, 함수에 다른 함수를 매개변수로 전달해 줄 수도 있다.
func printResult(_ function: (Int, Int) -> Int, _ a: Int, _ b: Int) { //(Int, Int) -> Int type의 매개변수를 받는다. //매개변수가 3개 이다.
    let result = function(a, b)
    print(result)
}
printResult(add, 4, 2) //6
//이렇게 다른 함수로 함수를 전달하는 것은 매우 유용하며 재사용 가능한 코드를 작성하는 데 도움이 된다. 또한 코드 실행의 유연성을 확보할 수 있다.

//The land of no return
//일부 함수는 호출자에게 제어를 반환하지 않는다(ex. 앱을 중단시키도록 설계된 함수(fatalError), 이벤트 루프(UIApplicationMain)).
//Swift에서는 제어를 반환하지 않는 함수를 다음과 같이 써줄 수 있다.

//func noReturn() -> Never {
//    //Function with uninhabited return type 'Never' is missing call to another never-returning function on all paths
//}

//반환하지 않는 다는 의미의 Never라는 특수한 return 유형을 사용한다. 일반적인 함수에서 Never를 사용하면 다음과 같은 오류가 발생한다.
//Function with uninhabited return type 'Never' is missing call to another never-returning function on all paths
//Never를 사용하는 함수는 제어가 반환되지 않도록 코드를 작성해야 한다.
func infiniteLoop() -> Never {
    while true {
        
    }
}
//이 함수는 무한 루프가 되기 때문에 제어가 반환되지 않아 Never에 만족한다.
//Never를 명시적으로 써주면, 컴파일러가 함수가 반환되지 않는다는 것을 알기 때문에 성능을 최적화할 수 있다.

//Writing good functions
//함수 각각은 하나의 간단한 작업을 수행하도록 구성하고, 다른 함수와 결합해 큰 문제를 해결하도록 구현하는 것이 좋다.
//이름을 보고 쉽게 추론할 수 있게 함수를 선언하고, 같은 입력에는 같은 값을 반환하는 반복되는 작업을 코드로 써준다.
//간단하고 잘 구성된 함수를 구성해야 코드 유지 보수, 테스트가 쉬워진다.




//Commenting your functions
//함수 문서화는 코드 공유 시, 다른 사람이 코드를 쉽게 이해할 수 있으므로 중요한 작업이다.
//Swift와 Xcode의 자동 완성 및 기타 다른 기능을 사용하면 매우 쉽게 문서화 할 수 있다.
//다른 많은 언어에서도 널리 사용되는 문서화 주석의 표준인 Doxygen 으로 문서화 한다.

/// Calculates the average of three values
/// - Parameters:
/// - a: The first value.
/// - b: The second value.
/// - c: The third value.
/// - Returns: The average of the three values.
func calculateAverage(of a: Double, and b: Double, and c: Double) -> Double {
  let total = a + b + c
  let average = total / 3
  return average
}
calculateAverage(of: 1, and: 3, and: 5)

//일반적으로 주석 작성시 사용되는 // 대신 /// 을 사용한다.
//첫 번째 줄은 함수의 기능에 대한 설명을 기술한다. 다음은 매개 변수 목록과 마지막으로 반환 값에 대한 설명을 추가한다.
//따로 기억할 필요 없이, Xcode에서 함수명에 커서를 두고, "Option-Command-/"를 누르면 문서화 주석 템플릿을 추가한다.
//이렇게 문서화 해 놓으면 자동 코드 완성 시, 해당 설명이 추가로 표시된다.
//또한 Option 키를 누른 상태에서 함수 이름을 클릭하면 팝 오버로 설명이 표시된다.
//특히 자주 사용하거나 복잡한 함수를 문서화해 두는 것이 좋다.








