//: Chapter 6: Optionals

//Optional은 value or nil의 상태

var errorCode: Int? //Optional Int

//Unwrapping optionals
var result: Int? = 30
print(result)

//print(result + 1) //옵셔널이기에 이런 연산을 할 수 없다.

//Force unwrapping
var authorName: String? = "Matt Galloway"
var authorAge: Int? = 30
var unwrappedAuthorName = authorName! //느낌표를 사용해 강제로 언래핑할 수 있다.
print("Author is \(unwrappedAuthorName)")

authorName = nil
//print("Author is \(authorName!)") //nil인 경우 강제로 언래핑했을 때 에러가 난다. (값이 없기 때문) //runtime에 결정되는 경우 에러를 찾기 어려울 수 있다.

if authorName != nil { //if문으로 옵셔널이 nil이 아닌 경우에만
    print("Author is \(authorName!)")
} else {
    print("No author.")
}

//Optional binding
//위의 방법은 안전하나 항상 if문으로 확인을해야 하는 번거로움이 있다. 이를 해결하기 위해 옵셔널 바인딩 사용
if let unwrappedAuthorName = authorName { //느낌표 대신, nil이 아닌경우 대입. //Optional binding은 Optional을 제거한다.
    print("Author is \(unwrappedAuthorName)")
} else { //이 경우에는 unwrappedAuthorName이 존재하지 않는다.
    print("No author.")
}

if let authorName = authorName { //보통 같은 변수(상수)명으로 대체한다.
    print("Author is \(authorName)")
} else {
    print("No author.")
}

if let authorName = authorName, let authorAge = authorAge { //동시에 여러개의 optional binding을 할 수 있다.
    print("The author is \(authorName) who is \(authorAge) years old.") //두 변수 모두 optional이 아닌 경우에만 실행된다.
} else {
    print("No author or no age.")
}

if let authorName = authorName, let authorAge = authorAge, authorAge >= 40 { //이런 식으로 조건을 달아 줄 수도 있다.
    print("The author is \(authorName) who is \(authorAge) years old.")
} else {
    print("No author or no age or age less than 40.")
}

//Introducing guard
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
    default:
        return nil
    }
}

func maybePrintSides(shape: String) {
    let sides = calculateNumberOfSides(shape: shape)
    if let sides = sides { //optional이 아닌 경우에만
        print("A \(shape) has \(sides) sides.")
    } else {
        print("I don't know the number of sides for \(shape).")
    }
}

func maybePrintSides1(shape: String) {
    guard let sides = calculateNumberOfSides(shape: shape) else { //guard else를 사용하면 이렇게 표현 //false인 경우 guard 블럭 코드 실행
        print("I don't know the number of sides for \(shape).")
        return
    }
    
    print("A \(shape) has \(sides) sides.")
}

//Nil coalescing
var optionalInt: Int? = 10
var mustHaveResult = optionalInt ?? 0 //optionalInt가 값이 있다면 그 값을 대입하고, 값을 가지지 않는다면(nil) 0을 대입한다.

//아래와 같이 풀어쓴 것과 같다.
//var optionalInt: Int? = 10
//var mustHaveResult: Int
//if let unwrapped = optionalInt {
//    mustHaveResult = unwrapped
//} else {
//    mustHaveResult = 0
//}


let number: Int??? = 10
print(number)
