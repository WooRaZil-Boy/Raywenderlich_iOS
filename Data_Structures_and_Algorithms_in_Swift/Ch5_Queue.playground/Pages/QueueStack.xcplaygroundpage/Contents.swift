// Copyright (c) 2018 Razeware LLC
// For full license & permission details, see LICENSE.markdown.

public struct QueueStack<T> : Queue {
    //Queue 프로토콜 구현 //Element 타입은 T로
    private var leftStack: [T] = [] //dequeue할 경우, 오른쪽 스택을 뒤집어 왼쪽 스택에 저장(FIFO가 된다).
    //FIFO(First In Frist Out)
    private var rightStack: [T] = [] //enqueue할 때마다 오른쪽 스택에 저장
    //LIFO(Last In Frist Out)
    
    //두 개의 Stack(배열)을 사용한다. p.64
    
    public init() {}
    
    public var isEmpty: Bool {
        return leftStack.isEmpty && rightStack.isEmpty
        //양쪽 스택이 모두 비었는 지 확인. 큐에서 dequeue할 요소도, enqueue할 요소도 없는 상태. O(1)
    }
    
    public var peek: T? {
        return !leftStack.isEmpty ? leftStack.last : rightStack.first
        //첫 요소 반환. 왼쪽 스택이 비어 있지 않으면, 왼쪽 스택의 가장 윗 요소가 큐의 맨 앞 요소가 된다.
        //왼쪽 스택이 비어 있다면, 오른쪽 스택의 첫 요소가 큐의 맨 앞 요소가 된다.
        //(오른쪽 스택이 뒤집혀 왼쪽 스택으로 오게 되므로) O(1)
    }
    
    public mutating func enqueue(_ element: T) -> Bool {
        //오른쪽 스택은 요소를 큐에 넣는데에 사용된다. p.65 //O(1)
        rightStack.append(element)
        
        return true
    }
    
    public mutating func dequeue() -> T? { //p.65 //O(1)
        if leftStack.isEmpty { //왼쪽 스택이 비어 있다면
            leftStack = rightStack.reversed() //오른쪽 스택을 뒤집은 것이 왼쪽 스택이 된다.
            rightStack.removeAll() //그 후, 오른쪽 스택을 비운다(전부 왼쪽 스택으로 옮겼으니 상관없다).
        }
        //배열을 뒤집는 것은 O(n)의 작업이지만 전체적인 dequeue은 O(1). 왼쪽 스택이 비어 있는 경우가 그리 많이 일어나지 않는다.
        
        return leftStack.popLast() //왼쪽 스택에서 마지막 요소를 pop 한다.
    }
}




//MARK - Debug and test
extension QueueStack: CustomStringConvertible {
    //CustomStringConvertible을 구현해, String으로 변환하거나 print 함수 사용시 반환할 값을 지정해 준다
    public var description: String {
        //description 변수를 설정하면 CustomStringConvertible이 구현된다.
        let printList = leftStack + rightStack.reversed()
        //왼쪽 스택을 오른쪽 스택의 반대편에 결합하고 모든 요소를 출력한다.
        
        return printList.description
    }
}

var queue = QueueStack<String>()
queue.enqueue("Ray")
queue.enqueue("Brian")
queue.enqueue("Eric")
queue.dequeue()
queue
queue.peek




//Strengths and weaknesses //p.67
// Operations           Best case       Worst case
// enqueue(_:)          O(1)            O(1)
// dequeue(_:)          O(1)            O(1)
// Space Complexity     O(n)            O(n)

//두 스택의 구현은 동적이며, 링 버퍼 기반 큐처럼 크기 제한도 없다.
//배열은 각 슬롯이 메모리에서 서로 옆에 위치하기 때문에 LinkedList보다 효율이 좋다.
//LinkedList에서는 다음 요소에 접근하는데 메모리 주소를 찾아야 하므로 캐싱 미스가 생기고 액세스 시간이 길어질 수 있다.
