//Chapter 6: Linked List

//Linked List는 단일방향 sequence를 이룬 값들의 모음이다. 이론적으로 연결 리스트는 배열에 비해 몇 가지 장점이 있다.
// • 리스트의 front에서 insert, remove 할 때 상수 시간(Constant time) 시간복잡도를 가진다.
// • 안정적인 성능
//다이어그램(p.56)에서 알 수 있듯이 연결 리스트는 노드들이 연결되어 있는 것이다(chain of nodes). 노드는 두 가지 역할을 한다.
// 1. 값을 유지한다.
// 2. 다음 노드에 대한 참조(reference)를 유지한다. 해당 참조가 nil이라면 해당 노드가 리스트의 끝이라는 의미이다.
//여기서는 기본적인 연결 리스트의 기능 외에, Swift의 간결한 기능 중 하나인 COW(copy-on-write)를 구현한다.




//Node
public class Node<Value> {
    public var value: Value
    public var next: Node?
    
    public init(value: Value, next: Node? = nil) {
        self.value = value
        self.next = next
    }
}

extension Node: CustomStringConvertible {
    public var description: String {
        guard let next = next else { //next가 존재하지 않으면, 해당 value만 출력(Linked List에서의 마지막 node)
            return "\(value)"
        }
        return "\(value) -> " + String(describing: next) + " "
    }
}

example(of: "creating and linking nodes") {
    let node1 = Node(value: 1)
    let node2 = Node(value: 2)
    let node3 = Node(value: 3)

    node1.next = node2
    node2.next = node3

    print(node1) // 1 -> 2 -> 3
}
//세 개의 노드를 생성하고 연결한다.
//하지만, 노드가 많아지면 위와 같은 방식으로 노드를 연결하는 것이 힘들어진다.
//이 문제를 해결하는 일반적인 방법은 노드 객체를 관리하는 LinkedList를 작성하는 것이다.




//LinkedList
public struct LinkedList<Value> {
    public var head: Node<Value>?
    public var tail: Node<Value>?
    public init() {}
    public var isEmpty: Bool {
        head == nil
    }
}

extension LinkedList: CustomStringConvertible {
    public var description: String {
        guard let head = head else {
          return "Empty list"
        }
        return String(describing: head)
    }
}
//Linked List는 head와 tail을 가지고 있으며, 이는 각 리스트의 첫 노드와 마지막 노드를 가리킨다. p.59




//Adding values to the list
//Linked List에 value를 추가하는 세 가지 방법이 있다.
// 1. push : list의 앞에 node를 추가한다.
// 2. append : list의 뒤에 node를 추가한다.
// 3. insert(after:) : list의 특정 node 뒤에 node를 추가한다.

//push operations
//push는 list의 앞에 value를 추가한다. 이를 head-first insertion 이라고도 한다.
extension LinkedList {
    public mutating func push(_ value: Value) {
        copyNodes()
        head = Node(value: value, next: head)
        if tail == nil { //빈 list에 push하는 경우, 새 node는 head이자, tail이 된다.
            tail = head
        }
    }
}

example(of: "push") {
    var list = LinkedList<Int>()
    list.push(3)
    list.push(2)
    list.push(1)
    
    print(list) // 1 -> 2 -> 3
}

//append operations
//append는 list의 끝에 value를 추가한다. 이를 tail-end insertion 이라고도 한다.
extension LinkedList {
    public mutating func append(_ value: Value) {
        copyNodes()
        guard !isEmpty else { //list가 비어 있는 경우에는 push와 같다(head와 tail을 동일한 새 Node로 업데이트 한다).
            push(value)
            return
        }
        
        tail!.next = Node(value: value)
        //빈 list에 append하는 경우가 아니라면, 새 Node를 생성하고 tail Node의 next에 연결한다.
        //위의 guard 구문에서 list가 비어 있지 않다는 것을 확인했기 때문에 Force unwrapping을 사용한다.
        
        tail = tail!.next
        //새 Node를 tail로 지정한다.
    }
}

example(of: "append") {
    var list = LinkedList<Int>()
    list.append(3)
    list.append(2)
    list.append(1)
    
    print(list) // 1 -> 2 -> 3
}

//insert(after:) operations
//insert(after:) 는 list의 특정 위치에 value를 삽입하며, 두 단계로 이루어진다.
// 1. list에서 특정 node를 찾는다.
// 2. 새 node를 insert 한다.
extension LinkedList {
    public func node(at index: Int) -> Node<Value>? { //값을 insert할 node를 찾는다.
        //주어진 index로 list에서 node를 검색한다.
        //LinkedList는 head Node에서만 list의 Node에 액세스할 수 있으므로 반복 순회를 해야 한다.
        
        var currentNode = head
        var currentIndex = 0
        //현재 Node와 Index를 트래킹할 변수를 생성하고 값을 head로 할당한다.
        
        while currentNode != nil && currentIndex < index { //원하는 index에 도달할 대까지 list의 참조를 이동한다.
            //비어 있는 list이거나, index가 범위를 벗어날 경우에는 nil을 반환하게 된다(tail Node의 next가 nil 이므로).
            currentNode = currentNode!.next
            currentIndex += 1
        }
        
        return currentNode
    }
    
    @discardableResult //@discardableResult 주석을 달면, 메서드의 반환값을 변수로 받지 않아도 warning이 호출되지 않는다.
    public mutating func insert(_ value: Value, after node: Node<Value>) -> Node<Value> {
        copyNodes()
        guard tail !== node else { //insert 하는 index가 list의 마지막이라면(tail Node), append와 같다.
            //메모리 비교를 해야 한다.
            append(value)
            return tail!
        }
        
        node.next = Node(value: value, next: node.next)
        //찾은 Node의 next로 새 Node를 생성하고, 새 Node를 index로 찾은 Node의 next로 연결한다.
        return node.next!
    }
}

example(of: "inserting at a particular index") {
    var list = LinkedList<Int>()
    list.push(3)
    list.push(2)
    list.push(1)
    
    print("Before inserting: \(list)") // Before inserting: 1 -> 2 -> 3
    
    var middleNode = list.node(at: 1)!
    for _ in 1...4 {
        middleNode = list.insert(-1, after: middleNode)
    }
    
    print("After inserting: \(list)") // After inserting: 1 -> 2 -> -1 -> -1 -> -1 -> -1 -> 3
}

//Performance analysis
// • push : head에 node 추가 : O(1)
// • append : tail에 node 추가 : O(1)
// • insert(after:) : after node 뒤에 node 추가 : O(1)
// • node(at:) : 해당 index node 반환 : O(i)
//p.63




//Removing values from the list
//Linked List에서 node를 삭제하는 세 가지 방법이 있다.
// 1. pop : list의 가장 앞 node를 제거한다.
// 2. removeLast : list 끝의 node를 제거한다.
// 3. remove(at:) : list의 특정 node를 제거한다.

//pop operations
//pop은 list의 앞 node를 제거한다. push 만큼이나 간단하게 구현할 수 있다.
extension LinkedList {
    @discardableResult
    public mutating func pop() -> Value? {
        copyNodes()
        defer { //메서드에서 코드 흐름과 상관없이 가장 마지막에 defer 블록이 실행된다. //return 이후에 호출된다.
            head = head?.next //head를 두 번째 node(head의 next)로 할당한다.
            //더 이상 head에 참조가 없으므로 ARC가 제거한다.
            if isEmpty { //list가 비었다면, tail을 nil로 할당한다.
                tail = nil
            }
        }
        
        return head?.value //list에서 제거된 value를 반환한다.
    }
}

example(of: "pop") {
    var list = LinkedList<Int>()
    list.push(3)
    list.push(2)
    list.push(1)
    
    print("Before popping list: \(list)") // Before popping list: 1 -> 2 -> 3
    let poppedValue = list.pop()
    print("After popping list: \(list)") // After popping list: 2 -> 3
    print("Popped value: " + String(describing: poppedValue)) // Popped value: Optional(1)
}

//removeLast operations
//list의 마지막 node를 제거하는 것은 다소 복잡하다.
//tail node에 대한 참조가 있지만, 그 이전 node에 대한 참조 없이 제거할 수 없다(새로 tail node 지정해 줘야 하기 때문에).
extension LinkedList {
    @discardableResult
    public mutating func removeLast() -> Value? {
        copyNodes()
        guard let head = head else { //list가 비어 있다면 반환할 것이 없으므로 nil 반환
            return nil
        }
        
        guard head.next != nil else { //list에 node가 head 하나 뿐인 경우, pop으로 head(유일한 node) 반환
            return pop() //node가 하나인 경우에는 pop과 같다.
        }
        
        //current.next가 nil이 될 때까지(마지막 node 까지) 순회한다.
        //단순히 tail node만 가져오려면, tail로 접근하면 되지만
        //마지막 node를 제거하고 마지막 이전 node를 새로 tail로 지정해줘야 하기 때문에 마지막 이전 node를 알아야 한다.
        var prev = head
        var current = head
        
        while let next = current.next {
            prev = current
            current = next
        }
        
        //current는 마지막 node가 된다.
        prev.next = nil //prev.next의 참조를 제거한다.
        tail = prev //tail의 참조를 업데이트 해 준다.
        
        return current.value
    }
}

example(of: "removing the last node") {
    var list = LinkedList<Int>()
    list.push(3)
    list.push(2)
    list.push(1)
    
    print("Before removing last node: \(list)") // Before removing last node: 1 -> 2 -> 3
    let removedValue = list.removeLast()
    
    print("After removing last node: \(list)") // After removing last node: 1 -> 2
    print("Removed value: " + String(describing: removedValue)) // Removed value: Optional(3)
}
//removeLast는 list 전체를 순회해야 하므로, 비교적 시간복잡도가 큰 O(n) 연산이 필요하다.

//remove(after:) operations
//특정 node를 제거하는 remove(after:)는 insert(after :)와 유사하다.
//제거하려는 node 바로 앞의 node를 찾은 다음 next연결을 해제해야 한다. p.66
extension LinkedList {
    @discardableResult
//    public mutating func remove(after node: Node<Value>) -> Value? {
//        copyNodes()
//        defer { //메서드에서 코드 흐름과 상관없이 가장 마지막에 defer 블록이 실행된다. //return 이후에 호출된다.
//            //defer 블록에서 Node를 연결 해제해 준다.
//            if node.next === tail { //tail를 제거하는 경우에는 tail 참조를 업데이트 해 줘야 한다.
//                //메모리 비교를 해야 한다.
//                tail = node
//            }
//            node.next = node.next?.next
//            //제거하려는 node 바로 앞의 node를 찾아 새로 next 참조를 업데이트 해 준다.
//            //해당 node는 더 이상 참조가 없으므로 ARC에서 해제 된다.
//        }
//
//        return node.next?.value
//    }
    
    
    
    
    //A minor predicament
    //COW 적용 이후, 제대로 동작하지 않는 점을 수정해 준다.
    public mutating func remove(after node: Node<Value>) -> Value? {
        guard let node = copyNodes(returningCopyOf: node) else { //새로운 copyNodes(returningCopyOf:) 메서드를 사용한다.
            return nil
        }
        
        defer { //메서드에서 코드 흐름과 상관없이 가장 마지막에 defer 블록이 실행된다. //return 이후에 호출된다.
            //defer 블록에서 Node를 연결 해제해 준다.
            if node.next === tail { //tail를 제거하는 경우에는 tail 참조를 업데이트 해 줘야 한다.
                //메모리 비교를 해야 한다.
                tail = node
            }
            node.next = node.next?.next
            //제거하려는 node 바로 앞의 node를 찾아 새로 next 참조를 업데이트 해 준다.
            //해당 node는 더 이상 참조가 없으므로 ARC에서 해제 된다.
        }
        
        return node.next?.value
    }
}

example(of: "removing a node after a particular node") {
    var list = LinkedList<Int>()
    list.push(3)
    list.push(2)
    list.push(1)
    

    print("Before removing at particular index: \(list)") // Before removing at particular index: 1 -> 2 -> 3
    let index = 1
    let node = list.node(at: index - 1)!
    let removedValue = list.remove(after: node)
    
    print("After removing at index \(index): \(list)") // After removing at index 1: 1 -> 3
    print("Removed value: " + String(describing: removedValue)) // Removed value: Optional(2)
}
//insert(at:)와 마찬가지로이 remove(after:) 시간 복잡도는 O(1)이지만, 특정 노드에 대한 참조가 필요하므로 실질적인 시간 복잡도는 더 높아지게 된다.

//Performance analysis
// • pop : head의 node 삭제 : O(1)
// • removeLast : tail의 node 삭제 : O(n)
// • remove(after:) : after node 뒤의 node 삭제 : O(1)
//p.68
//기본적인 LinkedList를 구현했지만, 이후부터는 Swift interface의 장점을 이용해 최대한 Swiftty한 구현을 추가한다.




//Swift collection protocols
//Swift standard library에는 특정 유형을 정의하는 protocol이 있다.
// • Tier 1, Sequence : 해당 요소에 대한 순차적 액세스를 한다. 순차 액세스 시, desctructive한 경우도 있다.
//      Using the sequential access may destructively consume the elements.
//      ex. value type에서 for in loop를 사용하는 경우, iterator는 사본이 되기 때문에 nondestructive.
//      하지만, reference type의 경우에는 for in loop 시, iterator가 자기 자신을 참조하기 때문에, 순회 이후 desctructive하다.
//      즉, Sequence는 특정 시점에서 다음 지점의 원소를 꺼내 쓰는 것일 뿐, 다음 순회에서 재시작할지, 이어서 진행할지의 조건은 보증하지 않는다.
//      https://soooprmx.com/archives/7047
//      nondestructive를 지원하려면, Collection을 구현해야 한다.
//      https://developer.apple.com/documentation/swift/sequence
// • Tier 2, Collection : 추가적인 guarantee를 제공한다. nondestructive sequential access를 허용한다.
// • Tier 3, BidirectionalColllection : 양방향(상하, 좌우)으로 이동할 수 있다.
//      앞에서 구현한 LinkedList는 head에서 tail로 일방향으로 이동하기 때문에 BidirectionalColllection이 불가능하다.
// • Tier 4, RandomAccessCollection : BidirectionalColllection은 특정 index로 해당 요소에 액세스하는 시간이
//      다른 요소에 액세스하는 시간과 동일하다면 RandomAccessCollection이 될 수 있다.
//      어느 요소에 액세스하더라도, 같은 시간 내에 호출된다. sequential access와 대조된다.
//      https://en.wikipedia.org/wiki/Random_access
//앞에서 구현한, LinkedList는 두 가지의 경우에 해당한다.
// 1. LinkedList는 Node들의 연결이므로, Sequence protocol을 채택한다.
// 2. Node들의 연결은 유한한(finite) sequence이므로, Collection protocol을 채택한다.




//Becoming a Swift collection
//Collection protocol은 유한(finite) sequence이며, nondestructive sequential access를 제공한다.
//Swift Collection은 여기에 추가적으로 subscript 액세스를 허용하는데, 이를 사용해 index에 collection의 value를 매핑시킬 수 있다.
//ex. Array에서 array[5]와 같이 사용한다. subscript는 대괄호로 정의되고, index와 함께 사용해 Collection의 value를 반환한다.

//Custom collection indexes
//Collection protocol 메서드의 성능은 index의 value에 매핑하는 속도로 정의된다.
//Swift Array에서와 달리, LinkedList는 subscript 연산자를 사용하여 O(1) 연산을 할 수 없다.
//따라서 LinkedList에서의 subscript 연산자를 사용하기 위해 해당 Node에 대한 참조가 포함된 custom index를 정의해야 한다.
//https://developer.apple.com/documentation/swift/collection
extension LinkedList {
    public struct Index: Comparable {
        public var node: Node<Value>?
        
        static public func ==(lhs: Index, rhs: Index) -> Bool {
            switch (lhs.node, rhs.node) {
            case let (left?, right?):
                return left.next === right.next
            case (nil, nil):
                return true
            default:
                return false
            }
        }
        
        static public func <(lhs: Index, rhs: Index) -> Bool {
            guard lhs != rhs else {
                return false
            }

            let nodes = sequence(first: lhs.node) { $0?.next }
            return nodes.contains { $0 === rhs.node }
        }
    }
}

extension LinkedList: Collection { //Collection 구현을 위해서는 다음 변수와 메서드를 구현해야 한다.
    public var startIndex: Index {
        Index(node: head)
        //head를 반환한다.
    }
    
    public var endIndex: Index {
        Index(node: tail?.next)
        //tail.next을 반환한다.
        //마지막으로 액세스 가능한 값 바로 다음 node를 endIndex로 지정한다.
        //tail로 해야 하는 거 아닌가??
    }
    
    public func index(after i: Index) -> Index { //index 증가
        Index(node: i.node?.next) //바로 다음 Node의 index를 반환한다.
    }
    
    public subscript(position: Index) -> Value {
        //subscript는 index를 Collection의 value에 매핑하는 데 사용한다.
        position.node!.value
    }
}

example(of: "using collection") {
    var list = LinkedList<Int>()
    for i in 0...9 {
        list.append(i)
    }

    print("List: \(list)") // List: 0 -> 1 -> 2 -> 3 -> 4 -> 5 -> 6 -> 7 -> 8 -> 9
    print("First element: \(list[list.startIndex])") // First element: 0
    print("Array containing first 3 elements: \(Array(list.prefix(3)))") // Array containing first 3 elements: [0, 1, 2]
    print("Array containing last 3 elements: \(Array(list.suffix(3)))") // Array containing last 3 elements: [7, 8, 9]

    let sum = list.reduce(0, +)

    print("Sum of all values: \(sum)") // Sum of all values: 45
}
//Collection을 구현하면, 해당 프로토콜에서 이미 구현된 여러 메서드와 변수들을 사용할 수 있다.

//Value semantics and copy-on-write
//Swift Collection의 또 다른 중요한 점은 value 들이 semantic(의미론)를 가진다는 것이다.
//이는 copy-on-write(COW)를 사용해 구현한다. COW의 개념을 배열로 확인하면 다음과 같다.
example(of: "array cow") {
    let array1 = [1, 2]
    var array2 = array1 //여기에서는 값을 복사하지 않고 참조를 가지고 있는다.
    
    print("array1: \(array1)") // array1: [1, 2]
    print("array2: \(array2)") // array2: [1, 2]
    print("---After adding 3 to array 2---")
    array2.append(3) //array2가 수정 될 때, array1의 요소는 변경되지 않는다.
    //처음 할 당할 때가 아닌 append가 호출될 때, 사본을 만든다.
    print("array1: \(array1)") // array1: [1, 2]
    print("array2: \(array2)") // array2: [1, 2, 3]
}
//array2가 수정 될 때, array1의 요소는 변경되지 않는다.
//처음 할 당할 때가 아닌 append가 호출될 때, 사본을 만든다. p.72
example(of: "linked list cow") {
    var list1 = LinkedList<Int>()
    list1.append(1)
    list1.append(2)
    var list2 = list1
    print("List1: \(list1)") // List1: 1 -> 2
    print("List2: \(list2)") // List2: 1 -> 2
    
    print("After appending 3 to list2")
    list2.append(3)
    print("List1: \(list1)") //COW 구현 전 List1: 1 -> 2 -> 3     //COW 구현 후 List2: 1 -> 2
    print("List2: \(list2)") // List2: 1 -> 2 -> 3
}
//Node가 class로 구현되었기 때문에 LinkedList에서는 semantic이 구현되지 않는다.
//하지만, LinkedList는 struct로 구현했기 때문에 semantic이 적용되지 않는 것은 심각한 문제이다.
//COW를 구현하면 이 문제가 해결된다. COW로 semantic을 구현하는 방법은 매우 간단하다.
//LinkedList의 내용을 변경하기 전에, 복사본을 만들고 모든 참조(head, tail)을 복사본으로 업데이트 하면 된다.
extension LinkedList {
//    private mutating func copyNodes() {
//        guard !isKnownUniquelyReferenced(&head) else { //Optimizing COW
//            //참조하고 있는 owner의 수를 확인해 최적화 해 준다.
//            //하나의 list만 가지고 계속 작업하는 경우에는(LinkedList를 복사할 필요가 없는 경우)
//            //이 guard에서 종료되므로, 복사가 일어나지 않아 오버헤드를 줄일 수 있다.
//            return
//        }
//
//        guard var oldNode = head else {
//            return
//        }
//
//        head = Node(value: oldNode.value)
//        var newNode = head
//
//        while let nextOldNode = oldNode.next {
//            newNode!.next = Node(value: nextOldNode.value)
//            newNode = newNode!.next
//
//            oldNode = nextOldNode
//        }
//
//        tail = newNode
//    }
    
    
    
    
    //A minor predicament
    //remove(after:)에서 제대로 동작하지 않기 때문에 수정해 준다.
    private mutating func copyNode(returningCopyOf node: Node<Value>?) -> Node<Value>? {
        guard !isKnownUniquelyReferenced(&head) else { //Optimizing COW
            //참조하고 있는 owner의 수를 확인해 최적화 해 준다.
            //하나의 list만 가지고 계속 작업하는 경우에는(LinkedList를 복사할 필요가 없는 경우)
            //이 guard에서 종료되므로, 복사가 일어나지 않아 오버헤드를 줄일 수 있다.
            return nil
        }
        
        guard var oldNode = head else {
            return nil
        }
        
        head = Node(value: oldNode.value)
        var newNode = head
        var nodeCopy: Node<Value>?
        
        while let nextOldNode = oldNode.next {
            if oldNode === node {
                nodeCopy = newNode
            }
            newNode!.next = Node(value: nextOldNode.value)
            newNode = newNode!.next
            oldNode = nextOldNode
        }
        
        return nodeCopy
    }
}
//LinkedList의 기존 Node를 동일한 값을 가진 새 Node로 대체한다.
//COW를 구현하려면, mutating 키워드를 사용한 모든 메서드의 맨 처음에 copyNodes()를 호출하면 된다.
//수정된 메서드는 모두 6개로 다음과 같다. push, append, insert(after:), pop, removeLast, remove(after:)
//다시 위의 linked list cow 예제 코드를 돌려보면, COW가 구현된 것을 알 수 있다.
//하지만, 모든 mutating 메서드를 호출할 때, copyNodes()를 먼저 호출하면서 O(n)의 오버헤드가 추가되게 된다.

//Optimizing COW
//이 추가적인 오버헤드를 완화하기 위한 두 가지 방법이 있다.
//그 중 첫 번째는 LinkedList의 node를 참조하는 owner가 오직 하나라면, 복사를 하지 않는 것이다.

//isKnownUniquelyReferenced
//Swift standard library에는 isKnownUniquelyReferenced 함수가 있다.
//이 함수는 객체에 정확히 하나의 참조가 있는지 여부를 확인한다.
example(of: "isKnownUniquelyReferenced") {
    var list1 = LinkedList<Int>()
    list1.append(1)
    list1.append(2)
    
    print("List1 uniquely referenced: \(isKnownUniquelyReferenced(&list1.head))") //List1 uniquely referenced: true
    var list2 = list1
    print("List1 uniquely referenced: \(isKnownUniquelyReferenced(&list1.head))") //List1 uniquely referenced: false
}
//isKnownUniquelyReferenced를 사용해, node 객체가 공유되는지 여부를 확인할 수 있다.
//copyNodes()에서 참조를 확인해 최적화해 준다.
//위의 linked list cow 예제와 달리, 하나의 list만 가지고 계속 작업하는 경우에는(LinkedList를 복사할 필요가 없는 경우)
//copyNodes()의 isKnownUniquelyReferenced guard에 걸리게 되어 오버헤드를 줄일 수 있다.

//A minor predicament
example(of: "A minor predicament") {
    var list1 = LinkedList<Int>()
    list1.append(1)
    list1.append(2)
    var list2 = list1
    print("List1: \(list1)") // List1: 1 -> 2
    print("List2: \(list2)") // List2: 1 -> 2
    
    print("After appending 3 to list2")
    list2.append(3)
    print("List1: \(list1)") //List2: 1 -> 2
    print("List2: \(list2)") // List2: 1 -> 2 -> 3
    
    print("Removing middle node on list2") //COW
    if let node = list2.node(at: 0) {
        list2.remove(after: node)
    }

    print("List2: \(list2)") //List2: 1 -> 2 -> 3
}
//COW 최적화 이후로, remove 메서드가 더 이상 정상적으로 작동하지 않는다.
//모든 mutate 메서드는 node들을 복사할 수 있으므로(copyNodes), remove(after:) 실행 시에도 복사되어 잘못된 구현이 된다.
//이를 수정하기 위해 새로운 버전의 copyNodes() 메서드를 작성해야 한다.
//수정한 copyNodes() 메서드는 복사된 Node를 반환한다. remove(after:) 메서드도 수정해 줘야 한다.

//Sharing nodes
//두 번째 최적화는 부분적으로 Node를 공유하는 것이다. 이 방법을 사용해 복사를 피할 수 있는 경우가 있다.
//여기에서 모든 경우를 구현하기는 힘들지만, 몇 가지 경우를 구현하고, 어떤 방식으로 작동하는지 살펴본다.
var list1 = LinkedList<Int>()
(1...3).forEach{ list1.append($0) }
var list2 = list1
//이 경우, lsit1과 list2의 참조는 Node를 가리키게 된다. p.77
//이 상태에서 COW가 비활성화된 list2에서 push를 수행한다.
list2.push(0)
//그러면 list1과 list2는 서로 다른 참조를 가진다. 이 경우에는 list1이 list2의 push 작업에 영향을 받지 않는다. 두 list를 출력하면 다음과 같다.
// List1: 1 -> 2 -> 3
// List2: 0 -> 1 -> 2 -> 3
//이 상태에서 list1에 100을 push하면 다음과 같다. p.78
list1.push(100)
// List1: 100 -> 1 -> 2 -> 3
// List2: 0 -> 1 -> 2 -> 3
//이와 같이 head-first insertion은 COW의 오버헤드에 영향 받지 않는다.
