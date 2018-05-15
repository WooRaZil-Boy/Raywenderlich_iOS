public class TreeNode<T> {
    public var value: T
    public var children: [TreeNode] = []
    //트리는 노드로 이루어져 있으며, 각 노드는 값을 처리하고 배열을 사용하여 모든 자식 노드에 대한 참조를 유지한다.
    
    public init(_ value: T) {
        self.value = value
    }
    
    public func add(_ child: TreeNode) {
        //노드를 자식으로 추가
        children.append(child)
    }
}

//트리는 다음과 같은 소프트웨어 개발에서 여러가지 반복되는 상황을 해결하는 데 사용되는 중요한 자료구조이다.
//• 계층 관계를 나타낸다.
//• 정렬된 데이터를 관리한다.
//• 빠른 조회 작업을 실행한다.




//Terminology p.70
//Node : LinkedList와 같이 트리는 노드로 이루어져 있다.
//  각 노드는 데이터를 캡슐화하고, 하위 노드를 참조한다.
//Parent : 모든 노드(최상위 노드 제외)는 단 하나의 상위 노드를 가지고 있는데 그 노드를 부모 노드라 한다.
//Child : 해당 노드의 아래에 있으면서 연결되어 있는 노드를 자식 노드라 한다.
//Root : 트리의 최상위 노드를 루트라 한다. 부모 노드가 없는 유일한 노드이다.
//Leaf : 자식 노드가 없는 노드를 리프라 한다.




//Traversal algorithms
//배열이나 링크드리스트 같은 선형 컬렉션의 경우, 명확한 시작과 끝이 있기 때문에 Iterating이 매우 간단하다. p.73
//하지만 트리의 경우에는 명확한 시작과 끝을 정하기 나름이므로, Iterating이 전략에 따라 달라진다.

//MARK: - Depth-first traversal
extension TreeNode {
    public func forEachDepthFirst(visit: (TreeNode) -> Void) {
        visit(self) //visit로 들어오는 (TreeNode) -> Void 타입 실행
        //self가 visit의 파라미터 (TreeNode)로 들어가고 visit는 반환형이 없다(Void).
        children.forEach {
            $0.forEachDepthFirst(visit: visit) //재귀함수로 다음 노드를 처리한다.
        }
    }
}

//MARK: - Level-order traversal
extension TreeNode {
    public func forEachLevelOrder(visit: (TreeNode) -> Void) {
        visit(self)
        
        var queue = Queue<TreeNode>() //큐 생성
        children.forEach { queue.enqueue($0) } //큐에 자식 노드를 넣는다.
        
        while let node = queue.dequeue() { //큐가 빌 때까지 하나씩 꺼내온다.
            visit(node)
            node.children.forEach { queue.enqueue($0) } //큐에 자식노드의 자식노드를 넣는다.
        }
        //로직은 p.76
    }
}




//MARK: - Search
extension TreeNode where T: Equatable {
    //Tree의 value가 Equatable을 구현해야 한다.
    public func search(_ value: T) -> TreeNode? {
        var result: TreeNode?
        
        forEachLevelOrder { node in
            //Level-order traversal. Depth-first traversal을 사용할 수도 있다(결과가 달라질 수 있다).
            if node.value == value {
                result = node
            }
        }
        //모든 노드를 검색하기 때문에, 여러 개의 일치 항목이 있는 경우 마지막 일치 항목을 반환한다.
        //따라서 순회 방법에 따라 결과가 달라질 수 있다.
        
        return result
    }
}
