// Copyright (c) 2018 Razeware LLC
// For full license & permission details, see LICENSE.markdown.

public struct AVLTree<Element: Comparable> {
  
  public private(set) var root: AVLNode<Element>?
  
  public init() {}
}

extension AVLTree: CustomStringConvertible {
  
  public var description: String {
    return root?.description ?? "empty tree"
  }
}

extension AVLTree {
  
  public mutating func insert(_ value: Element) {
    root = insert(from: root, value: value)
  }
  
  private func insert(from node: AVLNode<Element>?, value: Element) -> AVLNode<Element> {
    guard let node = node else {
      return AVLNode(value: value)
    }
    
    if value < node.value {
      node.leftChild = insert(from: node.leftChild, value: value)
    } else {
      node.rightChild = insert(from: node.rightChild, value: value)
    }
    
//    return node //삽입 후 직접 노드 반환
    
    //Revisiting insertion
    let balancedNode = balanced(node) //균형을 잡은 노드를 반환한다. //모든 노드의 균형을 조정한다.
    balancedNode.height = max(balancedNode.leftHeight, balancedNode.rightHeight) + 1
    //노드 높이 업데이트
    
    return balancedNode
  }
}

extension AVLTree {
  
  public func contains(_ value: Element) -> Bool {
    var current = root
    while let node = current {
      if node.value == value {
        return true
      }
      if value < node.value {
        current = node.leftChild
      } else {
        current = node.rightChild
      }
    }
    return false
  }
}

private extension AVLNode {
  
  var min: AVLNode {
    return leftChild?.min ?? self
  }
}

extension AVLTree {
  
  public mutating func remove(_ value: Element) {
    root = remove(node: root, value: value)
  }
  
  private func remove(node: AVLNode<Element>?, value: Element) -> AVLNode<Element>? {
    guard let node = node else {
      return nil
    }
    
    if value == node.value {
      if node.leftChild == nil && node.rightChild == nil {
        return nil
      }
      if node.leftChild == nil {
        return node.rightChild
      }
      if node.rightChild == nil {
        return node.leftChild
      }
      node.value = node.rightChild!.min.value
      node.rightChild = remove(node: node.rightChild, value: node.value)
    } else if value < node.value {
      node.leftChild = remove(node: node.leftChild, value: value)
    } else {
      node.rightChild = remove(node: node.rightChild, value: value)
    }
    
//    return node //삭제 후 노드 반환
    
    //Revisiting remove
    let balancedNode = balanced(node)
    //균형을 잡은 노드를 반환한다. //모든 노드의 균형을 조정한다.
    balancedNode.height = max(balancedNode.leftHeight, balancedNode.rightHeight) + 1
    //노드 높이 업데이트
    
    return balancedNode
  }
}

//이진 검색 트리에서 균형 잡힌 트리가 되지 않으면, 효율이 크게 감소한다.
//1962년 Georgy Adelson-Velsky와 Evgenii Landis는 최초로 자체 균형 조정 이진 검색 트리인 AVL Tree를 만들었다.




//Understanding balance
//균형 트리는 이진 검색 트리의 성능을 최적화하는 핵심 요소이다.

//Perfect balance
//가장 이상적인 형태로, 트리가 완벽하게 대칭이면서 모든 레벨의 노드가 채워져 있다. p.102

//"Good-enough" balance
//Perfect balance는 특정 수의 노드가 있을 경우에만 구현 가능하므로 흔한 경우가 아니다.
//가장 아래를 제외하고, 트리의 모든 레벨을 채운 형태로 대부분의 경우 이 상태가 가장 좋은 방법이 된다. p.103

//Unbalanced
//이 상태의 트리는 성능에 손실이 있다.
//AVL 트리는 이 상태가 되면, 트리 구조를 조정하여 균형 상태로 만든다. p.103

//이진 검색 트리의 구현과 대부분 동일하다. 트리의 균형을 잡아주는 요소를 추가한다.
//자동으로 균형을 맞춰 주기 때문에 최적의 성능인 O(log n)으로 삽입 및 제거가 되도록 보장한다.
//AVL 트리 외에도 다양한 자동 균형 이진 검색 트리 들이 있다.
//https://github.com/raywenderlich/swift-algorithm-club/tree/master/Red-Black%20Tree
//https://github.com/raywenderlich/swift-algorithm-club/tree/master/Splay%20Tree




//MARK: - Rotations
//이진 검색 트리의 균형을 맞추는 데 사용하는 절차를 회전이라 한다.
//각 경우에 따라 4가지의 방법이 있다(left, left-right, right, right-left).
extension AVLTree {
    private func leftRotate(_ node: AVLNode<Element>) -> AVLNode<Element> {
        //Left rotation //p.107, p.108
        //Right rotation에 대칭적인 회전이다. 일련의 우측 자식 노드들이 불균형일 때 사용한다.
        //• 노드에 대한 In-order traversal는 동일하게 유지된다.
        //• 회전후 트리의 depth가 1 단계 줄어든다.
        let pivot = node.rightChild! //오른쪽 자식을 피벗으로 선택한다.
        //이 노드(피벗)는 회전 후, 회전 된 노드를 하위로 가지는 부모 노드가 된다(level 증가).
        node.rightChild = pivot.leftChild
        //회전할 노드가 피벗의 왼쪽 자식 노드가 된다(level 감소). 따라서 피벗의 왼쪽 자식이 다른 쪽으로 이동해야 한다.
        //피벗의 왼쪽 자식 노드는 회전할 노드의 오른쪽 자식이 된다.
        pivot.leftChild = node
        //피벗의 왼쪽 자식을 회전할 노드로 설정한다.
        node.height = max(node.leftHeight, node.rightHeight) + 1
        //회전된 노드를 업데이트 한다.
        pivot.height = max(pivot.leftHeight, pivot.rightHeight) + 1
        //피벗의 높이를 업데이트 한다.
        
        return pivot //트리에서 회전된 노드를 바꿀 수 있도록 피벗을 반환한다.
    }
    
    private func rightRotate(_ node: AVLNode<Element>) -> AVLNode<Element> {
        //Right rotation //p.109
        //Left rotation에 대칭적인 회전이다. 일련의 좌측 자식 노드들이 불균형일 때 사용한다.
        let pivot = node.leftChild!
        node.leftChild = pivot.rightChild
        pivot.rightChild = node
        node.height = max(node.leftHeight, node.rightHeight) + 1
        pivot.height = max(pivot.leftHeight, pivot.rightHeight) + 1
        
        return pivot
        //왼쪽과 오른쪽에 자식 노드에 대한 참조가 바뀌었다는 점을 제외하면 leftRotate와 같다.
    }
    
    private func rightLeftRotate(_ node: AVLNode<Element>) -> AVLNode<Element> {
        //Right-left rotation
        //Left-right rotation에 대칭적인 회전이다.
        //한쪽으로 치우쳐진 불균형이 아닌 경우, 회전을 두 번 수행해서 균형을 맞출 수 있다.
        //rightRotate 이후, leftRotate을 수행한다. p.110
        guard let rightChild = node.rightChild else {
            //오른쪽 자식이 없는 경우 종료
            return node
        }
        
        node.rightChild = rightRotate(rightChild)
        //rightRotate를 실행한다.
        
        return leftRotate(node)
        //이후, leftRotate을 실행한다.
    }
    
    private func leftRightRotate(_ node: AVLNode<Element>) -> AVLNode<Element> {
        //Left-right rotation
        //Right-left rotation에 대칭적인 회전이다. p.111
        guard let leftChild = node.leftChild else {
            //왼쪽 자식이 없는 경우 종료
            return node
        }
        
        node.leftChild = leftRotate(leftChild)
        //leftRotate를 실행한다.
        
        return rightRotate(node)
        //이후, rightRotate를 실행한다.
    }
}




//MARK: - Balance
extension AVLTree {
    private func balanced(_ node: AVLNode<Element>) -> AVLNode<Element> {
        //위에서 구현한 Rotation 메서드들을 적용할 곳을 찾는데에 Balance를 사용한다. 세 가지 경우가 있다.
        switch node.balanceFactor {
            //balanceFactor로 균형을 맞춰야 하는 지 판단한다.
            //balanceFactor의 절대값이 2 이상이라면 균형을 맞춰줘야 한다.
        case 2:
            //balanceFactor가 2라면, 왼쪽 자식이 오른쪽 자식보다 노드의 수가 많으면서 불균형이다.
            //leftRightRotate 혹은 rightRotate를 사용해 균형 상태로 만들어야 한다.
            if let leftChild = node.leftChild, leftChild.balanceFactor == -1 {
                //leftChild가 존재하는 데, 왼쪽 자식의 balanceFactor가 -1이라는 것은
                //왼쪽 자식 노드의 자식이 오른쪽 한쪽만 있고 leaf인 경우이다. < 형태로 되어 있다 p.112
                return leftRightRotate(node)
            } else {
                return rightRotate(node)
            }
        case -2:
            //balanceFactor가 -2라면, 오른쪽 자식이 왼쪽 자식보다 노드의 수가 많으면서 불균형이다.
            //rightLeftRotate 혹은 leftRotate를 사용해 균형 상태로 만들어야 한다.
            if let rightChild = node.rightChild, rightChild.balanceFactor == 1 {
                //rightChild가 존재하는 데, 오른쪽 자식의 balanceFactor가 1이라는 것은
                //오른쪽 노드의 자식이 왼쪽 한쪽만 있고 leaf인 경우이다. > 형태로 되어 있다.
                return rightLeftRotate(node)
            } else {
                return leftRotate(node)
            }
        default:
            //balanceFactor의 값이 -1, 0, 1로 균형을 이루고 있는 상태이다.
            return node
            //단순히 해당 노드를 반환하면 된다.
        }
        
        //balanceFactor의 부호를 사용하여 한 번 혹은 두 번 회전해야 하는 지 알아낼 수 있다.
        //https://github.com/raywenderlich/swift-algorithm-club/tree/master/AVL%20Tree
    }
}
