//튜플에 여러 Data를 담을 수 있지만, 이럴 경우 튜플은 각기 다른 Type이 되며(문자열 2개가 있는 튜플과 3개가 있는 튜플은 서로 다른 Type이다) 서로 변환하기 쉽지 않다.
//Swift는 Collection으로 여러 Data를 담을 수 있다. Collection은 여러 값을 저장하는 컨테이너이다.
//Collection을 사용 할 때 항상 성능을 염두에 둬야 한다. 흔히 big-O notation 으로 이를 표현한다.

//Introducing big-O notation
//Big-O notation은 실행 시간(running time) 또는 작업이 완료되는 데 걸리는 시간을 설명하는 방법이다. 정확한 시간을 구하는 것이 아니라 상대적인 값을 구한다.
//데이터 양에 상관없이 항상 일정한 상수의 시간이 소요된다면(constant time) O(1)이 된다.
//데이터 양이 늘어남에 따라 선형적으로 소요 시간이 증가한다면(linear time) O(N)이다.
//Big-O notation은 Collection 유형을 처리할 때 특히 중요하다.




//Mutable versus immutable collections
//mutable, immutable의 개념을 먼저 생각해 봐야 한다. 다른 Type을 생성 했을 때와 마찬가지로 Collection을 생성할 때 상수(let) 또는 변수(var)로 선언해야 한다.
//선언 이후 collection을 변경할 칠요 없는 경우 let을 사용해 상수로 설정할 수 있다. 값을 추가, 제거, 업데이트 해야 하는 경우에는 var로 선언해 변수로 설정한다.




//Arrays
//배열은 가장 일반적인 Collection이다. 간단한 목록처럼 여러 값을 저장한다.

//What is an array?
//배열은 동일한 Type의 정렬된 값들의 모음이다. zero-index부터 시작하므로, 마지막 index는 값의 개수 -1이 된다. p.143
//배열의 각 값은 같은 Type이어야 하며, 동일한 값이 여러 번 포함될 수 있다.

//When are arrays useful?
//배열은 항목을 특정 순서로 저장하는 경우 유용하다. 전체 배열을 반복하지 않고 index로 해당 요소를 가져 올 수 있다.




//Creating arrays
//배열을 만드는 가장 쉬운 방법은 array literal를 사용하는 것이다. 이것은 배열의 값을 직접 입력해 주는 방법이다. 쉼표로 구분되고, 대괄호로 묶인다.
let evenNumbers = [2, 4, 6, 8]  //파이썬 처럼 다른 타입을 섞어 쓸 수는 없다. 여기서는 Int 값만 써야 한다. //let으로 선언했기 때문에 immutable
//Type inference 가 적용된다. type은 [Int]가 된다.
var subscribers: [String] = [] //빈 배열 선언 //빈 배열의 경우에는 컴파일러가 Type inference를 할 수 없으므로 Type을 명시적으로 지정해 줘야 한다.
let allZeros = Array(repeating: 0, count: 5) // [0, 0, 0, 0, 0] //모든 값을 default value로 설정한 배열을 생성 한다.
let vowels = ["A", "E", "I", "O", "U"] //상수로 선언되면 변경할 수 없다. //추가(append), 삭제(remove), 변경(subscript) 등이 불가능하다.




//Accessing elements
//배열의 각 값에 액세스할 수 있는 방법은 여러 가지가 있다.

//Using properties and methods
//카드 게임에 참여하는 참가자 이름을 배열에 저장한다.
var players = ["Alice", "Bob", "Cindy", "Dan"] //mutable //참가자가 새로 참여하거나 떠날때 목록을 변경해야 하므로 var로 선언해야 한다.
print(players.isEmpty) // > false //isEmpty 속성으로 배열이 비어 있는 지 확인할 수 있다.

if players.count < 2 { //count 속성으로 배열의 요소 수를 가져올 수 있다.
    print("We need at least two players!")
} else {
    print("Let's start!")
}
// > Let's start!

var currentPlayer = players.first //property //배열의 첫 요소를 가져온다.
print(currentPlayer as Any) //배열이 비어 있다면, players.first에서 nil을 반환한다. warning을 해제하려면 as Any를 뒤에 추가해 준다.
// > Optional("Alice")
print(players.last as Any) //배열의 마지막 요소를 가져온다. //배열이 비어 있다면, players.last에서 nil을 반환한다. warning을 해제하려면 as Any를 뒤에 추가해 준다.
// > Optional("Dan")

currentPlayer = players.min() //method //사전 순에서 먼저 나올 수록 값이 낮아 min이 된다. //index가 아닌 value를 기준으로 한다. //반대로 max()도 있다.
print(currentPlayer as Any) //배열이 비어 있다면, players.min()에서 nil을 반환한다. warning을 해제하려면 as Any를 뒤에 추가해 준다.
// > Optional("Alice")

print([2, 3, 1].first as Any) // > Optional(2)
print([2, 3, 1].min() as Any) // > Optional(1)

//first, last 속성 및 min(), max() 메서드는 배열이 아닌 모든 collection이 가지고 있는 속성과 메서드이다. 이는 프로토콜로 구현되어 있다.

if let currentPlayer = currentPlayer { //optional을 해제해 준다(optional binding).
    print("\(currentPlayer) will start")
}
// > Alice will start

//Using subscripting
//배열의 요소에 액세스하는 가장 보편적인 방법은 subscript를 사용하는 것이다. 대괄호 사이에 index를 사용하여 모든 요소에 액세스할 수 있다.
var firstPlayer = players[0] //첫 요소. 배열의 인덱스는 0부터 시작한다.
print("First player is \(firstPlayer)")
// > First player is "Alice"
//var player = players[4] //배열의 size를 초과하는 index로 subscripting하는 경우 런타임 오류가 발생한다.
// > fatal error: Index out of range
//subscript는 항상 non-optional type을 반환한다. 따라서 존재하지 않는다면 nil을 반환하는 것이 아니라 런타임 오류가 발생한다.

//Using countable ranges to make an ArraySlice
//countable range로 subscript syntax를 사용하면 배열에서 하나 이상의 값을 가져올 수 있다.
let upcomingPlayersSlice = players[1...2] //index가 1...2 인 요소를 가져온다. //시작 값이 최종 값보다 작거나 같고, 배열 범위 내에 있는 index인 경우 사용할 수 있다.
//upcomingPlayersSlice의 Type은 Array가 아니라 원래 배열 타입의 ArraySlice이다.
//ArraySlice<String> type인 이유는 가져온 배열(여기서는 players)과 storage를 공유하고 있다는 것을 명확히 하기 위해서 이다.
//띠라서 이렇게 따로 값을 복사해 저장한다. 이후에 배열의 값이 변화해도 영향 받지 않는다.
print(upcomingPlayersSlice[1], upcomingPlayersSlice[2]) //players의 특정 값을 가져 온 것이므로, upcomingPlayersSlice[0] 처럼 쓰면 오류가 난다.
// > "Bob Cindy\n"
//ArraySlice를 새로운 Array로 변환하는 것은 매우 간단하게 할 수 있다.
let upcomingPlayersArray = Array(players[1...2]) //Array로 변환한다. //Array<String>
print(upcomingPlayersArray[0], upcomingPlayersArray[1])
// > "Bob Cindy\n"

//Checking for an element
//contains(_:)를 사용해, 배열에 특정 요소가 하나 이상 있는지 여부를 확인할 수 있다.
func isEliminated(player: String) -> Bool {
    !players.contains(player) //하나 이상 있는 지 여부
    //Swift 5.1 부터 한 줄 코드로 된 함수의 경우 return을 생략할 수 있다.
}
print(isEliminated(player: "Bob"))
// > false
players[1...3].contains("Bob") // > true //특정 범위에 대해 contains를 사용할 수도 있다.




//Modifying arrays
//요소의 추가, 제거, 업데이트 및 순서 변경 등의 작업을 수행할 수 있다.

//Appending elements
players.append("Eli") //append(_:)로 요소를 배열 가장 뒤에 추가해 줄 수 있다(mutable에서만 가능). //배열은 같은 유형만 저장 가능하므로 Type을 맞춰줘야 한다.
players += ["Gina"] //append(_:)와 같다. += 연산자로 추가 시켜 줄 수도 있다. //단일 요소 뿐 아니라 += ["Gina", "Sam"] 등 여러 요소를 동시에 추가할 수 있다.
print(players)
// > ["Alice", "Bob", "Cindy", "Dan", "Eli", "Gina"]

//Inserting elements
players.insert("Frank", at: 5) //insert(_:at:) 로 원하는 위치에 요소를 삽입해 줄 수 있다. //index 5 자리에 Frank가 들어가고 그 뒤의 요소들은 index가 하나씩 밀린다.

//Removing elements
var removedPlayer = players.removeLast() //removeLast()로 마지막 요소를 배열에서 제거한다. 제거한 값을 반환한다.
print("\(removedPlayer) was removed")
// > Gina was removed
removedPlayer = players.remove(at: 2) //remove(at:) 으로 해당 index의 요소를 배열에서 제거한다. 제거한 값을 반환한다.
print("\(removedPlayer) was removed")
// > Cindy was removed
print(players.firstIndex(of: "Dan") as Any) //해당 요소의 첫 번째 index 반환한다. 요소를 찾지 못하면 nil을 반환한다.
//warning을 해제하려면 as Any를 뒤에 추가해 준다.

//Updating elements
print(players)
// > ["Alice", "Bob", "Dan", "Eli", "Frank"]
players[4] = "Franklin" //update 하려는 요소를 제거하고 다시 추가할 수도 있지만, subscript syntax로 쉽게 구현할 수 있다.
//subscript syntax는 non-optional을 반환하기 때문에 배열의 범위를 벗어나는 index를 사용하면 런타임 오류가 난다.
print(players)
// > ["Alice", "Bob", "Dan", "Eli", "Franklin"]
players[0...1] = ["Donna", "Craig", "Brian", "Anna"] //countable range를 subscript syntax로 사용해 여러 값을 동시에 update할 수 있다.
//꼭 range의 크기가 배열의 크기와 같을 필요 없다. 그 범위에 있는 모든 값을 대체한다.
print(players)
// > ["Donna", "Craig", "Brian", "Anna", "Dan", "Eli", "Franklin"]

//Moving elements
//배열 요소들의 순서를 맞춰주기 위한 작업을 한다.
let playerAnna = players.remove(at: 3)
players.insert(playerAnna, at: 0)
print(players) //이런 식으로 일일이 삭제, 삽입을 할 수도 있다.
// > ["Anna", "Donna", "Craig", "Brian", "Dan", "Eli", "Franklin"]
players.swapAt(1, 3) //위의 remove, insert를 swapAt()으로 구현할 수 있다.
print(players)
// > ["Anna", "Brian", "Craig", "Donna", "Dan", "Eli", "Franklin"]
players.sort() //정렬. sort()는 원본 배열을 변경한다. //sorted() 를 사용하면, 원본 배열을 변경하지 않고 사본을 정렬된 배열 사본을 반환한다.
print(players)
// > ["Anna", "Brian", "Craig", "Dan", "Donna", "Eli", "Franklin"]

//Iterating through an array
let scores = [2, 2, 8, 6, 1, 2, 1]
for player in players { //for-in loop로 배열의 각 요소를 반복할 수 있다. //index가 0부터 player.count-1 까지 players 배열의 모든 요소를 하나씩 가져온다.
    print(player)
}
// > Anna
// > Brian
// > Craig
// > Dan
// > Donna
// > Eli
// > Franklin

for (index, player) in players.enumerated() { //각 요소의 index가 필요한 경우, enumerated() 메서드로 가져올 수 있다. index와 value를 튜플로 반환한다.
    print("\(index + 1). \(player)")
}
// > 1. Anna
// > 2. Brian
// > 3. Craig
// > 4. Dan
// > 5. Donna
// > 6. Eli
// > 7. Franklin

//[Int]를 파라미터로 받아, 요소의 합을 반환하는 함수를 작성한다.
func sumOfElements(in array: [Int]) -> Int {
    var sum = 0
    for number in array { //for-in loop를 사용해 각 요소를 모두 더해서 반환한다.
        sum += number
    }

    return sum
}

print(sumOfElements(in: scores))
// > 22




//Running time for array operations
//배열은 연속적인 block으로 메모리에 저장된다(ex. 10 개의 요소가 있으면, 10 개의 값이 모두 서로의 옆에 나란히 저장된다. 따라서 배열의 성능(performance cost)은 다음과 같다.
// - Accessing elements : 요소에 접근하는 비용은 크지 않다. 배열의 크기에 상관없이 일정 시간 내에 subscript로 접근하므로 fetching에는 O(1)의 비용이 든다.
//  컴파일러가 알아야 할 것은 배열이 시작되는 index와 가져올 요소의 index 뿐이다.
// - Inserting elements : 요소를 삽입하는 비용은 삽입하려는 위치에 따라 다르다.
//      • 배열의 앞 부분에 삽입하는 경우 : 삽입하려는 요소를 위한 공간을 생성하고, 모든 요소를 하나씩 뒤로 이동해야 되기 때문에 배열의 크기에 비례한 시간이 필요하다.
//      이를 선형 시간(linear time)이라 하며 O(n)의 비용이 든다.
//      • 배열의 중간에 삽입하는 경우 : 앞 부분에 삽입하는 경우와 마찬가지로, 삽입하려는 요소를 위한 공간을 생성하고 index 이후의 요소를 하나씩 뒤로 이동해야 되기 때문에 n / 2의 비용이 든다.
//      이는 선형 시간(linear time)이므로 O(n)이다.
//      • 배열의 끝에 삽입하는 경우 : 대부분의 경우에는 append()를 사용해 바로 맨 뒤에 삽입할 수 있으므로 O(1)이다.
//      하지만 배열에 남은 공간이 없다면, 더 큰 크기의 배열을 만들고 이전 배열을 복사해야 되기 때문에 O(n)이 된다. 대부분의 경우가 O(1) 이므로 평균적으로 O(1)의 비용이 든다.
// - Deleting elements : 요소를 삭제하면 배열에 공간이 남게 된다. 모든 배열의 요소는 순차적이어야 하므로, 삭제한 index 뒤의 요소들을 앞으로 이동 시켜야 한다.
//  이는 삽입과 유사하다. 가장 마지막 요소를 삭제하는 경우는 O(1)이고, 그렇지 않은 경우는 O(n)이다.
// - Searching for an element : 찾으려는 요소가 배열의 첫 요소인 경우에는 한 번만에 검색이 종료된다. 하지만, 요소를 발견할 때까지 순차적으로 n번의 검색을 해야 한다.
//  평균적으로 n /2 가 되고 이는 선형적인 시간(linear time)이므로 O(n)이 된다.




//Dictionaries
//dictionary는 정렬되지 않은 key와 value의 쌍으로 구성된다. p.155. key는 고유한 값으로 동일한 key가 두 번 나타날 수 없지만, 다른 key가 동일한 value를 가리킬 수 있다.
//모든 key는 같은 Type이어야 하며, 모든 value도 같은 Type이어야 한다. key와 value가 다른 Type인 것은 상관없다.
//dictionary는 identifier를 사용해 value를 조회하는 경우에 유용하다.
//ex. 책의 목차. chapter의 이름과 페이지 번호를 매핑하여 읽고 싶은 chapter로 쉽게 이동 가능하다.
//배열은 index로 값을 가져온다. index는 정수여야 하며, 모든 index는 순차적이어야 한다. dictionary에서 key는 어떤 Type이든 될 수 있으며, 특별한 순서가 없다.




//Creating dictionaries
//dictionary를 만드는 가장 쉬운 방법은 dictionary literal을 사용하는 것이다. 이것은 key-value 쌍의 목록이다. //쉼표로 구분되고, 대괄호로 묶인다.
//이전 카드 게임의 예에서, 참가자 배열과 점수 배열을 사용해, 참가자에 점수를 매핑하는 Dictionary를 만들 수 있다.
var namesAndScores = ["Anna": 2, "Brian": 2, "Craig": 8, "Donna": 6] //dictionary의 type은 [String: Int]가 된다. //Type inference가 적용된다.
print(namesAndScores) //Dictionary는 Array와 달리 순서가 없기 때문에 정렬을 할 수 없고, 출력할 때마다 결과가 다를 수 있다.
// > ["Craig": 8, "Anna": 2, "Donna": 6, "Brian": 2]
namesAndScores = [:] //빈 dictionary literal //선언 시 사용할 수도 있지만, 기존의 dictionary를 비우는 데 사용할 수도 있다.
var pairs: [String: Int] = [:] //선언과 동시에 빈 dictionary 할당 //빈 dictionary의 경우에는 Type inference를 적용할 수 없으므로 Type을 명시적으로 지정해 줘야 한다.

pairs.reserveCapacity(20) //reserveCapacity(_:)로 key-value를 저장할 공간(용량)을 설정한다. 성능이 최적화 되지만 자동으로 효율적인 할당을 하기에 크게 신경 쓸 필요는 없다.
//Array에서도 사용할 수 있으며, capacity 속성으로 확인해 볼 수 있다. https://zeddios.tistory.com/117
print(pairs.capacity)




//Accessing values
//Array와 마찬가지로, Dictionary에도 value에 액세스하는 여러 가지 방법이 있다.

//Using subscripting
//dictionary는 value에 액세스하기 위한 subscript syntax를 지원한다. 배열과 달리 index가 아닌 key로 액세스한다.
namesAndScores = ["Anna": 2, "Brian": 2, "Craig": 8, "Donna": 6] // Restore the values
print(namesAndScores["Anna"]!) // 2 //반환형은 optional이다. key가 존재하지 않는다면 nil를 반환한다.
namesAndScores["Greg"] // nil
//배열에서는 subscript syntax를 사용할 때, index의 범위를 벗어나면 런타임 오류가 발생하지만 dictionary에서는 optional로 반환한다.
//배열을 사용할 때는 요소를 loop하면서 특정 요소를 찾아야 했다. 하지만 dictionary에서는 모든 key를 반복하지 않고도 특정 key가 있는지 확인할 수 있다.

//Using properties and methods
//dictionary는 배열과 마찬가지로 Collection protocol을 구현한다. 따라서 많은 속성과 메서드를 공유한다.
namesAndScores.isEmpty  //  false
namesAndScores.count    //  4
//dictionary에 요소가 있는지 여부를 확인하려면 isEmpty속성을 사용하는 것이 좋다. count를 사용할 수도 있지만, 이를 계산하기 위해 리소스가 낭비된다. isEmpty는 O(1)이다.




//Modifying dictionaries

//Adding pairs
//새로운 key-value 쌍을 추가한다.
var bobData = [ //[String: String]
    "name": "Bob",
    "profession": "Card Player",
    "country": "USA"
] //mutable 이므로 수정 가능하다.
bobData.updateValue("CA", forKey: "state") //추가 정보를 dictionary에 추가할 수 있다.
bobData["city"] = "San Francisco" //subscript 를 사용해 추가할 수도 있다.

//Updating values
//해당 key에 존재하는 value를 업데이트 한다.
bobData.updateValue("Bobby", forKey: "name") // Bob //updateValue(_:forkey:)를 사용하면, 주어진 key의 value를 새 value로 바꾸고 이전 value를 반환한다.
//업데이트도 똑같은 함수 사용한다. key가 존재하지 않으면, 새로운 key-value를 추가하고 nil을 반환한다(add시에는 이전 값이 없으므로 nil 반환한다).
bobData["profession"] = "Mailman" //update도 subscript를 사용할 수도 있다. //key가 존재하지 않으면, 새로운 key-value를 추가한다.
//Dictionary에서는 add와 update 모두에 updateupdateValue(_:forkey:)와 subscript를 사용한다.
//이전 key가 있으면, update가 되고, key가 없다면 add가 된다.

//Removing pairs
bobData.removeValue(forKey: "state") //해당 key의 value를 제거한다.
bobData["city"] = nil //remove 역시 subscript를 사용할 수 있다. //key의 value로 nil을 지정하면 해당 key-value 쌍이 dictionary에서 제거된다.

var samData: [String: String?] = [
    "name": "Sam",
    "profession": "Card Player",
    "country": "USA"
]
samData["name"] = nil //Dictionary의 value Type이 optional인 경우에도 dictionary[key] = nil 을 사용하면 key를 완전히 제거한다.
print(samData) // > ["country": Optional("USA"), "profession": Optional("Card Player")]
samData.updateValue(nil, forKey: "country")
print(samData) // > ["country": nil, "profession": Optional("Card Player")]
//key는 유지하면서 값만 nil로 설정하려면 updateValue(_:forkey:)를 사용해야 한다.

//Iterating through dictionaries
//for-in loop는 dictionary에서도 사용할 수 있다.
for (player, score) in namesAndScores { //dictionary의 항목은 key-value 쌍이므로 튜플을 사용해야 한다.
    print("\(player) - \(score)")
}
// > Craig - 8
// > Anna - 2
// > Donna - 6
// > Brian - 2

for player in namesAndScores.keys { //keys 프로퍼티로 key만 가져와 loop를 사용할 수 있다.
    print("\(player), ", terminator: "") // no newline
}
print("") // print one final newline
// > Craig, Anna, Donna, Brian,

for score in namesAndScores.values { //values 프로퍼티로 value만 가져와 loop를 사용할 수 있다.
    print("\(score), ", terminator: "")
}
// > 8, 2, 6, 2

//print(_:terminator:) 로 carriage return 없이 한 줄에 출력할 수 있다.




//Running time for dictionary operations
//Dictionary가 어떻게 작동하는지 이해하려면 Hashing을 이해해야 한다. 해싱은 String, Int, Double, Bool 등의 값을 hash value 라는 numeric value으로 변환하는 프로세스이다.
//이 값을 사용하여 해시 테이블의 값을 빠르게 조회할 수 있다. 따라서 Dictionary의 key는 Hashable을 구현해야 하며, 그렇지 않으면 컴파일러 오류가 발생한다.
print("some string".hashValue)
print(1.hashValue)
print(false.hashValue)
//해쉬값을 가진 타입이 Dictionary의 key가 될 수 있다. 프로그램 실행 시 마다 Hash 값은 달라질 수 있다.
//Swift의 모든 기본 유형은 이미 Hashable을 구현하여 해시 값을 가진다. 이 값은 확정적인 값이어야 한다(즉, 동일한 값은 동일한 해시 값을 반환해야 한다).
//그러나 이 해시값을 저장해서 id등으로 사용해서는 안된다. 프로그램을 실행할 때마다 항상 동일하게 유지되지 않기 때문이다.
//Dictionary의 성능은 해시에 따라 달라진다. 좋지 않은 해싱 함수를 사용하면 모든 연산이 linear time, O(n)으로 성능이 저하된다. 하지만 기본 유형에 내장된 Hashable 구현은 최적화 되어 있다.
// - Accessing elements : key의 value를 가져오는 것은 일정한 시간이 걸리므로 O(1)이다. key로 바로 접근할 수 있다.
// - Inserting elements : 요소를 삽입하려면 dictionary는 key의 해시 값을 계산 한 후 해당 해시를 기반으로 데이터를 저장한다. O(1)의 작업 시간이 소요된다.
// - Deleting elements : dictionary는 해시 값을 계산하여 요소를 찾을 위치를 정확히 확인 한 후 제거해야 한다. O(1)의 시간이 소요된다.
// - Searching for an element : 요소에 액세스 하는 데 일정한 시간이 필요하므로 O(1)이다.
//배열과 비교해서 dictionary는 매우 빠른 속도를 보인다. 하지만, 순서가 없다는 것을 유의해야 한다.




//Sets
//집합(Set)은 동일한 Type의 고유 한 값(중복을 허용하지 않는다)의 정렬되지 않은 Collection이다. 따라서 중복되는 값이 없어야 하고 순서가 중요하지 않을 때 매우 유용하다.




//Creating sets
let setOne: Set<Int> = [1] //꺽쇠 괄호 안에 Type을 써서 명시적으로 Set을 선언할 수 있다.

//Set literals
//Set은 자체 literal 선언이 없기 때문에 반드시 명시적으로 선언해 줘야 한다.
let someArray = [1, 2, 3, 1] //Set을 이와 같이 선언해서는 안 된다(Array로 선언 된다). //Type을 따로 지정해 주지 않으면 배열이 된다.
var explicitSet: Set<Int> = [1, 2, 3, 1] //Set을 선언하려면 명시적으로 Type을 선언해 줘야 한다.
var someSet = Set([1, 2, 3, 1]) //이렇게 Set을 선언하면, 컴파일러가 Type Inference를 하도록 해 줄 수 있다.
print(someSet) //중복을 허용하지 않는다. 값은 고유해야 한다. //순서가 상관 없다.
// > [2, 3, 1] but the order is not defined




//Accessing elements
print(someSet.contains(1)) //contains(_:)를 사용해 특정 요소가 있는 지 확인할 수 있다.
// > true
print(someSet.contains(4))
// > false
//Set도 Collection protocol을 구현 했기 때문에, first와 last 속성을 사용할 수 있다. 집합의 한 요소가 반환되는데, 집합은 순서가 없기 때문에 어떤 요소가 반환될지 알 수 없다.




//Adding and removing elements
someSet.insert(5) //insert(_:)를 사용해 집합에 요소를 추가할 수 있다. 해당 요소가 이미 있으면, 중복이 허용되지 않으므로 메서드는 아무것도 수행하지 않는다.

let removedElement = someSet.remove(1) //remove(_:) 로 해당 요소를 집합에서 삭제해 줄 수 있다. //삭제된 요소를 반환한다. 삭제할 요소가 없다면 nil을 반환한다.
print(removedElement!)
// > 1




//Running time for set operations
//set은 dictionary와 매우 유사한 구현을 가지며, 요소가 Hashable해야 한다. 모든 작업의 실행 시간은 dictionary와 같다.
