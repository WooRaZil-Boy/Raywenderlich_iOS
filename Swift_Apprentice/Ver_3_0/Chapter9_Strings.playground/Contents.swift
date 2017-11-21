//: Chapter9: Strings

//Strings as collections
let string = "Matt"
for char in string {
    print(char)
}

let stringLength = string.count
//let fourthChar = string[3] //이거는 에러 //String은 int로 서브 스크립트 할 수 없다.

//Grapheme clusters
let cafeNormal = "café"
let cafeCombining = "cafe\u{0301}" //엑센트가 추가 된다. //e + ` = é //다른 단어의 조합이지만 하나로 된다.

cafeNormal.count // 4
cafeCombining.count // 4

cafeNormal.unicodeScalars.count // 4 //유니코드로 count
cafeCombining.unicodeScalars.count // 5

for codePoint in cafeCombining.unicodeScalars { //유니코드 별로 출력
    print(codePoint)
}

//Indexing strings
let firstIndex = cafeCombining.startIndex //Int가 아닌 String.Index 형
let fitstCahr = cafeCombining[firstIndex] //Int로 서브 스크립트 할 수 없다. // String.Index로 해야 한다.

let lastIndex = cafeCombining.index(before: cafeCombining.endIndex) //그냥 endIndex로 하면 1 범위 벗어난다.
let lastChar = cafeCombining[lastIndex]

let fourthIndex = cafeCombining.index(cafeCombining.startIndex, offsetBy: 3)
let fourthChar = cafeCombining[fourthIndex] // é

fourthChar.unicodeScalars.count // 2 //e + `
fourthChar.unicodeScalars.forEach { codePoint in
    print(codePoint.value) //유니코드 숫자 반환
}

//Equality with combining characters
let equal = cafeNormal == cafeCombining //다른 언어의 경우 char하나 하나 비교하기에 false이지만, Swift에서는 true //logically same을 비교
//스위프트는 비교 전에 정규화를 먼저 진행한다.

//Strings as bi-directional collections
let name = "Matt"
let backwardsName = name.reversed() //타입이 String이 아니다. //메모리 효율성 때문에
let secondCharIndex = backwardsName.index(backwardsName.startIndex, offsetBy: 1)
let secondChar = backwardsName[secondCharIndex] // "t"
let backwarsNameString = String(backwardsName) //String으로 해야 할 경우 형 변환 해줘야 한다.

//Substrings
let fullName = "Matt Galloway"
let spaceIndex = fullName.index(of: " ")!
let firstName = fullName[fullName.startIndex..<spaceIndex] //Matt //String은 Int를 SubScript로 쓸 수 없다. //open-ended range
let lastName = fullName[fullName.index(after: spaceIndex)...] //Galloway //String.SubSequence 타입
let lastNameString = String(lastName) //형 변환 해줘야 한다. //이때 새 메모리를 쓴다. 따라서 위의 단계까지는 모두 메모리 낭비를 줄일 수 있다.

//Encoding
let characters = "+\u{00bd}\u{21e8}\u{1f643}"
let arrowIndex = characters.index(of: "\u{21e8}")!
characters[arrowIndex] // ⇨

if let unicodeScalarsIndex = arrowIndex.samePosition(in: characters.unicodeScalars) {
    characters.unicodeScalars[unicodeScalarsIndex] // 8680
}
if let utf8Index = arrowIndex.samePosition(in: characters.utf8) {
    characters.utf8[utf8Index] // 226
}
if let utf16Index = arrowIndex.samePosition(in: characters.utf16) {
    characters.utf16[utf16Index] // 8680
}


