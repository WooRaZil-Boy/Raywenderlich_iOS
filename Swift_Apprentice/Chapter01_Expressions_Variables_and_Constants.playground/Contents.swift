//Code comments
// This is a comment. It is not executed.

// This is also a comment.
// Over multiple lines.

/* This is also a comment.
   Over many..
   many...
   many lines. */

/* This is a comment.
 
 /* And inside it
 is
 another comment.
 */

Back to the first. */




//Printing out
print("Hello, Swift Apprentice reader!")




//Arithmetic operations
//Simple operations
2 + 6
10 - 2
2 * 4
24 / 3

2+6

2+6   // OK
2 + 6 // OK
//2 +6  // ERROR //Consecutive statements on a line must be separated by ';'
//2+ 6  // ERROR //'+' is not a postfix unary operator

//Decimal numbers
22 / 7 //3
22.0 / 7.0 //3.142857142857143

//The remainder operation
28 % 10
(28.0).truncatingRemainder(dividingBy: 10.0)

//Shift operations
1 << 3
32 >> 2

//Order of operations
((8000 / (5 * 10)) - 32) >> (29 % 5)
350 / 5 + 2
350 / (5 + 2)




//Math functions
import Foundation

sin(45 * Double.pi / 180)
// 0.7071067811865475

cos(135 * Double.pi / 180)
// -0.7071067811865475

(2.0).squareRoot()
// 1.414213562373095

max(5, 10)
// 10

min(-5, -10)
// -10

max((2.0).squareRoot(), Double.pi / 2)
// 1.570796326794897




//Naming data
//Constants
let number: Int = 10
let pi: Double = 3.14159
//number = 0 //Cannot assign to value: 'number' is a 'let' constant

//Variables
var variableNumber: Int = 42
variableNumber = 0
variableNumber = 1_000_000

//Using meaningful names
var 🐶💩: Int = -1




//Increment and decrement
var counter0: Int = 0

counter0 += 1
// counter0 = 1

counter0 -= 1
// counter0 = 0

var counter: Int = 0
counter = counter + 1
counter = counter - 1

counter = 10

counter *= 3  // same as counter = counter * 3
// counter = 30

counter /= 2  // same as counter = counter / 2
// counter = 15
