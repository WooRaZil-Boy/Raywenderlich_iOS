// Copyright (c) 2019 Razeware LLC
// For full license & permission details, see LICENSE.markdown.
/*:
 [Previous Challenge](@previous)
 ## Challenge 5: Remove all occurrences of a specific element

 Create a function that removes all occurrences of a specific element from a linked list. The implementation is similar to the `remove(at:)` method that you implemented for the linked list.
 */
//연결 리스트(Linked List)에서 특정 요소를 모두 제거하는 함수를 작성한다. 이 구현은 연결 리스트의 remove(at:) 메서드와 유사하다.




//list를 순회하여 제거하려는 요소와 일치하는 모든 node를 제거한다.
//제거 할 때마다, 선행 node와 후속 node를 다시 연결해야 해야 하므로 복잡해질 수 있다.
//하지만, 많은 자료구조(Data Struct)와 알고리즘(Algorithm)은 포인터 연산을 다루는 경우가 많으므로, 충분한 연습이 필요하다.

extension LinkedList where Value: Equatable {
    mutating func removeAll(_ value: Value) {
        //고려해 봐야할 몇 가지 경우가 있다.
        
        //list의 앞에서 node를 제거하는 경우(Trimming the head) p.90
        //list의 head에 제거하려는 value가 포함된 경우이다.
        while let head = head, head.value == value {
            //같은 value를 가진 node가 head부터 여러 개 연달아 있을 수 있으므로, loop를 사용해 모두 제거한다.
            self.head = head.next
        }
        
        //중복되는 node를 찾아 연결을 해제한다.
        var prev = head
        var current = head?.next
        //두 개의 포인터로 목록을 순회한다.
        while let currentNode = current {
            if currentNode.next == nil {
                tail
            }
            
            guard currentNode.value != value else { //node를 제거해야하는 경우 guard 블록이 실행된다.
                prev?.next = currentNode.next
                current = prev?.next
                //제거한 node를 우회하도록 list의 참조를 수정한다.
                
                continue
            }
            
            //p.91 //이렇게만 구현하면, while 구문이 무한 loop가 될 수 있다.
            //prev와 current 참조를 이동해야 한다.
            prev = current
            current = current?.next
        }
        
        tail = prev //마지막으로, tail을 업데이트 한다. tail의 value가 제거하려는 value인 경우 필요하다.
    }
}




example(of: "deleting duplicate nodes") {
    var list = LinkedList<Int>()
    list.push(3)
    list.push(2)
    list.push(2)
    list.push(1)
    list.push(1)
    
    list.removeAll(3)
    print(list) // 1 -> 1 -> 2 -> 2
}
//이 알고리즘은 모든 요소를 순회하므로 시간복잡도는 O(n)이다.
//정렬된 LinkedList에서만 가능한 듯.
