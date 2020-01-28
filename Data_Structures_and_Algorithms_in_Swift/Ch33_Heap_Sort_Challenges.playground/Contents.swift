// Copyright (c) 2019 Razeware LLC
// For full license & permission details, see LICENSE.markdown.

/*:
 # Heap Sort Challenges
 ## 1. Add Heap Sort to `Array`

 Add a `heapSort()` method to Array. This method should sort the array
 in ascending order.
 
 */
//Array를 extension 해서 오름차순 힙 정렬을 구현한다.




extension Array where Element: Comparable {
  //힙 정렬을 구현하려면, Array의 요소가 Comparable을 구현해야 한다.
  func leftChildIndex(ofParentAt index: Int) -> Int {
    (2 * index) + 1
  }
  
  func rightChildIndex(ofParentAt index: Int) -> Int {
    (2 * index) + 2
  }
  
  mutating func siftDown(from index: Int, upTo size: Int) {
    var parent = index
    while true {
      let left = leftChildIndex(ofParentAt: parent)
      let right = rightChildIndex(ofParentAt: parent)
      var candidate = parent
      
      if (left < size) && (self[left] > self[candidate]) {
        candidate = left
      }
      if (right < size) && (self[right] > self[candidate]) {
        candidate = right
      }
      if candidate == parent {
        return
      }
      swapAt(parent, candidate)
      parent = candidate
    }
  }
  
  mutating func heapSort() {
    // Build Heap
    if !isEmpty {
        for i in stride(from: count / 2 - 1, through: 0, by: -1) {
            siftDown(from: i, upTo: count)
        }
    }
    
    // Perform Heap Sort.
    for index in indices.reversed() {
        swapAt(0, index)
        siftDown(from: 0, upTo: index)
    }
  }
}

var array = [6, 12, 2, 26, 8, 18, 21, 9, 5]
array.heapSort()

/*:
 ## 2. Theory
 When performing a heap sort in ascending order, which of these starting
 arrays requires the fewest comparisons?
 - `[1,2,3,4,5]`
 - `[5,4,3,2,1]`
*/
//오름차순으로 힙 정렬을 구현할 때, 비교 횟수가 더 적은 Array는 무엇인가?




//힙 정렬을 사용하여 요소를 오름차순으로 정렬할 때, max heap을 사용한다. 따라서 살펴봐야 할 것은 max heap을 구성할 때 발생하는 비교 횟수이다.
//[5, 4, 3, 2, 1]은 이미 max heap이고, swap이 없기 때문에 비교 횟수가 가장 적다.
//max heap을 만들 때 parent node만을 확인한다. 따라서, [5, 4, 3, 2, 1]는 두 개의 parent node가 있으며 2번의 비교가 있다. //p.313
//반면, [1, 2, 3, 4, 5]는 비교 횟수가 가장 많다. 두 개의 parent node가 있지만, 3번의 비교를 해야 한다. //p.313




/*:
 ## 3. Descending Order
 The chapter implementation of heap sort, sorts the elements in ascending order.
 How would you sort in descending order?
 */
//지금까지 오름차순(ascending order)로 힙 정렬을 구현했다. 내림차순(descending order)으로도 heap sort를 구현할 수 있다.




//정렬 하시 전에 max heap 대신 min heap을 사용하면, 내림차순 힙 정렬을 구현할 수 있다.
//let heap = Heap(sort: <, elements: [6, 12, 2, 26, 8, 18, 21, 9, 5])
//print(heap.sorted())
