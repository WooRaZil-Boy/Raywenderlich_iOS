public struct BinarySearchTree<Element: Comparable> {
    //이진 검색 트리는 비교 가능한 값만 가질 수 있다.
    public private(set) var root: BinaryNode<Element>?
    
    public init() {}
}

//이진 검색 트리(BST)는 빠르게 검색, 요소 추가 및 삭제가 가능한 자료구조이다.
//각 연산의 평균 시간 복잡도는 O(log n)이며, 이는 배열이나 링크드리스트보다 매우 빠르다.
//이진 검색 트리는 이진 트리에 두 가지 규칙을 추가한다.
//• 왼쪽 자식 노드의 값은 부모 노드의 값보다 작아야 한다.
//• 오른쪽 자식 노드의 값은 부모 노드의 값보다 크거나 같아야 한다.
//이런 규칙들 때문에 이진 검색 트리는 의사 결정 트리처럼 작동한다. p.86
//한 쪽을 선택하게 되면, 반대 쪽의 모든 가능성을 상실하게 된다. 이를 통해 불필요한 검사를 건너 뛸 수 있다.




//Case study: array vs. BST //p.87
//배열과 이진 검색 트리에 대한 성능 비교

//Lookup
//정렬되지 않은 배열에 대해 요소 조회를 하는 방법은 오직, 배열의 모든 요소를 처음부터 확인하는 방법 뿐이다. p.87
//array.contains(:) 메서드를 이용하며, O(n)이다.
//이진 검색 트리에서는 각 노드를 방문할 때마다 다음과 같은 규칙을 이용해 불필요한 검사를 줄인다. p.88
//• 검색 값이 현재 값보다 작다면 왼쪽 하위 트리에 있어야 한다.
//• 검색 값이 현재 값보다 크다면 오른쪽 하위 트리에 있어야 한다.
//따라서 이진 검색 트리에서 조회는 O(log n)으로 배열보다 빠르다.

//Insertion
//배열의 맨 앞에 값을 추가할 경우, 뒤의 모든 요소들은 한 칸씩 뒤로 밀려야 한다. 따라서 O(n). p.88
//이진 검색 트리는 삽입 위치를 찾는데 특정 요소들만 확인하면 된다. O(log n). p.89

//Removal
//배열의 경우 삽입과 마찬가지로, 다른 요소들이 모두 움직여야 한다. O(n). p.89
//이진 검색 트리에서는 삽입, 삭제 후 다시 요소들을 정렬시켜야 하지만, 시간 복잡도는 O(log n)이다. p.90

extension BinarySearchTree: CustomStringConvertible {
    //CustomStringConvertible을 구현해, String으로 변환하거나 print 함수 사용시 반환할 값을 지정해 준다.
    public var description: String {
        //description 변수를 설정하면 CustomStringConvertible이 구현된다.
        return root?.description ?? "empty tree"
    }
}




//MARK: - Inserting elements
extension BinarySearchTree {
    //BST의 규칙에 따라 왼쪽 자식 노드에는 현재 노드보다 작은 값이 있어야 하고,
    //오른쪽 자식 노드에는 현재 노드보다 크거나 같은 값이 있어야 한다.
    public mutating func insert(_ value: Element) {
        //사용자가 삽입 시 직접 사용할 메서드
        root = insert(from: root, value: value)
    }
    
    private func insert(from node: BinaryNode<Element>?, value: Element) -> BinaryNode<Element> {
        //Helper 메서드
        guard let node = node else {
            //재귀적으로 호출되므로, 재귀를 종료하기 위한 조건이 필요하다.
            //현재 노드가 nil이라면 삽입해야 할 곳을 찾았다는 의미. 값으로 새로운 BinaryNode를 생성해 반환한다.
            return BinaryNode(value: value)
        }
        
        if value < node.value {
            //새 값이 현재 값보다 작다면
            node.leftChild = insert(from: node.leftChild, value: value)
            //왼쪽에 insert를 호출한다.
        } else {
            //새 값이 현재 값보다 크거나 같으면
            node.rightChild = insert(from: node.rightChild, value: value)
            //오른쪽에 insert를 호출한다.
        }
        
        return node //현재 노드를 반환한다.
        //node = insert(from: node, value: value) 형식이 nil이 아닐 때 node를 생성하거나, nil일 때 node를 반환하도록 한다.
        //모든 재귀가 다 끝이 났을 때, 마지막으로 (보통은 root) 반환한다.
    }
}




//MARK: - Finding elements
extension BinarySearchTree {
//    public func contains(_ value: Element) -> Bool {
//        guard let root = root else { //루트가 nil이면 false
//            return false
//        }
//
//        var found = false //해당 요소 찾았는지 여부
//
//        root.traverseInOrder {
//            //기존의 순회 알고리즘으로 간단한 구현을 할 수 있다.
//            //In-order traversal은 O(n)이므로 정렬되지 않은 배열과 같다.
//            if $0 == value { //찾고자 하는 값과 같다면
//                found = true //true
//            }
//        }
//
//        return found
//    }
    
    //Optimizing contains
    //In-order traversal은 O(n)이므로 정렬되지 않은 배열과 같다.
    //이를 개선하기 위해서 BST의 규칙을 활용할 수 있다.
    public func contains(_ value: Element) -> Bool {
        var current = root //루트 부터 시작

        while let node = current {
            //현재 노드가 nil이 아닌 경우에만 loop
            if node.value == value {
                //노드의 값이 찾으려는 값과 같다면 true
                return true
            }
            
            if value < node.value {
                //찾으려는 값이 현재 노드의 값보다 작다면
                current = node.leftChild
                //왼쪽 자식 노드로 이동
            } else {
                //찾으려는 값이 현재 노드의 값보다 크거나 같다면
                current = node.rightChild
                //오른쪽 자식 노드로 이동
            }
        }

        return false
    }
    //이진 검색 트리의 규칙을 사용하면 시간 복잡도를 O(log n)으로 줄일 수 있다.
}




//MARK: - Removing elements
//삭제는 처리해야할 몇 가지 시나리오가 있기 때문에 더 까다롭다.

//Case 1: Leaf node
//Leaf(자식 노드가 없는 노드)노드 제거는 단순히 해당 노드를 제거하는 것으로 충분하다. p.96

//Case 2: Nodes with one child
//자식 노드가 하나 있는 노드를 제거할 때는 해당 노드를 제거하고, 자식 노드를 부모 노드의 자식으로 다시 연결해야 한다. p.96

//Case 3: Nodes with two children
//자식 노드가 두 개 있는 노드를 제거할 때는 삭제할 노드의 오른쪽 자식 트리에서 가장 작은 노드와 교체 한 후 삭제한다. p.97
//즉, 오른쪽 자식 트리 중 가장 왼쪽 노드가 된다. 새 노드가 오른쪽 자식 트리의 가장 작은 노드이기 때문에
//오른쪽 하위 트리의 모든 노드는 여전히 새 노드보다 크거나 같다.
//또한 새 노드가 오른쪽 하위 트리에서 왔기 때문에 왼쪽 하위 트리의 모든 노드는 새 노드보다 작다(이진 검색 트리가 유지된다).
//교체 후, 단순히 Leaf가 된 삭제할 노드를 제거해 주면 된다.

private extension BinaryNode {
    var min: BinaryNode { //하위 트리에서 가장 작은 값을 가진 노드를 찾는다.
        return leftChild?.min ?? self
        //BST에서 가장 작은 값의 노드는 가장 왼쪽 아래 노드이므로 자신보다 낮은 값을 가진 노드(왼쪽 자식 노드)를 재귀적으로 호출한다.
        //왼쪽 자식 노드가 있으면 재귀적으로 호출하다가, 없으면 자신을 반환
    }
}

extension BinarySearchTree {
    public mutating func remove(_ value: Element) {
        //사용자가 삭제 시 직접 사용할 메서드
        root = remove(node: root, value: value)
    }
    
    private func remove(node: BinaryNode<Element>?, value: Element) -> BinaryNode<Element>? {
        //Helper 메서드
        guard let node = node else { //node가 nil이라면 종료
            return nil
        }
        
        if value == node.value {
            if node.leftChild == nil && node.rightChild == nil {
                //자식 노드가 없는 경우. Leaf인 경우.
                return nil
                //단순히 nil을 반환해 현재 노드를 제거한다.
            }
            
            if node.leftChild == nil {
                //왼쪽 자식 노드가 없는 경우
                return node.rightChild
                //오른쪽 자식 트리를 반환
            }
            
            if node.rightChild == nil {
                //오른쪽 자식 노드가 없는 경우
                return node.leftChild
                //왼쪽 자식 트리를 반환
            }
            
            //양쪽에 모두 자식이 있는 경우
            node.value = node.rightChild!.min.value
            //노드의 값을 오른쪽 자식 트리의 가장 작은 값(가장 왼쪽 아래 값)으로 대체한다.
            node.rightChild = remove(node: node.rightChild, value: node.value)
            //교체 이후, 오른쪽 자식 노드에서 교체한 값(삭제할 값)을 찾아 제거한다.
        } else if value < node.value {
            //삭제하려는 값이 현재 노드의 값보다 작다면
            node.leftChild = remove(node: node.leftChild, value: value)
            //왼쪽 자식 트리를 대상으로 재귀로 값을 찾아 삭제한다.
        } else {
            //삭제하려는 값이 현재 노드의 값보다 크거나 같다면
            node.rightChild = remove(node: node.rightChild, value: value)
            //오른쪽 자식 트리를 대상으로 재귀로 값을 찾아 삭제한다.
        }
        
        return node
    }
}

