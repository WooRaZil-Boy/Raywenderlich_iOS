public class Trie<CollectionType: Collection> where CollectionType.Element: Hashable {
    //Collection 프로토콜을 채택하는 모든 유형에 대해 작성할 수 있다.
    //컬렉션의 각 요소는  TrieNode에서 자식 노드의 Dictionary 키로 사용하기 때문에 Hashable이어야 한다.
    public typealias Node = TrieNode<CollectionType.Element>

    private let root = Node(key: nil, parent: nil)

    public init() {}
}

//트라이는 영어 단어와 같이 컬렉션으로 표시될 수 있는 데이터를 저장하는 데 사용되는 트리이다. p.116
//문자열의 각 문자는 노드에 매핑된다. 각 문자열의 마지막 노드는 종결 노드(점)으로 표시된다.
//접두사가 일치하는 문자열을 쉽게 찾을 수 있는 것이 트라이의 장점이다.




//Example
//class EnglishDictionary {
//    private var words: [String]
//
//    func words(matching prefix: String) -> [String] {
//        //문자열 컬렉션에서 접두어와 일치하는 문자열을 반환한다.
//        return words.filter { $0.hasPrefix(prefix) }
//    }
//    //이 방법의 시간 복잡도는 O(k*n)이다(k는 컬렉션에서 가장 긴 문자열, n은 확인해야할 단어의 수).
//}
//트라이 데이터 구조는 이러한 유형의 문제에 대해 훨씬 효율적이다. 여러 자식 노드가 있는 트리로 각 노드는 단일 문자를 나타낼 수 있다.
//루트에서 특수 문자(종결)가 있는 노드에 이르기까지 문자를 추적해 단어를 만든다.
//트라이의 흥미로운 점은 여러 단어가 동일한 문자를 공유할 수 있다는 것이다. p.118




//MARK: - Insert
extension Trie {
    public func insert(_ collection: CollectionType) {
        var current = root
        //현재 노드를 루트로 해서 순회의 진행 상황을 추적한다.
        
        for element in collection { //컬렉션의 각 요소를 별도의 노드에 저장한다.
            if current.children[element] == nil {
                //컬렉션의 각 요소에 대해 현재 노드의 자식 Dictionary에 있는지 확인한다.
                current.children[element] = Node(key: element, parent: current)
                //없다면 새 노드를 만든다.
            }
            
            current = current.children[element]!
            //현재 노드를 다음 노드로 이동한다.
        }
        
        current.isTerminating = true
        //루프 반복 이후 현재 컬렉션의 끝을 나타내는 노드 설정
    }
    
    //각 노드를 탐색하거나 생성하기 때문에 삽입의 시간 복잡도는 O(k)이다. k는 삽입하려는 컬렉션의 요소 수이다.
}




//MARK: - Contains
extension Trie {
    public func contains(_ collection: CollectionType) -> Bool {
        var current = root
        //현재 노드를 루트로 해서 순회의 진행 상황을 추적한다.
        
        for element in collection { //컬렉션의 각 요소를 루프
            guard let child = current.children[element] else {
                //현재 노드의 자식 Dictionary에 없다면 false 반환 종료
                return false
            }
            
            current = child
            //현재 노드를 다음 노드로 이동한다.
        }
        
        return current.isTerminating
        //모든 요소를 검사한 경우(컬렉션의 마지막 요소에 도달한 경우), 해당 요소가 종료 요소여야 한다.
        //그렇지 않으면, 해당 컬렉션이 트라이에 추가되지 않았고, 더 큰 집합의 하위 집합일 뿐이다.
    }
    
    //insert와 매우 유사하며 시간 복잡도는 O(k)이다. k는 찾으려는 컬렉션의 요소 수이다.
}




//MARK - Remove
extension Trie {
    public func remove(_ collection: CollectionType) {
        var current = root
        //현재 노드를 루트로 해서 순회의 진행 상황을 추적한다.
        
        for element in collection {
            guard let child = current.children[element] else {
                //현재 노드의 자식 Dictionary에 없다면 false 반환 종료
                return
            }
            
            current = child
             //현재 노드를 다음 노드로 이동한다.
        }
        
        guard current.isTerminating else {
            return
        }
        
        //여기까지의 코드는 contains와 같다.
        //컬렉션이 트라이의 일부인지 확인하고 현재 컬렉션의 마지막 노드를 가리키기 위해 사용한다.
        
        current.isTerminating = false
        //current.isTerminating를 false로 설정하면, 다음 단계에서 현재 노드를 루프에서 제거할 수 있다.
        
        while let parent = current.parent, current.children.isEmpty && !current.isTerminating {
            //노드를 공유할 수 있으므로 다른 컬렉션에 속한 요소를 제거하지 않아도 된다.
            //현재 노드에 하위 항목이 없으면 다른 컬렉션 요소가 현재 노드에 종속되지 않는 것을 의미한다.
            //현재 노드가 종단 노드인지 확인한다.
            parent.children[current.key!] = nil
            current = parent
            //조건이 만족될 때, 계속해서 부모 속성을 역추적하고 노드를 제거한다.
        }
    }
    
    //노드는 두 개의 다른 컬렉션 간에 공유 될 수 있으므로 각 노드를 제거할 때 주의해야 한다.
    //remove의 시간 복잡도는 O(k)이다. k는 찾으려는 컬렉션의 요소 수이다.
}




//MARK: - Prefix matching
public extension Trie where CollectionType: RangeReplaceableCollection {
    //트라이의 가장 상징적인 알고리즘은 접두어 일치이다.
    //컬렉션 타입이 RangeReplaceableCollection의 append 메서드를 사용해야 하므로 제한된다.
    func collections(startingWith prefix: CollectionType) -> [CollectionType] {
        var current = root
        
        for element in prefix { //트라이에 해당 접두사가 포함되었는지 확인한다
            guard let child = current.children[element] else {
                //없으면 빈 배열 반환
                return []
            }
            
            current = child
        }
        
        return collections(startingWith: prefix, after: current)
        //접두사의 끝을 표시하는 노드를 찾으면 재귀 메서드를 호출하여 현재 노드 뒤의 모든 시퀀스를 찾는다.
    }
    
    private func collections(startingWith prefix: CollectionType, after node: Node) -> [CollectionType] {
        var results: [CollectionType] = []
        //배열을 만들어 결과를 보관한다.
        
        if node.isTerminating {
            results.append(prefix)
            //현재 노드가 종단 노드인 경우 results에 추가한다.
        }

        for child in node.children.values {
            //자식 노드 loop
            var prefix = prefix
            prefix.append(child.key!)
            
            results.append(contentsOf: collections(startingWith: prefix, after: child))
            //재귀적으로 호출하면서 다른 종단 노드를 찾는다.
        }
        
        return results
    }
    //시간 복잡도는 O(k * m)이 된다. k는 접두어와 일치하는 가장 긴 컬렉션을 나타내고 m은 접두사와 일치하는 컬렉션의 수를 나타낸다.
    //cf. 배열은 시간 복잡도가 O(k * n) 이다. 여기서 n은 컬렉션의 요소 수이다.
    //따라서 각 컬렉션이 균등하게 분산된 대규모 데이터 세트의 경우, 접두어 일치를 위해 트라이를 사용하는 것이 성능이 훨씬 좋다.
}
