// Copyright (c) 2019 Razeware LLC
// For full license & permission details, see LICENSE.markdown.
/*:
 [Previous Challenge](@previous)
 ## Challenge 2: Find the middle node

 Create a function that finds the middle node of a linked list.
 */
//연결리스트(Linked List)의 중간 노드(node)를 찾는 함수를 만든다. 예를 들면 다음과 같다.




//해결 방법 중 하나는 2개의 참조를 사용해, Node를 순회하는 것이다. 하나의 참조는 다른 것 보다 2배 빠르게 설정한다.
//빠른 참조가 끝에 도달하면, 느린 참조는 리스트의 중간에 있게 된다.

func getMiddle<T>(_ list: LinkedList<T>) -> Node<T>? {
    var slow = list.head
    var fast = list.head
    
    while let nextFast = fast?.next {
        fast = nextFast.next
        //다음 node가 있는 경우, 해당 node는 nextFast가 되어 slow보다 2배 빠르게 순회한다.
        //fast는 두 번 업데이트 된다.
        slow = slow?.next //slow는 한 번만 업데이트 된다.
    }
    
    return slow
}
//이렇게 구현하는 것을 runner’s technique 라고 한다.




example(of: "getting the middle node") {
    var list = LinkedList<Int>()
    list.push(3)
    list.push(2)
    list.push(1)
    
    print(list) // 1 -> 2 -> 3
    
    if let middleNode = getMiddle(list) {
        print(middleNode) // 2 -> 3
    }
}
//리스트의 끝까지 순회 하기 때문에 이 알고리즘의 시간 복잡도는 O(n) 이다. 
//runner’s technique은 LinkedList와 관련된 다양한 문제를 해결하는 데 도움이 된다.
//: [Next Challenge](@next)
