// Copyright (c) 2019 Razeware LLC
// For full license & permission details, see LICENSE.markdown.
//: [Previous Challenge](@previous)
//: ## Challenge 2: Find a duplicate
//: Given a collection of Equatable elements, return the first element
//: that is a duplicate in the collection.
//Equatable 요소들이 주어졌을때, 중복된 요소가 있으면 중복된 첫 요소를 반환한다.




extension Sequence where Element: Hashable {
    var firstDuplicate: Element? {
        var found: Set<Element> = [] //현재까지의 요소를 추적한다.
        for value in self {
            if found.contains(value) {
                return value
            } else {
                found.insert(value)
            }
        }
        return nil
    }
}
//Set을 사용해, 지금까지의 요소를 추적할 수 있다. 이 알고리즘의 시간 복잡도는 O(n)이다.

let array = [2, 4, 5, 5, 2]
array.firstDuplicate

//: [Next Challenge](@next)
