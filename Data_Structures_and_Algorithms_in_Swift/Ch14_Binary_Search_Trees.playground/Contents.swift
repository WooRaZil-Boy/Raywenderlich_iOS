//Chapter 14: Binary Search Trees

//binary search tree(BST)는 빠른 조회(lookup), 삽입(insert), 제거(removal) 작업을 용이하게 하는 자료 구조이다.
//한 쪽을 선택하면, 다른 쪽의 모든 가능성이 없어지게 되어 문제를 절반으로 줄이는 의사 결정 트리(decision tree)가 있다. p.158
//결정을 내리고 가지를(branch) 선택하면 뒤로 돌아갈 수 없다. leaf에서 최종 결정을 내릴 때까지 계속 내려가야 한다.
//Binary tree는 이와 같은 작업을 수행할 수 있다. BST는 이진 트리에 두 가지 규칙을 적용한다.
// • left child의 value는 parent의 value 보다 작아야 한다.
// • 결과적으로 right child의 value는 parent의 value보다 크거나 같아야 한다.
//BST는 불필요한 확인을 생략하기 위해 이 속성들을 사용한다.
//그 결과, 조회, 삽입, 제거는 평균 O(log n)의 시간복잡도를 가지며, 이는 Array나 Linked list와 같은 선형(linear) 자료구조보다 훨씬 빠르다.




//Case study: array vs. BST
//BST의 장점을 알아보기 위해, 몇 가지 일반적인 작업을 Array와 비교해 보면 다음과 같다. p.159

//Lookup
//정렬되지 않은 Array에 대한 요소 검색을 수행하는 방법은 처음부터 모든 요소를 확인하는 한 가지 방법뿐이다. p.160
//그래서 array.contains(_ :)는 O(n) 연산이다. 그러나 BST에서는 훨씬 빠르게 수행할 수 있다.
//검색 알고리즘이 BST의 node를 방문할 때마다, 다음 두 가지 가정을 안전하게 수행할 수 있다.
// • 검색하는 value가 현재 value보다 작으면, 왼쪽 하위 트리에 있어야 한다.
// • 검색하는 value가 현재 value보다 크면, 오른쪽 하위 트리에 있어야 한다.
//BST의 규칙을 활용하면 node를 방문하고 하위 트리를 결정할 때마다, 불필요한 점검을 피하고 검색 범위를 반으로 줄일 수 있다. BST에서 element lookup이 O(log n) 연산인 이유이다.

//Insertion
//삽입 연산에 대한 성능도 유사하다. collection에 0을 삽입하는 경우를 생각해 보면 다음과 같다. p.161
//Array에 value를 삽입하는 작업을 수행하려면, 선택한 지점 뒤의 모든 요소를 하나씩 밀어서 공간을 만들어야 한다.
//위의 예시에서는 Array의 가장 앞에 0이 삽입되어, 다른 모든 요소가 하나씩 뒤로 이동한다. Array에 요소를 삽입하는 시간 복잡도는 O(n)이다.
//BST에 요소를 삽입하는 것은 훨씬 쉽다. BST 규칙을 사용하면, 삽입 위치를 찾기 위해 3번만 순회하면 되므로 모든 요소를 움직일 필요가 없다. p.161
//BST에서 요소를 삽입하는 것은 O(log n) 작업이다.

//Removal
//삽입과 마찬가지로 Array에서 요소를 제거하면, 뒤의 요소들도 움직이게 된다. p.162
//이 동작은 줄서기의 비유와도 잘 어울린다. 줄 중간에서 사람이 이탈하면, 뒤에 있는 모든 사람이 앞으로 하나씩 이동해 빈 공간을 채워야 한다.
//BST에서 value를 제거하는 방법은 다음과 같다. p.162
//제거하는 node의 child가 있는 경우, 추가적인 작업이 있긴 하지만 대체로 간편하고 쉽게 처리된다.
//이런 추가 작업에도 불구하고, BST에서 요소를 제거하는 것은 O(log n) 작업이다.
//이진 검색 트리는 추가, 제거 및 조회 작업의 단계 수를 크게 줄인다.




//Implementation
public struct BinarySearchTree<Element: Comparable> {
    public private(set) var root: BinaryNode<Element>?
    public init() {}
}

extension BinarySearchTree: CustomStringConvertible {
    public var description: String {
        guard let root = root else { return "empty tree" }
        return String(describing: root)
    }
}
//비교를 위해 클로저를 사용하여 Comparable 요구 사항을 충족 시킬 수 있다. 더 단순하고 핵심 적인 개념에 집중할 것이기에 이렇게 구현한다.

//Inserting elements
//BST 규칙에 따라 left child의 node는 현재 node 보다 작은 value를 가져야 한다.
//그리고 right child의 node는 현재 node 보다 크거나 같은 value를 가져야 한다.
//이 규칙들을 지키면서 삽입을 구현해야 한다.
extension BinarySearchTree {
    public mutating func insert(_ value: Element) { //외부에 노출되는 메서드
        root = insert(from: root, value: value)
    }
    
    private func insert(from node: BinaryNode<Element>?, value: Element) -> BinaryNode<Element> { //helper
        guard let node = node else { //재귀 종료를 위한 guard
            return BinaryNode(value: value) //현재 node가 nil이면 삽입점을 찾은 후, 새 BinaryNode를 반환한다.
        }
        
        //Element가 Comparable이므로, 비교 연산을 할 수 있다.
        if value < node.value { //value가 현재 value보다 작으면, 왼쪽 child에서 insert를 호출한다.
            node.leftChild = insert(from: node.leftChild, value: value)
        } else { //value가 현재 value보다 크거나 같으면, 오른쪽 child에서 insert를 호출한다.
            node.rightChild = insert(from: node.rightChild, value: value)
        }
        
        return node //현재 node를 반환한다.
        //삽입 작업이 node를 생성하거나(nil인 경우), node를 반환하는 경우(nil이 아닌 경우) 모두
        //node = insert(from: node, value: value) 형식으로 할당가능하다.
    }
}
//첫 insert 메서드는 외부에 노출되고, 두 번째 insert 메서드는 내부에서 사용하는 helper 메서드이다.
example(of: "building a BST") {
    var bst = BinarySearchTree<Int>()
    for i in 0..<5 {
        bst.insert(i)
    }
    print(bst)
    //    ┌──4
    //   ┌──3
    //   │ └──nil
    //  ┌──2
    //  │ └──nil
    // ┌──1
    // │ └──nil
    // 0
    // └──nil
}
//tree가 약간 불균형 해 보이지만 bst 규칙을 따르고 있다. 하지만, 이렇게 불균형한 tree는 바람직하지 않다.
//tree로 작업 시에는 항상 균형이 잡히도록 구현하는 것이 좋다. p.165
//불균형한 tree는 성능에 영향을 준다. 방금 생성한 unbalanced tree에 5를 삽입하는 연산은 O(n)이 된다.
//자체적으로 균형을 유지하는 self-balancing tree를 만들 수 있다(ex. AVL).
//지금은 sample tree가 균형 잡힌 tree가 되도록 간단하게 insert 순서를 바꿔 구현한다.
var exampleTree: BinarySearchTree<Int> {
    var bst = BinarySearchTree<Int>()
    bst.insert(3)
    bst.insert(1)
    bst.insert(4)
    bst.insert(0)
    bst.insert(2)
    bst.insert(5)
    return bst
}

example(of: "building a BST") {
    print(exampleTree)
    //  ┌──5
    // ┌──4
    // │ └──nil
    // 3
    // │ ┌──2
    // └──1
    //  └──0
}

//Finding elements
//BST에서 요소를 찾으려면, 해당 node를 통과해야 한다. 이전에 배운 순회 매커니즘을 사용하면 간단하게 구현할 수 있다.
extension BinarySearchTree {
    public func containsInOrder(_ value: Element) -> Bool {
        guard let root = root else {
            return false
        }
        var found = false
        root.traverseInOrder {
            if $0 == value {
                found = true
            }
        }
        return found
    }
}

example(of: "finding a node") {
    if exampleTree.containsInOrder(5) {
        print("Found 5!")
    } else {
        print("Couldn’t find 5")
    }
    // Found 5!
}
//In-order traversal(중위 순회)는 O(n)의 시간 복잡도를 가지므로, 정렬되지 않은 Array의 전체 검색과 동일하다. 이를 개선할 수 있다.

//Optimizing contains
//BST의 규칙을 사용해 불필요한 비교를 생략할 수 있다.
extension BinarySearchTree {
    public func contains(_ value: Element) -> Bool {
        var current = root //root를 current에 할당한다.
        while let node = current { //current가 nil이 아니라면 loop
            if node.value == value { //현재 node의 value가 찾으려는 value와 같다면 true 반환
                return true
            }
            
            //같지 않다면 확인할 child node를 결정한다.
            if value < node.value { //value가 현재 value보다 작으면, 왼쪽 child에서 찾는다.
                current = node.leftChild
            } else { //value가 현재 value보다 크거나 같다면, 오른쪽 child에서 찾는다.
                current = node.rightChild
            }
        }
        
        return false
    }
}

//Removing elements
//제거는 몇 가지 시나리오가 있기 때문에 좀 더 까다롭다.

//Case 1: Leaf node
//leaf를 제거하는 것은 간단하다. 단순히 leaf node를 분리하면 된다. //p.169

//Case 2: Nodes with one child
//non-leaf node는 해당 node 제거 이후 추가 단계가 필요하다.
//child가 하나인 node를 제거할 때, 그 child를 나머지 tree와 다시 연결해야 한다. //p.169

//Case 3: Nodes with two children
//child가 두 개인 node는 더 복잡하다. 단순히 node를 제거하면 다시 연결할 하위 node를 선택해야 하는 딜레마가 생긴다. //p.170
//두 개의 하위 node가 있지만, 상위 node에는 하나의 공간만 있으므로, 이를 해결하려면 swap을 해야한다.
//child가 두 개인 node를 제거할 때는 제거할 node를 오른쪽 child tree에서 가장 작은 node와 교체한다.
//BST 규칙에 의하면, 이는 오른쪽 하위 tree에서 가장 왼쪽(leftmost) node이다. 이 작업을 해도, BST가 유지된다.
//새 node는 오른쪽 child tree에서 가장 작은 node 였기 때문에, 오른쪽 하위 tree의 모든 node는 여전히 새 node보다 크거나 같다.
//swap이후, leaf node가 된 복사한 node를 제거하면 된다. //p.171

//Implementation
private extension BinaryNode {
    var min: BinaryNode { //하위 tree에서 최소 node를 찾기 위한 속성
        leftChild?.min ?? self
    }
}

extension BinarySearchTree {
    public mutating func remove(_ value: Element) {
        root = remove(node: root, value: value)
    }
    
    private func remove(node: BinaryNode<Element>?, value: Element) -> BinaryNode<Element>? {
        guard let node = node else {
            return nil
        }
        
        if value == node.value { //이 절은 제외하면, 재귀적으로 node를 찾아가는 과정은 insert와 비슷하다.
            //해당 node를 찾은 경우
            if node.leftChild == nil && node.rightChild == nil { //leaf node인 경우
                return nil //nil을 반환하여 현재 node를 제거한다.
            }
            
            if node.leftChild == nil { //왼쪽 child가 없는 경우
                return node.rightChild //rightChild를 반환하여 오른쪽 하위 tree를 연결한다.
            }
            
            if node.rightChild == nil { //오른쪽 child가 없는 경우
                return node.leftChild //leftChild를 반환하여 왼쪽 하위 tree를 연결한다.
            }
            
            //양쪽 모두 child가 있는 경우
            node.value = node.rightChild!.min.value //오른쪽 하위 tree의 최소 node의 value로 바꾼다.
            //오른쪽 하위 tree의 가장 왼쪽 node
            node.rightChild = remove(node: node.rightChild, value: node.value)
            //오른쪽 하위 tree에서 remove를 호출하여 swap된 value를 제거한다.
        } else if value < node.value {
            node.leftChild = remove(node: node.leftChild, value: value)
        } else {
            node.rightChild = remove(node: node.rightChild, value: value)
        }
        
        return node
    }
}
//삽입과 마찬가지로, //첫 remove 메서드는 외부에 노출되고, 두 번째 remove 메서드는 내부에서 사용하는 helper 메서드이다.

example(of: "removing a node") {
    var tree = exampleTree
    print("Tree before removal:")
    print(tree)
    //  ┌──5
    // ┌──4
    // │ └──nil
    // 3
    // │ ┌──2
    // └──1
    //  └──0
    tree.remove(3)
    print("Tree after removing root:")
    print(tree)
    // ┌──5
    // 4
    // │ ┌──2
    // └──1
    //  └──0
}
