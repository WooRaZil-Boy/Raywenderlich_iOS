//Chapter 24: Priority Queue

//Queue는 FIFO(first-in-first-out)로 요소의 순서를 유지하는 단순한 list이다.
//우선 순위 큐(Priority Queue)는 FIFO 순서를 사용하는 대신, 요소를 우선 순위 순서대로 삭제하는 Queue의 또 다른 버전이다.
//우선 순위 큐의 종류는 다음과 같다.
// 1. Max-priority : 항상 front의 요소가 가장 크다.
// 2. Min-priority : 항상 front의 요소가 가장 작다.
//우선 순위 큐(Priority Queue)는 주어진 요소(element)의 리스트(list)에서 최대값 또는 최소값을 찾아야 할때 특히 유용하다.




//Applications
//우선 순위 큐를 응용하는 프로그램은 다음과 같다.
// • Dijkstra’s algorithm : 우선 순위 큐를 사용해 최소 비용을 계산한다.
// • A* pathfinding algorithm : 우선 순위 큐를 사용해 탐색되지 않은 경로를 추적하는 최단 경로를 생성한다.
// • Heap sort : 우선 순위 큐를 사용해 힙 정렬을 구현한다.
// • Huffman coding : 압축 트리(compression tree)를 구성한다.
//   우선 순위 큐는 상위 node가 없는 가장 frequency가 작은 두 개의 node를 반복적으로 찾는데 사용된다.




//Common operations
//Priority Queue는 일반 Queue와 동일한 연산자(Operation)를 가지고 있고, 구현만 달라진다.
//기본적으로 Queue protocol을 준수해, 일반 큐(Queue) 연산을 구현한다.
// • enqueue : 요소를 Queue에 삽입한다. 성공하면 true를 반환한다.
// • dequeue : 우선 순위가 가장 높은 요소를 제거하고 반환한다. Queue가 비어 있으면 nil을 반환한다.
// • isEmpty : Queue가 비었는지 확인한다.
// • peek : 우선 순위가 가장 높은 요소를 제거하지 않고, 반환한다. Queue가 비어 있으면 nil을 반환한다.




//Implementation
//우선 순위 큐는 다음과 같은 자료구조를 사용해 만들 수 있다.
// 1. Sorted array (정렬된 배열) : 요소의 최대값 또는 최소값을 얻는 데 O(1)이 걸려 유용하다.
//  그러나 insert 연산은 속도가 느리고, 순서대로 insert 해야 하므로 O(n)이 필요하다.
// 2. Balanced binary search tree (균형잡힌 이진 탐색 트리) : O(lon n)으로 최소값과 최대값을 모두 얻는
//  double-ended priority queue를 유용하게 사용할 수 있다. insert 또한 O(log n)으로 Sorted array 보다 낫다.
// 3. Heap (힙) : 우선 순위 큐를 구현하는 데 가장 보편적으로 사용한다. heap은 부분적으로만 정렬하면 되므로 Sorted array보다 더 효율적이다.
//  최대 우선 순위 값을 구하는 것(최소 우선 순위 큐에서 최소값, 최대 우선 순위 큐에서 최대값)을 제외한 모든 heap의 연산은 O(log n)이다.
//  min priority heap에서 최소값을 구하는 것과 max priority heap애소 최대값을 구하는 것은 O(1) 연산이다.
struct PriorityQueue<Element: Equatable>: Queue {
    //Queue 프로토콜을 구현한다. 요소(Element)는 비교할 수 있어야 하므로, Equatable를 구현해야 한다.
    private var heap: Heap<Element> //heap을 사용하여 우선 순위 큐를 구현한다.
    
    init(sort: @escaping (Element, Element) -> Bool, elements: [Element] = []) {
        //initializer는 적절한 정렬 함수를 전달 받는다.
        //이를 PriorityQueue에 사용하여 최소 우선 순위 대기열 및 최대 우선 순위 대기열을 모두 생성할 수 있다.
        heap = Heap(sort: sort, elements: elements)
    }
}
//간단한 기본 연산들을 추가 한다.
extension PriorityQueue {
    var isEmpty: Bool {
        heap.isEmpty
    }
    
    var peek: Element? {
        heap.peek()
    }
    
    mutating func enqueue(_ element: Element) -> Bool {
        heap.insert(element) //enqueue(_:)를 호출하여 heap에 insert 하면, heap은 자체적으로 sift up 한다(22장 참고).
        return true
        //enqueue(_:)의 전반적인 시간 복잡도는 O(log n)이다.
    }
    
    mutating func dequeue() -> Element? {
        heap.remove() //dequeue()를 호출하여 heap의 root 요소를 마지막 요소로 swap해 제거하면, heap은 자체적으로 sift down 한다.
        //dequeue()의 전반적인 시간 복잡도는 O(log n)이다.
    }
}
//heap으로 PriorityQueue를 구현한다. 우선 순위 큐의 작업을 구현하려면, heap의 다양한 메서드를 호출하기만 하면 된다.




//Testing
var priorityQueue = PriorityQueue(sort: >, elements: [1, 12, 3, 4, 1, 6, 8, 7]) //max priority queue
while !priorityQueue.isEmpty {
    print(priorityQueue.dequeue()!)
    // 12
    // 8
    // 7
    // 6
    // 4
    // 3
    // 1
    // 1
}
//우선 순위 큐는 일반 큐와 interface가 동일하다.
//max priority queue에서는 가장 큰 항목부터 dequeue 된다.




//Key points
// • 우선 순위 큐(Priority Queue)는 우선 순위 순서대로 요소(element)를 찾기 위해 사용한다.
// • 큐(Queue)의 기본 구현에 초점을 맞추고 힙(Heap)의 추가적인 기능을 제거해,
//  우선 순위 큐(Priority Queue)의 추상화(abstraction) 계층(layer)을 만든다.
// • 추상화(abstraction)는 우선 순위 큐(Priority Queue)의 의도를 명확하고 간결하게 한다.
//  우선 순위 큐(Priority Queue)는 enqueue와 dequeue만 구현하면 된다.
