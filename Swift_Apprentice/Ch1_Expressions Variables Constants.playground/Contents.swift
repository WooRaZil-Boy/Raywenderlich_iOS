//How a computer works
//중앙 처리 장치 (CPU)가 초당 수천만 번 처리되는 것이 컴퓨터.
//CPU는 레지스터라는 작은 메모리 유닛이 있다. 여기에 숫자가 저장되고
//CPU는 RAM(Random Access Memory, 컴퓨터 주 메모리)에서 레지스터로 숫자를 읽어들인다.
//반대로 레지스터에 저장된 숫자를 RAM에 다시 쓸 수 있다.

//Representing numbers
//컴퓨터에서 모든 정보는 숫자로 표현된다. 이미지도 수천 수백 만 개의 픽셀로 이루어져 있는데,
//픽셀은 RGB의 숫자로 이루어져 있다. 컴퓨터에서는 2진수(Binary numbers)를 사용한다.
//하나의 2진수인 비트(bit)는 0 혹은 1을 나타낸다. 4비트는 니블(nibble), 8비트가 1바이트(byte)이다.
//CPU의 비트는 처리할 수 있는 숫자를 나타낸다. 더 큰 숫자를 처리할 수 있지만, 분할해야 한다.
//32-bit CPU 에서는 이진수 11111111111111111111111111111111까지 표현할 수 있고, 이는 4,294,967,295 이다.
//이진수로 모든 것을 표현하는 것은 가독성에 문제가 있으므로 보통 16진수로 표현한다(0 ~ 9 + a ~ f).
//32비트의 최대값을 16진수로 나타내면 ffffffff이 된다. 더 직관적이다.

//How code works
//algorithm을 구현하는 방법을 풀어 쓴 것을 의사코드(pseudo-code)라 한다.
//컴파일러는 작성된 코드를 해석하고, CPU가 실행할 수 있는 명령어로 변환한다.




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
