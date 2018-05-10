public struct Stack<Element> {
    private var storage: [Element] = []
    //Stack에 적합한 storage 유형을 선택하는 것이 중요하다. 배열은 append와 popLast를 통해,
    //한쪽 끝에서 일정한 시간의 삽입과 삭제를 할 수 있으므로 스택 구현에 알맞은 유형이다(LIFO).
    
    public init() { }
    
    public init(_ elements: [Element]) {
        //기존 배열로 Stack 생성
        storage = elements
    }
}

extension Stack: CustomStringConvertible {
    //CustomStringConvertible을 구현해, String으로 변환하거나 print 함수 사용시 반환할 값을 지정해 준다.
    public var description: String {
        //description 변수를 설정하면 CustomStringConvertible이 구현된다.
        let topDivider = "----top----\n"
        let bottomDivider = "\n-----------"
        
        let stackElements = storage
            .map { "\($0)" } //map으로 storage 배열의 각 값을 문자열로 가져오고
            .reversed() //역순으로 재 정렬
            .joined(separator: "\n") //각 요소 사이에 \n 삽입해서 문자열로 반환
        
        return topDivider + stackElements + bottomDivider
    }
}




//MARK: - push and pop
extension Stack {
    public mutating func push(_ element: Element) {
        //push : 스택의 맨 위에 요소 추가. O(1)
        storage.append(element) //가장 뒤(위)에 추가
    }
    
    @discardableResult
    //@discardableResult를 설정하면, 반환한 result 값을 받아 사용하지 않고 무시할 수 있다.
    public mutating func pop() -> Element? {
        //pop : 스택의 맨 위 요소 제거. O(1)
        return storage.popLast() //가장 뒤(위)의 요소 제거
    }
}




//MARK: - Non-essential operations
extension Stack {
    public func peek() -> Element? {
        //peek : 스택의 내용을 변경하지 않고 스택의 맨 위 요소 반환
        return storage.last
    }
    
    public var isEmpty: Bool {
        //맨 위의 요소가 없다면 비어 있는 스택이 된다.
        return peek() == nil
    }
}




//MARK: - Less is more
extension Stack: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: Element...) {
        //...은 다수의 해당 파라미터를 받는다. 이를 통해 literal로 Stack을 구현할 수 있다.
        storage = elements
    }
}

//Stack
//Stack 데이터 구조는 기본적으로 물리적인 Stack과 같다. 항목을 추가할 때 맨 위에 놓고, 제거할 때도 맨 위 항목을 제거한다.
//Stack은 매우 간단하고, 유용하다. Stack 구현의 주된 목적은 데이터 액세스를 단순한 하나의 방법으로 강제하는 것이다.
//Stck은 두 가지 메서드만 있고, 데이터 구조의 한쪽에서만 요소를 추가하거나 제거할 수 있다. LIFO (last in first out)
//마지막에 push된 요소는 pop될 첫 요소이기도 하다.




//Less is more
//LinkedList처럼 Stack에서도 Swift Collection protocol을 구현할 수 있다.
//하지만, 스택의 목적은 데이터에 액세스하는 방법을 제한하고 단순화하는 것이므로,
//Collection을 구현하고 subscript operator을 만드는 것은 오히려 이 목적을 해친다.




//Where to go from here?
//Stack은 Tree와 graph에서 search를 구현하는 데, 중요한 역할을 한다.
//잘못 선택한 지점까지 pop을 하며, 간단한 미로 찾기 알고리즘에도 Stack을 이용할 수 있다.
