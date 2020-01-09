// Copyright (c) 2019 Razeware LLC
// For full license & permission details, see LICENSE.markdown.

public struct AVLTree<Element: Comparable> {
  
  public private(set) var root: AVLNode<Element>?
  
  public init() {}
}

extension AVLTree: CustomStringConvertible {
  
  public var description: String {
    guard let root = root else { return "empty tree" }
    return String(describing: root)
  }
}

extension AVLTree {
  
  public mutating func insert(_ value: Element) {
    root = insert(from: root, value: value)
  }
  
//  private func insert(from node: AVLNode<Element>?, value: Element) -> AVLNode<Element> {
//    guard let node = node else {
//      return AVLNode(value: value)
//    }
//    if value < node.value {
//      node.leftChild = insert(from: node.leftChild, value: value)
//    } else {
//      node.rightChild = insert(from: node.rightChild, value: value)
//    }
//    return node
//  }
    
    
    
    
    //추가
    
    //left rotation
    //일련의 오른쪽 child가 불균형일 때 left rotation을 사용한다. //p.185
    //두 가지 요점이 있다.
    // • In-order traversal(중위 순회)는 동일하게 유지 된다.
    // • 회전 후 tree의 height가 하나 감소한다.
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
    //예시 다이어그램은 p.186

    //right rotation
    //left rotation의 대칭이다. 일련의 왼쪽 child가 불균형일 때 right rotation을 사용한다. //p.187
    private func rightRotate(_ node: AVLNode<Element>) -> AVLNode<Element> {
        let pivot = node.leftChild!
        node.leftChild = pivot.rightChild
        pivot.rightChild = node
        node.height = max(node.leftHeight, node.rightHeight) + 1
        pivot.height = max(pivot.leftHeight, pivot.rightHeight) + 1
        return pivot
    }
    //왼쪽 과 오른쪽이 바뀌었다는 점을 제외하면, leftRotate(_:)과 동일하다.

    //right-left rotation
    //left rotation은 일련의 right child의 균형을 맞춘다. 반대로 right rotation는 일련의 left child의 균형을 맞춘다.
    //하지만, 균형을 맞춰야할 node들이 left와 right child 모두 있는 경우도 있다. //p.188
    //right-left rotation은 right rotation으로 left node를 회전해, 일련의 right child를 불균형 상태로 만든 후,
    //left rotation을 해서 전체 트리의 균형을 맞춘다.
    private func rightLeftRotate(_ node: AVLNode<Element>) -> AVLNode<Element> {
        guard let rightChild = node.rightChild else {
            return node
        }
        node.rightChild = rightRotate(rightChild)
        return leftRotate(node)
    }

    //left-right rotation
    //left-right rotation은 right-left rotation의 대칭이다. //p.189
    //left-right rotation은 left rotation으로 right node를 회전해, 일련의 left child를 불균형 상태로 만든 후,
    //right rotation을 해서 전체 트리의 균형을 맞춘다.
    private func leftRightRotate(_ node: AVLNode<Element>) -> AVLNode<Element> {
        guard let leftChild = node.leftChild else {
            return node
        }
        node.leftChild = leftRotate(leftChild)
        return rightRotate(node)
    }
    //언제 올바른 위치에 회전을 적용하는지 결정해야 한다.

    //Balance
    //다음 작업은 balanceFactor를 사용해, node가 밸런싱이 필요한지 여부를 결정하는 것이다.
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
    
    //Revisiting insertion
    public func insert(from node: AVLNode<Element>?, value: Element) -> AVLNode<Element> {
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
    leftChild?.min ?? self
  }
}

extension AVLTree {
  
  public mutating func remove(_ value: Element) {
    root = remove(node: root, value: value)
  }
  
//  private func remove(node: AVLNode<Element>?, value: Element) -> AVLNode<Element>? {
//    guard let node = node else {
//      return nil
//    }
//    if value == node.value {
//      if node.leftChild == nil && node.rightChild == nil {
//        return nil
//      }
//      if node.leftChild == nil {
//        return node.rightChild
//      }
//      if node.rightChild == nil {
//        return node.leftChild
//      }
//      node.value = node.rightChild!.min.value
//      node.rightChild = remove(node: node.rightChild, value: node.value)
//    } else if value < node.value {
//      node.leftChild = remove(node: node.leftChild, value: value)
//    } else {
//      node.rightChild = remove(node: node.rightChild, value: value)
//    }
//    return node
//  }
    
    
    
    
    //Revisiting remove
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
        
        let balancedNode = balanced(node)
        balancedNode.height = max(balancedNode.leftHeight, balancedNode.rightHeight) + 1
        return balancedNode
    }
}
