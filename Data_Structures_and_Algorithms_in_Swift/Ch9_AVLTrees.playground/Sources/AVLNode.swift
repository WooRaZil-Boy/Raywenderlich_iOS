// Copyright (c) 2018 Razeware LLC
// For full license & permission details, see LICENSE.markdown.

public class AVLNode<Element> {
  
  public var value: Element
  public var leftChild: AVLNode?
  public var rightChild: AVLNode?
    public var height = 0 //균형 측정을 위한 속성
    //Measuring balance
    //트리의 균형을 유지하려면, 먼저 균형 여부를 측정해야 한다. AVL 트리는 각 노드의 높이 속성으로 이를 수행한다.
    //노드의 높이는 현재 노드에서 리프 노드까지의 최장 거리이다. p.104
    //즉, 모든 리프 노드에서 높이는 0이 된다.
    
    //균형을 이루려면, 각 노드의 왼쪽 및 오른쪽 하위 노드의 높이는 1 이하로 달라야 한다.
  
  public init(value: Element) {
    self.value = value
  }
}

extension AVLNode: CustomStringConvertible {
  
  public var description: String {
    return diagram(for: self)
  }
  
  private func diagram(for node: AVLNode?,
                       _ top: String = "",
                       _ root: String = "",
                       _ bottom: String = "") -> String {
    guard let node = node else {
      return root + "nil\n"
    }
    if node.leftChild == nil && node.rightChild == nil {
      return root + "\(node.value)\n"
    }
    return diagram(for: node.rightChild, top + " ", top + "┌──", top + "│ ")
      + root + "\(node.value)\n"
      + diagram(for: node.leftChild, bottom + "│ ", bottom + "└──", bottom + " ")
  }
}

extension AVLNode {
  
  public func traverseInOrder(visit: (Element) -> Void) {
    leftChild?.traverseInOrder(visit: visit)
    visit(value)
    rightChild?.traverseInOrder(visit: visit)
  }
  
  public func traversePreOrder(visit: (Element) -> Void) {
    visit(value)
    leftChild?.traversePreOrder(visit: visit)
    rightChild?.traversePreOrder(visit: visit)
  }
  
  public func traversePostOrder(visit: (Element) -> Void) {
    leftChild?.traversePostOrder(visit: visit)
    rightChild?.traversePostOrder(visit: visit)
    visit(value)
  }
}




//MARK: - Measuring balance
extension AVLNode {
    public var balanceFactor: Int {
        //트리의 균형을 유지하려면, 먼저 균형 여부를 측정해야 한다. AVL 트리는 각 노드의 높이 속성으로 이를 수행한다.
        //노드의 높이는 현재 노드에서 리프 노드까지의 최장 거리이다. p.104
        //즉, 모든 리프 노드에서 높이는 0이 된다.
        
        //균형을 이루려면, 각 노드의 balanceFactor(자식 노드의 높이 차이)의 절대값이 1 이하 이어야 한다(0이나 1).
        //balanceFactor는 왼쪽 자식 노드의 높이에서 오른쪽 자식 노드의 높이를 빼서 구한다.
        //자식이 오른쪽만 있고 leaf라면, balanceFactor는 -1이 된다. p.105
        //자식이 왼쪽만 있고 leaf라면, balanceFactor는 1이 된다.
        
        //여기서 특정 노드를 추가할 때 불균형 트리가 될 수 있다.
        //balanceFactor 절대값이 1을 초과하는 노드가 있는 경우 불균형 트리가 된다. p.106
        //여러 개의 노드의 balanceFactor가 적절하지 않아도(절대값이 1 초과)
        //잘못된 노드 중 가장 아래에 위치한 곳에서 rotation 절차를 수행하면 된다.
        
        return leftHeight - rightHeight
    }
    
    public var leftHeight: Int {
        //왼쪽 자식 노드의 높이
        return leftChild?.height ?? -1
        //왼쪽 자식 노드가 없다면 왼쪽 자식 노드의 높이는 -1
    }
    
    public var rightHeight: Int {
        //오른쪽 자식 노드의 높이
        return rightChild?.height ?? -1
        //오른쪽 자식 노드가 없다면 오른쪽 자식 노드의 높이는 -1
    }
    
    //한 쪽만 자식을 가지고 있는 노드의 경우, 자식이 없는 쪽의 높이는 -1이 된다.
}
