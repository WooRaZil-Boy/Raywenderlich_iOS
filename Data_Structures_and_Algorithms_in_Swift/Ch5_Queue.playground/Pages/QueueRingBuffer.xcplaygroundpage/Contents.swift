// Copyright (c) 2018 Razeware LLC
// For full license & permission details, see LICENSE.markdown.

public struct QueueRingBuffer<T>: Queue {
    //Queue 프로토콜 구현 //Element 타입은 T로
    private var ringBuffer: RingBuffer<T> //RingBuffer 사용
    
    public init(count: Int) {
        ringBuffer = RingBuffer<T>(count: count)
        //RingBuffer의 count(링 버퍼의 크기)를 지정해 줘야 한다.
    }
    
    public var isEmpty: Bool {
        return ringBuffer.isEmpty
        //버퍼가 비었는 지 확인. O(1)
    }
    public var peek: T? {
        return ringBuffer.first
        //버퍼의 첫 요소 반환. O(1)
    }
    
    public mutating func enqueue(_ element: T) -> Bool {
        return ringBuffer.write(element)
        //write 포인터를 한 칸 뒤로 이동 시킨다. //O(1)
    }
    
    public mutating func dequeue() -> T? {
        return isEmpty ? nil: ringBuffer.read()
        //비어 있는 경우 nil, 그렇지 않으면 버퍼 가장 앞의 항목 반환 //read 포인터를 한 칸 뒤로 이동시킨다.
    }
}

//링 버퍼는 순환 버퍼라고도 한다. 고정된 크기를 배열을 사용하며, 끝에 제거할 항목이 더 이상 없을 때, 처음부터 다시 접근한다. p.59
//링 버퍼에는 read와 write 두개의 참조가 있다.
//read 포인터는 큐의 앞을 가리킨다. dequeue할 때마다 read 포인터가 가리키는 객체는 하나씩 뒤로 이동한다(삭제하지 않고 포인터만 뒤로 이동).
//write 포인터는 다음 사용 가능한 슬롯을 가리킨다. enqueue할 때마다 write 포인터가 가리키는 객체는 하나씩 뒤로 이동한다.
//write 포인터가 버퍼의 끝에 도달한 상태에서 enqueue를 한다면, write 포인터는 버퍼의 가장 앞으로 이동하게 된다(링, 순환).
//read 포인터와 write 포인터가 같은 위치에 있으면, 큐가 비어 있는 것이다.
//https://github.com/raywenderlich/swift-algorithm-club/tree/master/Ring%20Buffer




//MARK - Debug and test
extension QueueRingBuffer: CustomStringConvertible {
    //CustomStringConvertible을 구현해, String으로 변환하거나 print 함수 사용시 반환할 값을 지정해 준다.
    public var description: String {
        //description 변수를 설정하면 CustomStringConvertible이 구현된다.
        return ringBuffer.description
    }
}

var queue = QueueRingBuffer<String>(count: 10)
queue.enqueue("Ray")
queue.enqueue("Brian")
queue.enqueue("Eric")
queue
queue.dequeue()
queue
queue.peek //peek은 첫 번째 요소를 제거하지 않고 출력만 한다.




//Strengths and weaknesses //p.63
// Operations           Best case       Worst case
// enqueue(_:)          O(1)            O(1)
// dequeue(_:)          O(1)            O(1)
// Space Complexity     O(n)            O(n)

//링 버퍼로 큐를 구현하면, LinkedList로 구현한 큐와 같은 시간 복잡도를 가진다.
//차이점은 공간의 복잡성이다. 링 버퍼의 크기는 고정되어 있어 큐에 오류가 발생할 수 있다.
