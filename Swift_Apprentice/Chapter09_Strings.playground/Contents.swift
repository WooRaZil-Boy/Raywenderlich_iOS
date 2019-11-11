//: Chapter9: Strings

//Swift는 성능을 유지하면서 유니 코드 문자를 올바르게 처리하는 몇 안 되는 프로그래밍 언어 중 하나이다.




//Strings as collections
//문자열은 나타내는 각 문자(character)에 컴퓨터 내부에서 사용하는 숫자를 매핑한 것이다.
//string as a collection of characters(문자열은 Collection이다). 문자열은 Collection이므로 다음과 같은 작업을 할 수 있다.
let string = "Matt"
for char in string {
    print(char)
}
//개별 character를 출력한다. Collection에 구현된 프로퍼티와 함수를 사용할 수 있다.
let stringLength = string.count //문자열의 길이를 출력한다.
//let fourthChar = string[3] //Error //String은 int로 서브 스크립트 할 수 없다.
// 'subscript' is unavailable: cannot subscript String with an Int, see the documentation comment for discussion
//character의 크기가 고정되어 있지 않기 때문에, Array처럼 subscript로 액세스할 수 없다. Grapheme(자소, 의미상 구별할 수 있는 가장 작은 단위) cluster의 개념을 이해해야 한다.




//Grapheme clusters
//문자열은 유니코드 문자의 모음으로 구성된다. 보통은 하나의 코드에 정확히 하나의 character가 매핑된다(반대로도 마찬가지).
//하지만, 일부 character는 표현하는 방법이 두 가지가 될 수 있다.
//ex. café의 é는 액센트가 추가된 e 이다. 이 문자(é)는 하나 또는 두 개의 문자로 나타낼 수 있다.
//é를 나타내는 단일 문자 코드는 233 이다. 두 개의 문자로 나타낼 때는 e(101) +  ́(769)로, combining character가 된다.
//combining character는 유니 코드 표준에 정의된 grapheme cluster를 형성한다. 보통 우리가 생각하는 character는 grapheme cluster로 되어 있다.
//grapheme cluster는 Swift의 Character 유형으로 표시된다.
//combining characters의 또 다른 예는 특정 이모티콘에 색을 변경하는 것이다.
//👍(128077) + 🏽 (127997) . 이렇게 thumb-up 이모지에 스킨 톤 character 를 결합하면, 👍🏽 가 출력된다.
//문자열이 collection으로 사용될 때, grapheme cluster를 적용할 수 있다.
let cafeNormal = "café"
let cafeCombining = "cafe\u{0301}" //엑센트가 추가 된다. //e +  ́ = é //다른 단어의 조합이지만 하나로 된다.
//유니코드 문자를 입력하려면 \u{}를 사용하면 된다.
cafeNormal.count // 4
cafeCombining.count // 4
//Swift는 문자열을 grapheme cluster의 모음으로 간주하기 때문에 cafeNormal와 cafeCombining의 count는 모두 4로 같다.
//또한 문자열의 길이를 계산하는 데에는 linear time 이 걸린다.
//grapheme cluster의 수를 확인하려면, 모든 문자를 검토해야 하기 때문에 해당 문자열이 메모리에서 얼마나 공간을 차지할지 한 눈에 판단할 수 없다.
//unicodeScalars 메서드를 사용해, 문자열을 기본 유니코드 포인트로 액세스할 수도 있다.
cafeNormal.unicodeScalars.count // 4 //유니코드로 count
cafeCombining.unicodeScalars.count // 5
//unicodeScalars 별로 출력해 보면 다음과 같다.
for codePoint in cafeCombining.unicodeScalars { //유니코드 별로 출력
    print(codePoint)
}
// 99
// 97
// 102
// 101
// 769

//Indexing strings
//문자열이 grapheme cluster로 구성되어 있기 때문에, 단순히 정수형 subscript로 인덱싱 할 수 없다.
//Swift에서는 혼동의 여지가 있으므로 확실한 구문을 사용해 줘야 한다. 문자열을 인덱싱하려면 특별한 string index type 을 사용해야 한다.
let firstIndex = cafeCombining.startIndex //Int가 아닌 String.Index type 이다.
//Int 대신, String.Index로 subscript할 수 있다.
let firstChar = cafeCombining[firstIndex] //Int로 subscript 할 수 없다. // String.Index로 해야 한다.
//c //firstChar는 grapheme cluster로 된 Character type이 된다.
//비슷하게, 마지막 index를 가져올 수도 있다. 하지만 오류가 난다.
//let lastIndex = cafeCombining.endIndex
//let lastChar = cafeCombining[lastIndex]
//Fatal error: String index is out of bounds
//오류가 발생하는 이유는 endIndex가 실제 마지막 문자열보다 하나 더 뒤의 index를 가리키기 때문이다. lastIndex를 얻으려면 다음과 같이 작업해야 한다.
let lastIndex = cafeCombining.index(before: cafeCombining.endIndex) //그냥 endIndex로 하면 1 범위 벗어난다. //endIndex 바로 앞의 index를 가져온다.
let lastChar = cafeCombining[lastIndex]
//특정 유니코드가 조합되지 않은, 일반 문자열을 사용할 때도 위와 같이 사용해야 오류가 나지 않는다.
let fourthIndex = cafeCombining.index(cafeCombining.startIndex, offsetBy: 3) //startIndex에서 3 뒤의 index를 가져온다.
let fourthChar = cafeCombining[fourthIndex] // é
//여기서 fourthChar는 é이다. é는 위에서 살펴 봤듯이 2개의 유니코드 포인트가 결합된 문자이다. unicodeScalars를 사용해 유니코드 코드 포인트 단위로 액세스할 수 있다.
fourthChar.unicodeScalars.count // 2 //e +  ́ .
fourthChar.unicodeScalars.forEach { codePoint in
    print(codePoint.value) //유니코드 숫자 반환
}
// 101
// 769

//Equality with combining characters
//이렇게 character가 결합되어 있는 경우에는 문자열의 동등 비교하기 까다로워진다.
//ex. c(99) + a(97) + f(102) + é(233)
//  c(99) + a(97) + f(102) + e(101) +  ́(769) //p.188
//위의 예의 두 문자열은 논리적으로 동일하고 화면에 출력될 때도 동일하게 나타난다(동일한 glyph). 하지만, 컴퓨터 내부에서는 다른 방식으로 표현된다.
//많은 프로그래밍 언어는 코드 포인트를 하나씩 비교하기 때문에, 이런 경우에 문자열이 동일하지 않은 것으로 간주한다. 하지만, Swift는 동일하다고 간주한다.
let equal = cafeNormal == cafeCombining // true //다른 언어의 경우 char하나 하나 비교하기에 false이지만, Swift에서는 true
//Swift는 logically same을 비교한다. Swift는 동등 비교 전에 두 문자열을 정규화(canonicalization)하여 동일한 문자 표현이 되도록 변환한다.
//따라서, Swift 동등 비교에서 단일 문자(single character), 결합 문자(combining character)를 사용한 것은 중요하지 않다.
//동등 비교 뿐 아니라, 문자열에 몇 개의 문자가 있는지 판단할 때도(count) 동일한 정규화(canonicalization)가 적용된다.
//따라서 이전에서 본 것처럼 cafeNormal.count와 cafeCombining.count는 모두 4 로 동일하다.




//Strings as bi-directional collections
//문자열을 반대로 바꿔야 할 때(reverse), 뒤에서 부터 iterate 할 수 있다. 하지만, Swift에는 reversed()라는 메서드로 이를 수행할 수 있다.
//Collection에 구현된 메서드 이므로, Array 등에서도 사용할 수 있다.
let name = "Matt"
let backwardsName = name.reversed() //타입이 String이 아니다. ReversedCollection<String> //메모리 효율성 때문에
//reversed()를 사용하면, type에 주의해야 한다. 위의 경우 type은 ReversedCollection<String> 이다.
//이는 String이 아닌, reversed collection 이다. 추가적인 메모리 사용 없이 Collection을 다른 방식으로 사용하는 wrapper라고 사용하면 된다.
//ReversedCollection<String>를 일반 문자열과 마찬가지로 액세스할 수 있다.
let secondCharIndex = backwardsName.index(backwardsName.startIndex, offsetBy: 1) //startIndex에서 1 뒤의 문자의 index
let secondChar = backwardsName[secondCharIndex] // "t"
//실제 String을 사용해야 할 경우에는 문자열로 형 변환할 수 있다.
let backwarsNameString = String(backwardsName)
//하지만 이렇게 String으로 형 변환 하면, 자체적인 메모리 영역을 확보해서 새 문자열(여기서는 원본 문자열의 reversed)을 저장한다.
//따라서, 문자열 전체가 필요하지 않은 경우에는 ReversedCollection<String>으로 사용하는 것이 좋다.




//Raw strings
//원시 문자열(Raw string)은 특수 문자나 문자열 보간(string interpolation)을 피하고자 할 때 유용하다. 입력할 때 보이는 문자열이 그대로 전체 문자열이 된다.
let raw1 = #"Raw "No Escaping" \(no interpolation!). Use all the \ you want!"#
print(raw1)
// Raw "No Escaping" \(no interpolation!). Use all the \ you want!
//# 를 사용하지 않으면, 문자열은 interpolation을 시도하지만, 올바른 형식이 아니기 때문에 오류가 나게 된다.
//반드시 #를 앞 뒤로 한 번만 써야 하는 것은 아니다. 앞 뒤로 #의 숫자만 일치하면 얼마든지 추가해도 문제 없다.
let raw2 = ##"Aren’t we "# clever"##
print(raw2)
// Aren’t we "# clever
//raw string을 사용하면서, interpolation을 사용할 수도 있다.
let can = "can do that too"
let raw3 = #"Yes we \#(can)!"# //Raw String을 사용하면서, interpolation 사용
print(raw3)
// Yes we can do that too!




//Substrings
//문자열 조작 시 자주 하는 작업은 문자열의 일부를 자체 변수로 가져오는, 부분 문자열(substring)을 생성하는 것이다.
//index를 사용해 subscript로 부분 문자열 작업을 해 줄 수 있다.
let fullName = "Matt Galloway"
let spaceIndex = fullName.firstIndex(of: " ")! //첫 번째 공백의 index를 찾는다. //실제 사용 시에는 force unwrap를 자제하는 것이 좋다.
let firstName1 = fullName[fullName.startIndex..<spaceIndex] // "Matt" //String은 Int를 SubScript로 쓸 수 없다. String.Index를 써야 한다.
//open-ended range를 사용할 때 한쪽에만 index를 사용하면, 나머지 하나는 Collection의 시작 또는 끝이라고 유추하게 된다. 따라서 다음과 같이 쓸 수도 있다.
let firstName2 = fullName[..<spaceIndex] // "Matt"
//open-ended range 에서 fullName.startIndex를 생략해도, 컴파일러가 유추해서 Collection의 시작으로 가정한다.
let lastName = fullName[fullName.index(after: spaceIndex)...] // "Galloway"
//지금까지의 Substring 반환형을 살펴보면, String이 아닌 String.SubSequence 타입이다. 실제 String으로 사용하기 위해서는 형 변환해줘야 한다.
let lastNameString = String(lastName) //형 변환
//바로 String으로 변환하지 않고, Substring을 쓰는 이유는 메모리 최적화 때문이다. Substring은 상위 문자열과 저장 공간을 공유한다.
//따라서, Substring 과정에서 여분의 메모리를 추가적으로 사용하지 않는다. String으로 명시적 형 변환을 할 때, 새로운 문자열을 생성하면서 메모리를 쓴다.
//Swift는 Substring 유형을 사용하여, 좀 더 명확하게 구분한다. String과 Substring은 거의 동일하게 작동하며, 필요한 경우 쉽게 변환할 수 있다.



//Character properties
//Character에는 다양한 property 들이 있다.
let singleCharacter: Character = "x"
singleCharacter.isASCII // true //해당 Character가 ASCII 문자 세트에 속하는지 여부를 반환한다.
//ASCII는 American Standard Code for Information Interchange의 약자이다.
let partyFace: Character = "🥳"
partyFace.isASCII // false //해당 이모지는 ASCII 코드에 속하지 않는다.
let space: Character = " "
space.isWhitespace // true //공백 여부를 확인한다.
let hexDigit: Character = "d"
hexDigit.isHexDigit // true //16진 숫자인지 확인한다. 유효한 16진수인지 확인할 때 사용한다.
let notHexDigit: Character = "s"
notHexDigit.isHexDigit // false //16진수는 0 ~ 9, A ~ F의 값을 가지므로 s는 유효한 16진수가 될 수 없다.
//Character를 숫자로 변환할 수 있다. 라틴 문자 외에도 작동한다.
let thaiNine: Character = "๙" //태국 문자로 9
thaiNine.wholeNumberValue // 9
let chineseNine: Character = "九"
chineseNine.wholeNumberValue // 9




//Encoding
//문자열은 unicode의 코드 포인트 모음으로 구성된다. 이 code point의 범위는 0 ~ 114111(0x10FFFF) 까지 이다.
//즉, 코드 포인트를 모두 나타내는 데 필요한 bit 수는 21개 이다. 하지만, 라틴 문자만 표현하는 경우에는 8bit만 사용하면 된다(라틴 문자는 유니코드의 코드 포인트도 작은 수로 되어 있다).
//컴퓨터는 수 십억 개의 트랜지스터로 만들어졌기 때문에 대부분의 프로그래밍 언어의 숫자 유형은 8bit, 16bit, 32bit와 같이 2의 거듭 제곱 bit 크기를 사용한다.
//문자열을 저장할 때, 개별 코드 포인트를 UInt32 와 같이 특정 bit 유형을 지정해 줄 수 있다.
//위에서 설명한 것과 같이, 라틴 문자만 사용하는 경우에는 모든 bit가 필요하지 않기 때문에 저장 공간을 줄여 줄 수 있는데 이렇게, 문자열 저장 방법을 지정하는 것을 encoding 이라 한다.
//위와 같이 32bit 타입으로 인코딩 하는 것을 UTF-32라고 한다. 하지만, UTF-32는 메모리 관리가 비효율적이기 때문에 거의 사용하지 않는다.

//UTF-8
//일반적으로 8bit 코드 단위를 사용하는 UTF-8을 주로 사용한다. UTF-8이 범용적인 이유는 7bit의 ASCII 코드(영문)와 완벽하게 호환되기 때문이다.
//8bit 이상의 코드 포인트가 필요한 문자를 나타내야 할 때에도 7bit까지는 ASCII 코드와 동일하다(UTF-8에 대한 설명이 아니라, 8bit 이상의 코드 포인트 인코딩에 대한 설명).
//7bit를 넘어서는 코드 포인트는 최대 4개의 코드 단위(code unit)를 사용해 해당 코드 포인트를 나타낸다.
//8 ~ 11 bit의 코드 포인트에서는 2개의 코드 단위를 사용한다. 첫 번째 코드 단위의 초기 3 bit는 110이고, 남은 5 bit는 코드 포인트의 처음 5 bit이다.
//두 번째 코드 단위의 초기 2 bit는 10이고, 나머지 6 bit는 코드 포인트의 나머지 6 bit 이다.
//ex. 코드 포인트 0x00BD 는 "½"이다. 이진수로는 10111101 이며, 8bit를 사용한다. UTF-8에서 이것은 11000010와 10111101의 2개의 코드 단위로 구성된다. //p.194
//  110 + 00010, 10 + 111101 //첫 코드는 앞에 000으로 채워줘서 00010이 된다. //https://en.wikipedia.org/wiki/UTF-8
//11 bit 이상에서도 비슷한 방법으로 표현해 준다. 12 ~ 16 bit의 코드 포인트에서는 3 UTF-8 코드 단위를 사용하고, 17 ~ 21 bit의 코드 포인트에서는 4 UTF-8 코드 단위를 사용한다. //p.195
//첫 코드 단위만 110에서 1만 하나씩 더 늘어나고, 뒤의 코드 단위는 모두 10으로 시작한다.
//Swift에서는 utf8을 사용해, UTF-8 인코딩할 수 있다.
let char = "\u{00bd}" // "½"
for i in char.utf8 {
    print(i)
}
// 194 //11000010 위에서 계산한 첫 번째 코드 단위
// 189 //10111101 위에서 계산한 두 번째 코드 단위
//utf8은 unicodeScalars과 같다. 각 값은 UTF-8의 코드 단위(code unit)이다.
let characters = "+\u{00bd}\u{21e8}\u{1f643}" //"+½⇨🙃"
for i in characters.utf8 {
  print("\(i) : \(String(i, radix: 2))") //10진수와 2진수를 모두 출력한다.
}
// 43 : 101011       // + : 1코드 단위 사용

// 194 : 11000010    // ½ : 2코드 단위 사용
// 189 : 10111101

// 226 : 11100010    // ⇨ : 3코드 단위 사용
// 135 : 10000111
// 168 : 10101000

// 240 : 11110000    //🙃 : 4코드 단위 사용
// 159 : 10011111
// 153 : 10011001
// 131 : 10000011
//UTF-8은 UTF-32보다 훨씬 간결하다. 위의 문자의 경우에는 10byte를 사용하여 4개의 코드 포인트를 저장했다.
//UTF-32에서는 16byte(code unit 당 4byte. code point 당 1 code unit, 4 code point)가 필요하다.
//하지만, UTF-8에도 단점이 있는데, 특정 문자열 작업을 처리하려면 모든 바이트를 검사해야 한다는 것이다.
//ex. n 번째 코드 포인트로 이동하려면, n-1 코드 포인트를 지날때 까지 모든 byte를 검사해야 한다. 얼마나 멀리 이동할지 알 수 없기 때문에 단순히 버퍼로 이동할 수 없다.

//UTF-16
//UTF-16은 16 bit 코드 단위를 사용한다. 코드 포인트 1개에 1개의 코드 단위를 사용한다. 17 ~ 21 bit의 코드 포인트는 surrogate pairs를 사용하여 표현한다.
//surrogate pairs는 16 bit 이상의 범위에서 코드 포인트를 나타내는 2개의 UTF-16 코드 단위이다.
//이런 surrogate pairs를 대비해 유니코드 내에는 예약된 공백이 있다. 공백은 low surrogate(0xDC00 ~ 0xDFFF)와 high surrogate(0xD800 ~ 0xDBFF)가 있다.
//반대로 생각할 수 있지만, 여기서 low 와 high는 surrogate로 표시되는 원본 코드 포인트의 bit를 나타낸다.
//🙃 의 코드 포인트는 0x1F643 이다. 이 코드 포인트의 surrogate pairs를 찾는 알고리즘은 다음과 같다. p.197
// 1. 0x10000를 빼면, 0xF643 혹은 이진수로 0000 1111 0110 0100 0011 이 된다.
// 2. 이 20 bit를 2개로 분할 한다. 0000 1111 01 과 10 0100 0011 이 된다.
// 3. 첫 번째 이진수에 0xD800를 더해, 0xD83D 가 된다(high surrogate).
// 4. 두 번째 이진수에 0xDC00를 더해, 0xDE43 가 된다(low surrogate).
//따라서 UTF-16에서 🙃는 코드 단위 0xD83D 0xDE43 으로 표시된다.
//UTF-8과 마찬가지로, UTF-16에 액세스할 수 있다.
for i in characters.utf16 { //"+½⇨🙃"
    print("\(i) : \(String(i, radix: 2))") //10진수와 2진수를 모두 출력한다.
}
// 43 : 101011                  // + : 1 코드 단위 사용

// 189 : 10111101               // ½ : 1 코드 단위 사용

// 8680 : 10000111101000        // ⇨ : 1 코드 단위 사용

// 55357 : 1101100000111101     // 🙃 : 2 코드 단위 사용
// 56899 : 1101111001000011
//위의 예에서 UTF-16을 사용해, UTF-8과 동일한 10byte(5 code unit, 2 code unit 당 2 byte)를 사용했다.
//하지만, 동일한 byte를 사용했어도, UTF-8과 UTF-16의 메모리 사용량은 다를 수 있다.
//ex. 7bit 이하의 코드 포인트로 구성된 문자열은 UTF-8에서보다 UTF-16에서 2배의 공간을 차지한다.
//7bit 이하의 코드 포인트로 구성된 문자열의 경우, 문자열은 해당 범위에 포함된 라틴어 문자로 완전하게 구성되어야 한다. "£"도 여기에 속하지 않는다.
//따라서 UTF-16과 UTF-8의 메모리 사용량은 비슷한 경우가 많다.
//Swift의 String view는 문자열 인코딩을 무시하는 몇 안 되는 언어 중 하나이다. 내부적으로는 UTF-16을 사용해 메모리 사용과 복잡성 사이를 절충한다.

//Converting indexes between encoding views
//위에서 살펴 본 것처럼 index를 사용해서 문자열의 grapheme cluster에 액세스할 수 있다.
let arrowIndex = characters.firstIndex(of: "\u{21e8}")!
characters[arrowIndex] // ⇨ //String.Index 타입
//이 index를 unicodeScalars, utf8, utf16 에서 사용할 index로 변환할 수 있다.
if let unicodeScalarsIndex = arrowIndex.samePosition(in: characters.unicodeScalars) { //String.UnicodeScalarView.Index 유형이 된다.
    characters.unicodeScalars[unicodeScalarsIndex] // 8680
    //unicodeScalars는 grapheme cluster가 유일한 코드 포인트를 표시하므로 하나이다. e +  ́ 와 같인 조합된 경우에는, "e"만 반환한다.
}
if let utf8Index = arrowIndex.samePosition(in: characters.utf8) { //String.UTF8View.Index
    //첫 번째 유일한 코드만을 가져온다.
    characters.utf8[utf8Index] // 226
}
if let utf16Index = arrowIndex.samePosition(in: characters.utf16) { //String.UTF16View.Index
    //첫 번째 유일한 코드만을 가져온다.
    characters.utf16[utf16Index] // 8680
}



