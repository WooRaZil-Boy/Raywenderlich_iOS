// Copyright (c) 2019 Razeware LLC
// For full license & permission details, see LICENSE.markdown.
//:
/*:
 [Previous Challenge](@previous)
 ## 2. Find all the shortest paths
 
 Add a method to class `Dijkstra` that returns a dictionary of all the
 shortest paths to all vertices given a starting vertex.
 */
//시작 정점에서 모든 정점에 대한 최단 경로 dictionary를 반환하는 메서드를 추가한다.

//: ![challenge1Diagram](challenge1Question.png)

extension Dijkstra {
  public func getAllShortestPath(from source: Vertex<T>) -> [Vertex<T> : [Edge<T>]] {
    var pathsDict = [Vertex<T> : [Edge<T>]]() //source에서 모든 정점으로의 경로를 저장한다.
    let pathsFromSource = shortestPath(from: source) //Dijkstra’s algorithm을 수행하여 source 정점에서 모든 경로를 찾는다.
    for vertex in graph.vertices { //그래프의 모든 정점에 대해
        let path = shortestPath(to: vertex, paths: pathsFromSource) //source 정점과 그래프의 모든 정점 사이의 간선 목록을 생성한다.
        pathsDict[vertex] = path
    }
    return pathsDict //경로 dictionary를 반환한다.
  }  
}




let graph = AdjacencyList<String>()

let a = graph.createVertex(data: "A")
let b = graph.createVertex(data: "B")
let c = graph.createVertex(data: "C")
let d = graph.createVertex(data: "D")
let e = graph.createVertex(data: "E")

graph.add(.directed, from: a, to: b, weight: 1)
graph.add(.directed, from: a, to: e, weight: 21)
graph.add(.directed, from: a, to: c, weight: 12)
graph.add(.directed, from: b, to: d, weight: 9)
graph.add(.directed, from: b, to: c, weight: 8)
graph.add(.directed, from: d, to: e, weight: 2)
graph.add(.directed, from: c, to: e, weight: 2)

print(graph)

let dijkstra = Dijkstra(graph: graph)
let pathsDict = dijkstra.getAllShortestPath(from: a) //Dijkstra.swift에서 구현

for (vertex, path) in pathsDict {
  print("Path to \(vertex) from \(a)")
  for edge in path {
    print("\(edge.source) --|\(edge.weight ?? 0.0)|--> \(edge.destination)")
  }
  print("\n")
}



