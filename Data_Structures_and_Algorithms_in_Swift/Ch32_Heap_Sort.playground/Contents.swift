//Chapter 32: Heap Sort

//힙 정렬은 Heap을 사용하여 오름차순으로 Array를 정렬하는 또 다른 비교 기반(comparison-based) 알고리즘이다.
//힙 정렬은 정의에 따라 다음과 같은 특징을 갖는 부분적으로 정렬된 이진 트리인 힙을 이용한다.
// 1. max heap에서 모든 부모 node는 자식보다 크다.
// 2. min heap에서 모든 부모 node는 자식보다 작다.
//p.304




//Getting started
//이전에 구현한 힙(Heap)﻿을 활용한다. 여기서는 최대 힙(max heap)을 사용해, 정렬에 사용할 수 있도록 힙(heap)을 확장(extension)한다.




//Example
//정렬되지 않은 Array의 경우, 오름차순으로 정렬하려면 먼저 이 Array를 최대 힙(max heap)으로 변환해야 한다. //p.305
//모든 상위 node가 올바른 위치에 오도록 이동해서 최대 힙을 만든다.
//단일 sift-down의 시간 복잡도는 O(log n)이므로, heap을 구축하는 총 시간 복잡도는 O(n log n)이다.
//이제 만들어진 Array를 오름차순으로 변경한다.
//max heap에서 가장 큰 요소(최대값)은 항상 root에 있기 때문에 index 0의 첫 요소를 index n-1의 마지막 요소와 교환하는 것으로 시작한다.
//swap의 결과로 Array의 마지막 요소는 올바른 곳에 위치하지만, heap이 성립하지 않게 된다.
//따라서, 새로운 root가 올바른 위치에 놓일 때까지 sift down한다.
//힙(heap)의 마지막 요소는 더 이상 힙(heap)의 요소가 아닌 정렬된 배열(Array)의 일부로 간주한다.
//sift down 결과 두 번째로 큰 요소가 새 root가 된다.
//이전 단계를 반복해서 정렬을 맞춰간다. 패턴은 매우 간단하다.
//첫 요소와 마지막 요소를 교환(swap)할 때, 더 큰 요소들이 올바른 순서가 되도록 배열(Array)의 뒤로 이동한다.
//힙(heap)의 크기가 1이 될 때까지, 교환(swap)과 shift를 반복하면 배열의 정렬이 완료된다.
//이런 정렬 과정은 선택 정렬(selection sort)과 매우 비슷하다.




//Implementation
//힙 정렬은 heap의 siftDown을 사용하므로, 실제 구현은 매우 간단하다.
extension Heap {
    func sorted() -> [Element] {
        var heap = Heap(sort: sort, elements: elements) //Heap의 사본을 만든다.
        //힙 정렬이 Array를 정렬한 후에는 더이상 유요하지 않다.
        //사본을 만들어 작업하면, 힙이 유요한 상태로 유지할 수 있다.
        
        for index in heap.elements.indices.reversed() { //마지막 요소부터 Array를 반복한다.
            heap.elements.swapAt(0, index) //첫 번째 요소와 마지막 요소를 swap한다.
            //정렬되지 않은 가장 큰 요소가 올바른 위치로 이동한다.
            heap.siftDown(from: 0, upTo: index) //heap이 유요하지 않으므로, 새 root node를 분류해야 한다.
            //이 결과, 다음으로 큰 요소가 새로운 root가 된다.
            //힙 정렬 구현을 위해, siftDown 메서드에 매개변수 upTo를 추가했다.
            //이런 식으로 siftDown은 loop가 반복될때 마다 줄어드는 배열의 정렬되지 않은 부분만을 사용한다.
        }
        
        return heap.elements
    }
}

let heap = Heap(sort: >, elements: [6, 12, 2, 26, 8, 18, 21, 9, 5])
print(heap.sorted()) // [2, 5, 6, 8, 9, 12, 18, 21, 26]




//Performance
//힙 정렬은 in-memory 정렬의 이점이 있지만, 시간 복잡도는 최상, 최악, 평균 모두 O(n log n) 이다.
//전체 목록을 순회하고, 요소를 교체할 때마다 O(log n) 연산인 sift down을 수행해야 하기 때문이다.
//힙 정렬은 어떻게 배치되어 힙에 저장되는가에 따라 달라지기 때문에 안정적이지 않다.
//ex. 카드의 덱을 순위별로 heap sort 하는 경우, 원본 덱(deck)의 순서가 변경될 수 있다.




//Key points
//힙 정렬(heap sort)은 최대 힙(max heap) 자료 구조(data structure)를 활용하여 배열(array)의 요소(element)를 정렬한다.
