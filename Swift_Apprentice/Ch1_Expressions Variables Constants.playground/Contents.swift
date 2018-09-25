//How a computer works

//Representing numbers
//bit(2지수의 축소)는 0 혹은 1을 나타낸다. 8bit가 1byte가 되고, 4bit는 nibble이라 부른다.
//32-bit CPU 에서는 이진수 11111111111111111111111111111111까지 표현할 수 있고, 이는 4,294,967,295 이다.
//이진수로 모든 것을 표현하는 것은 쓰기나 입력에 오랜 시간이 걸리므로 보통 16진수로 표현한다(0 ~ 9 + a ~ f).

//How code works
//pseudo-code(의사 코드)는 프로그래밍 언어로 작성된 것은 아니지만, 알고리즘을 나타낸다. 단계별 지침 목록과 같다고 할 수 있다.




//Playgrounds
//소프트웨어를 작성하는 도구 집합을 toolchain이라 하며, 코트를 작성하는 툴 체인을 IDE(Integrated Development Environment)라 한다. Swift에서는 주로 Xcode를 쓴다.
//Xcode의 Playground는 완벽한 앱을 만들 필요없이 코드를 빠르게 작성하고 테스트해 볼 수 있다.




//Getting started with Swift

//Code comments
//주석은 '/'를 두 번 입력해서 사용한다(single line comment).
//여러 줄 주석은 /* */ 를 사용한다(multi-line comment).




//Printing out
//인쇄 명령으로 콘솔(디버그 영역)에 출력할 수 있다.
print("Hello, Swift Apprentice reader!")





//Arithmetic operations
//Shift-Enter로 왼쪽의 파란 사이드 바를 바로 실행할 수 있다(현재 커서까지의 코드를 실행하고 다음 행으로 넘어간다).

//Decimal numbers
22 / 7 //이 결과는 3이다. 표현식을 정수로만 사용하면 Swift도 결과를 정수로 만들기 때문이다.
22.0 / 7.0 //이렇게 해야 소수의 결과를 얻게 된다.

//The remainder operation
//나머지 연산은 %로 한다.
28 % 10 //8
(28.0).truncatingRemainder(dividingBy: 10.0) //이렇게 나타낼 수도 있다.

//Shift operations
14 //00001110 를 2자리 만큼 << 하면
56 //00111000

1 << 3
32 >> 2
//두 개 모두 8이 된다.

//Shift operation은 곱셈, 나눗셈을 쉽게 한다. 예전에는 이렇게 처리하는 것이 훨씬 빨랐지만, 현재는 임베디드 시스템이 아닌 이상 사용할 일이 잘 없다.




//Math functions
import Foundation //Foundation import 해야 사용할 수 있다.

sin(45 * Double.pi / 180) // 0.7071067811865475
cos(135 * Double.pi / 180) // -0.7071067811865475
(2.0).squareRoot() // 1.414213562373095
max(5, 10) // 10
min(-5, -10) // -10
max((2.0).squareRoot(), Double.pi / 2) // 1.570796326794897




//Naming data
//Swift에서는 각 데이터를 참조할 때 사용할 수 있는 이름을 지정할 수 있다. 여기에는 데이터의 종류를 나타내는 유형이 있다.

//Constants
let number: Int = 10
let pi: Double = 3.14159 //Float이 더 적은 메모리를 차지하지만, 일반적으로 숫자에 대한 메모리 사용은 크지 않아 대부분 Double을 사용한다.
//number = 0 // Cannot assign to value: 'number' is a 'let' constant : 상수는 변경할 수 없다. 따라서 변경되지 않는 값에 유용하다(ex. 생일).

//Variables
//데이터를 변경해야 할 때는 변수를 사용한다(ex. 계좌 잔고).
var variableNumber: Int = 42
variableNumber = 0
variableNumber = 1_000_000 //언더스코어로 자리수를 표시해 줄 수 있다.

//Using meaningful names
//변수나 상수는 의미하는 바를 명확히 나타내도록 이름 지어야 한다. camel case name을 사용한다.
//Swift는 유니코드 문자를 사용할 수도 있다. 다음과 같이 선언 가능하다.
var 🐶💩: Int = -1




//Increment and decrement
var counter: Int = 0
counter += 1 // counter = 1
counter -= 1 // counter = 0

counter = 10
counter *= 3  // same as counter = counter * 3 // counter = 30
counter /= 2  // same as counter = counter / 2 // counter = 15
