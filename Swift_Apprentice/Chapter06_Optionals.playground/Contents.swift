//Swift는 Type에도 안전 기능이 내장되어 있다. Type이 Int, String과 같이 표시되면 실제 정수 또는 문자열이 보장된다.
//optional은 실제의 값이 있을 수도 없을 수도 있는 값이다.




//Introducing nil
//때로는 값이 없음을 나타내야 하는 것이 유용할 때가 있다.
var name = "Matt Galloway"
var age = 30
var occupation = "Software Developer & Author"
//여기서 실업을 하거나 퇴직하게 된다면 occupation 값이 없어질 수도 있다. 빈 문자열을 사용할 수도 있지만 optional이 더 나은 해결책이다.

//Sentinel values
//값이 없는 것과 같이 특수한 조건을 나타내는 유효한 값을 sentinel value라고 한다. 비어있는 문자열도 sentinel value이 될 수 있다.
//다른 예로 서버에서 통신후 status 값을 가져오는 것을 생각해 볼 수 있다. 이때 빈 문자열이나 0 을 sentinel value로 사용하면, 개발자에게 혼란을 줄 수도 있다.
//또한 0이나 빈 문자열이 실제로 다른 상황을 나타내는 값으로 후에 변경될 수도 있다. 이런 경우에서처럼, 값이 없음을 나타내는 특수한 유형을 사용하는 것이 좋다.
//nil은 값이 없음을 나타내는 이름이다. 이렇게 명시적으로 선언해 주면, 컴파일러가 값이 존재하는지 아닌지 체크해야 할 때를 알려줄 수 있다.
//다른 프로그래밍 언어에서는 단순히 센티널 값을 사용하기만 한다(ex. Objective-C 에서의 nil은 0의 동의어일 뿐이다).
//Swift에서는 새로운 유형인 Optional을 도입하여 값이 0이 될 수 있는 가능성을 처리한다. nil이 될 수 있는 유형을 optional이라고 한다.
//optional이 아닌 유형을 처리할 때에는 값이 보장되며, sentinal value를 생각할 필요가 없다.
//optional을 사용하는 경우, nil case에 대한 처리를 반드시 해줘야 한다. sentinel value를 사용하여 모호성을 제거한다.




//Introducing optionals
//optional은 값이 없음을 나타내는 Swift의 해결책이다. value을 가지거나 nil이 된다.
//optional을 상자라 생각할 수 있다. 하나의 value를 포함하고 있거나 비어있다. 값이 포함되어 있지 않으면(비어 있으면) nil을 포함한다고 하며, 상자 자체는 항상 존재한다.
//이를 열어 안을 확인할 수 있다. optional이 아닌 일반 type에는 상자가 없다. 대신 항상 실제 value를 보장한다. 슈뢰딩거의 고양이를 생각하면 된다!
var errorCode: Int? //optional의 선언은 이와 같이 한다.
//일반 Type의 선언과 다른 점은 끝에 ?를 붙여준다는 것이다. 유형은 Int? 가 된다. 변수는 Int 또는 nil 을 가진다(Int 또는 nil을 포함하는 상자).
//optional은 초기화 시 그 값을 유추할 수 없으므로, 명시적으로(여기서는 Int?) 선언해 줘야 한다.
errorCode = 100 //값을 설정해 준다. //상자에 값을 채운다
errorCode = nil //nil을 설정해 준다. //상자를 비운다.




//Unwrapping optionals
var result: Int? = 30
print(result) // Optional(30) //Expression implicitly coerced from 'Int?' to 'Any'
//Swift는 Any 유형 대신 optional을 사용하고 있다고 경고를 낸다. 경고를 없애려면 print(result as Any) 라고 코드를 써줘야 한다.
//출력 값은 Optional(30)이다. 이는 30 과는 다른 value가 될 수도, nil이 될 수도 있는 값이다.
//print(result + 1) //Value of optional type 'Int?' must be unwrapped to a value of type 'Int'
//보통의 Int처럼 사용하려하면 오류가 난다. optional이라는 상자 안의 value가 아닌 상자 자체에 정수를 추가하려고 하기 때문이다.

//Force unwrapping
//위의 예에서 오류 메시지를 해결하려면, optaional을 풀어야 한다.
var authorName: String? = "Matt Galloway"
var authorAge: Int? = 30
//optional을 푸는 두 가지 방법이 있다. 첫 번째는 force unwrapping으로 !를 사용해 강제로 해제한다.
var unwrappedAuthorName = authorName!
print("Author is \(unwrappedAuthorName)") //Author is Matt Galloway
//변수 뒤에 !를 입력해, 컴파일러에게 상자 안을 들여다보고 값을 가져오고 싶다고 알려준다. optional이 해제된 본래 type을 가져온다.
//따라서 unwrappedAuthorName의 type은 String? 이 아닌 String이 된다.
//하지만, Force unwrapping은 되도록 사용을 지양해야 한다.
authorName = nil
//print("Author is \(authorName!)") //Fatal error: Unexpectedly found nil while unwrapping an Optional value
//변수에 값이 없을 떄 force unwrapping을 사용하면 오류가 발생한다. 런타임 오류이므로, 앱이 중단 된다.
//이런 상황을 막으려면, optaional을 체크해서 unwrapping 해야 한다.
if authorName != nil { //nil이 아니라면 unwrapping 할 값이 있음을 의미한다.
    print("Author is \(authorName!)")
} else {
    print("No author.")
}
//if 구문으로 optaional의 nil을 확인해서 래핑하는 것이 안전하다. 하지만 이런식으로 매번 확인하는 것은 번거롭다.

//Optional binding
//Swift의 optional binding을 사용해 optional 내부의 값에 안전하게 액세스할 수 있다. 다음과 같이 사용한다.
if let unwrappedAuthorName = authorName { //optional binding //optional을 제거한다.
    //optional binding은 optional을 제거하기 때문에 !를 써줄 필요 없다.
    //optional에 값이 있으면, unwrapped 되어 unwrappedAuthorName에 값이 저장된다.
    //unwrappedAuthorName는 String? 이 아닌 String 이므로 안전하게 사용할 수 있다.
    print("Author is \(unwrappedAuthorName)")
} else { //nil인 경우
    //이 경우에는 unwrappedAuthorName이 존재하지 않는다.
    print("No author.")
}
//optional binding이 force unwrapping보다 안전하며, nil이 될 수 있는 optaional 변수에 사용해 주는 것이 좋다.
//force unwrapping은 nil이 될 수 없다고 확신할 수 있는 경우에만 사용해야 한다.
if let authorName = authorName { //optional binding 시 일반적으로 동일한 이름의 상수에 할당한다.
    print("Author is \(authorName)")
} else {
    print("No author.")
}
//동시에 여러개의 optional binding을 할 수 있다.
if let authorName = authorName,
    let authorAge = authorAge { //optional binding
    print("The author is \(authorName) who is \(authorAge) years old.") //두 변수 모두 optional이 아닌 경우에만 실행된다.
} else {
    print("No author or no age.")
}
//optional binding을 하면서, 동시에 bool 조건을 체크할 수도 있다.
if let authorName = authorName,
    let authorAge = authorAge,
    authorAge >= 40 { //optional binding의 unwrapping된 값에 조건을 달아 줄 수 있다.
    //authorName와 authorAge이 unwrapping 되고(nil이 아니고), authorAge>= 40인 경우에만 해당 코드가 실행된다.
    print("The author is \(authorName) who is \(authorAge) years old.")
} else { //세 조건 중 하나라도 만족되지 않으면 else 구문이 실행된다.
    print("No author or no age or age less than 40.")
}




//Introducing guard
//조건을 확인하고 if condition이 true인 경우만 계속 실행해야 하는 경우가 있다(ex. 네트워크에서 데이터를 가져오는 경우).
//이 경우 캡슐화하는 일반적인 방법은 optional을 사용하는 것이다(네트워크에서 가져올 데이터가 있는 경우에는 값이 있고, 그렇지 않으면 nil).
//이 같은 상황에 guard statement를 사용할 수 있다.
func guardMyCastle(name: String?) {
    guard let castleName = name else {
        print("No castle!")
        return
    }
    // At this point, `castleName` is a non-optional String
    print("Your castle called \(castleName) was guarded!")
}
//guard 문은 guard 다음 Bool 표현식과 optional binding을 포함하는 조건, else, 코드 블럭을 포함한다.
//조건이 false이면, else 구문이 실행되며, 반드시 return 되어야 한다.
//Guard statement는 코드를 읽기 쉽고 이해하기 쉽게 한다. 또한, Swift 컴파일러는 guard 조건에서 true가 된 변수와 상수를 최적화 하므로 효율적이다.
//guard statement 대신, if-let binding을 사용해 else 구문에서 return할 수도 있다.
//하지만, if-let binding에 비해, guard statement는 else 구문에서 반드시 return을 해야 하므로 코드의 안전성이 높아진다.
func calculateNumberOfSides(shape: String) -> Int? {
    switch shape {
    case "Triangle":
        return 3
    case "Square":
        return 4
    case "Rectangle":
        return 4
    case "Pentagon":
        return 5
    case "Hexagon":
        return 6
    default: //도형을 알 수 없는 경우
        return nil
    }
}
//shape에 따라 변의 수를 반환한다. 도형을 알 수 없거나 도형이 아니라면, nil을 반환한다.
func maybePrintSides(shape: String) {
    let sides = calculateNumberOfSides(shape: shape)
    if let sides = sides {
        print("A \(shape) has \(sides) sides.")
    } else {
        print("I don't know the number of sides for \(shape).")
    }
}
//이 경우 아무 문제없이 작동할 것이다. 같은 로직을 guard statement로 써 줄 수 있다.
func maybePrintSidesWithGuard(shape: String) {
    guard let sides = calculateNumberOfSides(shape: shape) else {
        print("I don't know the number of sides for \(shape).")
        return
    }
    
    print("A \(shape) has \(sides) sides.")
}
//함수가 복잡해질 수록, if-let binding 보다 guard statement를 쓰는 것이 가독성이 좋아진다.
//guard statement는 하나의 함수에 여러개가 있을 수 있으며, 함수의 시작부분에 위치한 경우가 많다.
//guard statement는 Swift에서 광범위하게 사용된다.




//Nil coalescing
//optional을 풀 수 있는 편리한 방법이 더 있다. optional에서 어떤 값이든 반드시 필요할 때, 기본값을 사용하며 이것을 nil coalescing이라 한다.
var optionalInt: Int? = 10
var mustHaveResult = optionalInt ?? 0
// ?? 는 nil coalescing operator라고 한다. optionalInt가 nil인 경우 mustHaveResult는 0이 된다. nil이 아닌 경우에는 optionalInt의 값이 된다.
//이 코드를 풀어 쓰면 다음과 같다.

//var optionalInt: Int? = 10
//var mustHaveResult: Int
//if let unwrapped = optionalInt {
//    mustHaveResult = unwrapped
//} else {
//    mustHaveResult = 0
//}

optionalInt = nil
mustHaveResult = optionalInt ?? 0 //0




//Nested optionals
let number: Int??? = 10
//이는 중첩된 optional 을 표현한다. 사실 거의 쓸 일은 없다.
print(number) // Optional(Optional(Optional(10)))
print(number!) // Optional(Optional(10))
