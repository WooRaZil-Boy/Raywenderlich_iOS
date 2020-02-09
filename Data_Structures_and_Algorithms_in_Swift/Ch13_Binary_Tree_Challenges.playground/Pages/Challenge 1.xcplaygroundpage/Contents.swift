// Copyright (c) 2019 Razeware LLC
// For full license & permission details, see LICENSE.markdown.

//이진트리는 알고리즘 인터뷰에서 굉장히 인기있는 주제이다.
//이진트리에서 순회 방법에 대한 기초를 잘 갖추어야 할 뿐아니라 재귀 역추적(recursive backtracking)에 대한 이해가 필요하다.
/*:
 # Binary Tree Challenges
 
 ## #1. Height of a Tree
 
 Given a binary tree, find the height of the tree. The height of the binary tree
 is determined by the distance between the root and the furthest leaf. The
 height of a binary tree with a single node is zero, since the single node is
 both the root and the furthest leaf.
 */

//주어진 이진 트리(Binary Tree)의 높이(height)를 계산한다. 트리의 높이는 root와 가장 먼 leaf 사이의 거리로 결정된다.
//단일 노드로 이뤄진 트리(Root밖에 없는 트리)는, root가 가장 먼 leaf이므로 높이는 0이 된다.

var tree: BinaryNode<Int> = {
  let zero = BinaryNode(value: 0)
  let one = BinaryNode(value: 1)
  let five = BinaryNode(value: 5)
  let seven = BinaryNode(value: 7)
  let eight = BinaryNode(value: 8)
  let nine = BinaryNode(value: 9)
  
  seven.leftChild = one
  one.leftChild = zero
  one.rightChild = five
  seven.rightChild = nine
  nine.leftChild = eight
  
  return seven
}()

print(tree)




//재귀를 사용해 간단히 이진트리의 높이를 구할 수 있다.
func height<T>(of node: BinaryNode<T>?) -> Int {
    guard let node = node else { //node가 nil이면 -1 반환한다.
        return -1
    }
    
    return 1 + max(height(of: tree.leftChild), height(of: tree.rightChild))
    //재귀적으로 height 함수를 호출한다. 방문하는 모든 node에서 가장 높이가 큰 child를 추가한다.
    //leaf에서는 leftChild와 rightChild가 모두 없으므로 max(-1, -1)이 되어 +1 하여 0이 된다.
    //한쪽 child만 있는 경우에는 max(-1, 0) 혹은 max(0, -1)이 되므로 +1 하여 1이 된다.
    //이런 식으로 계속 재귀 호출되면서 height를 구하게 된다.
}
//이 알고리즘은 모든 노드를 순회해야 하므로 시간 복잡도는 O(n)이다.
//공간 복잡도 또한, 호출 Stack에 대해 동일한 n 재귀를 수행해야 하므로 O(n)이다.

height(of: tree)
//: [Next Challenge](@next)
