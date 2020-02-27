// Copyright (c) 2019 Razeware LLC
// For full license & permission details, see LICENSE.markdown.
/*:
 [Previous Challenge](@previous)
 ### #2. Equatable
 The binary search tree currently lacks `Equatable` conformance. Your challenge is to conform adopt the `Equatable` protocol.
 */
//앞선 이진 탐색 트리(binary search tree)는 Equatable을 구현하고 있지 않다. Equatable 프로토콜(protocol)을 준수하도록 구현한다.




var bst = BinarySearchTree<Int>()
bst.insert(3)
bst.insert(1)
bst.insert(4)
bst.insert(0)
bst.insert(2)
bst.insert(5)

print(bst)

var bst2 = BinarySearchTree<Int>()
bst2.insert(2)
bst2.insert(5)
bst2.insert(3)
bst2.insert(1)
bst2.insert(0)
bst2.insert(4)

//Equatable을 구현하는 것은 간단하다. 두 개의 이진 트리(binary tree)가 모두 동일한 순서로 동일한 요소를 가지고 있으면 된다.

extension BinarySearchTree: Equatable {
    public static func == (lhs: BinarySearchTree, rhs: BinarySearchTree) -> Bool {
        //Equatable을 준수하려면 반드시 == 함수를 구현해야 한다.
        isEqual(lhs.root, rhs.root)
    }
    
    private static func isEqual<Element: Equatable>(_ node1: BinaryNode<Element>?, _ node2: BinaryNode<Element>?) -> Bool { //helper 메서드 //재귀적으로 호출된다.
        guard let leftNode = node1, let rightNode = node2 else { //양쪽 모두 node가 있지 않다면 재귀가 종료된다.
            return node1 == nil && node2 == nil //양쪽 node가 모두 nil인 경우는 동일하다.
        }
        
        return leftNode.value == rightNode.value && //node 비교
            isEqual(leftNode.leftChild, rightNode.leftChild) && //leftChild 비교
            isEqual(leftNode.rightChild, rightNode.rightChild) //rightChild 비교
    }
}
//이 함수의 시간복잡도, 공간복잡도 모두 O(n)이다.

//: [Next Challenge](@next)
