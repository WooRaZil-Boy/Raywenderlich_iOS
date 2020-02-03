// Copyright (c) 2019 Razeware LLC
// For full license & permission details, see LICENSE.markdown.

//Stack은 간단하지만, 여러 프로그램에서 사용되는 자료구조이다.
/*:
 # Stack Challenges
 
 ## #1. Reserve an Array
 
 Create a function that prints the contents of an array in reversed order.
 */
//배열(Array)의 내용을 역순으로 출력하는 함수를 생성한다.




let array: [Int] = [1, 2, 3, 4, 5]

//Stack의 주요 사용 사례 중 하나는 역추적(backtracking)이다.
//일련의 값을 Stack으로 push 한 후, 다시 pop하면 역순으로 배열된다.

func printInReverse<T>(_ array:[T]) {
    var stack = Stack<T>()
    
    for value in array {
        stack.push(value)
    }
    
    while let value = stack.pop() {
        print(value)
    }
}

//노드를 Stack으로 push하는 시간 복잡도는 O(n)이고, 값을 출력하기 위해 Stack을 pop하는 시간복잡도 또한 O(n)이다.
//따라서 전체적인 이 알고리즘의 시간 복잡도는 O(n)이 된다.
//함수 내부에서 Stack을 할당하기 때문에 공간복잡도 또한 O(n)이 된다.


 printInReverse(array)
//: [Next Challenge](@next)
