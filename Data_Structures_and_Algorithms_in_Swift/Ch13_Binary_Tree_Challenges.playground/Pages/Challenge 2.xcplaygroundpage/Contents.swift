// Copyright (c) 2019 Razeware LLC
// For full license & permission details, see LICENSE.markdown.
/*:
 [Previous Challenge](@previous)
 ## #2. Serialization
 
 A common task in software development is serializing an object into another
 data type. This process is known as serialization, and allows custom types to
 be used in systems that only support a closed set of data types.
 
 An example of serialization is JSON. Your task is to devise a way to serialize
 a binary tree into an array, and a way to deserialize the array back into
 the same binary tree.
 
 To clarify this problem, consider the following binary tree:
 
 ![Binary Tree](binary-tree.png)
 
 A particular algorithm may output the serialization as
 `[15, 10, 5, nil, nil, 12, nil, nil, 25, 17, nil, nil, nil]`.
 The deserialization process should transform the array back into the same
 binary tree. Note that there are many ways to perform serialization.
 You may choose any way you wish.
 */
//소프트웨어 개발에서 일반적인 작업은 객체를 다른 데이터 유형으로 직렬화(serialization)하는 것이다.
//closed set of data type만 사용하는 시스템에서 Custom type을 사용할 수 있게 한다.
//직렬화의 대표적인 예는 JSON이다.
//여기서는 이진트리를 배열로 직렬화(serialize)하고, 다시 배열을 이진트리로 역직렬화 한다(deserialize).
//https://ko.wikipedia.org/wiki/%EC%A7%81%EB%A0%AC%ED%99%94

var tree: BinaryNode<Int> = {
  
  let root = BinaryNode(value: 15)
  let ten = BinaryNode(value: 10)
  let five = BinaryNode(value: 5)
  let twelve = BinaryNode(value: 12)
  let twentyFive = BinaryNode(value: 25)
  let seventeen = BinaryNode(value: 17)
  
  root.leftChild = ten
  root.rightChild = twentyFive
  ten.leftChild = five
  ten.rightChild = twelve
  twentyFive.leftChild = seventeen
  
  return root
}()

print(tree)




//이진트리를 직렬화(serialization) 또는 역직렬화(deserialization)하는 방법은 여러 가지가 있다.
//구현하기 앞서 먼저 순회 방법을 결정해야 한다. 여기에서는 전위 순회로 직렬화, 역직렬화를 구현한다.

//Traversal
extension BinaryNode {
    public func traversePreOrder(visit: (Element?) -> Void) {
        visit(value)
        
        if let leftChild = leftChild {
            leftChild.traversePreOrder(visit: visit)
        } else {
            visit(nil)
        }
        
        if let rightChild = rightChild {
            rightChild.traversePreOrder(visit: visit)
        } else {
            visit(nil)
        }
    }
}
//전위순회는 하위 node를 순회하기 전에 node를 방문한다(PLR).
//직렬화, 역직렬화에서는 node를 기록하는 것이 중요하므로, nil node도 방문해야 한다.
//모든 순회 함수와 마찬가지로, 이 알고리즘은 트리의 모든 요소를 한 번씩 방문하므로 시간 복잡도는 O(n)이다.

//Serialization
//직렬화에서는 단순히 tree를 순회하면서 배열에 value를 저장한다. 배열은 nil node도 저장해야 하기 때문에 T? type으로 선언해야 한다.
func serialize<T>(_ node: BinaryNode<T>) -> [T?] {
    var array: [T?] = []
    
    node.traversePreOrder { array.append($0) }
    
    return array //pre-order로 value를 가진 배열을 반환한다.
}
//직렬화의 시간 복잡도와 공간 복잡도는 모두 O(n)이다.

//Deserialization
//직렬화에서는 전위 순회로 tree의 value를 가져와 array에 저장했다.
//역직렬화는 array에서 각 value를 가져와 tree를 구성한다. 배열을 반복해 트리를 전위 순회로 구성한다.
func deserialize<T>(_ array: inout [T?]) -> BinaryNode<T>? { //매개변수 자체를 변경하므로 inout 키워드가 필요하다.
    //역직렬화는 배열을 매개변수로 받는다. 각 재귀 단계에서 배열을 변경하고, 재귀 호출에서 변경된 배열을 사용하므로 이는 중요하다.
//    guard let value = array.removeFirst() else {
    guard !array.isEmpty, let value = array.removeLast() else {
        //removeFirst()가 nil을 반환하면, 배열에 더 이상 요소가 없는 것이므로 종료한다.
        //removeFirst()는 배열의 첫 번째 요소를 pop 한다.
        
        //removeFirst()는 첫 요소를 제거한 후, 뒤의 모든 요소가 하나씩 이동하여 누락된 공간을 채우기 때문에, O(n) 연산이다.
        //반대로 removeLast()는 가장 뒤의 요소를 제거하므로 O(1) 연산이다. 따라서 reverse() 후, removeLast()를 사용하는 것이 좋다.
        return nil
    }
    
    //재귀적으로 전위순회 순서대로 tree를 구성한다.
    let node = BinaryNode(value: value)
    node.leftChild = deserialize(&array)
    node.rightChild = deserialize(&array)
    //value를 추출하는 대신 node를 작성한다는 점을 제외하면, 전위순회와 매우 유사하다.
    
    return node
}

var array = serialize(tree)
let node = deserialize(&array)
print(node!)
//   ┌──nil
// ┌──9
// │ └──8
// 7
// │ ┌──5
// └──1
//   └──0

//역직렬화의 결과로 처음에 주어진 트리가 출력된다.
//하지만, 배열에 요소 수 만큼 removeFirst를 호출하므로, 알고리즘의 시간 복잡도는 O(n^2)이다.
//이를 해결할 수 있는 쉬운 방법이 있다.
func deserialize<T>(_ array: [T?]) -> BinaryNode<T>? {
    var reversed = Array(array.reversed())
    
    return deserialize(&reversed)
}
//deserialize 함수를 호출하기 전에 배열을 먼저 reverse하는 help 함수이다.
//그리고 deserialize 함수의 guard 구문에서 !array.isEmpty를 추가한다. 이 작은 수정만으로 성능에 큰 영향을 미친다.
//removeFirst는 첫 요소를 제거한 후, 뒤의 모든 요소가 하나씩 이동하여 누락된 공간을 채우기 때문에, O(n) 연산이다.
//반대로 removeLast는 가장 뒤의 요소를 제거하므로 O(1) 연산이다.
let node1 = deserialize(&array) // old
let node2 = deserialize(array) // new
//역직렬화 전후로 정확히 동일한 tree가 출력되어야 한다.
//helper 함수를 사용한 이후, 시간복잡도는 O(n)이 된다. 새로운 reverse array를 생성해 재귀로 구현했기 때문에 공간 복잡도는 O(n)이다.
