//: Chapter 25: Protocol-Oriented Programming

//Introducing protocol extensions
extension String {
    func shout() {
        print(uppercased()) //대문자로 변환
    }
}

"Swift is pretty cool".shout()

protocol TeamRecord {
    var wins: Int { get }
    var losses: Int { get }
    var winningPercentage: Double { get }
}

extension TeamRecord { //Protocol, Struct, Class, Enum 모두 extension 가능하다.
    var gamesPlayed: Int { //extension에서 Protocol을 구현해 주거나(Struct, Class 등) 새로운 속성(computed)을 추가해 줄 수 있다.
        return wins + losses
    }
    
    //반복적으로 구현해야할 것을 extension에서 구현해 줄 수 있다. //기본 protocol 내에서는 구현할 수 없다.
    var winningPercentage: Double { //winningPercentage를 더 이상 명시적으로 구현할 필요 없다.
        return Double(wins) / Double(wins + losses)
    }
}

struct BaseballRecord: TeamRecord {
    var wins: Int
    var losses: Int
    
//    var winningPercentage: Double {
//        return Double(wins) / Double(wins + losses)
//    }
}

let sanFranciscoSwifts = BaseballRecord(wins: 10, losses: 5)
sanFranciscoSwifts.gamesPlayed

//Default implementations
struct BasketballRecord: TeamRecord {
    var wins: Int
    var losses: Int
    let seasonLength = 82
    
//    var winningPercentage: Double { //반복적인 코드가 생긴다. 그리고 대부분의 경우 이 구현이 같을 것이다.
//        return Double(wins) / Double(wins + losses)
//    }
}

let minneapolisFunctors = BasketballRecord(wins: 60, losses: 22)
minneapolisFunctors.winningPercentage

struct HockeyRecord: TeamRecord {
    var wins: Int
    var losses: Int
    var ties: Int
    
    var winningPercentage: Double { //extension에서 구현한 winningPercentage과 달리 무승부를 추가해야 한다.
        return Double(wins) / Double(wins + losses + ties)
    } //이렇게 extension에서 default로 구현하고, 특별히 필요한 경우에만 구현해주면 된다.
}

let chicagoOptionals = BasketballRecord(wins: 10, losses: 6)
let phoenixStridables = HockeyRecord(wins: 8, losses: 7, ties: 1)

chicagoOptionals.winningPercentage // 10 / (10 + 6) == 0.625
phoenixStridables.winningPercentage // 8 / (8 + 7 + 1) == 0.5

//Understanding protocol extension dispatching
protocol WinLoss {
    var wins: Int { get }
    var losses: Int { get }
}

extension WinLoss {
    var winningPercentage: Double {
        return Double(wins) / Double(wins + losses)
    }
}

struct CricketRecord: WinLoss {
    var wins: Int
    var losses: Int
    var draws: Int
    
    var winningPercentage: Double {
        return Double(wins) / Double(wins + losses + draws)
    }
}

let miamiTuples = CricketRecord(wins: 8, losses: 7, draws: 1)
let winLoss: WinLoss = miamiTuples

miamiTuples.winningPercentage // 0.5
winLoss.winningPercentage // 0.53 !!!
//타입에 따라 구현된 winningPercentage이 다르기 때문에 결과가 달라진다.
//사용되는 메서드의 속성은 생성시의 동적인 유형이 아니라, 할당된 변수나 상수의 유형에 따라 달라진다.

//Type constraints
protocol PostSeasonEligible {
    var minimimWinsForPlayoffs: Int { get }
}

extension TeamRecord where Self: PostSeasonEligible { //TeamRecord중 PostSeasonEligible을 구현한 객체에만 적용 //제약 조건
    var isPlayoffEligible: Bool {
        return wins > minimimWinsForPlayoffs
    }
}

protocol Tieable {
    var ties: Int { get }
}

extension TeamRecord where Self: Tieable { //Tieable를 구현한 TeamRecord에만 적용
    var winningPercentage: Double {
        return Double(wins) / Double(wins + losses + ties)
    }
}

struct RugbyRecord: TeamRecord, Tieable {
    var wins: Int
    var losses: Int
    var ties: Int
}

let rugbyRecord = RugbyRecord(wins: 8, losses: 7, ties: 1)
rugbyRecord.winningPercentage // 0.5

//Protocol-oriented benefits
//Programming to interfaces, not implementations
//상속을 지원하지 않는 유형에도 비슷한 효과를 낼 수 있다.
//프로토콜을 사용하면 특정 유형 또는 해당 클래스가 클래스인지 구조체인지에 대해 걱정할 필요가 없다.
//특정 공통 속성과 메서드의 존재에만 신경쓰면 된다.

//Traits, mixins, and multiple inheritance
//프로토콜로 다중 상속과 같은 효과도 낼 수 있다.
protocol TieableRecord {
    var ties: Int { get }
}

protocol DivisionalRecord {
    var divisionalWins: Int { get }
    var divisionalLosses: Int { get }
}

protocol ScoreableRecord {
    var totalPoints: Int { get }
}

extension ScoreableRecord where Self: TieableRecord, Self: TeamRecord { //TieableRecord와 TeamRecord를 구현한 ScoreableRecord
    var totalPoints: Int {
        return (2 * wins) + (1 * ties) //TieableRecord의 ties, TeamRecord의 wins를 각각 사용
    }
}

struct NewHockeyRecord: TeamRecord, TieableRecord, DivisionalRecord, CustomStringConvertible, Equatable { //프로토콜 여러 개를 구현할 수 있다.
    var wins: Int
    var losses: Int
    var ties: Int
    var divisionalWins: Int
    var divisionalLosses: Int
    
    var description: String {
        return "\(wins) - \(losses) - \(ties)"
    }
    static func ==(lhs: NewHockeyRecord, rhs: NewHockeyRecord) -> Bool {
        return lhs.wins == rhs.wins && lhs.ties == rhs.ties && lhs.losses == rhs.losses
    }
}




