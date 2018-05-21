public class TrieNode<Key: Hashable> {
    public var key: Key?
    //노드에 대한 데이터를 보유한다. 루트노드는 키가 없기 때문에 optional이다.
    
    public weak var parent: TrieNode?
    //부모 노드에 대한 weak 참조. 이 참조로 나중에 remove를 단순화할 수 있다.
    
    public var children: [Key: TrieNode] = [:]
    //이진 검색 트리에서 노드의 자식은 최대 왼쪽, 오른쪽 자식 하나씩만 있었지만, 트라이에서는 많은 수의 자식을 가질 수 있다.
    //자식 노드에 쉽게 접근하기 위해 Dictionary로 선언한다.
    
    public var isTerminating = false
    //컬렉션의 끝을 나타내는 지표(이전 예에서는 종결 문자)로 사용한다.
    
    public init(key: Key?, parent: TrieNode?) {
        self.key = key
        self.parent = parent
    }
}
