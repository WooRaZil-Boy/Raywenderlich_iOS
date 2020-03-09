// Copyright (c) 2019 Razeware LLC
// For full license & permission details, see LICENSE.markdown.
//: [Previous Challenge](@previous)
//: ## Challenge 3: Reverse a collection
//: Reverse a collection of elements by hand. Do not rely on the
//: reverse or reversed methods.
//Collection을 뒤집는다. reverse나 reversed 메서드를 사용해선 안 된다.



//Collection을 reverse하는 것은 매우 간단하다. 이중 참조를 사용해, Collection의 시작과 끝에서 요소를 swap하면서 반복하면 반복하면서 가운데로 이동하면 된다.
extension MutableCollection where Self: BidirectionalCollection {
    //Collection이 변경되므로, MortableCollection을 구현해야 한다.
    //또한, 양방향으로 순회하므로 BidirectionalCollection를 구현해야 한다.
    mutating func reversed() {
        var left = startIndex
        var right = index(before: endIndex)
        
        while left < right {
            swapAt(left, right)
            formIndex(after: &left)
            formIndex(before: &right)
        }
    }
}
//이 알고리즘의 시간 복잡도는 O(n)이다.

