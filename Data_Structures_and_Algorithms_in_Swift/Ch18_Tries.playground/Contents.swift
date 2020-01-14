//Chapter 18: Tries

//Trie(try와 발음이 같다)는 영어 단어와 같이 Collection으로 표현할 수 있는 데이터를 저장하는 데 특화된 tree이다. //p.200
//문자열(String)의 각 문자(Character)는 node에 매핑된다. 각 문자열의 마지막 node는 종단 node로 표시 된다.
//trie의 장점은 context의 접두사 일치 확인 시 가장 잘 설명된다.




//Example
//문자열의 접두사 일치를 처리하는 방법은 다음과 같다.
class EnglishDictionary {
    private var words: [String] = []
    
    func words(matching prefix: String) -> [String] { //접두사 일치 여부 확인
        words.filter { $0.hasPrefix(prefix) }
    }
}
//문자열 집합에서 접두사와 일치하는 문자열을 반환한다.
//단어 배열의 요소 수가 작다면, 이는 잘 작동한다. 하지만, 수천 개 이상의 단어를 다뤄야 한다면 소요시간이 매우 늘어나게 된다.
//words(matching:)의 시간 복잡도는 O(k*n)이다. 여기서 k는 가장 긴 문자열이고, n은 확인해야 할 단어의 수이다.
//Trie 자료구조는 이러한 유형의 문제에 대해 뛰어난 성능을 보인다.
//Trie는 트리이므로 여러 child를 가질 수 있고, 각 node는 단일 character를 나타낼 수 있다.
//이 예에서는 구둣점으로 표시한 indicator(종단 node를 나타낸다)를 가진 node를 추적해 단어를 형성한다.
//trie의 흥미로운 특징은 여러 단어가 동일한 문자를 공유할 수 있다는 것이다.
//ex. 접두사 cu를 포함한 단어를 찾아야 하는 경우 //p.202
//먼저 c가 포함된 node로 이동한다. 그러면 trie의 다른 분기를 빠르게 제외할 수 있다.
//이후 u node로 이동한다. 여기가 접두사 cu의 끝이므로, trie는 node chain으로 형성된 모든 Collection을 u node에서 반환한다.
//이 경우에는 cut 과 cute가 반환된다. 수십 만개의 단어를 검색해야 하는 경우, trie를 사용하여 제외할 수 있는 비교의 수는 매우 많다.




//Implementation

//TrieNode
public class TrieNode<Key: Hashable> {
    public var key: Key? //node에 대한 데이터를 보유한다.
    //root node는 key가 없기 때문에 optional 이다.
    public weak var parent: TrieNode? //상위 node에 대한 weak 참조를 보유한다.
    //해당 참조를 사용해 remove 메서드를 단순화할 수 있다.
    public var children: [Key: TrieNode] = [:]
    //이진 탐색 트리에서 node는 left, right 하위 node를 가지지만, trie는 여러 개의 하위 node를 가질 수 있다.
    //node 관리를 위해 dictionary를 사용한다.
    public var isTerminating = false //collection의 종료를 나타낸다(위의 그림에선 구둣점으로 표현. 종단 node).
    public init(key: Key?, parent: TrieNode?) {
        self.key = key
        self.parent = parent
    }
}
//TrieNode는 이전에 작성한 Node들과는 약간 다르다.

//Trie
public class Trie<CollectionType: Collection> where CollectionType.Element: Hashable {
    public typealias Node = TrieNode<CollectionType.Element>
    private let root = Node(key: nil, parent: nil)
    public init() {}
}
//Trie 클래스는 문자열을 비롯한 Collection 프로토콜을 구현하는 type을 사용한다.
//이 요구사항 외에도, Collection의 각 요소는 Hashable을 구현해야 한다.
//이는 Collection의 요소를 TrieNode에서 children dictionary의 key로 사용하기 때문이다.

//Insert
//Trie는 Collection을 준수하는 모든 type을 사용한다. trie는 각 node가 Collection의 요소에 매핑된다.
extension Trie {
    public func insert(_ collection: CollectionType) {
        var current = root //root node에서 시작하여 진행 상황을 추적한다.
        
        for element in collection { //trie는 Collection의 각 요소를 별도의 node에 저장한다.
            if current.children[element] == nil { //현재 요소가 dictionary에 있는지 확인한다.
                current.children[element] = Node(key: element, parent: current) //없다면 새 node를 만든다.
            }
            current = current.children[element]! //다음 node로 이동한다.
        }
        
        current.isTerminating = true
    }
}
//시간 복잡도는 O(k)이며, 여기서 k는 insert하려는 Collection의 요소 수 이다. Collection의 각 요소 node를 통과하거나 생성해야 하기 때문이다.

//Contains
//contains는 insert와 매우 유사하다.
extension Trie {
    public func contains(_ collection: CollectionType) -> Bool {
        var current = root
        for element in collection {
            guard let child = current.children[element] else {
                return false
            }
            current = child
        }
        return current.isTerminating
    }
}
//insert와 비슷한 방법으로 trie를 순회(traverse)한다. collection의 모든 요소를 검사하여, tree에 있는지 확인한다.
//Collection의 마지막 요소에 도달하면, 이는 반드시 종단 node여야 한다.
//그렇지 않다면, 이 Collection은 tree에 추가되지 않은 것이고, 찾은 요소는 더 큰 Collection의 하위 집합일 뿐이다.
//contains의 시간 복잡도는 O(k)이다. 여기서 k는 찾고 있는 Collection의 요소 수 이다.
//Collection이 trie에 있는지 확인하려면, k node를 통과해야 하기 때문이다.
example(of: "insert and contains") {
    let trie = Trie<String>()
    trie.insert("cute")
    if trie.contains("cute") {
        print("cute is in the trie")
    }
}

//Remove
//trie에서 node를 제거하는 것은 좀 더 까다롭다. node는 서로 다른 두 Collection 간에 공유할 수 있으므로 각 node를 제거할 때 특히 주의해야 한다.
extension Trie {
    public func remove(_ collection: CollectionType) {
        var current = root
        for element in collection {
            guard let child = current.children[element] else {
                return
            }
            current = child
        } //이 부분은 contains와 같다. Collection이 trie의 일부인지 확인하고, Collection의 마지막 node를 가리키도록 한다.
        guard current.isTerminating else {
            return
        }
        
        current.isTerminating = false //isTerminating를 false로 설정하면, 다음 loop에서 현재 node를 제거할 수 있다.
        while let parent = current.parent,
                current.children.isEmpty && !current.isTerminating {
                //node는 공유할 수 있으므로, 다른 Collection에 속하는 요소를 제거해 버리는 것에 주의해야 한다.
                //현재 node에 children이 없으면 다른 Collection과 공유 되는 요소가 없다 의미이다.
                //또한, 현재 node가 종단 node인지 확인해야 한다. 종단 node라면, 다른 Collection에 속하기 때문이다.
                //current가 이러한 조건을 만족한다면, 부모 속성을 역추적하면서 node를 제거한다.
            parent.children[current.key!] = nil
            current = parent
        }
    }
}
//시간 복잡도는 O(k)이다. 여기서 k는 제거하려는 Collection의 요소 수를 의미한다.
example(of: "remove") {
    let trie = Trie<String>()
    trie.insert("cut")
    trie.insert("cute")
    
    print("\n*** Before removing ***")
    assert(trie.contains("cut"))
    print("\"cut\" is in the trie")
    assert(trie.contains("cute"))
    print("\"cute\" is in the trie")
    
    print("\n*** After removing cut ***")
    trie.remove("cut")
    assert(!trie.contains("cut"))
    assert(trie.contains("cute"))
    print("\"cute\" is still in the trie")
    
    // *** Before removing ***
    // "cut" is in the trie
    // "cute" is in the trie
    //
    // *** After removing cut ***
    // "cute" is still in the trie
}

//Prefix matching
//Trie에 대한 가장 상징적인 알고리즘은 접두사 일치 알고리즘(prefix-matching algorithm)이다.
public extension Trie where CollectionType: RangeReplaceableCollection {
    //CollectionType은 RangeReplaceableCollection 유형의 append 메서드를 사용해야 하므로 이를 구현해야 한다.
    func collections(startingWith prefix: CollectionType) -> [CollectionType] {
        var current = root
        for element in prefix { //prefix의 각 문자들이 trie에 있는 지 확인
            guard let child = current.children[element] else { //하나라도 없으면 빈 배열 반환(접두사가 포함된 요소가 없다)
                return []
            }
            current = child
        }
        //trie에 접두사가 포함되어 있는지 확인한다. 그렇지 않다면 빈 Array를 반환한다.
        
        return collections(startingWith: prefix, after: current) //접두사의 각 문자들이 모두 trie애 있다면 시퀀스를 찾는다.
        //접두사의 종단 node를 찾은 후, 함수를 호출해 모든 시퀀스를 찾는다.
        //해당 함수를 재귀적으로 호출해 모든 종단 node를 대상으로 이를 수행한다.
    }
    
    private func collections(startingWith prefix: CollectionType, after node: Node) -> [CollectionType] {
        var results: [CollectionType] = [] //결과 Array
        
        if node.isTerminating { //현재 node가 종단 node인 경우 results에 추가한다.
            results.append(prefix)
        }
        
        for child in node.children.values { //현재 node의 children을 확인한다.
            var prefix = prefix
            prefix.append(child.key!) //접두사에 Character 추가해서 새 문자열을 만든다.
            results.append(contentsOf: collections(startingWith: prefix, after: child))
            //모든 하위 node에 반복적으로 호출하여 다른 종단 node를 찾는다.
            //종단 node에서 반환된 Array(하나의 CollectionType 요소가 있는 배열)를 결과에 append 한다.
            //Array를 추가하므로 append(contentsOf:)를 사용한다.
        }
        
        return results
    }
    //collection(startingWith:)의 시간 복잡도는 O(k*m)이다.
    //여기서 k는 접두사와 일치하는 가장 긴 collection이고, m은 접두사와 일치하는 collection의 수이다.
    //Array로 접두사 일치를 구현하는 경우(맨 처음의 example) 시간 복잡도는 O(k*n)이다. 여기서 n은 collection의 요소 수이다.
    //각 collection이 균일하게 분산 된 대규모 데이터 집합의 경우, 접두사 일치에 Array를 사용하는 것에 비해 훨씬 우수한 성능을 보여준다.
}
//접두사 일치 알고리즘은 위의 extension에서 구현된다.
example(of: "prefix matching") {
    let trie = Trie<String>()
    trie.insert("car")
    trie.insert("card")
    trie.insert("care")
    trie.insert("cared")
    trie.insert("cars")
    trie.insert("carbs")
    trie.insert("carapace")
    trie.insert("cargo")
    
    print("\nCollections starting with \"car\"")
    let prefixedWithCar = trie.collections(startingWith: "car")
    print(prefixedWithCar)

    print("\nCollections starting with \"care\"")
    let prefixedWithCare = trie.collections(startingWith: "care")
    print(prefixedWithCare)
    
    // Collections starting with "car"
    // ["car", "carbs", "care", "cared", "cars", "carapace", "cargo", "card"]
    
    // Collections starting with "care"
    // ["care", "cared"]
}
//개별 node가 공유될 수 있기 때문에 trie는 메모리 효율이 높다.
//ex. "car", "carb", "care"는 단어의 첫 세 글자를 공유할 수 있다.
