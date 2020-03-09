// Copyright (c) 2019 Razeware LLC
// For full license & permission details, see LICENSE.markdown.
//: # n² Sorting Challenges
//: ## Challenge 1: Group elements
//: Given a collection of Equatable elements, bring all instances of a given
//: value in the array to the right side of the array.

//Equatable 요소의 Collection이 주어졌을 때, 동일한 모든 value를 배열의 오른쪽으로 이동한다.




//두 개의 참조를 사용해, swap을 관리한다. 첫 번째 참조는 오른쪽으로 이동해야 하는 다음 요소를 찾고, 두 번째 참조는 대상의 swap 위치를 관리한다.
extension MutableCollection where Self: BidirectionalCollection, Element: Equatable {
    //기본 Storage를 변경해야 하므로, 이 함수는 MutableCollection를 구현한 type에서만 사용할 수 있다.
    //이 알고리즘을 효율적으로 완료하려면, 역방향 index 순회가 필요하므로, BidirectionalCollection도 구현해야 한다.
    //마지막으로 값을 찾기 위한 비교 연산이 필요하므로, 요소는 Equatable를 구현해야 한다.
    mutating func rightAlign(value: Element) {
        var left = startIndex
        var right = index(before: endIndex)
        
        while left < right {
            while self[right] == value {
                formIndex(before: &right) //주어진 index를 -1 해서 바꾼다.
            }
            while self[left] != value {
                formIndex(after: &left) //주어진 index를 +1 해서 바꾼다.
            }
            guard left < right else {
                return
            }
            swapAt(left, right)
        }
    }
}
//이 알고리즘의 시간 복잡도는 O(n)이다.

var array = [3, 4, 134, 3, 5, 6, 3, 5, 6, 1, 0]

array.rightAlign(value: 3)
print(array) // [0, 4, 134, 1, 5, 6, 6, 5, 3, 3, 3]

//: [Next Challenge](@next)
