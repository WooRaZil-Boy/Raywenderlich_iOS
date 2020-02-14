// Copyright (c) 2019 Razeware LLC
// For full license & permission details, see LICENSE.markdown.

//Chapter 42: Dijkstra’s Algorithm
//Google 또는 Apple의 Maps 앱을 사용하면, 한 곳에서 다른 곳까지의 최단 거리 또는 최단 시간의 경로를 찾을 수 있다.
//다익스트라 알고리즘(Dijkstra’s Algorithm)은 GPS 네트워크에서 두 위치 사이의 최단 경로를 찾는 데 특히 유용하다.
//Dijkstra’s Algorithm은 욕심쟁이(greedy) 알고리즘이다.
//Greedy Algorithm은 단계별로 solution을 구성하며, 모든 단계에서 최적의 경로를 선택한다(매 선택에서 지금 이 순간 당장 최적인 답을 선택한다).
//특히 Dijkstra’s Algorithm은 방향 또는 무방향 그래프에서 정점 사이의 최단 경로를 찾는다. 그래프의 정점을 지정하면, Dijkstra’s Algorithm은 해당 시작 정점에서 모든 최단 경로를 찾는다.
//Dijkstra’s Algorithm을 사용하여 다음과 같은 프로그램을 구현할 수 있다.
// 1. 전염병 전파(Communicable disease transmission) : 질병이 가장 빠르게 퍼지는 곳을 발견할 수 있다.
// 2. 전화 네트워크(Telephone network) : 네트워크에서 이용할 수 있는 최대 대역폭 경로(highest-bandwidth path) 통화 라우팅을 찾을 수 있다.
// 3. 지도(Mapping) : 최단 경로와 가장 빠른 경로 찾기




//Example
//지금까지 살펴본 모든 그래프는 모두 무방향 그래프(undirected graph)였다. 방향 그래프(directed graph)로 GPS 네트워크를 나타낼 수 있다.
//정점은 물리적 위치를 나타내며, 정점 사이의 간선은 방향과 비용이 있는 경로를 나타낸다.
//: ![sampleGraph](sampleGraph.png)
//Dijkstra’s Algorithm에서는 그래프의 나머지 node에 대한 경로를 찾으려면, 시작점이 필요하므로 먼저 시작 정점(starting vertex)을 선택해야 한다. 여기에서는 A를 시작점으로 선택했다 가정한다.

//First pass
//정점 A에서 나가는 간선을 확인한다. 이 경우에는 3가지 간선이 있다. //p.391
// • A to B, 비용 8
// • A to F, 비용 9
// • A to G, 비용 1
//나머지 정점은 A에서 출발해 도착하는 직접적인 경로가 없기 때문에 nil로 표시한다.
//그래프 오른쪽의 표는 각 단계에서 Dijkstra’s Algorithm의 기록을 나타낸다. 알고리즘의 각 pass마다 표에 행을 추가한다.
//표의 마지막 행은 알고리즘의 최종 출력이 된다.

//Second pass
//다음 주기에서, Dijkstra’s Algorithm은 지금까지의 경로 중 가장 비용이 낮은 경로를 살펴 본다. A에서 G까지의 최소 비용은 1 이며, G에 도달하는 가장 짧은 경로이기도 하다. //p.392
//이는 출력표(output table)에서 어두운 색으로 표시된다.
//가장 저렴한 경로인 정점 G에서 출발하는 모든 간선을 보면, G에서 C까지의 단 하나의 간선이 있으며 총 비용은 4가 된다. A에서 G까지의 비용이 1 + 3 = 4 이기 때문이다.
//출력표의 모든 value는 두 가지 부분으로 나눠져 있다. 해당 정점에 도달하는 데 드는 총 비용과 해당 정점에 대한 경로의 마지막 인접 정점이다.
//예를 들어, 정점 C에 대한 value인 4 G는 (A에서 출발)C에 도달하는데 4의 비용이 들고, C에 대한 경로가 G를 통과함을 의미한다.
//nil은 해당 정점에 대한 경로가 발견되지 않았음을 나타낸다.

//Third pass
//다음 주기에서는, 다음으로 가장 저렴한 비용(next-lowest cost)을 살펴본다. 표를 보면, C로 가는 경로가 비용이 가장 적으므로, C에서 계속 탐색 하게 된다. //p.393
//C로 가는 최단 경로를 찾아 C 열을 채운다. C에서 출발하는 간선을 모두 살펴본다.
// • C to E, 비용 4 + 1 = 5
// • C to B, 비용 4 + 3 = 7
//B로 가는 더 저렴한 비용의 경로를 찾았으므로, B에 대한 이전 경로의 값을 대체해 준다(이전 경로는 A to B, 비용 8).

//Fourth pass
//다시 다음 주기에서는, 다음으로 가장 저렴한 비용(next-lowest cost)을 살펴본다. 출력표를 보면, C에서 E까지의 경로가 총 비용 5로 가장 작으므로, E에서 계속 탐색 하게 된다. //p.394
//최단 경로를 찾았으므로 E 열을 채운다. 정점 E에서 출발하는 간선은 다음과 같다.
// • E to C, 비용 5 + 8 = 13. C에 대한 최단 경로(A - G - C, 비용 4)가 이미 있으므로, 해당 경로를 무시한다.
// • E to D, 비용 5 + 2 = 7.
// • E to B, 비용 5 + 1 = 6. 출력표에 따르면, B로의 최단 경로의 비용은 현재 7(A - G - C - B)이다.
//  현재 경로(A - G - C - E - B)가 비용이 더 저렴하므로 업데이트 해 준다.

//Fifth pass
//다음으로 B에서 탐색을 계속 한다. //p.395
//정점 B에서 출발하는 간선은 다음과 같다.
// • B to E, 비용 6 + 1 = 7. 하지만, E에 대한 최단 경로(A - G - C - E, 비용 5)가 이미 있으니 이 경로를 무시한다.
// • B to F, 비용 6 + 3 = 9. 표를 살펴보면, 현재 작성된 경로(A - F)의 비용도 9임을 알 수 있다. 비용이 같으나 더 짧은 경로가 있으므로 해당 경로(B to F)를 무시한다.

//Sixth pass
//다음으로 D에서 탐색을 계속 한다. //p.396
//그러나 D에서 출발하는 간선은 없으므로 막다른 곳이다. 출력표에 D까지으 최단 경로를 찾았다는 기록만 하면 된다(어둔운 색으로 음영 처리).

//Seventh pass
//다음은 F이다. //p.397
//정점 F에서 출발하는 간선은 F to A, 비용 9 + 2 = 11 하나 뿐이다. A는 시작 정점이므로, 이 간선은 무시한다.

//Eighth pass
//H를 제외한 모든 정점을 기록했다. H에는 간선이 H to G와 H to F 두 개가 있다. 그러나 A to H의 경로가 없기 때문에, 출력표의 H열이 없다. H열을 모두 nil로 채워준다. //p.398
//모든 정점을 방문했기 때문에 Dijkstra’s algorithm이 완료되었다.
//이제 최종 행을 확인해 최단 경로와 비용를 확인할 수 있다. 예를 들어, D에 도달하는 비용은 7임을 확인할 수 있다.
//경로를 찾으려면 역추적(backtrack)하면 된다. 각 열은 현재 정점이 연결된 이전 정점을 기록하므로 D에서 E로, C에서 G로, 마지막으로 A로 돌아간다. //p.398




//Implementation
//우선 순위 큐(priority queue)는 방문하지 않은 정점을 저장하는 데 사용한다. 우선 순위 큐에서 dequeue 할 때마다, 현재에서 잠정적인 최단 경로의 정점를 제공한다.
public enum Visit<T: Hashable> { //열거형. 두 가지 상태가 있다.
    case start //시작 정점
    case edge(Edge<T>) //정점은 시작 정점으로 돌아가는 경로의 연결된 인접 간선을 가지고 있다.
}
//Dijkstra 클래스를 정의한다.
public class Dijkstra<T: Hashable> {
    public typealias Graph = AdjacencyList<T> //Graph는 AdjacencyList의 typealias이다.
    //필요한 경우 인접 행렬(adjacency matrix)로 대체할 수 있다.
    let graph: Graph

    public init(graph: Graph) {
        self.graph = graph
    }
}

//Helper methods
//Dijkstra’s Algorithm을 구축하는 데 도움이 되는 helper method를 만든다.

//Tracking back to the start //p.400
//현재 정점에서 시작 정점가지의 총 가중치(weight, 여기서는 비용)를 추적하는 매커니즘이 필요하다. 이를 위해 모든 정점에 대해 방문 상태를 저장하는 Dictionary가 필요하다.
extension Dijkstra {
    public func route(to destination: Vertex<T>, with paths: [Vertex<T> : Visit<T>]) -> [Edge<T>] {
        //기존 경로의 dictionary와 함께 대상(목적) 정점을 가져와, 대상 정점으로 연결되는 경로를 구성한다.
        var vertex = destination //대상(목적) 정점에서 시작한다.
        var path: [Edge<T>] = [] //경로를 저장할 간선 Array를 만든다.
        
        while let visit = paths[vertex], case .edge(let edge) = visit { //시작 정점에 도달하지 않는 한, 다음 간선을 계속 추출한다.
            path = [edge] + path //간선을 경로에 추가한다.
            vertex = edge.source //현재 정점을 간선의 source 정점으로 설정한다. 그러면, 시작 정점에 더 가깝게 이동한다.
        }
        
        return path //while loop가 시작 정점에 도달하면, 경로를 완료 한 후 반환한다.
    }
}

//Calculating total distance //p.401
//대상에서 시작 정점까지의 경로를 구성할 수 있으면, 해당 경로의 총 가중치(비용)을 계산할 방법이 필요하다(start to destination).
extension Dijkstra {
    public func distance(to destination: Vertex<T>, with paths: [Vertex<T> : Visit<T>]) -> Double {
        //대상(목적) 정점과 기존 경로의 dictionary를 가져와, 총 가중치(비용)을 반환한다.
        let path = route(to: destination, with: paths) //대상(목적) 정점에 대한 경로를 구성한다.
        let distances = path.compactMap { $0.weight } //compactMap을 사용해, 경로에서 가중치가 없는(nil) 모든 값을 제거한다.
        //compactMap은 map과 동일하게 지정된 변환을 시행하지만, nil인 요소를 제외한다.
        return distances.reduce(0.0, +) //모든 간선의 가중치(비용)을 합산한다.
    }
}

//Generating the shortest paths
extension Dijkstra {
    public func shortestPath(from start: Vertex<T>) -> [Vertex<T> : Visit<T>] {
        //시작 정점을 가져와, 모든 경로의 dictionary를 반환한다.
        var paths: [Vertex<T> : Visit<T>] = [start: .start] //시작 정점으로 초기화 한다.
        var priorityQueue = PriorityQueue<Vertex<T>>(sort: { //방문해야 할 정점을 저장하기 위해 최소 우선 순위 큐를 만든다.
            self.distance(to: $0, with: paths) < self.distance(to: $1, with: paths)
            //이전에 작성한, distance 함수를 사용해 시작 정점으로부터 해당 정점의 거리 순으로 정렬한다.
        })
        priorityQueue.enqueue(start) //방문할 첫 번째 정점으로 시작 정점을 enqueue 한다.
        
        while let vertex = priorityQueue.dequeue() { //모든 정점을 방문할 때 까지 Dijkstra’s Algorithm을 계속 사용하여 최단 경로를 찾는다
            //우선 순위 큐가 비어 있다면 종료된다.
            for edge in graph.edges(from: vertex) { //현재 정점의 모든 간선을 loop 한다.
                guard let weight = edge.weight else { //간선에 가중치(비용)이 있는 지 확인한다.
                    continue
                }
                if paths[edge.destination] == nil || distance(to: vertex, with: paths) + weight < distance(to: edge.destination, with: paths) {
                    //대상(목적) 정점을 방문한 적이 없거나 비용이 더 저렴한 경로를 찾은 경우,
                    paths[edge.destination] = .edge(edge) //경로를 업데이트 한다.
                    priorityQueue.enqueue(edge.destination) //인접 정점(대상, 목적 정점)을 우선 순위 큐에 추가한다.
                }
            }
        }
        return paths
    }
}
//모든 정점을 방문하고 우선 순위 큐가 비어 있다면, 최단 경로의 dictionary를 다시 시작 정점으로 되돌린다.

//Finding a specific path
extension Dijkstra {
    public func shortestPath(to destination: Vertex<T>, paths: [Vertex<T> : Visit<T>]) -> [Edge<T>] {
        return route(to: destination, with: paths)
    }
}
//단순히 대상(목적) 정점과 최단 경로 dictionary를 가져와, 대상 정점에 대한 경로를 반환한다.




//Trying out your code
let graph = AdjacencyList<String>()

let a = graph.createVertex(data: "A")
let b = graph.createVertex(data: "B")
let c = graph.createVertex(data: "C")
let d = graph.createVertex(data: "D")
let e = graph.createVertex(data: "E")
let f = graph.createVertex(data: "F")
let g = graph.createVertex(data: "G")
let h = graph.createVertex(data: "H")

graph.add(.directed, from: a, to: b, weight: 8)
graph.add(.directed, from: a, to: f, weight: 9)
graph.add(.directed, from: a, to: g, weight: 1)
graph.add(.directed, from: b, to: f, weight: 3)
graph.add(.directed, from: b, to: e, weight: 1)
graph.add(.directed, from: f, to: a, weight: 2)
graph.add(.directed, from: h, to: f, weight: 2)
graph.add(.directed, from: h, to: g, weight: 5)
graph.add(.directed, from: g, to: c, weight: 3)
graph.add(.directed, from: c, to: e, weight: 1)
graph.add(.directed, from: c, to: b, weight: 3)
graph.add(.undirected, from: e, to: c, weight: 8)
graph.add(.directed, from: e, to: b, weight: 1)
graph.add(.directed, from: e, to: d, weight: 2)
//위 Example 방향 그래프를 구현한다.

let dijkstra = Dijkstra(graph: graph)
let pathsFromA = dijkstra.shortestPath(from: a) //시장 정점 A에서 모든 정점까지의 최단 경로를 계산한다.
let path = dijkstra.shortestPath(to: d, paths: pathsFromA) //D 까지의 최단 경로를 얻는다.
for edge in path { //해당 경로를 출력한다.
    print("\(edge.source) --|\(edge.weight ?? 0.0)|--> \(edge.destination)")
    // A --|1.0|--> G
    // G --|3.0|--> C
    // C --|1.0|--> E
    // E --|2.0|--> D
}




//Performance
//Dijkstra’s algorithm에서 인접 목록(adjacency list)을 사용하여 그래프를 구성했다. 그리고 최소 우선 순위 큐(min-priority queue)를 사용해 정점을 저장하고, 최소 경로로 정점을 추출한다.
//이 경우 전체 성능은 O(log V)이다. 이는 우선 순위 큐에서 최소 요소를 추출하거나, 요소를 삽입하는 heap 작업에 O(log V)가 필요하기 때문이다.
//너비 우선 탐색(BFS)에서 모든 정점과 간선을 통과하는데 O(V + E)가 필요했다. Dijkstra’s algorithm은 모든 인접 간선을 탐색하기 때문에, BFS와 다소 유사하다.
//하지만, Dijkstra’s algorithm에서는 다음 level로 넘어가는 대신, 최소 우선 순위 큐를 사용하여 최단 거리의 정점을 선택한다. 이것의 시간 복잡도는 O(1 + E) 또는 O(E)가 된다.
//따라서 순회작업과 최소 우선 순위 큐의 작업을 결합한 Dijkstra’s algorithm의 시간 복잡도는 O(E log V)가 된다.




//Key points
// • Dijkstra’s algorithm은 시작 정점에 주어지고, 나머지 node에 대한 경로를 찾는다.
// • 이 알고리즘은 서로 다른 끝점(end point) 사이의 최단 경로를 찾는데 유용하다.
// • Visit의 상태는 간선을 시작 정점으로 다시 추적하는 데 사용된다.
// • 우선 순위 큐(priority queue) 자료구조는 항상 최단 경로의 정점을 반환하는 데 도움이 된다.
// • 따라서, 욕심쟁이 알고리즘(greedy algorithm)이다.
