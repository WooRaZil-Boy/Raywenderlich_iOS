//: ## Chapter 1: Expressions, Variables & Constants
//:The computer term given to each digit of a binary number is a **bit** (a contraction of “binary digit”). Eight bits make up a **byte**. Four bits is called a **nibble**.

//: Code comments
// This is a comment. It is not executed. : single line comment

/* This is also a comment.
 Over many..
 many...
 many lines. : multi-line comment */

/* This is a comment.
 /* And inside it
 is
 another comment.
 */
 Back to the first.
 : 다른 언어와 달리 주석을 중첩할 수 있다.
 */

// Print out
print("Hello, Swift Apprentice reader!")

// The remainder operation
28 % 10
(28.0).truncatingRemainder(dividingBy: 10.0) // 소수의 나머지 연산을 할 때는 truncatingRemainder를 써야 한다.

// Shift operations

1 << 3
32 >> 2 //요즘은 임베디드 아닌 이상 사용할 일 거의 없다.

// Math functions
import Foundation

sin(45 * Double.pi / 180) //Foundation import 해야 사용할 수 있다.
cos(135 * Double.pi / 180)
(2.0).squareRoot()

max(5, 10)
min(-5, -10)

max((2.0).squareRoot(), Double.pi / 2)

//Constants

let number: Int = 10 //상수 선언. 값을 바꿀 수 없다.
let pi: Double = 3.14159

//Variables
var variableNumber: Int = 42
variableNumber = 0
variableNumber = 1_000_000 //언더스코어로 자리수를 표시해 줄 수 있다.

var 🐶💩: Int = -1

var counter: Int = 0
counter += 1
// counter = 1
counter -= 1
// counter = 0





