// Copyright (c) 2019 Razeware LLC
// For full license & permission details, see LICENSE.markdown.
/*:
 [Previous Challenge](@previous)
 
 ## 2. Step-by-Step Diagram
 
 See solutions chapter.
 
 ## 3. Combining Two Heaps

 Write a method that combines two heaps together.
 
 Following function added in **Heap.swift**.
 ```
 mutating public func merge(heap: Heap) {
   // Your solution here 
 }
 ```
 */
// 2. Step-by-Step Diagram :: p.245 다이어그램 참고



// 3. Combining Two Heaps
//    mutating public func merge(heap: Heap) {
//        elements = elements + heap.elements
//        buildHeap()
//    }
//Heap.swift에 추가
//두 개의 heap을 병합하는 것은 매우 간단하다. 먼저 두 Array를 결합한다. 이 작업의 시간 복잡도는 O(m)이다(m은 병합할 heap의 길이).
//그리고 병합된 Array로 Heap을 만드는데 O(n)이 걸린다. 전체적인 알고리즘의 시간복잡도는 O(n)이다.
    

  


let elements = [21, 10, 18, 5, 3, 100, 1]
let elements2 = [8, 6, 20, 15, 12, 11]
var heap = Heap(sort: <, elements: elements)
var heap2 = Heap(sort: <, elements: elements2)

heap.merge(heap: heap2)
print(heap)

//: [Next Challenge](@next)
