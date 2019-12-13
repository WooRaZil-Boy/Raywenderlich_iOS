// Copyright (c) 2019 Razeware LLC
// For full license & permission details, see LICENSE.markdown.
/*:
 [Previous Challenge](@previous)
 ## Challenge 3: Reverse a linked list

 Create a function that reverses a linked list. You do this by manipulating the nodes so that they’re linked in the other direction.
 */
//LinkedList를 reverse 하려면, 각 node의 next참조를 다른 node를 가리키도록 업데이트해야 한다.
//여러 node에 대한 참조를 관리해야 하므로 까다로운 작업이 될 수 있다.
//간단한 방법은 새로운 임시 LinkedList를 만든 후, push하여 List를 reverse하는 것이다.

extension LinkedList {
    mutating func reverse1() {
        var tempList = LinkedList<Value>() //임시 LinkedList
        for value in self {
            tempList.push(value)
            //현재 LinkedList에서 tempList로 push(앞에서 삽입)한다. List가 역순으로 생성된다.
        }
        
        head = tempList.head //head가 reverse된 list의 node를 가리킨다.
    }
}
//시간 복잡도는 O(n)이다.
//하지만, O(n)는 list를 reverse하기 위한 최적의 시간 복잡도 이지만, 이 알고리즘에는 상당히 큰 리소스가 사용된다.
//reverse()는 임시 list에 각 value를 push할 때마다, 새 node를 생성하고 할당한다.
//이렇게 임시 list를 완전히 사용하지 않고도, 각 node의 다음 포인터를 조작하여 list를 reverse할 수 있다.
//코드는 더 복잡해 지지만, 성능은 상당히 개선된다.

extension LinkedList {
    mutating func reverse2() {
        tail = head //tail에 head를 할당한다.
        
        //순회를 추적하기 위한 두 개의 참조를 생성한다.
        var prev = head
        var current = head?.next
        prev?.next = nil
        
        //각 node는 list에서 다음 node를 가리키고 있다.
        //list를 순회하면서, 각 node가 이전 node를 가리키게 하도록 업데이트 한다. p.85
        //current의 next를 prev로 할당하면, 나머지 list에 대한 참조가 사라지게 된다.
        //따라서 세 번째 참조를 관리해야 한다.
        
        while current != nil {
            let next = current?.next
            current?.next = prev //current node에 새로운 참조 작성
            prev = current //포인터 이동
            current = next //포인터 이동
        } //next node에 대한 새로운 참조가 작성된다.
        
        head = prev //모든 참조를 reverse한 후, head를 list의 마지막 node로 설정한다.
    }
}
//각 노드를 순회하면서, 참조가 이전 node를 가리키게 하도록 한다.




example(of: "reversing a list") {
    var list = LinkedList<Int>()
    list.push(3)
    list.push(2)
    list.push(1)
    
    print("Original list: \(list)") // Original list: 1 -> 2 -> 3
    list.reverse2()
    print("Reversed list: \(list)") // Reversed list: 3 -> 2 -> 1
}
//새로운 reverse() 메서드의 시간 복잡도는 여전히 O(n)이다. 하지만, tempList를 사용하거나 새 node 객체를 생성할 필요 없어 성능은 크게 향상된다.
//: [Next Challenge](@next)
