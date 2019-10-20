// Copyright (c) 2018 Razeware LLC
// For full license & permission details, see LICENSE.markdown.

//힙은 완전 이진 트리로, 배열을 이용해 만들 수 있다(cf. 포화 이진 트리).
//https://ko.wikipedia.org/wiki/%EC%9D%B4%EC%A7%84_%ED%8A%B8%EB%A6%AC
//https://namu.wiki/w/%ED%9E%99%20%ED%8A%B8%EB%A6%AC
//힙은 두 가지가 있다.
//Max heap (최대 힙) : 높은 값을 가진 요소가 높은 우선 순위를 가지는 힙
//Min heap (최소 힙) : 낮은 값을 가진 요소가 높은 우선 순위를 가지는 힙




//The heap property
//힙에서 항상 만족해야 하는 중요한 특성이 있다. 이를 힙 불변성 또는 힙 특성이라 한다. p.133
//최대 힙에서는 부모 노드는 자식 노드보다 항상 크거나 같은 값을 가져야 한다.
//최소 힙에서는 부모 노드는 자식 노드보다 항상 작거나 같은 값을 가져야 한다.
//다른 중요한 힙 특성은 힙은 완전 이진 트리여야 한다는 것이다. 이것은 마지막 레벨을 제외한 모든 레벨이 완전히 채워져 있어야 한다는 의미이다.
//힙이 유용한 프로그램은 다음과 같다.
//• 컬렉션 요소의 최소 또느 최대 요소 계산
//• 힙 정렬
//• 우선 순위 큐
//• 그래프 알고리즘(Dijkstra’s, Prim’s..)
//메모리 힙과는 전혀 다르다.




//Common heap operations
struct Heap<Element: Equatable> {
    var elements: [Element] = [] //힙 요소를 보유할 배열
    let sort: (Element, Element) -> Bool //힙을 정렬하는 방법을 정의하는 정렬 함수
    
    init(sort: @escaping (Element, Element) -> Bool) {
        //생성자에서 적절한 함수를 전달해서, 최대 힙 혹은 최소 힙을 생성한다.
        self.sort = sort
    }
}




//How do you represent a heap?
//힙은 이진 트리이지만, 간단한 배열로 표시할 수 있어 쉽다. 힙 구현의 장점은 힙의 요소가 모두 메모리에 저장되므로 시간과 공간 복잡도가 효율적이다.
//요소를 스와핑하는 것이 힙에서는 중요한 역할을 한다. p.135
//트리 구조를 레벨 별로 왼쪽 부터 오른쪽 까지 차례대로 요소를 배열에 담으면 된다. p.136
//레벨이 올라갈 수록 이전 레벨보다 두 배 많은 노드가 생긴다.
//따라서 힙에 접근할 때는 간단한 수식을 사용해 index로 접근하면 된다. 0부터 시작하는 index i가 있을 때
//• 이 노드의 왼쪽 자식은 2i + 1로 접근한다.
//• 이 노드의 오른쪽 자식은 2i + 2로 접근한다. p.136
//• 이 노드의 부모 노드는 floor((i - 1) / 2)로 접근할 수 있다.
//자식 노드 순회의 시간 복잡도는 O(log n)이다. 배열 구조에서는 O(1)이다.
extension Heap {
    var isEmpty: Bool {
        return elements.isEmpty
    }
    
    var count: Int {
        return elements.count
    }
    
    func peek() -> Element? {
        return elements.first
    }
    
    func leftChildIndex(ofParentAt index: Int) -> Int {
        return (2 * index) + 1
    }
    
    func rightChildIndex(ofParentAt index: Int) -> Int {
        return (2 * index) + 2
    }
    
    func parentIndex(ofChildAt index: Int) -> Int {
        return (index - 1) / 2
    }
}



