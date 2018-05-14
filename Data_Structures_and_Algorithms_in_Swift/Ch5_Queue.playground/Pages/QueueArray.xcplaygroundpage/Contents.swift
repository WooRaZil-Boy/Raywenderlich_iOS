// Copyright (c) 2018 Razeware LLC
// For full license & permission details, see LICENSE.markdown.

public struct QueueArray<T>: Queue {
    //Queue 프로토콜 구현 //Element 타입은 T로
    private var array: [T] = [] //배열 사용
    public init() {}
    
    public var isEmpty: Bool {
        return array.isEmpty
        //배열이 비었는 지 확인. O(1)
    }
    
    public var peek: T? {
        return array.first
        //배열의 첫 요소 반환. O(1)
    }
    
    public mutating func enqueue(_ element: T) -> Bool {
        array.append(element) //배열의 뒤에 추가해 주기만 하면 된다. O(1)
        //배열의 뒤에 빈 공간이 있기 때문 크기에 관계없이 요소를 큐에 넣는 것은 O(1)이 된다.
        //하지만 할당된 배열의 빈 공간이 가득 찼을 때 append할 경우 추가 공간을 만들기 위해 배열 크기를 조정해야 한다.
        //여기서 크기를 조정하는 작업은 새 메모리 할당하고 기존 데이터를 복사해야 하므로 O(n)이 추가된다.
        //하지만 이 경우는 자주 발생하지 않기 때문에 O(1)으로 한다.
        
        return true
    }
    
    public mutating func dequeue() -> T? {
        return isEmpty ? nil: array.removeFirst()
        //배열이 빈 경우 nil, 아닌 경우는 첫 번째 요소를 삭제하고 반환한다. O(n)
        //배열의 가장 첫 요소를 제거한 후, 나머지 모든 요소가 메모리에서 하나씩 앞으로 이동해야 하기 때문에 O(n)이 된다.
    }
}

//Array로 구현한 Queue의 구조는 p.52




//MARK: - Debug and test
extension QueueArray: CustomStringConvertible {
    //CustomStringConvertible을 구현해, String으로 변환하거나 print 함수 사용시 반환할 값을 지정해 준다.
    public var description: String {
        //description 변수를 설정하면 CustomStringConvertible이 구현된다.
        return array.description
        //.description는 배열과 그 요소를 텍스트로 변환해준다.
    }
}

var queue = QueueArray<String>()
queue.enqueue("Ray")
queue.enqueue("Brian")
queue.enqueue("Eric")
queue.dequeue()

queue
queue.peek //peek은 첫 번째 요소를 제거하지 않고 출력만 한다.




//Strengths and weaknesses //p.55

// Operations           Best case       Worst case
// enqueue(_:)          O(1)            O(1)
// dequeue(_:)          O(1)            O(n)
// Space Complexity     O(n)            O(n)

//배열로 큐를 구현할 경우 구현이 쉽고 빠르지만, dequeue(모든 요소를 하나씩 앞으로 당겨야 한다.)와
//배열의 공간 확장(배열이 꽉 찬 경우, 새로 만들어야 하고 메모리 사용량이 최적화되지 않는다)에서 단점이 있다.

