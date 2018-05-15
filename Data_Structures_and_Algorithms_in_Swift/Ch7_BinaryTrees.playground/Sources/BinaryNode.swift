public class BinaryNode<Element> {
    public var value: Element
    public var leftChild: BinaryNode?
    public var rightChild: BinaryNode?
    
    public init(value: Element) {
        self.value = value
    }
}
//이진 트리는 각 노드가 최대 두 개의 자식 노드(left, right)를 가지는 트리이다. p.79




//MARK: - Building a diagram
extension BinaryNode: CustomStringConvertible {
    //CustomStringConvertible을 구현해, String으로 변환하거나 print 함수 사용시 반환할 값을 지정해 준다.
    public var description: String {
        //description 변수를 설정하면 CustomStringConvertible이 구현된다.
        return diagram(for: self)
    }
    
    private func diagram(for node: BinaryNode?, _ top: String = "", _ root: String = "", _ bottom: String = "") -> String {
        //이진 트리를 시각화한다. //https://www.objc.io/books/optimizing-collections/
        //재귀적으로 이진 트리를 출력하는 문자열을 만든다.
        guard let node = node else {
            //노드가 없다면
            return root + "nil\n"
            //nil 추가
        }
        
        if node.leftChild == nil && node.rightChild == nil {
            //자식 노드가 하나도 없다면
            return root + "\(node.value)\n"
            //자신의 값을 추가
        }
        
        return diagram(for: node.rightChild, top + " ", top + "┌──", top + "│ ")
            + root + "\(node.value)\n"
            + diagram(for: node.leftChild, bottom + "│ ", bottom + "└──", bottom + " ")
        //자식 노드가 한 개 이상 있다면 재귀적으로 문자열을 만든다.
    }
}




//Traversal algorithms

//MARK: - In-order traversal
extension BinaryNode {
    public func traverseInOrder(visit: (Element) -> Void) {
        //중위 순회는 현재 노드를 중간에 순회한다. p.82
        leftChild?.traverseInOrder(visit: visit)
        //• 1. 현재 노드 왼쪽에 자식이 있는 경우 재귀적으로 왼쪽을 재귀적으로 방문한다.
        visit(value)
        //• 2. 현재 노드를 방문한다.
        rightChild?.traverseInOrder(visit: visit)
        //• 3. 현재 노드 오른쪽에 자식이 있는 경우, 오른쪽으 노드를 재귀적으로 방문한다.
        
        //트리가 정렬되어 있는 경우, 중위 순회는 오름 차순으로 출력된다.
    }
}

//MARK: - Pre-order traversal
extension BinaryNode {
    public func traversePreOrder(visit: (Element) -> Void) {
        //전위 순회는 현재 노드를 먼저 방문한다(루트부터 시작된다). p.83
        visit(value)
        //• 1. 현재 노드를 방문한다.
        leftChild?.traversePreOrder(visit: visit)
        //• 2. 현재 노드 왼쪽에 자식이 있는 경우 재귀적으로 왼쪽을 재귀적으로 방문한다.
        rightChild?.traversePreOrder(visit: visit)
        //• 3. 현재 노드 오른쪽에 자식이 있는 경우, 오른쪽으 노드를 재귀적으로 방문한다.
        
        //전위 순회는 루트가 가장 처음으로 출력된다.
    }
}

//MARK: - Post-order traversal
extension BinaryNode {
    public func traversePostOrder(visit: (Element) -> Void) {
        //후위 순회는 자식 노드들을 먼저 방문한뒤, 현재 노드를 방문한다. p.84
        leftChild?.traversePostOrder(visit: visit)
        //• 1. 현재 노드 왼쪽에 자식이 있는 경우 재귀적으로 왼쪽을 재귀적으로 방문한다.
        rightChild?.traversePostOrder(visit: visit)
        //• 2. 현재 노드 오른쪽에 자식이 있는 경우, 오른쪽으 노드를 재귀적으로 방문한다.
        visit(value)
        //• 3. 현재 노드를 방문한다.
        
        //후위 순회는 루트가 가장 마지막으로 출력된다.
    }
}

//순회 알고리즘은 모두 O(n)의 시간 및 공간 복잡도를 가진다. 이진 트리는 삽입 시에 몇 가지 규칙을 준수해서 순회를 더 강화할 수 있다.
//-> 이진 검색 트리


