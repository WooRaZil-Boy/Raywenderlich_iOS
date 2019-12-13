// Copyright (c) 2019 Razeware LLC
// For full license & permission details, see LICENSE.markdown.
/*:
 # Linked List Challenges
 ## Challenge 1: Print in reverse

 Create a function that prints the nodes of a linked list in reverse order.
 */
//재귀를 사용하면, 함수 호출을 Stack 으로 작성할 수 있다. 이 호출 Stack이 unwind 될 때 print만 작성해 주면 된다.

private func printInReverse<T>(_ node: Node<T>?) {
    guard let node = node else { return } //재귀 종료 조건
    //node가 nil 이면(list의 마지막) 재귀호출을 종료한다.
    
    printInReverse(node.next)
    //LinkedList의 끝까지 재귀적으로 순회한다.
    print(node.value) //printInReverse가 재귀적으로 호출되므로, LinkedList의 역순으로 print 된다.
}

func printInReverse<T>(_ list: LinkedList<T>) {
    printInReverse(list.head)
}




example(of: "printing in reverse") {
    var list = LinkedList<Int>()
    list.push(3)
    list.push(2)
    list.push(1)
    
    print("Original list: \(list)") // Original list: 1 -> 2 -> 3
    print("Printing in reverse:")
    printInReverse(list)
    // 3
    // 2
    // 1
}
//List의 각 node를 순회해야 하기 때문에 이 알고리즘의 시간 복잡도는 O(n)이다.
//함수 호출 Stack을 사용하여 각 요소를 처리하므로, 공간 복잡도 또한 O(n)이다.
//: [Next Challenge](@next)
