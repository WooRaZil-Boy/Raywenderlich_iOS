//Node
example(of: "creating and linking nodes") { //p.25
    let node1 = Node(value: 1)
    let node2 = Node(value: 2)
    let node3 = Node(value: 3)
    
    node1.next = node2
    node2.next = node3
    
    print(node1)
}




//LinkedList

//Adding values to the list
//push : head에 추가 O(1)
example(of: "push") {
    var list = LinkedList<Int>()
    list.push(3)
    list.push(2)
    list.push(1)
    
    print(list)
}

//append : tail에 추가 O(1)
example(of: "append") {
    var list = LinkedList<Int>()
    list.append(1)
    list.append(2)
    list.append(3)
    
    print(list)
}

//insert(after:) : after 뒤에 추가 O(1)
//그러나 after 노드를 찾는 node(at:)이 O(i)가 된다.
example(of: "inserting at a particular index") {
    var list = LinkedList<Int>()
    list.push(3)
    list.push(2)
    list.push(1)
    
    print("Before inserting: \(list)")
    
    var middleNode = list.node(at: 1)!
    for _ in 1...4 {
        middleNode = list.insert(-1, after: middleNode)
    }
    print("After inserting: \(list)")
}

//Performance analysis p.31




//Removing values from the list
//pop : head 삭제. O(1)
example(of: "pop") {
    var list = LinkedList<Int>()
    list.push(3)
    list.push(2)
    list.push(1)
    
    print("Before popping list: \(list)")
    let poppedValue = list.pop()
    print("After popping list: \(list)")
    print("Popped value: " + String(describing: poppedValue))
}

//removeLast : tail 삭제 O(n)
example(of: "removing the last node") {
    var list = LinkedList<Int>()
    list.push(3)
    list.push(2)
    list.push(1)
    
    print("Before removing last node: \(list)")
    let removedValue = list.removeLast()
    print("After removing last node: \(list)")
    print("Removed value: " + String(describing: removedValue))
}

//remove(after:) : after 뒤의 노드 삭제 O(1)
//그러나 after 노드를 찾는 node(at:)이 O(i)가 된다.
example(of: "removing a node after a particular node") {
    var list = LinkedList<Int>()
    list.push(3)
    list.push(2)
    list.push(1)
    
    print("Before removing at particular index: \(list)")
    let index = 1
    let node = list.node(at: index - 1)!
    let removedValue = list.remove(after: node)
    
    print("After removing at index \(index): \(list)")
    print("Removed value: " + String(describing: removedValue))
}

//Performance analysis p.35




//Becoming a Swift collection
example(of: "using collection") {
    var list = LinkedList<Int>()
    for i in 0...9 {
        list.append(i)
    }
    
    print("List: \(list)")
    print("First element: \(list[list.startIndex])")
    print("Array containing first 3 elements: \(Array(list.prefix(3)))")
    print("Array containing last 3 elements: \(Array(list.suffix(3)))")
    
    let sum = list.reduce(0, +)
    print("Sum of all values: \(sum)")
}




//Value semantics and copy-on-write
example(of: "array cow") {
    let array1 = [1, 2]
    var array2 = array1
    
    print("array1: \(array1)")
    print("array2: \(array2)")
    
    print("---After adding 3 to array 2---")
    array2.append(3)
    print("array1: \(array1)")
    print("array2: \(array2)")
    //array2가 변경되더라도, array1이 변경되지 않는다. 배열은 copy-on-write이기 때문이다.
    //내부적으로, array2.append()가 호출될 때 복사본을 만든다. p.39
}

example(of: "inked list cow") {
    var list1 = LinkedList<Int>()
    list1.append(1)
    list1.append(2)
    
    print("List1 uniquely referenced: \(isKnownUniquelyReferenced(&list1.head))")
    //isKnownUniquelyReferenced 함수는 객체에 정확히 하나의 참조가 있는 지 여부를 반환한다. true
    var list2 = list1
    print("List1 uniquely referenced: \(isKnownUniquelyReferenced(&list1.head))")
    //isKnownUniquelyReferenced 함수는 객체에 정확히 하나의 참조가 있는 지 여부를 반환한다. false
    
    print("List1: \(list1)")
    print("List2: \(list2)")
    
    print("After appending 3 to list2")
    list2.append(3)
    print("List1: \(list1)")
    print("List2: \(list2)")
    //그러나 지금까지 만든 LinkedList는 copy-on-write가 적용되지 않는다.
    //기본적으로 reference 타입의 Node(class)를 사용했기 때문이다(LinkedList는 struct로 구현).
    //COW로 만드는 방법은, LinkedList의 내용을 변경 하기 전에 복사본을 만들고 모든 참조(head, tail)를 새로 복사본에 업데이트 하면 된다.
}




