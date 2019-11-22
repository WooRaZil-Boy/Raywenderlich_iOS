// Copyright (c) 2019 Razeware LLC
// For full license & permission details, see LICENSE.markdown.
/*:
 [Previous Challenge](@previous)
 
 ## #2. Balance Parentheses
 
 Check for balanced parentheses. Given a string, check if there are `(` and `)` characters, and return `true` if the parentheses in the string are balanced.
 ```
 // 1
 h((e))llo(world)() // balanced parentheses
 // 2
 (hello world // unbalanced parentheses
 ```
 */
var testString1 = "h((e))llo(world)()"

//괄호가 균형으로 되어 있는지 판단하기 위해 문자열의 각 문자를 확인해야 한다.
//( 가 있으면 이를 Stack에 push한다. 반대로 )가 있다면 Stack에서 pop한다.

func checkParentheses(_ string: String) -> Bool {
    var stack = Stack<Character>()
    
    for character in string {
        if character == "(" {
            stack.push(character)
        } else if character == ")" {
            if stack.isEmpty {
                return false
            } else {
                stack.pop()
            }
        }
    }
    
    return stack.isEmpty
}
//문자열의 character를 loop하여 "(" 를 push 하고 ")" 를 pop 해서 Stack이 비어 있으면 괄호가 균형적으로 된 문자열인 것이다.
//이 알고리즘의 시간복잡도는 O(n)이고, 여기서 n은 문자열의 문자 수 이다.
//Stack 자료구조를 사용했기 때문에 공간복잡도 역시 O(n)이다.

checkParentheses(testString1) // should be true
