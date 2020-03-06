// Copyright (c) 2019 Razeware LLC
// For full license & permission details, see LICENSE.markdown.
/*:
 # Heap Data Structure Challenges
 ## 1. Find the nth Smallest Integer
 Write a function to find the `nth` smallest integer in an unsorted array. For example:
 ```
  let integers = [3, 10, 18, 5, 21, 100]
  n = 3
 ```
 If  `n = 3`, the result should be `10`.
 */
//정렬되지 않은 Array에서 n 번째로 작은 요소 구하기. 위의 예에서는 n이 3이면, 결과는 10이어야 한다.




//정렬되지 않은 Array에서 n 번째로 작은 정수를 구하는 방법은 여러 가지가 있다.
//ex. 정렬 알고리즘으로 Array를 정렬한 다음 n 번째 index를 가져온다.
//최소 힙을 사용하여 n 번째 작은 요소를 구하는 방법은 다음과 같다.
func getNthSmallestElement(n: Int, elements: [Int]) -> Int? {    
    var heap = Heap(sort: <, elements: elements) //정렬 되지 않은 Array로 최소 힙을 초기화 한다.
    var current = 1 //n번째로 작은 요소를 tracking
    
    while !heap.isEmpty { //heap이 비어 있지 않으면 loop
        let element = heap.remove() //root 요소를 제거한다.
        
        if current == n { //n번째로 작은 요소에 도달했는지 확인한다.
            return element //요소 반환
        }
        
        current += 1 //n번째 요소에 아직 도달하지 않았으면 current 증가
    }
    
    return nil //heap이 빌때 까지 해당 요소를 찾지 못했으면 nil 반환
}
//heap을 구축하는 데 O(n)이 필요하다. heap에서 요소를 제거할 때마다 O(log n)이 필요하다.
//이를 n 번 반복해서 요소를 찾아야 하므로, 전체 시간 복잡도는 O(n log n)이다.




let elements = [3, 10, 18, 5, 21, 100]
let nthElement = getNthSmallestElement(n: 3, elements: elements)


//: [Next Challenge](@next)
