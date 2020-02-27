// Copyright (c) 2019 Razeware LLC
// For full license & permission details, see LICENSE.markdown.
/*:
 [Previous Challenge](@previous)
 ### #3. Comparing Trees
 Create a method that checks if the current tree contains all the elements of another tree.
 */
//현재 트리가 다른 트리의 모든 요소를 포함하고 있는지 확인하는 메서드를 만든다. 요소가 Hashable을 구현하도록 할 수도 있다.




var bst = BinarySearchTree<Int>()
bst.insert(3)
bst.insert(1)
bst.insert(4)
bst.insert(0)
bst.insert(2)
bst.insert(5)

var bst2 = BinarySearchTree<Int>()
bst2.insert(2)
bst2.insert(5)
bst2.insert(3)
bst2.insert(1)
bst2.insert(0)
// bst2.insert(100)

// bst.contains(bst2)


//현재 tree에 다른 tree의 모든 요소가 포함되어 있는 지 확인하는 함수를 만든다. 즉, 현재 tree는 다른 tree의 상위 집합이어야 한다.
extension BinarySearchTree where Element: Hashable { //Set을 사용하려면, 요소가 Hashable이어야 한다. Element를 Hashable로 제한한다.
    public func contains(_ subtree: BinarySearchTree) -> Bool {
        var set: Set<Element> = []
        root?.traverseInOrder{ //현재 tree의 모든 요소를 set에 삽입한다.
            set.insert($0)
        }
        
        var isEqual = true //최종 결과
        //traverseInOrder가 클로저를 내부에서 직접 반환할 수 없다.
        
        subtree.root?.traverseInOrder { //서브 tree의 모든 요소에 대해 value가 set에 포함되어 있는 지 확인한다.
            isEqual = isEqual && set.contains($0)
        }
        
        return isEqual
    }
}
//이 함수의 시간 복잡도와 공간 복잡도는 모두 O(n)이다.
