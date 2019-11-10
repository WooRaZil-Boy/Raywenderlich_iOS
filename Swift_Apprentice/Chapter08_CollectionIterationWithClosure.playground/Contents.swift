//: Chapter8 : Collection Iteration with Closure

//Function 외에도, Swift에서는 재사용할 수 있는 코드를 분할하는 데에 클로저(closure)를 사용할 수 있다. Collection을 다룰 때 특히 유용하다.
//클로저는 단순히 이름이 없는 Function이다. 클로저를 변수에 할당하거나 다른 변수처럼 전달할 수도 있다.




//Closure basics
//클로저는 자체 범위 내에서 변수와 상수를 "close over" 할 수 있기 때문에 Closure라 이름 붙여졌다.
//이는 클로저가 주변 컨텍스트에서 변수 또는 상수의 값에 액세스해서 저장하고 변경할 수 있음을 의미한다.
//클로저 내부에서 사용되는 변수와 상수는 클로저에 의해 captured 되었다고 한다.
//클로저 변수 선언은 다음과 같다.
var multiplyClosure: (Int, Int) -> Int
//두 개의 Int 값을 가져와, Int를 반환한다. 이는 함수 type 변수 선언과 동일하다. 클로저의 type은 함수 type이다.
multiplyClosure = { (a:Int, b:Int) -> Int in
    return a * b
}
//함수 선언과 비슷하지만 차이가 있다. 함수와 같이 매개변수 목록, ->, 반환 유형 등을 사용하지만, 클로저의 경우에는 이와 같은 요소가 중괄호 안에 표기되며 in 키워드가 붙는다.
let result = multiplyClosure(4, 2)
//클로저 변수를 정의하면, 함수처럼 사용할 수 있다.
print(result) //8
//함수와 달리 클로저에서는 매개 변수의 외부 이름을 선언할 수 없다.

//Shorthand syntax
//클로저는 함수에 비해 심플한 문법을 제공한다. 클로저 구문을 줄이는 방법에는 여러 가지가 있다.
// 1. 일반 함수와 마찬가지로 클로저가 단일 return 문으로 구성된 경우, return 키워드를 생략할 수 있다.
multiplyClosure = { (a: Int, b: Int) -> Int in //클로저 구문이 return 밖에 없을 경우 return 생략 가능
    a * b
}
// 2. type을 제거하여, 컴파일러가 type inference하도록 구문을 줄일 수 있다.
multiplyClosure = { (a, b) in //타입 추정으로 타입형 생략 가능
    a * b
}
//이미 multiplyClosure를 선언할 때, 두 개의 Int를 받아 Int를 반환하는 (Int, Int) -> Int 로 선언했으므로 컴파일러가 타입을 추정할 수 있다.
// 3. 매개변수 목록을 생략할 수도 있다. 0부터 시작하여 각 매개 변수를 해당 숫자로 참조할 수 있다.
multiplyClosure = { //in 키워드도 생략된다.
    $0 * $1 //파라미터를 각각 '$숫자' 로 표시 가능
}
//이렇게 매개 변수 목록, 반환 유형, 키워드(in)를 모두 생략할 수 있으며, 코드의 양을 크게 줄일 수 있다.
//하지만, '$숫자'를 사용해서 매개변수를 생략할 때에는 가독성에 유의해야 한다.
//매개 변수 목록이 길어지거나, 각 매개변수가 무엇을 의미하는지 한 번에 알아내기 어려워 질 경우에는 코드가 길어지더라도 매개 변수를 직접 명명해 사용하는 것이 좋다.
func operateOnNumbers(_ a: Int, _ b: Int, operation: (Int, Int) -> Int) -> Int {
    let result = operation(a, b)
    print(result)
    
    return result
}
//위의 함수의 매개변수로 클로저를 사용할 수 있다.
let addClosure = {(a: Int, b: Int) in //클로저
    a + b
}
operateOnNumbers(4, 2, operation: addClosure)
//클로저는 단순히 이름 없는 함수이다. 따라서, operateOnNumbers의 세 번째 매개변수로 함수를 전달할 수도 있다.
func addFunction(_ a: Int, _ b: Int) -> Int { //함수
    return a + b
}
operateOnNumbers(4, 2, operation: addFunction)//클로저는 함수이기 때문에, 클로저가 들어가 자리에 함수가 들어갈 수도 있다.
//클로저를 정의하고 이를 local 변수나 상수에 할당할 필요가 없다. 함수 매개변수에 클로저를 바로 전달할 수 있다. //클로저를 사용하면, 위에서 살펴본 대로 구문을 줄일 수 있다.
operateOnNumbers(4, 2, operation: {(a: Int, b: Int) -> Int in return a + b })
operateOnNumbers(4, 2, operation: { $0 + $1 })
operateOnNumbers(4, 2, operation: +) //+는 두개의 연산자로 하나를 반환하는 함수이므로(option-click으로 추가 정보 확인) 이런 식으로 더 줄일 수 있다.
operateOnNumbers(4, 2) { $0 + $1 } //함수에 전달되는 마지막 매개 변수가 클로저인 경우 이런 식으로 함수 호출 외부에 클로저를 붙여 쓸 수 있다. //trailing closure syntax

//Closures with no return value
//함수와 마찬가지로 반환하는 값이 없는 클로저를 선언할 수도 있다.
let voidClosure: () -> Void = { //Void와 ()는 같은 표현. 따라서 ()->(), Void->Void, Void->()는 같은 식이다.
    //하지만 함수에서 매겨변수는 항상 괄호로 표시해야 한다. 따라서 Void->(), Void->Void 식으로 쓸 수 없다.
    print("Swift Apprentice is awesome!")
}
voidClosure()

//Capturing from the enclosing scope
//클로저는 자체 범위 내에서 변수와 상수에 액세스할 수 있다.
//scope는 entity(variable, constant 등)이 액세스 할 수 있는 range를 정의한다. ex. if-statement
//클로저도 이와 같이 새로운 범위를 설정하고, 정의된 scope의 모든 entity를 상속한다.
var counter = 0
let incrementCounter = {
    counter += 1
}
//incrementCounter는 단순히 외부 변수인 counter를 증가시킨다. 클로저는 해당 변수와 동일한 scope에서 정의되므로 변수에 액세스할 수 있다.
//클로저는 변수를 capture한다. 해당 변수에 대한 변경 사항은 클로저 내, 외부 모두에서 확인할 수 있다.
incrementCounter()
incrementCounter()
incrementCounter()
incrementCounter()
incrementCounter() // 5
//클로저가 범위 내에서 변수를 capture 하는 특성은 매우 유용하게 사용할 수 있다.
func countingClosure() -> () -> Int {
    var counter = 0
    let incrementCounter: () -> Int = {
        counter += 1
        return counter
    }
    return incrementCounter
}
//이 함수는 매개변수가 없고, 클로저를 반환한다. 내부 클로저는 매개 변수가 없고, Int를 반환한다.
//해당 함수에서 반환된 클로저는 호출될 때마다 내부 counter 변수를 증가시킨다. 따라서, 이 함수를 호출할 때마다 다른 counter 변수를 사용한다.
let counter1 = countingClosure()
let counter2 = countingClosure()
counter1() // 1
counter2() // 1
counter1() // 2
counter1() // 3
counter2() // 2
//각각의 함수로 생성된 counter는 서로 배타적이며 독립적이다.




//Custom sorting with closures
//클로저는 Collection에서 유용하게 사용할 수 있다. 이미 내장된 sort 함수가 있지만, 클로저로 사용자 정의 정렬을 지정해 줄 수 있다.
let names = ["ZZZZZZ", "BB", "A", "CCCC", "EEEEE"]
names.sorted() //sort()는 원본 배열의 순서를 정렬하고, sorted()는 정렬된 배열을 복사해서 반환한다(원본 배열은 정렬되지 않고 그대로).
// ["A", "BB", "CCCC", "EEEEE", "ZZZZZZ"]
//사용자 정의 클로저를 지정하여 세부적인 정렬 방법을 변경해 줄 수 있다.
names.sorted { //trailing closure
    $0.count > $1.count //긴 문자열이 앞으로 온다.
} //custom sort
// ["ZZZZZZ", "EEEEE", "CCCC", "BB", "A"]




//Iterating over collections with closures
//Swift Collection은 functional programming과 관련된 편리한 특성들이 구현되어 있다.
//이러한 특성들은 Collection에 적용하여 특정 작업을 수행할 수 있는 함수 형태로 되어있다. 각 요소의 변환 또는 특정 요소 필터링과 같은 작업들이 있다.
// 1. forEach : Collection의 요소를 반복해 특정 작업을 수행한다.
let values = [1, 2, 3, 4, 5, 6]
values.forEach { //클로저로 루프
    print("\($0): \($0*$0)") //거듭 제곱을 출력한다.
}
// 2. filter : 특정 요소를 필터링한다.
var prices = [1.5, 10, 4.99, 2.30, 8.19]
let largePrices = prices.filter { //클로저로 필터링
    $0 > 5
} //새로운 배열을 리턴
// (10, 8.19)
//filter 함수의 원형은 다음과 같다. //func filter(_ isIncluded: (Element) -> Bool) -> [Element]
//하나의 클로저(또는 함수) 매개변수를 가지고, 해당 클로저(또는 함수)는 Element를 가져와 Bool을 반환한다.
//전체 filter 함수는 Element 배열을 반환한다. 클로저는 값을 유지해야 하는 지에 따라 true / false를 반환한다.
//filter로 반환된 배열은 클로저가 true를 반환한 모든 요소를 포함한다. filter는 새로운 배열을 반환한다. 원본 배열은 변경되지 않는다.
// 3. first : 특정 조건을 만족하는 첫 요소를 반환한다.
let largePrice = prices.first { //trailing closure
    $0 > 5 //조건을 만족하는 첫 번째 요소만 반환한다.
}
// 10
// 4. map : 각 요소를 반영한 새 배열을 반환한다.
let salePrices = prices.map { //각 요소에 적용
    $0 * 0.9 //90% 가격으로 변환
} //순서가 유지된 상태로 결과를 포함하는 새 배열을 반환한다.
// [1.35, 9, 4.491, 2.07, 7.371]
//map을 사용해 type을 변경할 수도 있다.
let userInput = ["0", "11", "haha", "42"]
let numbers1 = userInput.map { //map으로 형 변환. 옵셔널 반환 //[Int?]
    Int($0)
}
// [Optional(0), Optional(11), nil, Optional(42)]
//유효하지 않은 값을 필터링 하려면 compactMap을 사용한다.
let numbers2 = userInput.compactMap { //non-nil로 리턴. //[Int]
    Int($0)
}
// [0, 11, 42]
// 5. reduce : 시작값을 지정해 준다. 클로저는 시작값에서 부터 작업한 현재값과 배열의 요소를 매개변수로 받아 다음 값을 반환한다.
let sum = prices.reduce(0) { //reduce로 시작값을 가지고 클로저를 실행
    $0 + $1 //$0이 현재값(첫 번째에는 초기값), $1이 collection의 요소이다.
}
// 26.98
//여기서는 0이 시작값이 되고 배열의 첫 요소를 더한다. 그 후, 현재값은 시작값 + 배열 첫 요소 값이 되고, 현재값과 배열의 다음 요소 값을 계속해서 더해 업데이트 한다.
//위에서 살펴본 클러저 메서드들을 사용하면, 긴 코드 추가 없이 간단하게 Collection의 값들을 사용해 계산할 수 있다.
//Array 뿐 아니라, Dictionary도 Collection을 구현했으므로 사용할 수 있다.
//가격과 남은 재고량을 매핑한 dictionary를 만든다.
let stock = [1.5: 5, 10: 2, 4.99: 20, 2.30: 5, 8.19: 30]
let stockSum = stock.reduce(0) { //딕셔너리에서도 사용 가능하다.
    $0 + $1.key * Double($1.value) //시작값에서 부터 각 요소의 키와 값을 곱해서 더한다.
    //$0이 현재값(첫 번째에는 초기값), $1이 collection의 요소이다.
    //value는 Int이므로 type 변환이 필요하다.
}
// 384.5
//또 다른 형태인 reduce(into:_:) 도 있다. 반환결과가 Array나 Dictionary 같은 Collection 인 경우 사용한다.
let farmAnimals = ["🐎": 5, "🐄": 10, "🐑": 50, "🐶": 1]
let allAnimals = farmAnimals.reduce(into: []) { //into자체가 파라미터 이름
    (result, this: (key: String, value: Int)) in //첫 파라미터가 빈 배열, 두번째가 동물 Dictionary
    for _ in 0 ..< this.value { //각 Dictionary의 값의 수 만큼 빈 배열에 Dictionary의 키를 넣는다.
        result.append(this.key)
    }
}
// ["🐎", "🐎", "🐎", "🐎", "🐎", "🐄", "🐄", "🐄", "🐄", "🐄", "🐄", "🐄", "🐄", "🐄", "🐄", "🐑", "🐑", "🐑", "🐑", "🐑", "🐑", "🐑", "🐑", "🐑", "🐑", "🐑", "🐑", "🐑", "🐑", "🐑", "🐑", "🐑", "🐑", "🐑", "🐑", "🐑", "🐑", "🐑", "🐑", "🐑", "🐑", "🐑", "🐑", "🐑", "🐑", "🐑", "🐑", "🐑", "🐑", "🐑", "🐑", "🐑", "🐑", "🐑", "🐑", "🐑", "🐑", "🐑", "🐑", "🐑", "🐑", "🐑", "🐑", "🐑", "🐑", "🐶"]
//클로저의 결과로 무언가를 반환하지 않는다는 것을 제외하면, reduce()와 같다.
// 6. 배열의 요소를 잘라야 하는 경우에 사용하는 몇 가지 함수들이 있다.
let removeFirst = prices.dropFirst() //첫째 요소 삭제
// [10, 4.99, 2.30, 8.19]
let removeFirstTwo = prices.dropFirst(2) //첫째 요소부터 2째 요소 전까지 삭제
// [4.99, 2.30, 8.19]
//dropFirst와 반대로 끝 요소를 제거하는 dropLast도 있다.
let removeLast = prices.dropLast() //마지막 요소 삭제
// [1.5, 10, 4.99, 2.30]
let removeLastTwo = prices.dropLast(2) //마지막에서 2째 요소 전까지 삭제
// [1.5, 10, 4.99]
//단순히, 배열의 첫 요소, 마지막 요소만 반환할 수도 있다.
let firstTwo = prices.prefix(2) //처음 두 요소
// [1.5, 10]
let lastTwo = prices.suffix(2) //마지막 두 요소
// [2.30, 8.19]
//removeAll()를 사용해, Collection의 모든 요소를 제거할 수 있다.
prices.removeAll() { $0 > 2 } // prices is now [1.5]
//2보다 큰 모든 요소를 제거한다.
prices.removeAll() // prices is now an empty array
//모든 요소를 제거한다.




//Lazy collections
//Collection이 너무 커지는 경우가 있다. //ex. 모든 소수(자기 자신과 1 이외에 약수를 가지지 않는 수)를 요소로 가지고 있는 collection
//이런 경우에도, collection을 조작해야 한다면, lazy collection을 사용하는 것이 좋다.
func isPrime(_ number: Int) -> Bool {
    if number == 1 { return false } //1은 소수가 아니다.
    if number == 2 || number == 3 { return true } //2, 3은 소수.
    
    for i in 2...Int(Double(number).squareRoot()) {
        if number % i == 0 { return false } //약수가 있다. == 소수가 아니다.
    }
    
    return true
}
//위의 함수로 소수를 판별할 수 있지만, 성능이 좋지는 않다.
//Sieve of Eratosthenes 참고 https://ko.wikipedia.org/wiki/%EC%97%90%EB%9D%BC%ED%86%A0%EC%8A%A4%ED%85%8C%EB%84%A4%EC%8A%A4%EC%9D%98_%EC%B2%B4
//var primes: [Int] = []
//var i = 1
//while primes.count < 10 {
//    if isPrime(i) {
//        primes.append(i)
//    }
//    i += 1
//}
//primes.forEach { print($0) }
//범위가 정해진 시퀀스에서 첫 10개의 소수를 얻으려면, prefix(10)을 사용하면 된다. 하지만, 무한한 길이의 시퀀스에서는 해당 요소를 계속해서 추가하므로 같은 방식으로 사용할 수 없다.
//이런 경우에는, lazy를 사용하여, 필요할 때 Collection을 생성하도록 할 수 있다. 위의 코드를 아래와 같이 수정할 수 있다.
let primes = (1...).lazy //무한대
    .filter { isPrime($0) }
    .prefix(10)
primes.forEach { print($0) }
//lazy를 사용하면, primes.forEach를 사용해 직접 해당 배열에 접근하기 전까지 primes는 생성되지 않는다.
//primes.forEach를 사용하면, 소수를 판단하고 처음 10개의 소수를 출력한다.
//lazy collection은 Collection이 크거나 생성하는데 비용이 큰 경우(ex. 무한대) 매우 유용하다. 해당 collection이 필요할 때까지 생성하지 않는다.
