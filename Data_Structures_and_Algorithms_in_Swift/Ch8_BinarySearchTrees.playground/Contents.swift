// Copyright (c) 2018 Razeware LLC
// For full license & permission details, see LICENSE.markdown.

var exampleTree: BinarySearchTree<Int> {
    var bst = BinarySearchTree<Int>()
    bst.insert(3)
    bst.insert(1)
    bst.insert(4)
    bst.insert(0)
    bst.insert(2)
    bst.insert(5)
    
    return bst
    //알고리즘으로 self-balancing trees를 구현할 수 있다(다음 장에 구현).
    //여기서는 약간의 트릭을 줘서 간단하게 구현하도록 한다.
}




//Inserting elements
example(of: "building a BST 1") {
    var bst = BinarySearchTree<Int>()
    
    for i in 0..<5 {
        bst.insert(i)
    }
    
    print(bst)
    //불균형을 이루고 있더라도 이진 검색 트리가 맞다.
    //하지만 이런 경우는 성능에 악영향을 끼치므로 균형 잡힌 트리가 되도록 구현하는 것이 좋다. p.92
}

example(of: "building a BST 2") {
    print(exampleTree)
}




//Finding elements
example(of: "finding a node") {
    if exampleTree.contains(5) {
        print("Found 5!")
    } else {
        print("Couldn't find 5")
    }
}




//Removing elements
example(of: "removing a node") {
    var tree = exampleTree
    print("Tree before removal:")
    print(tree)
    
    tree.remove(3)
    print("Tree after removing root:")
    print(tree)
}
