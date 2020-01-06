//Chapter 12: Methods

//메서드는 구조체(struct)안에 있는 함수이다.
//메서드는 구조체 외에도, 클래스(class), 열거형(enum) 등에서도 사용할 수 있다.




//Method refresher
//Array.removeLast() 메서드는 Array에서 마지막 항목을 삭제한다(pop).
var numbers = [1, 2, 3]
numbers.removeLast()
numbers // [1, 2]
//removeLast()와 같은 메서드는 구조체의 데이터를 제어하는데 도움이 된다.

//Comparing methods to computed properties
//computed property를 사용해, 구조체 내부에서 코드를 실행할 수 있다.
//computed property는 메서드와 매우 유사하다. 대부분의 경우에는 개인적인 선호도의 차이이지만, 둘 중 어떤 것을 사용할지 판단하는데 도움이 되는 기준이 있다.
//property는 메서드가 작업을 수행하는 동안 설정할 수 있는 value를 보유한다. 메서드의 목적인 단일 value를 반환하는 것일 때에는 이러한 기준이 모호해 진다.
//value를 설정하고 얻을 수 있는 지 고려해 본다. computed property에는 value를 쓰기 위해 setter가 있을 수 있다.
//고려해야 할 또 다른 질문은 광범위한 계산이 필요한지, 아니면 DB에서 읽어오는지 여부이다. 메서드는 호출하고 계산하는데 많은 자원을 소모한다.
//O(1)처럼 비용이 저렴하다면, computed property를 사용하는 것이 좋다. p.231 다이어그램 참고

//Turning a function into a method
//메서드와 초기화에 대한 예제로 SimpleDate라는 날짜에 관련된 모델을 작성한다. Foundation 라이브러리에는 날짜와 시간을 다루는 Date 클래스가 있다.
let months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
struct SimpleDate {
    var month: String
}
func monthsUntilWinterBreak(from date: SimpleDate) -> Int {
    months.firstIndex(of: "December")! - months.firstIndex(of: date.month)! //실제 구현에서는 force unwrapping을 지양하는 게 좋다.
}
//위의 예제에서 함수 monthsUntilWinterBreak(date:)를 메서드로 변환하려면, 구조체 내부로 이동하면 된다.

extension SimpleDate {
    func monthsUntilWinterBreak(from date: SimpleDate) -> Int {
        months.firstIndex(of: "December")! - months.firstIndex(of: date.month)! //실제 구현에서는 force unwrapping을 지양하는 게 좋다.
    }
}
//메서드를 구분하는 키워드는 따로 없다. 내부에 명명된 함수일 뿐이다. property와 같이 dot syntax를 사용해 인스턴스에서 메서드를 호출한다.
let date = SimpleDate(month: "October")
date.monthsUntilWinterBreak(from: date) // 2. //Xcode에서 자동완성 가능하다.
//하지만 위와 같은 구현이 조금 어색한 부분이 있다. 인스턴스 자체를 메서드의 매개변수로 전달하기보다는 인스턴스 내부의 컨텐츠에 액세스하는 것이 훨씬 더 좋은 구현이다.
//date.monthsUntilWinterBreak() // Error! //이런 식의 구현이 더 나은 구현이다.




//Introducing self
//구조체 내부에서 정적 속성에 액세스할 때, Self(대문자 S)를 사용한다(Ch11 참고). self(소문자 s)는 이와 비슷하지만, 실제 인스턴스 객체를 나타낸다.
//인스턴스의 값에 액세스하려면 self 키워드를 사용한다. Swift 컴파일러는 이를 매개변수로 메서드에 전달한다.
extension SimpleDate {
    func monthsUntilWinterBreak() -> Int { //이전 메서드와 비교해서, 매개 변수가 없다.
//        months.firstIndex(of: "December")! - months.firstIndex(of: self.month)! //self 사용
        months.firstIndex(of: "December")! - months.firstIndex(of: month)! //self를 생략할 수도 있다.
    }
}
date.monthsUntilWinterBreak() // 2
//self는 생략할 수 있다. self는 인스턴스에 대한 참조이지만, 대부분의 경우 변수 이름만 사용해도 Swift가 추정할 수 있기 때문에 생략할 수 있다.
//항상 self를 사용해서 현재 인스턴스의 속성과 메서드에 액세스할 수 있지만, 대부분의 경우에는 불필요하다.
//보통은 local 변수와 같은 이름의 속성을 명확히 해야 하는 경우에만 self를 사용한다.




//Introducing initializers
//initializer는 새 인스턴스를 생성하기 위해 호출하는 특수한 메서드이다. func 키워드와 개별 적인 메서드 이름 대신 init를 사용한다.
//initializer는 매개 변수를 가질 수 있지만, 반드시 그럴 필요는 없다.
//현재 SimpleDate 구조체의 새 인스턴스를 생성할 때, month 속성에 값을 지정해 줘야 한다.
let date1 = SimpleDate(month: "January")
//매개변수가 없는 initializer를 사용하는 것이 더 효율적일 수도 있다. 이 경우에는 default로 값이 설정되게 된다.
//let date2 = SimpleDate() // Error! //현재는 따로 구현 안 해서 Error
//init를 구현해 default value로 초기화하는 가장 간단한 경로를 생성할 수 있다.
extension SimpleDate {
    init() { //init에는 func 키워드나 이름이 필요하지 않다.
        month = "January"
    }
}
// 1. init에는 func 키워드나 이름이 필요하지 않다.
// 2. 함수와 같이 initializer는 비어있더라도 반드시 매개 변수 목록을 가져야 한다(괄호가 필요하다는 뜻).
// 3. initializer에서 해당 구조체의 모든 stored property에 값을 할당한다.
// 4. initializer는 값을 반환하지 않는다. initializer가 해야하는 작업은 새 인스턴스를 초기화하는 것이다.
let date3 = SimpleDate()
date3.month // January
date3.monthsUntilWinterBreak() // 11
//사용자 경험을 최적화하기 위해, 오늘 날짜를 기준으로 month에 값을 할당해 줄 수 있다. 이는 Foundation 라이브러리의 Date 클래스를 사용해 처리할 수 있다.

//Initializers in structures
//initializer는 인스턴스를 사용하기 전에 모든 속성이 설정되도록 한다.
struct SimpleDate1 {
    var month: String
    var day: Int
    
    init() { //day 속성에 값을 설정하지 않으면 오류가 발생한다.
        month = "January"
        day = 1
    }
    
    func monthsUntilWinterBreak() -> Int {
        months.firstIndex(of: "December")! - months.firstIndex(of: month)!
    }
}
//custom initializer를 사용하면, 더 이상 memberwise initializer를 사용할 수 없다.
//memberwise initializer는 init(month:day:)로 모든 속성을 순서대로 매개변수로 받아 초기화한다.
//let valentinesDay = SimpleDate(month: "February", day: 14) // Error! //custom initializer가 있다면, memberwise initializer를 사용할 수 없다.
//대신, 매개 변수를 사용하는 initializer를 정의해 줘야 한다.
extension SimpleDate1 {
    init(month: String, day: Int) { //매개변수와 속성의 이름이 같기 때문에 self를 사용한다.
        self.month = month
        self.day = day
    }
}
//위의 init() 에서는 속성과 같은 이름의 매개변수가 없었기 때문에 self가 필요하지 않았다.
//custom initializer를 사용하면, memberwise initializer를 사용할 수 없지만, 같은 매개변수의 custom initializer를 정의해서 이전과 같이 사용할 수 있다.
let valentinesDay1 = SimpleDate1(month: "February", day: 14)
valentinesDay1.month // February
valentinesDay1.day // 14

//Default values and initializers
//매개변수가 없는 initializer보다 간단한 방법이 있다. 속성의 default value을 설정하면, memberwise initializer가 이를 고려한다.
struct SimpleDate2 {
    var month = "January" //default value
    var day = 1 //default value
    
    func monthsUntilWinterBreak() -> Int {
        months.firstIndex(of: "December")! - months.firstIndex(of: month)!
    }
}
//initializer가 없어졌지만, 두 가지 방법으로 초기화 할 수 있다.
let newYearsDay2 = SimpleDate2() //default value가 모든 속성에 설정되어 있기 때문에 init()로 초기화 할 수 있다.
newYearsDay2.month // January
newYearsDay2.day // 1
let valentinesDay2 = SimpleDate2(month: "February", day: 14) //custom initializer를 사용하지 않았으므로 memberwise initializer로 초기화한다.
valentinesDay2.month // February
valentinesDay2.day // 14
//설정하고자 하는 값만 따로 매개변수로 전달할 수도 있다(default value가 설정되어 있지 않다면 오류).
let octoberFirst2 = SimpleDate2(month: "October")
octoberFirst2.month // October
octoberFirst2.day // 1
let januaryTwentySecond2 = SimpleDate2(day: 22)
januaryTwentySecond2.month // January
januaryTwentySecond2.day // 22




//Introducing mutating methods
//구조체의 메서드는 mutating 키워드를 사용하지 않으면, 인스턴스의 값을 변경할 수 없다.
//날짜를 하루 증가시키는 메서드를 생성한다(월의 마지막 날짜가 아님을 가정한다).
extension SimpleDate2 {
    mutating func advance() {
        day += 1
    }
}
//mutating method는 구조체의 값을 변경한다. 구조체는 value type이므로, 사용될 때마다 구조체가 복사된다.
//메서드가 속성 중 하나의 값을 변경하면, 원래 인스턴스와 복사된 인스턴스가 더 이상 동일하지 않다.
//메서드에 mutating 키워드를 사용하면, Swift 컴파일러에 해당 메서드가 상수에서 호출되서는 안 된다는 것을 알려준다.
//따라서, Swift는 컴파일 시에 허용할 메서드와 허용해선 안 되는 메서드를 판단할 수 잇다.
//구조체의 상수 인스턴스(let)에서 mutating 메서드를 호출하면, 컴파일러는 오류를 발생시킨다.
//mutating 메서드는 일반 메서드와 마찬가지로, Swift가 자체적으로 self로 인식해 전달 한다. 하지만, mutating 키워드를 추가하면, self에 inout 매개변수를 추가한다.
//mutating method에서의 작업은 외부적으로 type에 의존하는 모든 것에 영향을 끼친다.
//http://blog.davepang.com/post/353




//Type methods
//type property와 마찬가지로, 모든 인스턴스에서 액세스할 수 있는 type method를 사용할 수 있다.
//인스턴스에서가 아닌, type 자체에서 type method를 호출한다. type method를 사용하려면, static 접두어를 사용한다.
//type method는 특정 인스턴스에 대한 작업이 아니라, 전반적인 해당 type에 관한 작업이다.
//예를 들어, type method를 사용해, 유사한 메서드를 구조체 type 자체 메서드로 그룹화 할 수 있다.
struct Math {
    static func factorial(of number: Int) -> Int { //static을 사용해, type method를 정의한다.
        (1...number).reduce(1, *) //for-loop를 사용할 수도 있지만, reduce로 깔끔하게 구현할 수 있다.
    }
}
Math.factorial(of: 6) // 720 //인스턴스가 아닌 Math의 type method를 호출한다.
//독립적인 함수를 많이 사용하긴 대신 관련 함수를 type method로 그룹화 할 수 있다. 여기서 구조체는 namespace와 같은 역할을 한다.




//Adding to an existing structure with extensions
//구조체에 메서드를 추가하지만, 원래의 정의와 뒤섞이고 싶지 않거나, 소스 코드에 액세스할 수 없는 경우에 extension 으로 추가해 줄 수 있다.
//extension에서는 method, initializer, computed property를 추가해 줄 수 있다.
//extension을 사용하면, 코드 구성을 유연하게 할 수 있다.
extension Math {
    static func primeFactors(of value: Int) -> [Int] {
        var remainingValue = value //매개변수로 전달된 값을 계산할 수 있도록 변수에 할당한다.
        var testFactor = 2 //remainingValue를 나눌 값으로 2부터 시작한다.
        var primes: [Int] = []
        while testFactor * testFactor <= remainingValue { //remainingValue를 계속해서 나눠가면서 loop
            if remainingValue % testFactor == 0 {
                primes.append(testFactor)
                remainingValue /= testFactor
            } else {
                testFactor += 1
            }
        }
        if remainingValue > 1 {
            primes.append(remainingValue)
        }
        return primes
    }
}
//primeFactors는 매개변수의 prime factor(소인수)를 찾는다. ex. 81은 [3, 3, 3, 3]을 반환한다.
//이 알고리즘은 효율적이진 않지만, testFactor의 제곱이 remainingValue보다 작도록 최적화 했다. 또, remainingValue는 소수여야 한다.
Math.primeFactors(of: 81) // [3, 3, 3, 3]
//extension은 구조체의 크기와 메모리 레이아웃을 변경해 기존 코드를 손상시킬 수 있으므로 stored property를 추가할 수 없다.

//Keeping the compiler-generated initializer using extensions
//이전에 살펴본 것처럼, custom initializer를 구조체 내부에서 사용하면, 컴파일러가 생성한 memberwise initializer가 사라진다.
//하지만, init()를 extension에 추가하면, 두 가지를 모두 유지할 수 있다.
struct SimpleDate3 {
    var month = "January"
    var day = 1
    
    func monthsUntilWinterBreak() -> Int {
        months.firstIndex(of: "December")! - months.firstIndex(of: month)!
    }
    
    mutating func advance() {
        day += 1
    }
}

extension SimpleDate3 {
    init(month: Int, day: Int) {
        self.month = months[month-1]
        self.day = day
    }
}
//memberwise initializer가 사라지지 않으면서, init(month:day:) 가 추가된다.

