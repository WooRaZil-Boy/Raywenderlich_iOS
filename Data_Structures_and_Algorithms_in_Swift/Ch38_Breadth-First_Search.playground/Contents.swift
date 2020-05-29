// Copyright (c) 2019 Razeware LLC
// For full license & permission details, see LICENSE.markdown.

//Chapter 38: Breadth-First Search

//그래프를 사용하여, 객체 간의 관계를 표현하는 방법을 살펴 보았다.
//그래프에서 객체는 정점일 뿐이며, 객체 간의 관계는 간선으로 표시된다.
//그래프의 정점을 가로지르거나(traverse) 검색(search)하는 몇 가지 알고리즘이 있으며,
//그 중 하나는 너비 우선 탐색(breadth-first search, BFS)이다.
//BFS는 다음과 같은 다양한 문제를 해결하는 데 사용할 수 있다.
// 1. 최소 신장 트리(minimum-spanning tree) 생성
// 2. 정점 사이의 잠재적 경로 찾기
// 3. 두 정점 사이의 최단 경로 찾기




//Example
//BFS는 그래프에서 정점을 선택하는 것으로 시작한다. 그리고 해당 정점의 모든 인접 정점을 탐색 한 후, 다음 정점으로 넘어간다.
//이름에서 알 수 있듯이 이 알고리즘은 너비 우선 접근 방식을 취한다. 다음 무방향 그래프를 사용하여 BFS 예제를 살펴본다.
//: ![sampleGraph](sampleGraph.png)
//다음에 방문할 정점을 추적하기 위해 Queue를 사용한다.
//Queue의 선입선출(first-in-first-out) 특성을 사용하면, 다음 level로 이동하기 전에 모든 정점의 인접 정점을 방문할 수 있다. //p.365
// 1. source 정점을 선택하는 것으로 시작한다. 여기서는 Queue에 추가되어 있는 A를 선택한다.
// 2. Queue가 비어 있지 않으면, 다음 정점(여기서는 A)을 dequeue하고, 방문한다.
//  그런 다음 A의 모든 인접 정점인 [B, D, C]를 Queue에 추가한다. 아직 방문한 적 없고, Queue에 없는 정점만을 Queue에 추가해야 한다.
// 3. Queue가 비어 있지 않으므로, 다음 정점인 B를 dequeue하고 방문한다.
//  그리고, B의 인접 정점인 E를 Queue에 추가한다. A는 이미 방문했으므로 Queue에 추가하지 않는다.
//  이제 Queue는 [D, C, E]가 된다.
// 4. Qeueu에서 다음 정점인 D를 dequeue하고 방문한다.
//  D에는 방문하지 않은 정점이 없으므로 Queue에는 아무것도 추가하지 않는다.
//  이제 Queue는 [C, E]가 된다.
// 5. Qeueu에서 다음 정점인 C를 dequeue하고 방문한다.
//  그런 다음 C의 인접 정점 [F, G]를 Queue에 추가한다.
//  이제 Queue는 [E, F, G]가 된다.
//  정점 A의 모든 인접 정점을 방문했다. BFS는 이제 두 번째 level의 인접 정점으로 넘어간다.
// 6. Qeueu에서 다음 정점인 E를 dequeue하고 방문한다.
//  인접 정점인 B는 이미 방문했고 F는 Queue에 이미 있으므로, E의 인접 정점으로 H만 Queue에 추가한다.
//  이제 Queue는 [F, G, H]가 된다.
// 7. Qeueu에서 다음 정점인 F를 dequeue하고 방문한다.
//  F의 모든 인접 정점이 모두 Queue에 있거나 방문한 적이 있으므로, Queue에는 아무것도 추가하지 않는다.
//  이제 Queue는 [G, H]가 된다.
// 8. Qeueu에서 다음 정점인 G를 dequeue하고 방문한다.
//  G의 인접 정점인 C, F 모두 이전에 방문한 적이 있으므로, Queue에는 아무것도 추가하지 않는다.
//  이제 Queue는 [H]가 된다.
// 9. 마지막으로, H를 dequeue하고 방문한다. Queue가 비었으므로 BFS는 완료된다.
// 10. 정점을 탐색할 때 각 level의 정점으로 tree 구조를 만들 수 있다. //p.367
//  먼저 시작 정점을 root로, 인접 정점을 연결하고, 그 인접 정점의 인접 정점을 계속해서 연결해 준다.




//Implementation
//이전에 구축한 그래프(graph)와 스택 기반 큐(stack-based queue)를 사용해 BFS를 구현한다.
let graph = AdjacencyList<String>()
let a = graph.createVertex(data: "A")
let b = graph.createVertex(data: "B")
let c = graph.createVertex(data: "C")
let d = graph.createVertex(data: "D")
let e = graph.createVertex(data: "E")
let f = graph.createVertex(data: "F")
let g = graph.createVertex(data: "G")
let h = graph.createVertex(data: "H")

graph.add(.undirected, from: a, to: b, weight: nil)
graph.add(.undirected, from: a, to: c, weight: nil)
graph.add(.undirected, from: a, to: d, weight: nil)
graph.add(.undirected, from: b, to: e, weight: nil)
graph.add(.undirected, from: c, to: f, weight: nil)
graph.add(.undirected, from: c, to: g, weight: nil)
graph.add(.undirected, from: e, to: h, weight: nil)
graph.add(.undirected, from: e, to: f, weight: nil)
graph.add(.undirected, from: f, to: g, weight: nil)
//위 example을 그래프로 구현한다.

extension Graph where Element: Hashable {
    func breadthFirstSearch(from source: Vertex<Element>) -> [Vertex<Element>] {
        //해당 정점으로 BFS를 구현하는 메서드
        var queue = QueueStack<Vertex<Element>>() //다음에 방문할 인접 정점을 추적한다.
        var enqueued: Set<Vertex<Element>> = []
        //Queue에 동일한 정점을 여러 번 enqueue 하는 것을 방지하기 위해, 어떤 정점이 Queue에 추가 된 적이 있었는지 기억한다.
        //Set을 사용하면, lookup이 O(1) 이므로 효율적이다.
        var visited: [Vertex<Element>] = [] //정점이 탐색된 순서를 저장하는 Array이다.
        //세 가지 자료 구조를 사용한다.
        
        queue.enqueue(source) //source 정점을 Queue에 넣어 BFS 알고리즘을 시작한다.
        enqueued.insert(source)
        
        while let vertex = queue.dequeue() { //Queue가 빌 때까지 계속해서 정점을 dequeue 한다.
            visited.append(vertex) //Queue에서 정점을 dequeue할 때마다, 방문한 정점 Array에 추가한다.
            let neighborEdges = edges(from: vertex) //현재 정점에서 시작하는 모든 간선을 가져온다.
            
            neighborEdges.forEach { edge in //해당 정점에서의 모든 간선을 반복한다.
                if !enqueued.contains(edge.destination) {
                    //해당 간선의 목적 정점이 Queue에 추가 된 적이 있는 지 확인한다. //추가 된 적이 없다면, Queue에 추가한다.
                    queue.enqueue(edge.destination)
                    enqueued.insert(edge.destination)
                }
            }
        }
        
        return visited
    }
}

let vertices = graph.breadthFirstSearch(from: a)
vertices.forEach { vertex in
    print(vertex)
    // 0: A
    // 1: B
    // 2: C
    // 3: D
    // 4: E
    // 5: F
    // 6: G
    // 7: H
}
//탐색된 정점의 순서가 중요하다.
//인접 정점에서 명심해야 할 것은, 방문 순서는 그래프 구성 방법에 따라 달라진다는 것이다.
//A와 B사이의 간선을 추가하기 전에 A와 C 간선을 먼저 추가한 경우에는, C가 B보다 먼저 출력된다.




//Performance
//BFS를 사용하여 그래프를 순회할 때 각 정점은 한 번만 Queue에 추가된다. 이것의 시간 복잡도는 O(V)이다.
//BFS는 모든 간선을 방문하는데, 여기에 걸리는 시간 복잡도는 O(E)이다. 따라서 너비 우선 탐색(breadth-first search)의 총 시간복잡도는 O(V + E)이다.
//BFS의 공간 복잡도는 O(V)이다. 정점은 queue, enqueued, visited의 세 가지 구조에 저장되기 때문이다.




//Key points
// • 너비 우선 탐색(Breadth-first search, BFS)은 그래프를 탐색하거나 검색하는 알고리즘이다.
// • BFS는 다음 정점을 통과하기 전에 현재 정점의 모든 인접 정점을 탐색한다.
// • 그래프 구조에 인접 정점이 많거나, 가능한 모든 결과를 찾아야 할 때, BFS를 사용하는 것이 좋다.
// • Queue 자료구조는 다음 level의 정점으로 이동하기 전에, 해당 정점의 모든 간선을 방문하는 우선순위를 결정하는 데 사용된다.
