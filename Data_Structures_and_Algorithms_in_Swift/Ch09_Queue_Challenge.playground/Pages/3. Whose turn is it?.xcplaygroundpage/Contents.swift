// Copyright (c) 2019 Razeware LLC
// For full license & permission details, see LICENSE.markdown.
/*:
 # Queue Data Structure Challenges
 
 ## 3. Whose turn is it?
 
 Imagine that you are playing a game of Monopoly with your friends. The problem
 is that everyone always forget whose turn it is! Create a Monopoly organizer
 that always tells you whose turn it is. Below is a protocol that you can
 conform to:
 */
//친구들과 Monopoly 게임을 하고 있다. 자신의 차례(turn)를 알려주는 organizer를 만든다. 준수해야할 프로토콜(protocol)은 다음과 같다.
public protocol BoardGameManager {
    associatedtype Player
    mutating func nextPlayer() -> Player?
}




extension QueueArray: BoardGameManager { //Queue가 BoardGameManager를 구현하기 적합하다.
    public typealias Player = T //typealias의 매개변수를 T로 설정한다.
    
    public mutating func nextPlayer() -> T? {
        guard let person = dequeue() else { //dequeue로 다음 Player를 가져온다.
            return nil //Queue가 비어 있다면 nil을 반환한다.
        }
        enqueue(person) //dequeue한 Player를 Queue에 넣는다. 순서대로 진행되면 다시 차례가 오게 된다.
        
        return person //nextPlayer 반환
    }
}
//시간 복잡도는 선택한 Queue의 구현에 따라 달라진다. Array기반 Queue의 경우에는 전체 시간복잡도가 O(n) 이다.
//dequeue 시, 첫 번째 요소를 제거하면서 다음 요소들을 모두 하나씩 이동시켜야 하므로 O(n)이 된다.

var queue = QueueArray<String>()
queue.enqueue("Vincent")
queue.enqueue("Remel")
queue.enqueue("Lukiih")
queue.enqueue("Allison")
print(queue)

print("===== boardgame =======")
queue.nextPlayer()
print(queue)
queue.nextPlayer()
print(queue)
queue.nextPlayer()
print(queue)
queue.nextPlayer()
print(queue)

//: [Next Challenge](@next)
