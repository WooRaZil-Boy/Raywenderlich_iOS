// Copyright (c) 2018 Razeware LLC
// For full license & permission details, see LICENSE.markdown.

public protocol Queue {
    //다양한 자료구조로 큐를 만들수 있기 때문에 프로토콜로 큐의 기본적인 메서드와 요소를 정의한다.
    associatedtype Element
    
    mutating func enqueue(_ element: Element) -> Bool
    //큐의 맨 뒤에 요소를 삽입한다. 성공하면 true를 반환한다.
    mutating func dequeue() -> Element?
    //큐의 맨 앞의 요소를 제거하고, 이를 반환한다.
    
    var isEmpty: Bool { get }
    //큐가 비어있는지 확인
    var peek: Element? { get }
    //요소를 제거하지 않고 큐의 가장 앞 요소를 반환한다.
}

//Queue는 대기열이라 생각하면 쉽다.
//Queue는 FIFO(first-in-first-out)이다. 큐에 들어간 첫 요소가 가장 먼저 나온다.
//Queuesms 순서대로 작업을 처리해야 할 때 유용하게 사용할 수 있다.

//큐는 맨 앞 요소의 제거(dequeue)와 맨 뒤에 요소 삽입(enqueue)에만 관심이 있다.
//그 중간의 요소들이 무엇인지는 알 필요가 없다. 중간 요소들을 알아야 한다면 배열을 사용해야 한다.
