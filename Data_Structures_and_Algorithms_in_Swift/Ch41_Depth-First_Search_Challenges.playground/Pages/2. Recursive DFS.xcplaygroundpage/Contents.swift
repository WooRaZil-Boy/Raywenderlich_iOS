// Copyright (c) 2019 Razeware LLC
// For full license & permission details, see LICENSE.markdown.
/*:
 [Previous Challenge](@previous)
 ## 2. Recursive DFS
 
 In this chapter we went over an iterative implementation of Depth-first search.
 Now write a recursive implementation.
 */
//이전에는 DFS를 반복적(iterative)으로 구현했다. 재귀(recursive)로도 DFS를 구현할 수 있다.




extension Graph where Element: Hashable {
  
  func depthFirstSearch(from source: Vertex<Element>)
    -> [Vertex<Element>] {
      var visited: [Vertex<Element>] = [] //방문한 정점을 순서대로 추적한다.
      var pushed: Set<Vertex<Element>> = [] //어떤 정점을 방문했는지 추적한다.

      depthFirstSearch(from: source, visited: &visited, pushed: &pushed)
        //helper 함수를 호출하여, DFS를 재귀적으로 수행한다.
      
      return visited
  }
  
    func depthFirstSearch(from source: Vertex<Element>, visited: inout [Vertex<Element>], pushed: inout Set<Vertex<Element>>) {
        pushed.insert(source) //source 정점을 방문한 것으로 표시한다.
        visited.append(source)
        
        let neighbors = edges(from: source) //해당 정점의 모든 간선을 가져온다.
        for edge in neighbors { //해당 정점의 모든 간선을 반복
            if !pushed.contains(edge.destination) { //해당 인접 정점을 아직 방문하지 않은 경우,
                depthFirstSearch(from: edge.destination, visited: &visited, pushed: &pushed)
                //재귀적으로 DFS를 수행한다.
            }
        }
    }
}
//DFS의 전체 시간 복잡도는 O(V + E)이다.

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
graph.add(.undirected, from: c, to: g, weight: nil)
graph.add(.undirected, from: e, to: f, weight: nil)
graph.add(.undirected, from: e, to: h, weight: nil)
graph.add(.undirected, from: f, to: g, weight: nil)
graph.add(.undirected, from: f, to: c, weight: nil)

let vertices = graph.depthFirstSearch(from: a)
vertices.forEach { vertex in
  print(vertex)
    // 0: A
    // 1: B
    // 4: E
    // 5: F
    // 6: G
    // 2: C
    // 7: H
    // 3: D
}

//: [Next Challenge](@next)
