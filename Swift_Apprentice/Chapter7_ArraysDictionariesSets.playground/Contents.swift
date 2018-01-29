//: Chapter 7 : Arrays, Dictionaries, Sets

//Creating arrays
let evenNumbers = [2, 4, 6, 8] //파이썬 처럼 다른 타입을 섞어 쓸 수는 없다. //let으로 선언했기 때문에 immutable
var subscribers: [String] = [] //빈 배열 선언 //Swift는 타입을 꼭 지정해 줘야 한다.

let allZeros = Array(repeating: 0, count: 5) //[0, 0, 0, 0, 0]
let vowels = ["A", "E", "I", "O", "U"]

//Using properties and methods
var players = ["Alice", "Bob", "Cindy", "Dan"] //mutable
print(players.isEmpty)

if players.count < 2 {
    print("We need at least two players!")
} else {
    print("Let's start!")
}

var currentPlayer = players.first //properties
print(currentPlayer as Any) //배열에서 값이 없을 수도 있으므로 옵셔널을 반환한다.
print(players.last as Any) //Any로 변환해 출력하지 않으면 Warning

currentPlayer = players.min() //function //사전 순에서 먼저 나오는 게 min
print(currentPlayer as Any)

if let currentPlayer = currentPlayer {
    print("\(currentPlayer) will start")
}

//Using subscripting
var firstPlayer = players[0] //0이 첫 인덱스 //옵셔널에 대해 염려할 필요 없다. 서브스크립트에서 없는 인덱스에 엑세스 하면 오류.
print("First player is \(firstPlayer)")

//Using countable ranges to make an ArraySlice
let upcomingPlayersSlice = players[1...2] //인덱스 기준 //배열이 아니다. //값을 복사해 저장. 이후 배열의 값이 변화해도 영향 x
let upcomingPlayersArray = Array(players[1...2]) //배열

//Checking for an element
func isEliminated(player: String) -> Bool {
    return !players.contains(player) //contain으로 요소 존재 여부 확인 //!으로 not
}

print(isEliminated(player: "Bob"))
players[1...3].contains("Bob")

//Appending elements
players.append("Eli") //맨 뒤에 추가
players += ["Gina"]
print(players)

//Inserting elements
players.insert("Frank", at: 5)
print(players)

//Removing elements
var removedPlayer = players.removeLast() //마지막 삭제 //삭제한 요소를 반환
print("\(removedPlayer) was removed")
removedPlayer = players.remove(at: 2) //인덱스로 삭제
print("\(removedPlayer) was removed")

print(players.index(of: "Alice") as Any) //해당 인덱스 반환

//Updating elements
print(players)
players[4] = "Franklin" //인덱스 벗어나면 crash
print(players)
players[0...1] = ["Donna", "Craig", "Brian", "Anna"] //사이즈 안 맞아도 수에 맞춰 update
print(players)

//Moving elements
let playerAnna = players.remove(at: 3)
players.insert(playerAnna, at: 0)
print(players)

players.swapAt(1, 3) //swap
print(players)

players.sort() //정렬
print(players)

//Iterating through an array
let scores = [2, 2, 8, 6, 1, 2, 1]

for player in players {
    print(player)
}

for (index, player) in players.enumerated() {
    print("\(index + 1). \(player)")
}

func simOfElements(in array: [Int]) -> Int {
    var sum = 0
    for number in array {
        sum += number
    }
    return sum
}

print(simOfElements(in: scores))

//Creating dictionaries
var namesAndScores = ["Anna": 2, "Brian": 2, "Craig": 8, "Donna": 6] //[String: Int]
print(namesAndScores)

namesAndScores = [:] //빈 딕셔너리 //초기화
var pairs: [String: Int] = [:] //빈 딕셔너리를 선언할 때는 타입을 지정해 줘야 한다. //추정을 할 수 없기 때문에
pairs.reserveCapacity(20) //범위를 지정해 줄 수 있다.

//Using subscripting
namesAndScores = ["Anna": 2, "Brian": 2, "Craig": 8, "Donna": 6] //[String: Int]
print(namesAndScores["Anna"]) //배열과 달리 인덱스가 아닌 키로 접근한다. //배열과 같이 출력값은 옵셔널
print(namesAndScores["Matt"]) //옵셔널을 반환하기 때문에 배열의 서브스크립트와 달리 crash 되지 않고 nil을 반환한다.

//Using properties and methods
namesAndScores.isEmpty
namesAndScores.count

var bobData = [
    "name": "Bob",
    "profession": "Card Player",
    "country": "USA"
]

bobData.updateValue("CA", forKey: "state") //추가 //update //딕셔너리는 순서가 없다.
bobData["city"] = "San Francisco"

//Updating values
bobData.updateValue("Bobby", forKey: "name") //업데이트도 똑같은 함수 사용. //이전 값을 리턴한다. //add시에는 이전 값이 없으므로 nil 반환
bobData["profession"] = "Mailman" //update도 서브 스크립트를 사용할 수 있다.

//Removing pairs
bobData.removeValue(forKey: "state")
bobData["city"] = nil //키를 제거한다. //키를 유지하고 값만 nil로 바꾸고 싶은 경우라면, updateValue를 사용해야 한다.

//Iterating through dictionaries
for (player, score) in namesAndScores {
    print("\(player) - \(score)")
}

for player in namesAndScores.keys { //키만 출력
    print("\(player), ", terminator: "") //캐리지 리턴 없이 한 줄로 출력
}

for score in namesAndScores.values {
    print("\(score), ", terminator: "")
}

//Running time for dictionary operations
print("some string".hashValue)
print(1.hashValue)
print(false.hashValue)
//해쉬값을 가진 타입이 딕셔너리의 키가 될 수 있다.(unique를 보장)

//Creating sets
let setOne: Set<Int>
var someSet: Set<Int> = [1, 2, 3, 1] //배열과 선언이 같다 //타입 지정해 주지 않으면 배열이 된다.
print(someSet) //중복을 허용하지 않는다. //순서 상관 없다.

//Accessing elements
print(someSet.contains(1))
print(someSet.contains(4))
//배열에서 처럼, first, last를 쓸 수 있지만, 순서 상관 없기 때문에 어떤 값이 나올지 알 수는 없다.

//Adding and removing elements
someSet.insert(5)

let removedElement = someSet.remove(1) //삭제된 값을 반환 //없으면 nil
