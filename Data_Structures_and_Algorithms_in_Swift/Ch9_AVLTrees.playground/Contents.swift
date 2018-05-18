// Copyright (c) 2018 Razeware LLC
// For full license & permission details, see LICENSE.markdown.

////Revisiting insertion
example(of: "repeated insertions in sequence") {
    var tree = AVLTree<Int>()
    
    for i in 0..<15 {
        tree.insert(i)
    }
    
    print(tree)
    //균형 잡힌 트리를 만든다.
}




//Revisiting remove
example(of: "removing a value") {
    var tree = AVLTree<Int>()
    tree.insert(15)
    tree.insert(10)
    tree.insert(16)
    tree.insert(18)
    print(tree)
    tree.remove(10)
    print(tree)
}

