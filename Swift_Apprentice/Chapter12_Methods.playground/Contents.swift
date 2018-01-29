//: Chapter12: Methods

//Method refresher
var numbers = [1, 2, 3]
numbers.removeLast()
numbers

//Turning a function into a method
let months = ["January", "February", "March",
              "April", "May", "June",
              "July", "August", "September",
              "October", "November", "December"]

struct SimpleDate {
    var month: String
    var day: Int
    
    //Initializers are special methods you call to create a new instance
    //Initializers ensure all properties are set before the instance is ready to use
//    init(month: String, day: Int) { //custom initializer를 사용하면 automatic initializer를 사용할 수 없게 된다. //따라서 직접 만들어줘야 한다.
//        self.month = month
//        self.day = day
//    }
    
    func monthsUntilWinterBreak(from date: SimpleDate) -> Int { //관련된 함수를 메서드로 옮겨넣을 수 있다.
        return months.index(of: "December")! - months.index(of: date.month)!
    }
    
    func monthsUntilWinterBreak() -> Int { //No parameter
        return months.index(of: "December")! - months.index(of: month)! //self를 지워도 된다. 스위프트가 알아서 추정한다.
    }
    
    mutating func advance() { //구조체 안의 메서드는 mutating 키워드 없이 인스턴스의 값을 바꿀 수 없다.
        //원래는 상수로 값을 복사해와서 쓰기 때문에 mutating 키워드가 없으면 에러가 난다.
        day += 1
    }
}

extension SimpleDate { //custom initializer를 structure 안에서 추가하면 memberwise initializer가 사라진다.
    //하지만 extension을 사용하면 둘 다 사용할 수 있다.
    init() { //initializer 안에서 모든 stored properties에 접근할 수 있다. //initializer는 return을 하지 않는다.
        month = "March"
        day = 1 //self 안써도 추정한다.
    }
}

let date = SimpleDate()
date.monthsUntilWinterBreak(from: date)

//Introducing self
date.monthsUntilWinterBreak()

//Introducing initializers
let valentinesDay = SimpleDate(month: "February", day: 14)
valentinesDay.month
valentinesDay.day

//Type methods
struct Math {
    static func factorial(of number: Int) -> Int { //Type value처럼 Type method도 있다. //구조체 자체의 메서드 //static으로 선언
        return (1...number).reduce(1, *)
    }
}

Math.factorial(of: 6)

//Adding to an existing structure with extensions
//extension 키워드로 확장. 코드를 간결하게 유지할 수 있다.
extension Math { //extension에서 stored properties를 추가할 수는 없다.
    static func primeFactors(of value: Int) -> [Int] { //인수분해
        var remainingValue = value
        var testFactor = 2
        var primes: [Int] = []
        
        while testFactor * testFactor <= remainingValue {
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






