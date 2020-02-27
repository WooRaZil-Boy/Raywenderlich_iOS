// Copyright (c) 2019 Razeware LLC
// For full license & permission details, see LICENSE.markdown.
/*:
 # Binary Search Tree Challenges
 ### #1. Binary Tree or Binary Search Tree?
 
 Create a function that checks if a binary tree is a binary search tree.
 */
//해당 이진 트리(binary tree)가 이진 탐색 트리인지 확인하는 함수를 만든다.




var bst = BinarySearchTree<Int>()
bst.insert(3)
bst.insert(1)
bst.insert(4)
bst.insert(0)
bst.insert(2)
bst.insert(5)

print(bst)

//이진 탐색 트리는 모든 left child가 부모보다 작거나 같고(?), right child가 부모보다 큰 tree이다.
//트리가 이진 탐색 트리인지 확인하는 알고리즘에는 모든 노드를 순회해 이 속성들을 확인하는 과정이 포함되어야 한다.

extension BinaryNode where Element: Comparable {
    var isBinarySearchTree: Bool { //외부에 노출되는 해당 변수로 이진 탐색 트리 여부를 알 수 있다.
        isBST(self, min:nil, max: nil)
    }
    
    private func isBST(_ tree: BinaryNode<Element>?, min: Element?, max: Element?) -> Bool {
        //tree를 재귀적으로 순회하여 BST 특성을 확인한다. BinaryNode에 대한 참조로 진행 상황을 추적하고, 최소 및 최대 값으로 BST 특성을 확인한다.
        guard let tree = tree else { //tree가 nil이면 검사할 node가 없으므로 그대로 함수가 종료된다.
            return true //nil 노드도 BST이므로 true를 반환한다.
        }
        
        if let min = min, tree.value <= min { //최소 범위 이하
            return false
        } else if let max = max, tree.value > max { //최대 범위 초과
            return false
        }
        //해당 조건이면 BST가 아니다.
        
        return isBST(tree.leftChild, min: min, max: tree.value) &&
            isBST(tree.rightChild, min: tree.value, max: max)
        //재귀 호출.
        //leftChild을 순회할 때 현재 value가 max로 전달된다(왼쪽 child node는 부모 node보다 클 수 없다).
        //rightChild을 순회할 때 현재 value가 min으로 전달된다(오른쪽 child node는 부모 node보다 커야 한다).
        //재귀 호출 중 어느 하나라도 false가 되면, 전체가 false가 된다.
    }
}
//isBinarySearchTree는 외부에 노출되는 변수이고, isBST 함수는 helper이다.
//이 함수의 시간 복잡도는 전체 tree를 한 번 순회해야 하기 때문에 O(n)이다. 재귀 호출을 하기 때문에 공간 복잡도 또한 O(n)이 된다.

//: [Next Challenge](@next)

