public class Node<Value> {
    public var value: Value //값
    public var next: Node? //다음 노드 참조
    
    public init(value: Value, next: Node? = nil) {
        self.value = value
        self.next = next
    }
}

extension Node: CustomStringConvertible {
    //CustomStringConvertible을 구현해, String으로 변환하거나 print 함수 사용시 반환할 값을 지정해 준다
    public var description: String { //description 변수를 설정하면 CustomStringConvertible이 구현된다.
        guard let next = next else {
            //해당 노드가 리스트의 마지막 요소인 경우
            return "\(value)"
            //해당 값을 반환
        }
        
        return "\(value) -> " + String(describing: next) + " "
        //마지막 요소가 아닌 경우, 재귀적으로 다음 노드의 값을 출력한다.
        //일반적으로 String()으로 문자열 변환을 할 수 있지만, 직접 변환이 불가능한 타입들은 String(describing: )으로 캐스팅할 수 있다.
    }
}

//링크드 리스트는 Node로 이루어 지며, Node는 두 가지 책임이 있다.
//• 값을 가진다.
//• 다음 노드에 대한 참조를 가진다. 참조가 nil일 경우 리스트의 마지막이 된다.
