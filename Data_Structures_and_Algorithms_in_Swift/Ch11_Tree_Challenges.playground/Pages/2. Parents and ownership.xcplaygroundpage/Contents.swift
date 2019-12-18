//Challenge 2: Parents and ownership

//Consider the original definition of a tree node:
public class TreeNode<T> {
    public var value: T
    public var children: [TreeNode] = []
    
    public init(_ value: T) {
        self.value = value
    }
}

//How can you modify this definition to include a parent? What considerations should you make about ownership?




//부모 node를 클래스에 추가할 수 있다.
//public weak var parent: TreeNode?
//Root에는 parent가 없으므로 optional이 되야 한다. reference cycle을 피하기 위해 weak으로 선언된다.
//일반적으로 node는 하위 항목들과는 강력한 소유 관계를 가지지만, 상위 항목과는 관계가 약하다.
//이렇게 parent를 포함하는 node는 doubly linked list와 비슷하다.
//오버헤드에 주의해야 하지만, 트리를 상향으로 순회해야 할 때 빠르게 이동할 수 있다.

