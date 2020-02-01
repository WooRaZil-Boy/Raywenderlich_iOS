// Copyright (c) 2019 Razeware LLC
// For full license & permission details, see LICENSE.markdown.
/*:
 [Previous Challenge](@previous)
 ## 3. Disconnected Graph
 Add a method to `Graph` to detect if a graph is disconnected.
 
 To help you solve this challenge, a property `allVertices` was added
 to the `Graph` protocol:
 
 ```swift
 var allVertices: [Vertex<Element>] { get }
 ```
 
 This property is already implemented by `AdjacencyMatrix` and `AdjacencyList`.
 */
//그래프의 연결이 끊어졌는지를 감지하는 메서드를 추가한다. 연결이 끊어진 그래프의 예는 p.372와 같다.
//이 문제를 해결하기 위해 allVertices 변수를 추가했다. 이 속성은 AdjacencyMatrix, AdjacencyList에 이미 구현 되어 있다.




//두 node 사이에 경로가 없으면 그래프의 연결이 끊어졌다고 한다.
extension Graph where Element: Hashable {
  
  func breadthFirstSearch(from source: Vertex<Element>) -> [Vertex<Element>] {
    var queue = QueueStack<Vertex<Element>>()
    var enqueued: Set<Vertex<Element>> = []
    var visited: [Vertex<Element>] = []
    
    queue.enqueue(source)
    enqueued.insert(source)
    
    while let vertex = queue.dequeue() {
      visited.append(vertex)
      let neighborEdges = edges(from: vertex)
      neighborEdges.forEach { edge in
        if !enqueued.contains(edge.destination) {
          queue.enqueue(edge.destination)
          enqueued.insert(edge.destination)
        }
      }
    }
    
    return visited
  }
}

extension Graph where Element: Hashable {
  func isDisconnected() -> Bool {
    guard let firstVertex = allVertices.first else { //정점이 하나도 없다면, 그래프가 연결된 것으로 처리한다.
        return false
    }
    let visited = breadthFirstSearch(from: firstVertex) //첫 번째 정점에서 BFS를 수행한다. 방문한 모든 node가 반환된다.
    for vertex in allVertices { //그래프의 모든 정점을 반복한다.
        if !visited.contains(vertex) { //해당 정점을 방문했는지 확인한다.
            //visited Set에서 해당 정점이 누락되어 있는 경우 그래프가 끊어진 것이다.
            return true
        }
    }
    return false
  }
}
//visited Set에서 정점이 누락되어 있는 경우 그래프가 끊어진 것으로 간주한다.


//: ![challenge3Sample](challenge3Sample.png)

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
graph.add(.undirected, from: e, to: h, weight: nil)
graph.add(.undirected, from: e, to: f, weight: nil)
graph.add(.undirected, from: f, to: g, weight: nil)

graph.isDisconnected() // true

// Add the following connection to connect the graphs
graph.add(.undirected, from: a, to: e, weight: nil)
graph.isDisconnected() // false
