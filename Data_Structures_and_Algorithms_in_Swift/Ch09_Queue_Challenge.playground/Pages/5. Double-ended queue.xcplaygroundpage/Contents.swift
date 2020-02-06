// Copyright (c) 2019 Razeware LLC
// For full license & permission details, see LICENSE.markdown.
//: [Previous](@previous)
/*:
 ## 5. Double-ended queue
 
 A doubled-ended queue — a.k.a. a **deque** — is, as its name suggests, a queue where elements
 can be added or removed from the `front` or `back`.
 
 ### Recall:
 - A queue **(FIFO order)** allows you to add elements to the back and remove from the front.
 - A stack **(LIFO order)** allows you to add elements to the back, and remove from the back.
 
 Deque can be considered both a queue and a stack at the same time.
 
 A simple `Deque` protocol has been provided to help you build your data structure. An enum `Direction` has been provided to help describe whether you are adding or removing an element from the front or back of the deque. You can use any data structure you prefer to construct a `Deque`.
 
 > Note: In **DoubleLinkedList.swift** one additional property and function has been added:
 > 1. A property called `last` has been added to help get the tail element of a double-linked list.
 > 2. A function called `prepend(_:)` has been added to help you add an element to the front of a double-linked list.
 
 */
//Double-ended Queue는 요소를 앞, 뒤로 추가하거나 제거할 수 있는 Queue이다.
// • Queue(FIFO)를 사용해, 후면에서 요소를 추가하고, 전면에서 제거할 수 있다.
// • Stack(LIFO)를 사용해, 후면에서 요소를 추가하고, 후면에서 제거할 수 있다.
//Deque는 Stack과 Queue에서 동시에 고려할 수 있다.
//자료 구조 구축에 도움이 되는 Dequeue 프로토콜(protocol)이 제공된다.
//또, deque가 앞 또는 뒤에서 요소를 추가하는지 제거하는지 여부를 설명하기 위한 Direction 열거형(enum)이 제공된다.

//DoubleLinkedList에는 속성과 함수가 하나씩 추가 되었다.
// 1. double-linked list에서 tail 요소를 얻기 위해 last 속성이 추가 되었다.
// 2. double-linked list의 전면에 요소를 추가하기 위해 prepend(_:)함수가 추가 되었다.

enum Direction { //전면, 후면에서 요소를 추가, 제거 여부를 표현하기 위한 열거형
    case front
    case back
}

protocol Deque { //Deque protocol
    associatedtype Element
    var isEmpty: Bool { get }
    func peek(from direction: Direction) -> Element?
    mutating func enqueue(_ element: Element, to direction: Direction) -> Bool
    mutating func dequeue(from direction: Direction) -> Element?
}
//Deque에는 Queue와 Stack의 일반적인 연산들이 정의되어 있다.
//이를 구현하는 방법은 여러가지 있지만, 여기서는 doubly linked-list 를 사용한다.




class DequeDoubleLinkedList<Element>: Deque { //doubly linked-list로 구현
    private var list = DoublyLinkedList<Element>()
    public init() {}
}

extension DequeDoubleLinkedList {
    var isEmpty: Bool {
        list.isEmpty
    }
}
//LinkedList가 비어 있는 지 확인한다. O(1) 연산이다.

extension DequeDoubleLinkedList {
    func peek(from direction: Direction) -> Element? { //Deque의 양 방향에서 peek할 수 있어야 한다.
        switch direction {
        case .front:
            return list.first?.value
        case .back:
            return list.last?.value
        }
    }
}
//first와 last의 값을 확인하면 된다. 이는 head와 tail만 확인하면 되므로 O(1) 연산이다.

extension DequeDoubleLinkedList {
    func enqueue(_ element: Element, to direction: Direction) -> Bool { //Deque의 양 방향에서 enqueue할 수 있어야 한다.
        switch direction {
        case .front:
            list.prepend(element) //head
        case .back:
            list.append(element) //tail
        }
        
        return true
    }
}
// 1. Front : list의 전면에 요소를 추가한다. LinkedList는 새 node를 head로 업데이트 한다.
// 2. Back : list의 후면에 요소를 추가한다. LinkedList는 새 node를 tail로 업데이트 한다.
//head, tail 포인터를 업데이트 하기만 하면 되므로 O(1) 작업이다.

extension DequeDoubleLinkedList {
    func dequeue(from direction: Direction) -> Element? {
        let element: Element?
        switch direction {
        case .front:
            guard let first = list.first else { return nil } //head
            element = list.remove(first)
        case .back:
            guard let last = list.last else { return nil } //tail
            element = list.remove(last)
        }
        
        return element
    }
}
//dequeue 작업은 간단하다. head와 tail에 대한 참조가 있으므로, 해당 노드의 previous 와 next 참조를 해제하면 된다.
// 1. Front : list에서 head node를 가져와 제거한다.
// 2. Back : list에서 tail node를 가져와 제거한다.
//dequeue는 O(1) 작업이다.

extension DequeDoubleLinkedList: CustomStringConvertible {
    public var description: String {
        String(describing: list)
    }
}
//디버깅을 위해 CustomStringConvertible를 구현한다.




let deque = DequeDoubleLinkedList<Int>()
deque.enqueue(1, to: .back)
deque.enqueue(2, to: .back)
deque.enqueue(3, to: .back)
deque.enqueue(4, to: .back)

print(deque)

deque.enqueue(5, to: .front)

print(deque)

deque.dequeue(from: .back)
deque.dequeue(from: .back)
deque.dequeue(from: .back)
deque.dequeue(from: .front)
deque.dequeue(from: .front)
deque.dequeue(from: .front)

print(deque)
//: [Next](@next)
