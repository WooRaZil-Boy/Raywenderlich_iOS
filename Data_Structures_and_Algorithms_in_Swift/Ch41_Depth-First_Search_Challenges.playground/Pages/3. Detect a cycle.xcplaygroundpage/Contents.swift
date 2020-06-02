// Copyright (c) 2019 Razeware LLC
// For full license & permission details, see LICENSE.markdown.
/*:
 [Previous Challenge](@previous)
 ## 3. Detect a cycle
 
 Add a method to `Graph` to detect if a **directed** graph has a cycle.
 */
//방향 그래프에서 Cycle을 감지하는 메서드를 Graph에 추가한다.




//그래프에서 동일한 source로 이어지는 간선과 정점의 경로가 있는 경우, 이를 Cycle이라 한다.
//특정 정점에서 출발하여 다시 처음 출발했던 정점으로 되돌아 올 수 있다면 cycle이 있다고 한다.






extension Graph where Element: Hashable {
  
  func hasCycle(from source: Vertex<Element>) -> Bool  {
    var pushed: Set<Vertex<Element>> = [] //방문한 모든 정점을 추적하는 데 사용한다.
    
    return hasCycle(from: source, pushed: &pushed) //helper 메서드를 호출하여, 그래프에 cycle이 있는지 재귀적으로 확인한다.
  }
    
    func hasCycle(from source: Vertex<Element>, pushed: inout Set<Vertex<Element>>) -> Bool {
        pushed.insert(source) //source 정점을 insert 하면서 알고리즘을 시작한다.
        
        let neighbors = edges(from: source) //해당 정점의 모든 간선을 가져온다.
        for edge in neighbors {
            if !pushed.contains(edge.destination) && hasCycle(from: edge.destination, pushed: &pushed) {
                //방문하지 않은 인접한 정점이 있는 경우, 해당 경로를 더 깊이 재귀적으로 탐색한다.
                return true
            } else if pushed.contains(edge.destination) { //인접 정점을 방문한 적이 있다면, cycle이 존재하는 것이다.
                return true
            }
        }
        pushed.remove(source) //잠재적인 cycle이 있는 다른 경로를 계속 찾을 수 있도록 source 정점을 제거한다.
        return false //cycle이 발견되지 않은 경우
    }
}
//기본적으로 DFS를 사용한다. Cycle을 찾을 때까지 한 경로를 재귀적으로 탐색하고, 다른 경로를 찾기 위해 Stack에서 pop 해서 back-tracking한다.
//시간 복잡도는 O(V + E)가 된다.

//: ![sampleGraph2](sampleGraph2.png)

let graph = AdjacencyList<String>()
let a = graph.createVertex(data: "A")
let b = graph.createVertex(data: "B")
let c = graph.createVertex(data: "C")
let d = graph.createVertex(data: "D")

graph.add(.directed, from: a, to: b, weight: nil)
graph.add(.directed, from: a, to: c, weight: nil)
graph.add(.directed, from: c, to: a, weight: nil)
graph.add(.directed, from: b, to: c, weight: nil)
graph.add(.directed, from: c, to: d, weight: nil)

print(graph)
// 0: A ---> [ 1: B, 2: C ]
// 1: B ---> [ 2: C ]
// 2: C ---> [ 0: A, 3: D ]
// 3: D ---> [  ]

print(graph.hasCycle(from: a)) // true
