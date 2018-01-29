//: Chapter8 : Collection Iteration with Closure

//Closure basics
//클로져는 값을 캡쳐한다. //이름없는 함수
var multiplyClosure: (Int, Int) -> Int

multiplyClosure = { (a:Int, b:Int) -> Int in
    return a * b
}

let result = multiplyClosure(4, 2)

//Shorthand syntax
//클로저는 심플한 문법을 제공한다.
multiplyClosure = { (a: Int, b: Int) -> Int in //클로저 구문이 return 밖에 없을 경우 return 생략 가능
    a * b
}

multiplyClosure = { (a, b) in //타입 추정에 의해 타입형 생략 가능
    a * b
}

multiplyClosure = { $0 * $1 } //파라미터를 각각 달러로 표시 가능

func operateOnNumbers(_ a: Int, _ b: Int, operation: (Int, Int) -> Int) -> Int {
    let result = operation(a, b)
    print(result)
    
    return result
}

//위의 함수를 클로저를 써수 줄일 수 있다.
let addClosure = {(a: Int, b: Int) in
    a + b
}

operateOnNumbers(4, 2, operation: addClosure)

func addFunction(_ a: Int, _ b: Int) -> Int {
    return a + b
}
operateOnNumbers(4, 2, operation: addFunction)//클로저는 함수이기 때문에, 클로저가 들어가 자리에 함수가 들어갈 수도 있다.

operateOnNumbers(4, 2, operation: {(a: Int, b: Int) -> Int in return a + b })
operateOnNumbers(4, 2, operation: {$0 + $1})
operateOnNumbers(4, 2, operation: +) //+는 두개의 연산자로 하나를 반환하는 함수이므로 더 줄일 수 있다.
operateOnNumbers(4, 2) { $0 + $1 } //클로저에서 마지막 매개변수가 함수일 경우 이런 식으로 쓸 수 있다. //trailing closure syntax.

//Closures with no return value
let voidClosure: () -> Void = { //Void와 ()는 같은 표현. 따라서 ()->(), Void->Void, Void->()는 같은 식이다. //하지만 함수 매겨변수는 항상 괄호로 표시해야 한다. 따라서 Void->(), Void->Void 식으로 쓸 수 없다.
    print("Swift Apprentice is awesome!")
}
voidClosure()

//Capturing from the enclosing scope
var counter = 0
let incrementCounter = {
    counter += 1
}

incrementCounter()
incrementCounter()
incrementCounter()
incrementCounter()
incrementCounter() // 5

//하지만 클로저는 값을 캡쳐한다.
func countingClosure() -> () -> Int {
    var counter = 0
    let incrementCounter: () -> Int = {
        counter += 1
        return counter
    }
    return incrementCounter
}

let counter1 = countingClosure()
let counter2 = countingClosure()
counter1() // 1
counter2() // 1
counter1() // 2
counter1() // 3
counter2() // 2

//Custom sorting with closures
let names = ["ZZZZZZ", "BB", "A", "CCCC", "EEEEE"]
names.sorted()

names.sorted {
    $0.count > $1.count
} //custom sort

//Iterating over collections with closures
//Functional Programming
let values = [1, 2, 3, 4, 5, 6]
values.forEach { //클로저로 루프
    print("\($0): \($0*$0)")
}

var prices = [1.5, 10, 4.99, 2.30, 8.19]
let largePrices = prices.filter { //클로저로 필터링
    return $0 > 5
} //새로운 배열을 리턴

let salePrices = prices.map { //각 요소에 적용
    return $0 * 0.9
}

let userInput = ["0", "11", "haha", "42"]
let numbers1 = userInput.map { //map으로 형 변환. 옵셔널 반환
    Int($0)
}

let numbers2 = userInput.flatMap {Int($0)} //non-nil로 리턴.

let sum = prices.reduce(0) { //reduce로 시작값을 가지고 클로저를 실행
    return $0 + $1
}

let stock = [1.5: 5, 10: 2, 4.99: 20, 2.30: 5, 8.19: 30]
let stockSum = stock.reduce(0) { //딕셔너리에서도 사용 가능하다.
    return $0 + $1.key * Double($1.value) //시작값에서 부터 각 요소의 키와 값을 곱해서 더한다.
}

let farmAnimals = ["🐎": 5, "🐄": 10, "🐑": 50, "🐶": 1]
let allAnimals = farmAnimals.reduce(into: []) { //into자체가 파라미터 이름
    (result, this: (key: String, value: Int)) in //첫 파라미터가 빈 배열, 두번째가 동물 딕셔너리
    for _ in 0 ..< this.value { //각 디셔너리의 값의 수 만큼 빈 배열에 키를 넣는다.
        result.append(this.key)
    }
}

let removeFirst = prices.dropFirst() //첫째 요소 삭제
let removeFirstTwo = prices.dropFirst(2) //첫째 요소부터 2째요소 전까지 삭제

let removeLast = prices.dropLast() //마지막 요소 삭제
let removeLastTwo = prices.dropLast(2) //마지막에서 2째 요소 전까지 삭제

let firstTwo = prices.prefix(2) //처음 두 요소
let lastTwo = prices.suffix(2) //마지막 두 요소


