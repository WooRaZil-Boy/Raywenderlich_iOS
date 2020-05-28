// Copyright (c) 2019 Razeware LLC
// For full license & permission details, see LICENSE.markdown.
/*:
 # 1. Count the Number of Paths
 
 Write a method to count the number of paths between two vertices in a directed graph.
 */
//방향 그래프에서 두 정점 사이의 경로 수를 세는 메서드를 작성한다.
//ex. 아래 예에서는 A 에서 E 까지 5개의 경로가 있다.
//: ![numberOfPaths](numberOfPaths.png)




//Graph에서 두 정점 사이의 경로 수를 찾는 함수를 작성한다.
//한 가지 해결 방법은 깊이 우선 순회(depth-first traversal)를 수행하고, 방문한 정점을 추적하는 것이다.
extension Graph where Element: Hashable {
  public func numberOfPaths(from source: Vertex<Element>, to destination: Vertex<Element>) -> Int {
    var numberOfPaths = 0 //출발지와 목적지 사이에서 발견한 경로의 수를 추적한다.
    var visited: Set<Vertex<Element>> = [] //방문한 모든 정점을 추적한다.
    paths(from: source, to: destination, visited: &visited, pathCount: &numberOfPaths)
    //helper 메서드를 재귀적으로 호출한다.
    return numberOfPaths
  }
    
    
    func paths(from source: Vertex<Element>, to destination: Vertex<Element>, visited: inout Set<Vertex<Element>>, pathCount: inout Int) {
        visited.insert(source) //방문한 정점에 source(from)를 추가하면서 알고리즘을 시작한다.
        if source == destination { //source와 destination가 같은지 확인한다.
            pathCount += 1 //같다면, 경로가 존재하는 것이므로 pathCount를 1 추가한다.
        } else { //source와 destination가 같지 않은 경우
            let neighbors = edges(from: source) //source에서 모든 인접 간선을 가져온다.
            for edge in neighbors {
                //해당 source의 모든 간선에서 이전에 방문하지 않은 인접 정점을 재귀적으로 탐색하여 destination 정점에 대한 경로를 찾는다.
                if !visited.contains(edge.destination) {
                    paths(from: edge.destination, to: destination, visited: &visited, pathCount: &pathCount)
                }
            }
        }
        visited.remove(source)
        //방문한 정점 set에서 source를 제거하여, 해당 node에 대한 다른 경로를 계속해서 찾을 수 있도록 한다.
    }
}
//깊이 우선 그래프 탐색을 구현하고 있다. 목적지에 도달할 때까지 경로를 재귀적으로 진행(dive down)하고, stack에서 pop하면서 추적한다.
//시간 복잡도는 O(V+E)이다.

let graph = AdjacencyList<String>()

let a = graph.createVertex(data: "A")
let b = graph.createVertex(data: "B")
let c = graph.createVertex(data: "C")
let d = graph.createVertex(data: "D")
let e = graph.createVertex(data: "E")

graph.add(.directed, from: a, to: b, weight: 0)
graph.add(.directed, from: a, to: d, weight: 0)
graph.add(.directed, from: a, to: e, weight: 0)
graph.add(.directed, from: a, to: c, weight: 0)
graph.add(.directed, from: b, to: d, weight: 0)
graph.add(.directed, from: b, to: c, weight: 0)
graph.add(.directed, from: d, to: e, weight: 0)
graph.add(.directed, from: c, to: e, weight: 0)

print(graph)
// 0: A ---> [ 1: B, 3: D, 4: E, 2: C ]
// 1: B ---> [ 3: D, 2: C ]
// 2: C ---> [ 4: E ]
// 3: D ---> [ 4: E ]
// 4: E ---> [  ]
print("Number of paths: \(graph.numberOfPaths(from: a, to: e))") // 5

//: [Next Challenge](@next)
