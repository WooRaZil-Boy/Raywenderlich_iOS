// Copyright (c) 2019 Razeware LLC
// For full license & permission details, see LICENSE.markdown.
//: [Previous Challenge](@previous)
/*:
 ## 3. Partitioning with Swift Standard Library
 
 Implement Quicksort using the `partition(by:)` function that is part of the Swift Standard Library.

 > For more information refer to Apple's documentation here: https://developer.apple.com/documentation/swift/array/3017524-partition

 */
//Swift Standard Library의 partition(by:) 함수를 사용해, Quick sort를 구현한다.
//https://developer.apple.com/documentation/swift/array/3017524-partition
//partition(by:)는 Collection을 재정렬하고, 해당 조건을 만족하는 첫 index를 반환한다.
//따라서 반환되는 index 이전의 요소들은 해당 조건을 만족하지 않고, index 이후의 요소들은 해당 조건을 만족한다.




//Collection에서 퀵 정렬을 수행하려면, 다음 사항을 충족해야 한다.
// • Collection은 반드시 MutableCollection이어야 한다. 이를 구현해야 Collection 요소의 value를 변경할 수 있다.
// • Collection은 반드시 BidirectionalCollection이어야 한다. 이를 구현해야, Collection을 앞 뒤로 순회할 수 있다.
//  퀵 정렬은 Collection의 first와 last의 index에 따라 달라진다.
// • Collection의 요소는 Comparable이어야 한다.
extension MutableCollection where Self: BidirectionalCollection, Element: Comparable {
    mutating func quicksort() {
        quicksortLumuto(low: startIndex, high: index(before: endIndex))
    }
    
    private mutating func quicksortLumuto(low: Index, high: Index) {
        //low, high index로 정렬을 시행한다.
        if low <= high { //start와 end의 index가 서로 겹칠 때까지 Collection에서 퀵 정렬을 한다.
            let pivotValue = self[high] //Lumuto 알고리즘은 Collection의 마지막 요소를 pivot으로 선택해 구분한다.
            var p = self.partition { $0 > pivotValue }
            //Collection의 요소를 분할하고, pivot 값보다 큰 첫 번째 index p 를 반환한다.
            //p 이전의 요소들은 조건을 만족시키지 않고, p 이후의 요소들은 조건을 만족시킨다.
            
            if p == endIndex { //p 가 마지막 index인 경우, before index로 이동한다.
                // [8 3 2 8]
                //        p
                //이런 경우에(p가 마지막 index인 경우), partition을 수행해도 변화가 없다.
                //p 이전의 요소는 partition을 만족시키지 않으므로, out of memory가 될때까지 재귀 loop에 빠진다.
                p = index(before: p)
            }
            
            self[..<p].quicksortLumuto(low: low, high: index(before: p))
            //pivotValue보다 크지 않은 요소로 구성된 첫 partition에서 퀵 정렬을 수행한다.
            self[p...].quicksortLumuto(low: index(after: p), high: high)
            //pivotValue보다 큰 요소로 구성된 두 번째 partition에서 퀵 정렬을 수행한다.
        }
    }
}

var numbers = [12, 0, 3, 9, 2, 21, 18, 27, 1, 5, 8, -1, 8]
print(numbers) // [12, 0, 3, 9, 2, 21, 18, 27, 1, 5, 8, -1, 8]
numbers.quicksort()
print(numbers) // [-1, 0, 1, 2, 3, 5, 8, 8, 9, 12, 18, 21, 27]

//partition(by:)의 구현을 살펴보면, _partitionImpl(by:)이 Hoare’s partition과 유사한 전략을 사용하는 것을 확인할 수 있다.
