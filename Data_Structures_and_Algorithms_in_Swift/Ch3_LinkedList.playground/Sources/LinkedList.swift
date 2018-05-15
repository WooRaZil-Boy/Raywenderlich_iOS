public struct LinkedList<Value> { //p.26
    public var head: Node<Value>? //첫 노드
    public var tail: Node<Value>? //마지막 노드
    
    public init() {}
    
    public var isEmpty: Bool {
        return head == nil
        //처음부터 꼬리를 물며 노드가 붙기 때문에 첫 노드 존재 여부로 비었는지를 알 수 있다.
    }
}

extension LinkedList: CustomStringConvertible {
    //CustomStringConvertible을 구현해, String으로 변환하거나 print 함수 사용시 반환할 값을 지정해 준다.
    public var description: String {
        //description 변수를 설정하면 CustomStringConvertible이 구현된다.
        guard let head = head else {
            //head가 없다면 빈 리스트
            return "Empty List"
        }
        
        return String(describing: head)
        //head 노드를 출력하면, 재귀적으로 리스트의 끝까지 출력하게 된다.
    }
}

//링크드 리스트는 선형 단방향 시퀀스로 정렬된 값의 모음이다. p.24
//배열과 비교해 몇 가지 장점이 있다.
//• 첫 요소 삽입과 삭제 시 O(1)으로 배열보다 빠르다.
//• 안정적인 성능




//MARK: - Adding values to the list
extension LinkedList {
    //Node 객체를 관리하기 위한 몇 가지 인터페이스 들이 있다. 그 중 값을 추가하는 데에는 세 가지 방법이 있다.
    //1. push : 리스트의 앞에 값을 추가한다. O(1)
    //2. append : 리스트의 끝에 값을 추가한다. O(1)
    //3. insert(after:) : 리스트의 특정 노드 다음에 값을 추가한다. O(1) + O(i)
    public mutating func push(_ value: Value) {
        //push : head-first insertion 이라고도 하며, 리스트의 앞에 값을 추가한다.
        copyNodes()
        head = Node(value: value, next: head)
        //head에 새로운 노드를 생성하고, 이전 head를 다음 객체로 가리키게 한다.
        
        if tail == nil { //빈 리스트에 처음으로 노드를 추가한다면
            tail = head
            //tail과 head가 같다.
        }
    }
    
    public mutating func append(_ value: Value) {
        //append : tail-end insertion 이라고도 하며, 리스트의 맨 뒤에 값을 추가한다.
        copyNodes()
        guard !isEmpty else {
            //비어 있다면(빈 리스트에 처음으로 노드를 추가한다면)
            push(value) //push로 대체할 수 있다.
            return
        }
        
        tail!.next = Node(value: value)
        //현재 마지막 노드가 다음 객체로 새로 만든 노드를 가리키게 하고
        tail = tail!.next
        //새로 만든 객체를 tail로 지정해 준다.
        //새로 노드를 만들어 tail로 지정하면 이전 tail의 참조가 사라지기 때문에 다른 식으로 구현해야 한다.
    }
    
    //insert(after:) : 특정 위치에 값을 삽입하며 두 단계가 필요하다.
    public func node(at index: Int) -> Node<Value>? {
        //1. 리스트에서 특정 노드 찾기
        var currentNode = head
        //LinkedList는 head에서만 list의 노드에 접근할 수 있으므로 loop를 해야 한다.
        var currentIndex = 0 //현재 인덱스(head, 0)
        
        while currentNode != nil && currentIndex < index {
            //현재 노드가 nil이 아니고(마지막 노드인 tail 이후부터는 nil이 된다)
            //현재 인덱스가 찾으려는 index보다 작으면 loop. index 도달할 때까지 loop
            currentNode = currentNode!.next //currentNode를 다음 노드로 옮긴다.
            currentIndex += 1 //currentIndex를 하나 증가 시킨다.
        }
        
        return currentNode //찾으려는 index의 노드가 currentNode가 되어 반환된다.
    }
    
    @discardableResult
    //@discardableResult를 설정하면, 반환한 result 값을 받아 사용하지 않고 무시할 수 있다.
    public mutating func insert(_ value: Value, after node: Node<Value>) -> Node<Value> {
        //2. 새 노드 삽입. after 뒤의 위치에 value 값을 추가한다.
        //insert(after:) : 특정 위치에 값을 삽입한다.
        copyNodes()
        guard tail !== node else {
            //tail 노드와 같다면(단순히 값이 같은 게 아닌, 메모리 주소까지 같아야 한다)
            //삽입하려는 노드의 위치가 tail 뒤라면
            append(value) //append로 대체할 수 있다.
            return tail!
        }
        
        node.next = Node(value: value, next: node.next)
        //이전 노드의 next를 객체로 참조하는 새 노드를 생성하고 해당 노드 뒤로 새로 연결한다.
        
        return node.next! //새 노드 반환
    }
}




//MARK: - Removing values from the list
extension LinkedList {
    //노드 제거를 위한 메서드는 세 가지가 있다.
    //1. pop : 리스트 앞의 값을 제거한다.
    //2. removeLast : 리스트 끝의 값을 제거한다.
    //3. remove(at:) : 리스트의 특정 위치 값을 제거한다.
    @discardableResult
    public mutating func pop() -> Value? {
        //pop : 리스트 앞의 값을 제거한다. push의 역이라 생각하면 된다.
        copyNodes()
        defer {
            //defer는 현재 스코프를 벗어날 때 해당 코드를 실행한다
            head = head?.next
            //head를 뒤로 한 칸 옮긴다.
            //삭제되는 이전 head노드는 참조가 사라지므로 ARC가 정리한다.
            
            if isEmpty {
                //삭제 후, 리스트가 비어있는 경우엔
                tail = nil
                //tail을 nil로 설정해 준다.
            }
        }
        
        return head?.value
        //리스트에서 제거된 값을 반환한다. 리스트가 비어있을 경우가 있으므로 optional
    }
    
    @discardableResult
    public mutating func removeLast() -> Value? {
        //removeLast : 리스트의 마지막 노드를 제거한다.
        //마지막 노드에 대한 참조가 있지만(tail), tail 바로 앞의 노드에 대한 참조가 없으므로 제거하는 게 쉽지 않다.
        //따라서 순회를 통해 tail 바로 이전 노드를 찾아야한다.
        copyNodes()
        guard let head = head else {
            //head가 nil이라면 빈 리스트이므로 할 것이 없다.
            return nil
        }
        
        guard head.next != nil else {
            //head의 다음 노드가 없다면 head이자 tail인 노드 하나만 존재하는 경우이다.
            return pop() //pop으로 대체
        }
        
        var prev = head //이전 노드
        var current = head //현재 노드
        
        while let next = current.next { //current.next가 nil이 될 때까지(tail) 노드를 순회한다.
            prev = current
            current = next
            //하나씩 다음 노드로 이동한다.
        }
        //while 문이 종료되면 current는 tail이 된다.
        
        prev.next = nil //tail 바로 이전 노드에서 다음 객체(tail)의 참조를 해제한다. //삭제
        tail = prev //tail 업데이트
        
        return current.value //제거되는 노드를 반환한다.
    }
    
    @discardableResult
    public mutating func remove(after node: Node<Value>) -> Value? {
        //remove(after:) : after 뒤의 노드 삭제. insert(after:)와 비슷하다. p.34
        //먼저 제거하려는 노드 바로 앞에 있는 노드를 찾은 다음 next 참조를 해제해야 한다.
        copyNodes()
        defer {
            //defer는 현재 스코프를 벗어날 때 해당 코드를 실행한다
            if node.next === tail {
                //삭제한 노드 (after의 다음 노드)가 tail 이라면
                tail = node
                //after 노드를 tail로
            }
            
            node.next = node.next?.next
            //삭제한 노드의 다음 노드를 after 노드의 다음 노드로 붙인다. (after - [deleted] - next)
            //삭제한 노드 이후의 노드들을 하나씩 앞으로 땡긴다.
        }
        
        return node.next?.value
        //제거되는 값을 반환. after가 tail이면 삭제할 값이 없으므로 optional
    }
}




//MARK: - Swift collection protocols
extension LinkedList: Collection {
    //Swift 표준 라이브러리에는 특정 유형에 대해 예상되는 것을 정의하는 데 도움이 되는 프로토콜이 있다.
    //이 프로토콜들 각각은 특성 및 성능에 대한 확실한 보장을 한다.
    //이런 프로토콜 중 collection protocol이라 부르는 것이 4가지 있다.
    //Tier 1. Sequence : 시퀀스 유형은 요소에 순차적으로 접근할 수 있다.
    //Tier 2. Collection : 컬렉션 유형은 시퀀스 유형의 보완이다. 유한하며, 반복적인 접근을 할 수 있다.
    //Tier 3. BidirectionalColllection : 양방향 이동을 할 수 있는 콜 유형이다.
    //Tier 4. RandomAccessCollection : 특정 인덱스 요소에 접근하는 데 일정한 시간이 소요되는 BidirectionalColllection
    //LinkedList는 Sequence, Collection이다 (한 쪽으로만 이동하므로 BidirectionalColllection이 아니고,
    //head에 접근하는 것이 다른 인덱스에 접근하는 것보다 빠르므로 RandomAccessCollection이 아니다).
    //https://academy.realm.io/kr/posts/try-swift-soroush-khanlou-sequence-collection/
    
    //Becoming a Swift collection
    //컬렉션 유형은 유한하며, 반복적인 접근을 할 수 있다. Swift Collection는 subscript operator로 액세스할 수도 있다.
    
    //Custom collection indexes
    //컬렉션 protocol의 성능은 해당 인덱스 값에 액세스할 수 있는 속도에 크게 영향을 받는다.
    //LinkedList는 Array와 달리 subscript로 접근할 수 없다(O(1)). 따라서 해당 노드에 대한 참조가 포함된 사용자 지정 인덱스를 정의해야 한다.
    public struct Index: Comparable { //Index를 사용하여 Collection 요구 사항 충족 시킨다.
        //노드를 매핑하는 구조체
        public var node: Node<Value>?
        
        static public func ==(lhs: Index, rhs: Index) -> Bool {
            //각 노드의 일치 여부를 비교한다.
            switch (lhs.node, rhs.node) {
            case let (left?, right?):
                return left.next === right.next
                //각 노드들이 가리키는 다음 노드가 같으면 true. 다르면 false
            case (nil, nil):
                //각 노드들이 가리키는 다음 노드가 없다면 true(tail)
                return true
            default:
                return false
            }
        }
        
        static public func <(lhs: Index, rhs: Index) -> Bool {
            guard lhs != rhs else {
                //각 비교하려는 노드들이 같지 않아야(가리키는 다음 노드가 달라야) 한다.
                return false
            }
            
            let nodes = sequence(first: lhs.node) { $0?.next }
            //시퀀스화(단 한 번만 loop할 수 있다). lhs의 노드를 시작으로, 각 노드들이 가리키는 다음 노드를 묶어 nodes로 만든다.
            //결국 LinkedList의 lhs노드 포함한 그 뒤의 모든 요소들이 순차적으로 sequence(nodes)로 된다.
            
            return nodes.contains { $0 === rhs.node }
            //nodes가 rhs 노드를 포함하고 있는 지 여부
            //포함하고 있으면, lhs < rhs가 true가 되고, 아니라면 false가 된다.
        }
    }
    
    public var startIndex: Index {
        return Index(node: head)
        //startIndex는 head의 인덱스
    }
    
    public var endIndex: Index {
        return Index(node: tail?.next)
        //endIndex는 마지막 액세스 가능한 값의 바로 뒤에 있는 인덱스
    }
    
    public func index(after i: Index) -> Index {
        return Index(node: i.node?.next)
        //바로 다음 노드의 인덱스
    }
    
    public subscript(position: Index) -> Value {
        return position.node!.value
        //subscript operator. 해당 index의 value를 반환
    }
}




//MARK: - Value semantics and copy-on-write
extension LinkedList {
    private mutating func copyNodes() {
        //LinkedList를 복사한다.
        guard !isKnownUniquelyReferenced(&head) else {
            //isKnownUniquelyReferenced 함수는 객체에 정확히 하나의 참조가 있는 지 여부를 반환한다.
            //이를 사용하면, 노드 객체가 공유되고 있는지 여부를 확인할 수 있다.
            //참조 counter가 1이라면(소유자가 하나), 복사하지 않고 진행하는 것이 효율적이다.
            return
        }
        
        guard var oldNode = head else {
            //head가 없다면 return(빈 리스트)
            return
        }
        
        head = Node(value: oldNode.value)
        //head부터 시작한다. 이전 리스트에서 head를 가져와 Node 생성
        
        var newNode = head
        
        while let nextOldNode = oldNode.next {
            //이전 리스트에서 하나씩 뒤로 이동하면서
            newNode!.next = Node(value: nextOldNode.value)
            //새로운 리스트를 만든다.
            
            newNode = newNode!.next
            //새로운 리스트 하나 뒤로 이동
            oldNode = nextOldNode
            //이전 리스트 하나 뒤로 이동
        }
        //while문을 종료하고 나면 newNode는 마지막 노드가 된다.
        
        tail = newNode
        //tail 설정
    }
    
    //이후 각 메서드의 맨 위에서 copyNodes()를 호출해, LinkedList를 복사한 후 진행하면 된다.
}




//Optimizing COW
//하지만 위에서의 copy-on-write 구현은, mutating 메서드를 호출할 때마다 복사되므로 O(n)이 추가가 되어 비효율적이다.
//이 문제를 해결하는 데 두 가지 방법이 있다. 그 중 하나는 오직 하나의 소유자만 있을 때는 복사를 하지 않고 진행하는 것이다.
//두 번째 최적화 방법은 노드를 공유하는 것이다. p.42
//이런 경우에 대한 최적화가 필요하지만, 여기서 다루지는 않는다.
