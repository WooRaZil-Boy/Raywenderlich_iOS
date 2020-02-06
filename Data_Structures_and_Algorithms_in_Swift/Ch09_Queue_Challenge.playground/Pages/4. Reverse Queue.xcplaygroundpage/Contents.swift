// Copyright (c) 2018 Razeware LLC
// For full license & permission details, see LICENSE.markdown.
//: [Previous Challenge](@previous)
/*:
 ## 4. Reverse Queue
 
 Implement a method to reverse the contents of a queue.
 
 > Hint: The `Stack` data structure has been included in the **Sources** folder.
 */
//큐(Queue)를 반전(reverse)시키는 메서드를 구현한다.




//Queue는 FIFO(first-in-first-out) 이지만, Stack은 LIFO(last-in-first-out)이다.
//Stack을 사용하여 Queue를 reverse 할 수 있다.
//Queue의 모든 요소를 Stack에 삽입하고, 다시 Stack의 모든 요소를 pop하면 reverse가 구현된다.
extension QueueArray {
    func reversed() -> QueueArray {
        var queue = self //Queue를 복사한다.
        var stack = Stack<T>() //Stack을 생성한다.
        
        while let element = queue.dequeue() { //Queue의 모든 요소를 dequeue 해, Stack에 push 한다.
            stack.push(element)
        }
        
        while let element = stack.pop() { //Stack의 모든 요소를 pop 해, Queue에 enqueue 한다.
            queue.enqueue(element)
        }
        
        return queue //reverse 된 Queue를 반환한다.
    }
}
//전체적인 시간복잡도(time complexity)는 O(n) 이다. Queue에서 요소를 제거할 때, Stack에서 요소를 제거할 때, 총 2 번 looop를 사용한다.
//Queue를 어떤 방법으로 구현했는지는 중요하지 않다(Array로 구현하든, LinkedList로 구현하든 등). Queue의 특성으로 일반화할 수 있다.

var queue = QueueArray<String>()
queue.enqueue("1")
queue.enqueue("21")
queue.enqueue("18")
queue.enqueue("42")

print("before: \(queue)")
print("after: \(queue.reversed())")

//: [Next Challenge](@next)
