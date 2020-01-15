// Copyright (c) 2019 Razeware LLC
// For full license & permission details, see LICENSE.markdown.
/*:
 [Previous Challenge](@previous)
 
 ## Challenge 3
 
 Since there are many variants of binary trees, it makes sense to group shared
 functionality in a protocol. The traversal methods are a good candidate for
 this.
 
 Create a TraversableBinaryNode protocol that provides a default implementation
 of the traversal methods so that conforming types get these methods for free.
 Have AVLNode conform to this.
 */
//이진 트리에는 많은 종류가 있으므로, 공통적인 기능을 Protocol로 그룹화하는 것이 좋다. 순회 메서드가 이의 좋은 예이다.
//TraversableBinaryNode protocol을 생성하고, Transversal 메서드를 구현하고, AVLNode가 이를 준수하도록 한다.




protocol TraversableBinaryNode {
    associatedtype Element
    var value: Element { get }
    var leftChild: Self? { get }
    var rightChild: Self? { get }
    func traverseInOrder(visit: (Element) -> Void) //중위 순회
    func traversePreOrder(visit: (Element) -> Void) //전위 순회
    func traversePostOrder(visit: (Element) -> Void) //후위 순회
}

extension TraversableBinaryNode {
    func traverseInOrder(visit: (Element) -> Void) { //중위 순회
        leftChild?.traverseInOrder(visit: visit)
        visit(value)
        rightChild?.traverseInOrder(visit: visit)
    }
    
    func traversePreOrder(visit: (Element) -> Void) { //전위 순회
        visit(value)
        leftChild?.traversePreOrder(visit: visit)
        rightChild?.traversePreOrder(visit: visit)
    }
    
    func traversePostOrder(visit: (Element) -> Void) { //후위 순회
        leftChild?.traversePostOrder(visit: visit)
        rightChild?.traversePostOrder(visit: visit)
        visit(value)
    }
}

extension AVLNode: TraversableBinaryNode {}

example(of: "using TraversableBinaryNode") {
    var tree = AVLTree<Int>()
    for i in 0..<15 {
        tree.insert(i)
    }
    print(tree)
    //   ┌──14
    //  ┌──13
    //  │ └──12
    // ┌──11
    // │ │ ┌──10
    // │ └──9
    // │  └──8
    // 7
    // │  ┌──6
    // │ ┌──5
    // │ │ └──4
    // └──3
    //  │ ┌──2
    //  └──1
    //   └──0
    
    tree.root?.traverseInOrder { print($0) }
    // 0
    // 1
    // 2
    // 3
    // 4
    // 5
    // 6
    // 7
    // 8
    // 9
    // 10
    // 11
    // 12
    // 13
    // 14
}
