// Copyright (c) 2019 Razeware LLC
// For full license & permission details, see LICENSE.markdown.
/*:
 [Previous Challenge](@previous)
 ## Challenge 4: Merge two lists

 Create a function that takes two sorted linked lists and merges them into a single sorted linked list. Your goal is to return a new linked list that contains the nodes from two lists in sorted order. You may assume the sort order is ascending.
 */
//두 개의 정렬된 list에서 노드를 계속 가져와 새 list에 추가한다.
//두 list가 정렬되어 있으므로, 각 list의 next node를 비교하여 어느 것이 새 list에 추가되어야 하는지 확인할 수 있다.

func mergeSorted<T: Comparable>(_ left: LinkedList<T>,
                                _ right: LinkedList<T>) -> LinkedList<T> {
    guard !left.isEmpty else {
        return right
    }
    
    guard !right.isEmpty else {
        return left
    }
    //양쪽의 list가 비어 있는지 확인한다. 비어 있다면, 다른 list를 반환한다.
    
    var newHead: Node<T>? //정렬된 list에 사용할 새로운 node
    //left와 right의 node를 정렬된 순서로 newHead에 병합한다.
    var tail: Node<T>? //새 list의 tail node. //상수 시간(constant-time)의 append 연산을 허용한다.
    var currentLeft = left.head
    var currentRight = right.head
    
    if let leftNode = currentLeft, let rightNode = currentRight {
        //left와 right의 첫 node를 비교하여 newHead에 할당한다.
        if leftNode.value < rightNode.value {
            newHead = leftNode
            currentLeft = leftNode.next
        } else {
            newHead = rightNode
            currentRight = rightNode.next
        }
        tail = newHead
    }
    
    //위의 첫 node에 대해 작업한 것 처럼, left와 right를 iterate 해서 필요한 node를 선택해 새 list를 정렬되도록 한다.
    while let leftNode = currentLeft, let rightNode = currentRight {
        //while loop는 list 중 하나의 끝에 도달할 때까지 반복된다.
        if leftNode.value < rightNode.value {
            //첫 node에서 한 작업과 같이, left와 right의 첫 node를 비교하여 tail에 연결한다.
            tail?.next = leftNode
            currentLeft = leftNode.next
        } else {
            tail?.next = rightNode
            currentRight = rightNode.next
        }
        tail = tail?.next
    }
    //while 조건을 보면, 두 list 중 한 쪽에 아직 node가 남아 있더라도, 한 개의 list의 순회가 끝나면 loop가 종료된다.
    
    if let leftNode = currentLeft {
        tail?.next = leftNode
    }
    
    if let rightNodes = currentRight {
        tail?.next = rightNodes
    }
    //나머지 남은 list의 node들을 추가한다.
    
    //새 list를 인스턴스화 한다. append() 또는 insert() 메서드를 사용하여 요소를 list에 삽입하는 대신,
    //list의 head와 tail에 대한 참조를 직접 설정해 주면 된다.
    var list = LinkedList<T>()
    list.head = newHead
    list.tail = { //append() 또는 insert()를 사용하지 않고, tail에 대한 참조를 직접 설정해 준다.
        while let next = tail?.next {
            tail = next
        }
        return tail
    }()
    
    return list
}




example(of: "merging two lists") {
    var list = LinkedList<Int>()
    list.push(3)
    list.push(2)
    list.push(1)
    
    var anotherList = LinkedList<Int>()
    anotherList.push(-1)
    anotherList.push(-2)
    anotherList.push(-3)
    
    print("First list: \(list)") // First list: 1 -> 2 -> 3
    print("Second list: \(anotherList)") // Second list: -3 -> -2 -> -1
    let mergedList = mergeSorted(list, anotherList)
    print("Merged list: \(mergedList)") // Merged list: -3 -> -2 -> -1 -> 1 -> 2 -> 3
}
//이 알고리즘의 시간 복잡도는 O(m+n)이다. m의 첫 번째 list의 node 수 이고, n은 두 번째 list의 node 수 이다.

//: [Next Challenge](@next)
