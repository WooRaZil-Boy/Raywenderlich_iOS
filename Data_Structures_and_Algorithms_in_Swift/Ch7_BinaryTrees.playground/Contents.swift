// Copyright (c) 2018 Razeware LLC
// For full license & permission details, see LICENSE.markdown.

var tree: BinaryNode<Int> { //트리 생성
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
    //계층구조는 p.80
}

example(of: "tree diagram") {
    print(tree)
}




//Traversal algorithms

//In-order traversal
example(of: "in-order traversal") {
    tree.traverseInOrder { print($0) }
}

//Pre-order traversal
example(of: "pre-order traversal") {
    tree.traversePreOrder { print($0) }
}

//Post-order traversal
example(of: "post-order traversal") {
    tree.traversePostOrder { print($0) }
}
