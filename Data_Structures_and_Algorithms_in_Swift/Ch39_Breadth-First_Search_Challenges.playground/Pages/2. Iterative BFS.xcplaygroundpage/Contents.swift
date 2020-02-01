// Copyright (c) 2019 Razeware LLC
// For full license & permission details, see LICENSE.markdown.
/*:
 [Previous Challenge](@previous)
 
 ## 2. Iterative BFS
 
 In this chapter we went over an iterative implementation of breadth-first
 search. Now write a recursive implementation.
 */
//이전에는 BFS를 반복적(iterative)으로 구현 했다. 재귀(recursive)로도 BFS를 구현할 수 있다.




extension Graph where Element: Hashable {
    
  func bfs(from source: Vertex<Element>) -> [Vertex<Element>] {
    var queue = QueueStack<Vertex<Element>>() //다음에 방문할 인접 정점을 추적한다.
    var enqueued: Set<Vertex<Element>> = [] //Queue에 추가된 적 있는 정점을 기억한다.
    //lookup은 Set을 사용하면 O(1) 이지만, Array를 사용하면 O(n)이 된다.
    var visited: [Vertex<Element>] = [] //정점이 탐색된 순서를 저장하는 Array이다.

    queue.enqueue(source) //source 정점을 Queue에 enqueue하면서 알고리즘을 시작한다.
    enqueued.insert(source)
    
    bfs(queue: &queue, enqueued: &enqueued, visited: &visited) //helper 함수를 호출해 BFS를 재귀적으로 수행한다.

    return visited //방문한 정점을 순서대로 반환한다.
  }
    
    private func bfs(queue: inout QueueStack<Vertex<Element>>, enqueued: inout Set<Vertex<Element>>, visited: inout [Vertex<Element>]) {
        guard let vertex = queue.dequeue() else { //Queue가 비워질 때까지 재귀적으로 BFS를 호출해 정점을 dequeue한다.
            return
        }
        visited.append(vertex) //해당 점점을 방문한다.
        let neighborEdges = edges(from: vertex) //현재 정점의 모든 간선을 가져온다.
        neighborEdges.forEach { edge in
            if !enqueued.contains(edge.destination) { //Queue에 enqueue하기 전에 해당 인접 정점을 방문한 적이 있는지 확인한다.
                queue.enqueue(edge.destination)
                enqueued.insert(edge.destination)
            }
        }
        bfs(queue: &queue, enqueued: &enqueued, visited: &visited) //Queue가 비워질 때까지 BFS를 재귀적으로 수행한다.
    }
}
//너비 우선 탐색(breadth-first search, BFS)의 전체 시간 복잡도는 O(V + E)이다.


//: ![sampleGraph](sampleGraph.png)

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

print(graph)

let vertices = graph.bfs(from: a)
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

//: [Next Challenge](@next)
