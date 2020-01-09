//Chapter 16: AVL Trees

//이진 탐색 트리에서 여러 연산의 시간 복잡도는 O(log n)이다. 하지만, 트리가 불균형 상태이면, O(n)까지 성능이 저하될 수 있다.
//1962년, Georgy Adelson-Velsky와 Evgenii Landis는 최초의 self-balancing binary search tree인 AVL tree를 고안했다.




//Understanding balance
//이진 탐색 트리의 성능을 최적화하려면 balanced tree가 중요하다. 여기에는 세 가지 주요 균형 상태가 있다.

//Perfect balance
//이진 탐색 트리의 이상적인 형태는 완벽하게 균형 잡힌 상태이다. 이는 위에서 아래로 tree의 모든 level에서 node가 채워져 있다는 의미이다. //p.181
//tree는 완벽하게 대칭일 뿐 아니라 최하위 level의 node까지 완전히 채워진다. 이것이 Perfect balance의 요건이다.

//"Good-enough" balance
//Perfect balance을 이루는 것은 이상적이지만 대부분의 경우 불가능하다.
//완벽하게 균형 잡힌 트리는 바닥까지 모든 level을 채우기 위한 정확한 수의 node가 필요하다.
//ex. 1, 3, 7 개의 node를 가진 tree는 완벽하게 균형을 맞출 수 있지만,
// 2, 4, 5, 6 개의 node를 가진 tree는 마지막 level이 채워지지 않기 때문에 완벽하게 균형을 맞출 수 없다.
//균형 잡힌 tree의 정의는 tree의 가장 아래 level을 제외한 모든 lavel의 tree를 채워야 한다는 것이다.
//대부분의 이진 트리에서는 이것이 최선이다.

//Unbalanced
//마지막으로 불균형 상태가 있다. 이 상태의 이진 탐색 트리는 불균형 정도에 따라 다양한 수준의 성능 손실이 발생한다.
//tree의 균형을 유지하면, find, insert, remove 작업은 O(log n)의 시간 복잡도를 가진다.
//AVL tree는 tree의 균형이 맞지 않을 때 tree의 구조를 조정하여 균형을 유지한다.




//Implementation
//이진 탐색 트리(binary search tree)와 AVL tree는 거의 동일하다. 추가해야 할 것은 균형 구성 요소뿐이다.

//Measuring balance
//이진 트리의 균형을 유지하려면, tree의 균형을 측정하는 방법이 필요하다. AVL 트리는 각 node에서 height 속성을 사용하여 이를 달성한다.
//node의 height는 현재 node에서 leaf node까지의 가장 긴 거리이다.
//AVLNode에 height 속성을 추가한다.
//      public var height = 0
//특정 node의 균형이 맞는지 확인하기 위해 하위 node의 상대적인 height를 사용한다.
//      public var balanceFactor: Int {
//          leftHeight - rightHeight
//      }
//      public var leftHeight: Int {
//          leftChild?.height ?? -1
//      }
//      public var rightHeight: Int {
//          rightChild?.height ?? -1
//      }
//각 node의 왼쪽, 오른쪽 child의 height는 최대 1만큼(절대값 1) 달라야 한다. 이를 balance factor(균형인수, 균형계수, BF..)라 한다.
//balanceFactor는 왼쪽 및 오른쪽 child의 height 차이를 계산한다. 특정 child가 0이 아닌 경우 height는 -1로 간주된다. //p.184
//height와 balanceFactor를 계산한다. balanceFactor는 (왼쪽 서브 트리 height - 오른쪽 서브 트리 height)
//불균형한 tree가 되면, 균형을 잡는 과정이 추가 된다.
//균형 트리에서 삽입 혹은 삭제 후 불균형한 트리가 되면, 각 balanceFactor가 최소 -2, 최대 2 가 된다.
//즉, 균형 트리에서 삽입, 삭제 후에는 balanceFactor의 절대값이 2보다 크지 않다는 것이 보장된다.
//두 개 이상의 node에서 BF가 잘못될(-2 혹은 2) 수 있지만, 해당 node 중 가장 아래의 node에서만 균형 잡업(Rotation)을 해 주면 된다.

//Rotations
//이진 탐색 트리의 균형을 맞추는 데 사용되는 절차를 회전(Rotation)이라 한다.
//불균형 트리가 되는 4가지 경우에 대해, 총 4가지 방법의 회전이 있다

//left rotation
//일련의 오른쪽 child가 불균형일 때 left rotation을 사용한다. //p.185
//두 가지 요점이 있다.
// • In-order traversal(중위 순회)는 동일하게 유지 된다.
// • 회전 후 tree의 height가 하나 감소한다.
extension AVLTree {
    private func leftRotate(_ node: AVLNode<Element>) -> AVLNode<Element> {
        let pivot = node.rightChild! //오른쪽 child를 pivot으로 선택한다(다이어그램에서 y, node는 x).
        //이 node는 회전된 node를 하위 트리의 root로 교체한다(level 증가).
        node.rightChild = pivot.leftChild
        //회전할 node는 pivot의 왼쪽 child가 된다(level 감소). 즉, 현재 pivot의 왼쪽 child를 다른 곳으로 이동해야 한다.
        //해당 다이어그램에서 이 node는 b이다. b는 y보다 작지만, x보다 크므로 y를 x의 오른쪽 child로 바꿀 수 있다.
        //따라서 회전된 node의 rightChild를 pivot의 leftChild로 업데이트 한다.
        pivot.leftChild = node
        //pivot의 leftChild를 회전한 node로 설정한다.
        node.height = max(node.leftHeight, node.rightHeight) + 1
        pivot.height = max(pivot.leftHeight, pivot.rightHeight) + 1
        //회전한 node와 pivot의 height를 업데이트 한다.
        return pivot //마지막으로 tree에서 회전된 node를 교체할 수 있도록 pivot을 반환한다.
    }
}
//예시 다이어그램은 p.186

//right rotation
//left rotation의 대칭이다. 일련의 왼쪽 child가 불균형일 때 right rotation을 사용한다. //p.187
extension AVLTree {
    private func rightRotate(_ node: AVLNode<Element>) -> AVLNode<Element> {
        let pivot = node.leftChild!
        node.leftChild = pivot.rightChild
        pivot.rightChild = node
        node.height = max(node.leftHeight, node.rightHeight) + 1
        pivot.height = max(pivot.leftHeight, pivot.rightHeight) + 1
        return pivot
    }
}
//왼쪽 과 오른쪽이 바뀌었다는 점을 제외하면, leftRotate(_:)과 동일하다.

//right-left rotation
//left rotation은 일련의 right child의 균형을 맞춘다. 반대로 right rotation는 일련의 left child의 균형을 맞춘다.
//하지만, 균형을 맞춰야할 node들이 left와 right child 모두 있는 경우도 있다. //p.188
//right-left rotation은 right rotation으로 left node를 회전해, 일련의 right child를 불균형 상태로 만든 후,
//left rotation을 해서 전체 트리의 균형을 맞춘다.
extension AVLTree {
    private func rightLeftRotate(_ node: AVLNode<Element>) -> AVLNode<Element> {
        guard let rightChild = node.rightChild else {
            return node
        }
        node.rightChild = rightRotate(rightChild)
        return leftRotate(node)
    }
}

//left-right rotation
//left-right rotation은 right-left rotation의 대칭이다. //p.189
//left-right rotation은 left rotation으로 right node를 회전해, 일련의 left child를 불균형 상태로 만든 후,
//right rotation을 해서 전체 트리의 균형을 맞춘다.
extension AVLTree {
    private func leftRightRotate(_ node: AVLNode<Element>) -> AVLNode<Element> {
        guard let leftChild = node.leftChild else {
            return node
        }
        node.leftChild = leftRotate(leftChild)
        return rightRotate(node)
    }
}
//언제 올바른 위치에 회전을 적용하는지 결정해야 한다.

//Balance
//다음 작업은 balanceFactor를 사용해, node가 밸런싱이 필요한지 여부를 결정하는 것이다.
extension AVLTree {
    private func balanced(_ node: AVLNode<Element>) -> AVLNode<Element> {
        switch node.balanceFactor { //balanceFactor = leftHeight - rightHeight
        case 2: //왼쪽 child가 더 무겁다. right rotation 혹은 left-right rotation
            if let leftChild = node.leftChild, leftChild.balanceFactor == -1 { //이중 회전
                return leftRightRotate(node)
            } else { //단일 회전
                return rightRotate(node)
            }
        case -2: //오른쪽 child가 더 무겁다. left rotation 혹은 right-left rotation
            if let rightChild = node.rightChild, rightChild.balanceFactor == 1 { //이중 회전
                return rightLeftRotate(node)
            } else { //단일 회전
                return leftRotate(node)
            }
        default: //균형 상태
            return node //node 반환
        }
    }
}
//고려해야 할 세 가지 경우가 있다. //balanceFactor = leftHeight - rightHeight
// 1. balanceFactor가 2인 경우는 왼쪽 child가 오른쪽 child보다 더 무겁다(더 많은 node를 포함하고 있다)는 의미이다.
//  즉, right rotation 혹은 left-right rotation을 사용해야 한다.
// 2. balanceFactor가 -2인 경우는 오른쪽 child가 왼쪽 child보다 더 무겁다(더 많은 node를 포함하고 있다)는 의미이다.
//  즉, left rotation 혹은 right-left rotation을 사용해야 한다.
// 3. 이외의 경우에는 특정 node가 균형을 이루고 있음을 나타낸다.
//balanceFactor의 부호를 확인하여, 단일 회전(right rotation, left rotation)이 필요한지,
//이중 회전(left-right rotation, right-left rotation)이 필요한지 알 수 있다. //p.190
//node와 그 바로 아래 child의 부호가 같다면 단일 회전, 다르다면 이중 회전이 필요하다.

//Revisiting insertion
extension AVLTree {
    private func insert(from node: AVLNode<Element>?, value: Element) -> AVLNode<Element> {
        guard let node = node else {
            return AVLNode(value: value)
        }

        if value < node.value {
            node.leftChild = insert(from: node.leftChild, value: value)
        } else {
            node.rightChild = insert(from: node.rightChild, value: value)
        }

        //추가
        let balancedNode = balanced(node)
        balancedNode.height = max(balancedNode.leftHeight, balancedNode.rightHeight) + 1

        return balancedNode
    }
}
//insert 이후, node를 반환하기 전에 balanced()를 호출한다. 이렇게 하면, call stack은 모든 node에서 균형에 문제가 있는지 확인할 수 있다.
//또한, node의 height를 업데이트 한다.
example(of: "repeated insertions in sequence") {
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
}
//회전을 적용하지 않은 일반적은 tree 구현의 경우에는 다음과 같이 불균형한 tree가 된다.
//              ┌──14
//             ┌──13
//             │ └──nil
//            ┌──12
//            │ └──nil
//           ┌──11
//           │ └──nil
//          ┌──10
//          │ └──nil
//         ┌──9
//         │ └──nil
//        ┌──8
//        │ └──nil
//       ┌──7
//       │ └──nil
//      ┌──6
//      │ └──nil
//     ┌──5
//     │ └──nil
//    ┌──4
//    │ └──nil
//   ┌──3
//   │ └──nil
//  ┌──2
//  │ └──nil
// ┌──1
// │ └──nil
// 0
// └──nil

//Revisiting remove
//self-balancing 추가한 remove을 구현하는 것도 insert와 비슷하다.
//node를 반환하기 전에 balanced()를 호출해 node에서 균형 문제를 해결하고, node의 height를 업데이트 한다.
example(of: "removing a value") {
    var tree = AVLTree<Int>()
    tree.insert(15)
    tree.insert(10)
    tree.insert(16)
    tree.insert(18)
    print(tree)
    //  ┌──18
    // ┌──16
    // │ └──nil
    // 15
    // └──10
    tree.remove(10)
    print(tree)
    // ┌──18
    // 16
    // └──15
}
//AVL tree의 self-balancing property는 insert 및 remove이 O(log n) 시간복잡도로 최적의 성능으로 작동하도록 보장한다.




//Where to go from here?
//AVL tree는 최초의 self-balancing BST 이지만, 이후에 구현된 red-black tree, splay tree 등이 있다.
//https://github.com/raywenderlich/swift-algorithm-club/tree/master/Red-Black%20Tree
//https://github.com/raywenderlich/swift-algorithm-club/tree/master/Red-Black%20Tree
