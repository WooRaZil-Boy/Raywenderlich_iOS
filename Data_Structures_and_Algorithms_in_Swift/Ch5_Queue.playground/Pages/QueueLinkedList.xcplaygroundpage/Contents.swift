public class QueueLinkedList<T>: Queue {
    //Queue 프로토콜 구현 //Element 타입은 T로
    private var list = DoublyLinkedList<T>() //DoublyLinkedList 사용
    public init() {}
    
    public var isEmpty: Bool {
        return list.isEmpty
        //리스트가 비었는 지 확인. O(1)
    }
    
    public var peek: T? {
        return list.first?.value
        //리스트의 첫 요소 반환. O(1)
    }
    
    public func enqueue(_ element: T) -> Bool { //p.56
        list.append(element) //새 노드를 tail로 하고, 참조를 연결해 준다. //O(1)
        
        return true
    }
    
    public func dequeue() -> T? { //p.56
        guard !list.isEmpty, let element = list.first else {
            //리스트가 비어있지 않고, 첫 번째 요소가 있는 경우에만
            return nil
            //그렇지 않으면 nil 반환
        }
        
        return list.remove(element) //O(1)
        //리스트의 맨 앞 요소 삭제하고 반환
        //DoublyLinkedList로 큐를 구현하면, 요소를 하나씩 앞으로 당길 필요 없이
        //노드의 참조만 해제하면 되므로 dequeue도 O(1)이 된다.
    }
}




//MARK: - Debug and test
extension QueueLinkedList: CustomStringConvertible {
    //CustomStringConvertible을 구현해, String으로 변환하거나 print 함수 사용시 반환할 값을 지정해 준다.
    public var description: String {
        //description 변수를 설정하면 CustomStringConvertible이 구현된다.
        return list.description
    }
}

var queue = QueueLinkedList<String>()
queue.enqueue("Ray")
queue.enqueue("Brian")
queue.enqueue("Eric")
queue.dequeue()
queue
queue.peek //peek은 첫 번째 요소를 제거하지 않고 출력만 한다.




//Strengths and weaknesses //p.59

// Operations           Best case       Worst case
// enqueue(_:)          O(1)            O(1)
// dequeue(_:)          O(1)            O(1)
// Space Complexity     O(n)            O(n)

//리스트로 큐를 구현하면 배열과 달리, dequeue()에서 참조를 업데이트 하기만 하면 되므로 시간복잡도를 O(1)로 줄일 수 있다.
//하지만, 리스트로 구현한 큐는 각 요소의 이전과 다음 요소 참조를 위한 추가 적인 저장 공간이 필요해 높은 오버 헤드가 발생한다.
//또한 새 요소를 만들 때 마다 동적 할당을 해야 하므로 메모리가 낭비될 수 있다(정적 할당보다 비용이 크다).
//배열로 작성한 경우에는, 배열 공간을 늘릴 때 정적으로 대용량의 메모리를 확보하므로 리스트보다 빠르며 한 번씩만 수행하면 된다.
