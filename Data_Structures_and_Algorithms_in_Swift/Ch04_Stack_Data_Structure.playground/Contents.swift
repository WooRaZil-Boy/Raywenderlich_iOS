//Chapter 4: Stack Data Structure

//Stack은 매우 흔하다. 다음은 Stack의 일반적인 예시이다.
// • 팬케이크
// • 책
// • 종이
// • 현금
//Stack 자료구조는 개념적으로 실제 물리적인 Stack과 동일하다.
//Stack에 항목을 추가하면, Stack의 가장 위에 배치된다. Stack에서 항목을 삭제하면 항상 가장 위의 항목이 제거된다.




//Stack operations
//Stack은 매우 간단하면서 유용하다. Stack을 구축하는 목표는 데이터에 액세스하는 방법을 적용하는 것이다. Linked List보다 훨씬 쉽고 간편하게 구조를 구축할 수 있다.
//Stack에는 두 가지 필수 연산이 있다.
// • push : Stack의 맨 위에 요소를 추가
// • pop : Stack의 맨 위의 요소를 제거
//이처럼 Stack은 자료구조의 한쪽(최상단)에서만 항목을 추가하거나 제거할 수 있는 LIFO(last-in first-out) 구조이다.
//마지막으로 push 된 요소가 가장 먼저 pop 된다.
//Stack은 모든 프로그래밍 분야에서 중요하게 사용된다. 몇 가지 예시는 다음과 같다.
// • iOS는 navigation stack을 사용하여 View Controller를 화면으로 push 하거나 pop 한다.
// • architectural level의 메모리 할당에 Stack을 사용한다. 지역 변수에 대한 메모리도 Stack을 사용해 관리한다.
// • 미로에서 경로를 찾는 것과 같은 Search and conquer 알고리즘에서 역추적의 용도로 Stack을 사용한다.




//Implementation
public struct Stack<Element> {
    private var storage: [Element] = []
    //Array는 append 와 popLast로 한쪽 끝(최상단)에서 상수 시간으로 삽입 및 삭제가 가능하므로 Stack을 구현하기 좋다.
    public init() {}
}

extension Stack: CustomStringConvertible { //print 함수에서 출력되는 구문
    public var description: String {
        """
        ----top----
        \(storage.map{ "\($0)" }.reversed().joined(separator: "\n"))
        -----------
        """
        // 1. storage.map{ "\($0)" } 으로 storage의 요소를 String으로 매핑한 새 배열을 만든다.
        // 2. reversed() 를 사용해 해당 배열의 역순으로 하는 새 배열을 만든다.
        // 3. joined(separator:) 를 사용해, 배열을 문자열로 만든다. 여기서는 "\n"을 사용해 개행한다.
    }
}
//Stack은 적합한 storage type을 선택하는 것이 중요하다.
//Array는 append 와 popLast로 한쪽 끝(최상단)에서 상수 시간으로 삽입 및 삭제가 가능하므로 Stack을 구현하기 좋다.
//이 두 연산자(append, popLast)를 사용하면, Stack의 LIFO 특성 구현이 용이해진다.
//CustomStringConvertible에서 print로 출력되는 구문을 지정해 줄 수 있다.




//push and pop operations
//Stack에 두 가지 연산을 추가한다.
extension Stack {
    public mutating func push(_ element: Element) {
        //swift에서 함수와 메서드의 매개변수는 상수로 취급되어 코드 블럭 내에서 수정할 수 없다.
        //mutating을 추가하면, 해당 매개변수를 직접 변경할 수 있다.
        storage.append(element)
    }
    
    @discardableResult //해당 값을 반환할 때, 따로 변수나 상수로 할당을 하지 않아도 된다.
    //ex. 아래의 pop() 메서드는 반환값이 있기 때문에 let result = pop() 와 같은 식으로 반환값을 따로 할당해 줘야 한다.
    //그렇지 않고 그냥 pop()만 사용하는 경우에는 컴파일러에서 warning을 출력하는데,
    //@discardableResult를 추가하면, warning이 나타나지 않는다.
    public mutating func pop() -> Element? {
        storage.popLast()
    }
}

example(of: "using a stack") {
    var stack = Stack<Int>()
    stack.push(1)
    stack.push(2)
    stack.push(3)
    stack.push(4)
    
    print(stack) //CustomStringConvertible에서 정의한 대로 출력 된다.
    // ----top----
    // 4
    // 3
    // 2
    // 1
    // -----------
    
    if let poppedElement = stack.pop() {
        assert(4 == poppedElement)
        print("Popped: \(poppedElement)") // Popped: 4
    }
}
//push와 pop은 모두 O(1) 시간 복잡도를 가진다.

//Non-essential operations
//Stack을 보다 쉽게 사용할 수 있는 유용한 연산들을 추가해 준다.
extension Stack {
    public func peek() -> Element? {
        //peek으로 Stack의 내용을 변경하지 않고, 최상단의 요소를 확인할 수 있다.
        storage.last
    }
    
    public var isEmpty: Bool { //Stack이 비었는지 확인한다.
        peek() == nil
    }
}
//peek으로 Stack의 내용을 변경하지 않고, 최상단의 요소를 확인할 수 있다.

//Less is more
//Stack에 Swift Collection protocol을 구현할 수도 있다.
//하지만, Stack의 목적은 데이터에 액세스하는 방법을 제한하는 것인데 Collection을 구현하면 iterator와 subscript으로 모든 요소에 접근할 수 있게 된다.
//따라서 Stack에서는 Collection을 구현하지 않은 것이 더 낫다. Less is more
//액세스 순서가 보장되도록 기존 Array를 가져와 Stack으로 변환할 수 있다.
//배열 요소를 loop해 각 요소를 가져와 구현할 수도 있지만, private storage를 생성하는 initializer로 구현해 줄 수도 있다.
extension Stack {
    public init(_ elements: [Element]) { //기존의 array로 stack 구현
        storage = elements
    }
}

example(of: "initializing a stack from an array") {
    let array = ["A", "B", "C", "D"]
    var stack = Stack(array) // D가 가장 위의 요소가 된다.
    //Swift 컴파일러는 Array에서 요소의 유형을 유추(infer)할 수 있으므로, Stack<String> 대신, 단순히 Stack으로 사용할 수 있다.
    print(stack)
    // ----top----
    // D
    // C
    // B
    // A
    // -----------
    stack.pop()
}
//위 코드는 문자열(String) Stack을 만들고, 맨 위의 요소인 "D"를 pop한다.

//여기서 한 단계 더 나아가 array literal로 stack을 구현할 수 있다.
extension Stack: ExpressibleByArrayLiteral {
    //ExpressibleByArrayLiteral를 구현하면, array literal로 초기화할 수 있다.
    public init(arrayLiteral elements: Element...) {
        //ExpressibleByArrayLiteral는 반드시 해당 메서드를 구현해야 한다.
        storage = elements
    }
}

example(of: "initializing a stack from an array literal") {
    var stack: Stack = [1.0, 2.0, 3.0, 4.0] //4.0이 가장 위의 요소가 된다.
    //Swift 컴파일러는 Array에서 요소의 유형을 유추(infer)할 수 있으므로, Stack<Double> 대신, 단순히 Stack으로 사용할 수 있다.
    print(stack)
    // ----top----
    // 4.0
    // 3.0
    // 2.0
    // 1.0
    // -----------
    stack.pop()
}
//Double 자료형의 Stack을 생성하고, 맨 위의 요소인 4.0을 pop 한다.

//Stack은 Tree와 graph에서 search을 구현하는 데 중요하게 사용된다.
//ex. 미로에서 길을 찾을 때, 선택지점에서 가능한 모든 결정을(왼쪽, 오른쪽, 직진) stack에 push한다.
//막다른 곳에 다다르면 단순히 stack을 pop해서 이전 선택지점으로 돌아가 다른 결정을 한다.
//이런 식으로 Stack을 사용해 역추적하면서 문제를 해결할 수 있다.




//Key points
// • Stack은 LIFO(last-in first-out) 자료구조이다.
// • Stack은 매우 단순하지만, 다양한 곳에서 사용되는 핵심적인 자료구조이다.
// • Stack에서 구현해야 하는 필수 연산은 요소를 추가하는 push 메서드와, 요소를 제거하는 pop 메서드이다.
