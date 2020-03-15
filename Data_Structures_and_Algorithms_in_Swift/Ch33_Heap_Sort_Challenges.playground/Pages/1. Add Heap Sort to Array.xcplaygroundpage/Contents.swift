// Copyright (c) 2019 Razeware LLC
// For full license & permission details, see LICENSE.markdown.

/*:
 # Heap Sort Challenges
 ## 1. Add Heap Sort to `Array`

 Add a `heapSort()` method to Array. This method should sort the array
 in ascending order.
 
 */
//Array에 heapSort()메서드를 추가한다. 이 메서드는 array를 오름차순으로 정렬한다.




extension Array where Element: Comparable {
  //힙 정렬을 배열에 추가하려면, Array의 요소가 Comparable을 구현해야 한다.
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

//: [Next](@next)
