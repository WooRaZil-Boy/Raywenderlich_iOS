// Copyright (c) 2019 Razeware LLC
// For full license & permission details, see LICENSE.markdown.
/*:
 [Previous Challenge](@previous)
 ## 4. A Min Heap?
 Write a function to check if a given array is a min heap.
 */
//최소 힙인지 확인

func leftChildIndex(ofParentAt index: Int) -> Int {
  (2 * index) + 1
}

func rightChildIndex(ofParentAt index: Int) -> Int {
  (2 * index) + 2
}




func isMinHeap<Element: Comparable> (elements: [Element]) -> Bool {
    //주어진 Array가 최소 힙인지 확인하려면 binary heap의 모든 상위 node만 확인하면 된다.
    //최소 힙을 충족시키려면 모든 상위 node가 왼쪽 및 오른쪽 하위 node보다 작거나 같아야 한다.
    guard !elements.isEmpty else { //Array가 비어 있다면, 최소 힙이다.
        return true
    }
    
    for i in  stride(from: elements.count / 2 - 1, through: 0, by: -1) {
        //stride(from:to:by:) 는 to: 뒤의 경계를 포함하지 않는다.
        //stride(from:through:by:) 는 through: 뒤의 경계까지 포함한다.
        //Array의 모든 부모 node를 역순으로 진행한다. 최소 힙인지 확인하는 것이므로 요소의 절반(상위 node)만 반복한다(leaf node 제외).
        let left = leftChildIndex(ofParentAt: i) //왼쪽 child의 index를 가져온다.
        let right = rightChildIndex(ofParentAt: i) //오른쪽 child의 index를 가져온다.
        
        if elements[left] < elements[i] { //왼쪽 child의 요소가 부모보다 작은지 확인한다.
            return false //작다면, 최소 힙 조건에 위배된다.
        }
        
        if right < elements.count && elements[right] < elements[i] {
            //오른쪽 child 요소가 Array의 범위 내에 있고, 부모보다 작은지 확인한다.
            return false //작다면, 최소 힙 조건에 위배된다.
        }
    }
  
    return true //모든 parent-child 관계가 최소 힙 조건을 만족하면 true를 반환한다.
}
//시간복잡도는 O(n)이다. Arrray의 모든 요소를 거쳐야 하기 때문이다.




let elements = [1, 3, 12, 5, 10, 18, 21, 6, 8, 11, 15, 100, 20]
isMinHeap(elements: elements)

