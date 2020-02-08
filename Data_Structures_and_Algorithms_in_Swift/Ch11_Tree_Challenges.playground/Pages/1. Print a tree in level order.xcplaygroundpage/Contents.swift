// Copyright (c) 2019 Razeware LLC
// For full license & permission details, see LICENSE.markdown.
//: # #1. Print a Tree in Level Order
//: 
//: Print all the values in a tree in an order based on their level.
//: Nodes in the same level should be printed on the same line.
//: For example, consider the following tree:
//:
//: ![Image of Tree](tree.png)
//:
//: Your algorithm should print the following:
//:
//: ```none
//: 15
//: 1 17 20
//: 1 5 0 2 5 7
//: ```
//:
//: **Hint**: Consider using a `Queue` included for you in **Sources**.
//레벨(level)을 기준으로 tree의 모든 value를 순서대로 출력한다. 동일한 레벨의 node는 동일한 line에 출력해야 한다.




// Build the sample tree shown in the diagram
// Root of the tree
let tree = TreeNode(15)

// Second level
let one = TreeNode(1)
tree.add(one)

let seventeen = TreeNode(17)
tree.add(seventeen)

let twenty = TreeNode(20)
tree.add(twenty)

// Third level
let one2 = TreeNode(1)
let five = TreeNode(5)
let zero = TreeNode(0)
one.add(one2)
one.add(five)
one.add(zero)

let two = TreeNode(2)
seventeen.add(two)

let five2 = TreeNode(5)
let seven = TreeNode(7)
twenty.add(five2)
twenty.add(seven)




//node를 level 순서대로 출력하는 간단한 방법은 큐(Queue)를 사용하여 레벨 순서 순회(Level-order traversal)을 구현하는 것이다.
//까다로운 부분은 개행을 언제해야 하는지 결정하는 것이다.
func printEachLevel<T>(for tree: TreeNode<T>) {
    var queue = Queue<TreeNode<T>>() //Queue를 사용한다.
    var nodesLeftInCurrentLevel = 0 //남은 노드의 수 추적
    queue.enqueue(tree)
    
    while !queue.isEmpty { //Queue가 빌 때까지 순회한다.
        nodesLeftInCurrentLevel = queue.count //queue의 현재 요소 수를 설정한다.
        
        while nodesLeftInCurrentLevel > 0 {
            guard let node = queue.dequeue() else { break }
            print("\(node.value) ", terminator: "") //dequeue한 요소를 출력한다. 개행 없이 출려된다.
            node.children.forEach { queue.enqueue($0) } //dequeue된 요소의 children을 모두 queue에 넣는다.
            nodesLeftInCurrentLevel -= 1
        }
        
        print() //개행
    }
}
//이 알고리즘의 시간 복잡도는 O(n)이다. Queue를 컨테이너로 초기화하므로, 공간 복잡도 또한 O(n)이 된다.
