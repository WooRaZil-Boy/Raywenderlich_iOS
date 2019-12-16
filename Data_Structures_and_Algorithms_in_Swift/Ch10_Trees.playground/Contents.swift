//Chapter 10: Trees

//Tree는 정보를 구성하는 또 다른 방법으로, children과 parents의 개념을 사용한다.
//Tree는 매우 중요한 자료구조로, 소프트웨어 개발의 다양한 측면에서 사용된다.
// • 계층적 관계를 나타낸다.
// • 정렬된 데이터를 관리한다.
// • 빠른 조회 작업을 처리한다.
//모양과 크기가 다양한 여러 종류의 Tree가 있다.

//Terminology
//Tree에 관련된 여러가지 용어들이 있다. //p.132
// • Node : Linked List와 마찬가지로, Tree는 Node로 구성된다. 각 node는 데이터를 가질 수 있으며, 자식 node를 추적한다.
// • Parent and child : Tree는 실제 나무처럼 가지를 치는데, 방향은 반대로 위에서 시작해 아래로 뻗어나간다.
//  모든 node(최상위 root 제외)는 바로 위쪽으로 하나의 node와 연결된다. 이를 parent node라 한다.
//  바로 아래에 연결되어 있는 node는 child node라 한다. Tree에서 모든 child는 정확히 하나의 parent를 가진다.
// • Root : Tree의 최상위 node를 Root라고 한다. Parent가 없는 유일한 node이다.
// • Leaf : child가 없는 node이다.




//Implementation
public class TreeNode<T> {
    public var value: T
    public var children: [TreeNode] = []
    
    public init(_ value: T) {
        self.value = value
    }
}
//각 node는 value를 가지고 있으며, Array를 사용해 모든 child에 대한 참조를 보유한다.

extension TreeNode {
    public func add(_ child: TreeNode) {
        children.append(child)
    }
}
//child node르 추가한다.

example(of: "creating a tree") {
    let beverages = TreeNode("Beverages")
    
    let hot = TreeNode("Hot")
    let cold = TreeNode("Cold")
    
    beverages.add(hot)
    beverages.add(cold)
}
//Tree는 자연스럽게 계층적인 구조를 이룬다. p.133




//Traversal algorithms
//Array나 LinkedList와 같은 linear collection은 명확한 시작과 끝이 있으므로 반복하는(Iterating) 것이 간단하다.
//하지만 Tree는 non-linear collection이므로 반복하는(Iterating) 것이 쉽지 않다.
//어느 node를 먼저 순회할지는 해결하려는 문제에 따라 달라진다.

//Depth-first traversal
//깊이 우선 탐색은 Root에서 시작하여 backtracking 전까지 최대한 깊이 탐색을 하는 방법이다.
extension TreeNode {
    public func forEachDepthFirst(visit: (TreeNode) -> Void) {
        visit(self) //클로저 호출 //여기서는 print($0.value) 이므로, self의 value가 출력된다.
        
        children.forEach {
            $0.forEachDepthFirst(visit: visit) //재귀
        }
    }
}
//재귀를 사용하지 않고, Stack을 사용해 구현할 수도 있다.

func makeBeverageTree() -> TreeNode<String> {
    let tree = TreeNode("Beverages")
    
    let hot = TreeNode("hot")
    let cold = TreeNode("cold")
    
    let tea = TreeNode("tea")
    let coffee = TreeNode("coffee")
    let chocolate = TreeNode("cocoa")
  
    let blackTea = TreeNode("black")
    let greenTea = TreeNode("green")
    let chaiTea = TreeNode("chai")
    
    let soda = TreeNode("soda")
    let milk = TreeNode("milk")
    
    let gingerAle = TreeNode("ginger ale")
    let bitterLemon = TreeNode("bitter lemon")
    
    tree.add(hot)
    tree.add(cold)

    hot.add(tea)
    hot.add(coffee)
    hot.add(chocolate)

    cold.add(soda)
    cold.add(milk)

    tea.add(blackTea)
    tea.add(greenTea)
    tea.add(chaiTea)
    
    soda.add(gingerAle)
    soda.add(bitterLemon)
    
    return tree
}
//예제로 사용할 Tree를 생성한다. p.137

example(of: "depth-first traversal") {
    let tree = makeBeverageTree()
    tree.forEachDepthFirst { print($0.value) }
    // Beverages
    // hot
    // tea
    // black
    // green
    // chai
    // coffee
    // cocoa
    // cold
    // soda
    // ginger ale
    // bitter lemon
    // milk
}

//Level-order traversal
extension TreeNode {
    public func forEachLevelOrder(visit: (TreeNode) -> Void) {
        visit(self) //클로저 호출 //여기서는 print($0.value) 이므로, self의 value가 출력된다.
        
        var queue = Queue<TreeNode>() //Queue를 사용해, 너비 우선으로 순회한다.
        children.forEach { queue.enqueue($0) } //해당 node의 child를 먼저 Queue에 삽입 한다.
        
        while let node = queue.dequeue() {
            visit(node) //클로저 호출 //여기서는 print($0.value) 이므로, node의 value가 출력된다.
            node.children.forEach { queue.enqueue($0) } //순회 하면서 node의 child가 계속해서 Queue에 삽입 된다.
        }
    }
}
//각 node를 Level 순서대로(너비 우선)으로 순회한다. p.137
example(of: "level-order traversal") {
    let tree = makeBeverageTree()
    tree.forEachLevelOrder { print($0.value) }
    // Beverages
    // hot
    // cold
    // tea
    // coffee
    // cocoa
    // soda
    // milk
    // black
    // green
    // chai
    // ginger ale
    // bitter lemon
}




//Search
//node를 순회하는 알고리즘을 사용해 검색을 구현할 수 있다.
extension TreeNode where T: Equatable { //T가 Equatable를 구현해야 한다.
    public func search(_ value: T) -> TreeNode? {
        var result: TreeNode?
        
        forEachLevelOrder { node in
            if node.value == value {
                result = node
            }
        }
        return result
    }
}
//너비 우선 방식으로 Search를 구현한다.

example(of: "searching for a node") {
    let tree = makeBeverageTree()
    
    if let searchResult1 = tree.search("ginger ale") {
        print("Found node: \(searchResult1.value)")
    }
    
    if let searchResult2 = tree.search("WKD Blue") {
        print(searchResult2.value)
    } else {
        print("Couldn't find WKD Blue")
    }
    
    // Found node: ginger ale
    // Couldn't find WKD Blue
}
//모든 node를 순회하므로, 중복되는 값이 있다면, 마지막에 찾은 node가 반환된다.
//즉, 어떤 순회 방법을 사용하느냐에 따라 다른 객체를 얻게 될 수 있다.
