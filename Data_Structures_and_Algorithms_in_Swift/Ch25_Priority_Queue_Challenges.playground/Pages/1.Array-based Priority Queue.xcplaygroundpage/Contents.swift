
// Copyright (c) 2019 Razeware LLC
// For full license & permission details, see LICENSE.markdown.
/*:
 # Priority Queue Challenges
 ## 1. Array-based Priority Queue
 You know how to use a heap to construct a priority queue by conforming
 to the `Queue` protocol. Now construct a priority queue using an `Array`.
 */

public protocol Queue {
  associatedtype Element
  mutating func enqueue(_ element: Element) -> Bool
  mutating func dequeue() -> Element?
  var isEmpty: Bool { get }
  var peek: Element? { get }
}

//배열로 구현한 우선 순위 큐




//우선 순위 큐는 우선 순위에 따라 요소를 Queue에서 dequeue한다. 우선 순위에 따라 min 혹은 max priority queue 가 될 수 있다.
//Array 기반 우선 순위 큐를 구현하려면 Heap 대신 Array를 사용해Queue protocol을 구현하면 된다.
public struct PriorityQueueArray<T: Equatable>: Queue {
    private var elements: [T] = [] //heap 대신 array로 구현
    let sort: (Element, Element) -> Bool //정렬은 Queue 요소의 우선 순위를 결정한다.
    
    public init(sort: @escaping (Element, Element) -> Bool, elements: [Element] = []) {
        //initializer는 정렬 함수와 요소 배열을 사용한다.
        self.sort = sort
        self.elements = elements
        self.elements.sort(by: sort)
        //Apple의 sort 함수의 시간 복잡도는 O(n log n)이다.
        //Swift의 sort 함수는 insertion sort(삽입 정렬)과 heap sort(힙 정렬)을 조합한 introsort를 사용한다.
        //https://github.com/apple/swift/blob/master/stdlib/public/core/Sort.swift
    }
}
//추가적인 구현을 해 준다.
extension PriorityQueueArray {
    public var isEmpty: Bool { //Queue가 비어 있는지 확인한다.
        elements.isEmpty
    }
    
    public var peek: T? { //Queue의 첫 요소를 확인한다.
        elements.first
    }
}
//enqueue를 구현한다.
extension PriorityQueueArray {
    public mutating func enqueue(_ element: T) -> Bool {
        for (index, otherElement) in elements.enumerated() { //Queue의 모든 요소를 반복한다.
            if sort(element, otherElement) { //추가 하려는 요소의 우선 순위가 더 높은지 확인한다.
                elements.insert(element, at: index) //우선 순위가 더 높은 경우 현재 index에 삽입
                return true
            }
        }
        elements.append(element) //요소가 Queue의 요소보다 우선 순위가 높지 않으면 요소를 끝에 추가한다.
        return true
    }
}
//추가하는 새 요소의 우선 순위를 확인하기 위해 모든 요소를 거쳐야 하므로 O(n)의 시간 복잡도이다.
//또한 Array의 요소 사이에 insert 하는 경우, 요소를 오른쪽으로 하나씩 이동해야 한다.
//Heap처럼 트리 구조로 생각하지 않고 단순히 Array로 생각해야 한다.
//dequeue를 구현한다.
extension PriorityQueueArray {
    public mutating func dequeue() -> T? {
        isEmpty ? nil : elements.removeFirst()
    }
}
//Array의 요소를 제거하기 전에 Queue가 비어있는 지 확인해야 한다. dequeue 이후, 기존 요소를 왼쪽으로 하나씩 이동해야 하므로 O(n) 연산이다.
//마지막으로 우선 순위 큐 출력을 위해, CustomStringConvertible를 구현한다.
extension PriorityQueueArray: CustomStringConvertible {
    public var description: String {
        String(describing: elements)
    }
}

var priorityQueue = PriorityQueueArray(sort: >, elements: [1, 12, 3, 4, 1, 6, 8, 7])
priorityQueue.enqueue(5)
priorityQueue.enqueue(0)
priorityQueue.enqueue(10)
while !priorityQueue.isEmpty {
    print(priorityQueue.dequeue()!)
    // 12
    // 10
    // 8
    // 7
    // 6
    // 5
    // 4
    // 3
    // 1
    // 1
    // 0
}


//: [Next Challenge](@next)
