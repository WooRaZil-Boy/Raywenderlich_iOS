// Copyright (c) 2019 Razeware LLC
// For full license & permission details, see LICENSE.markdown.

/*:
# Binary Search Challenge

 ### Challenge 1: Binary search as a free function

 Implement binary search as a free function. You should be able to run:

 ```swift
 let array = [1, 2, 10, 43, 55, 60, 150, 1420]
 binarySearch(for: 10, in: array) == 2
 ```
 
 */
//이전에는 RandomAccessCollection 프로토콜을 extension해서 이전 탐색을 구현했다.
//이진 탐색은 정렬된 Collection에서만 작동하므로, RandomAccessCollection의 일부로 해당 함수를 노출하면 오용될 가능성이 있다.
//이를 방지하기 위해, 이진 검색을 일반 함수로 구현한다.




func binarySearch<Elements: RandomAccessCollection>(
    for element: Elements.Element,
    in collection: Elements,
    in range: Range<Elements.Index>? = nil) -> Elements.Index? where Elements.Element: Comparable {
    
    let range = range ?? collection.startIndex..<collection.endIndex
    
    guard range.lowerBound < range.upperBound else {
        return nil
    }
    
    let size = collection.distance(from: range.lowerBound, to: range.upperBound)
    let middle = collection.index(range.lowerBound, offsetBy: size / 2)
    
    if collection[middle] == element {
        return middle
    } else if collection[middle] > element {
        return binarySearch(for: element, in: collection, in: range.lowerBound..<middle)
    } else {
        return binarySearch(for: element, in: collection, in: collection.index(after: middle)..<range.upperBound)
    }
}
/*:
 [Next Challenge](@next)
 */
