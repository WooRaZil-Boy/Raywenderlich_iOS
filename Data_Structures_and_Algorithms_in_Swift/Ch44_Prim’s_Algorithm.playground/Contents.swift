// Copyright (c) 2019 Razeware LLC
// For full license & permission details, see LICENSE.markdown.

//Chapter 44: Prim’s Algorithm

//이전 장에서는 BFS와 DFS를 살펴봤다. 이 알고리즘들은 신장 트리(spanning tree) 이다.
//신장 트리는 무방향 그래프 중 하나로, 최소 간선 수로 모든 정점을 연결한다. 신장 트리는 cycle을 포함할 수 없으며, 단절 될 수 없다(최소 연결 부분 그래프).
//https://ko.wikipedia.org/wiki/%EC%8B%A0%EC%9E%A5_%EB%B6%80%EB%B6%84_%EA%B7%B8%EB%9E%98%ED%94%84
//https://gmlwjd9405.github.io/2018/08/28/algorithm-mst.html
//다음은 신장 트리(spanning tree)의 예이다. //p.410
//위와 같이 3개의 서로 다른 신장 트리를 생성할 수 있으며, 모든 정점을 연결하는 데 2개의 간선만 있으면 된다.
//이 장에서는 최소 신장트리(minimum spanning tree)를 구성하는 데 사용되는 욕심쟁이 알고리즘(greedy algorithm)인 프림 알고리즘(Prim’s algorithm)을 살펴본다.
//욕심쟁이 알고리즘은 단계별로 해결책을 탐색하고, 각 단계마다 최적의 경로를 선택한다(각 단계마다 해당 시점에서 최대 이익이 되는 해결책을 선택한다).
//최소 신장 트리는 선택된 간선의 총 가중치(비용)을 최소화하는 신장 트리이다. //ex. 수도관 네트워크를 구축하는 가장 저렴한 방법 찾기
//가중 무 방향 그래프에 대한 최소 신장 트리의 예는 다음과 같다. //p.410
//최소 비용은 3이므로, 마지막 그래프만이 최소 신장 트리가 된다.
//프림 알고리즘은 한 번에 하나씩 간선을 선택해 최소 신장 트리를 만든다. 간선을 선택할 때마다 정점 쌍을 연결하는 최소 비용의 간선을 선택하기 때문에 욕심쟁이 알고리즘이다.
//Prim’s Algorithm으로 최소 신장 트리를 찾는 6가지 단계가 있다. //p.411
// 1. 네트워크가 주어진다.
// 2. 한 정점을 선택한다.
// 3. 해당 정점에서 최소 비용의 간선을 선택한다.
// 4. solution에 없는 가장 가까운 인접 정점을 선택한다(아직 방문하지 않은 가장 가까운 정점을 선택한다).
// 5. 다음으로 가장 가까운 인접 정점에 동일한 비용을 가진 두 개의 간선이 있다면, 어느 하나를 선택한다.
// 6. 1 - 5를 반복해서 모든 정점을 방문하면, 최소 신장 트리가 완성된다.




//Example
//해당 그래프는 공항 네트워크를 나타낸다. //p.411
//정점은 공항이며, 그 사이 간선은 비행 시의 연료 비용을 나타낸다.
// 1. 그래프에서 정점을 선택한다. 정점 2가 선택되었다고 가정한다.
// 2. 이 정점에는 비용이 [6, 5, 3]인 간선이 있다. 욕심쟁이 알고리즘은 가장 작은 비용의 간선을 선택한다.
// 3. 따라서, 목적지가 정점 5인 비용 3의 간선을 선택한다.
//정점 2와 정점 5를 연결한다.
// 1. 탐색된 정점은 {2, 5} 이다.
// 2. 탐색된 정점에서 다음으로 가장 비용이 적은 간선을 선택한다. 각 비용이 [6, 5, 6, 6]인 간선들이 있다. 정점 3에 연결된 비용 5의 간선을 선택한다.
// 3. 정점 5와 정점 3 사이의 간선은 이미 신장 트리의 일부이므로 고려 대상에서 제거해 줄 수 있다.
//정점 2와 정점 3을 연결한다.
// 1. 탐색된 정점은 {2, 3, 5} 이다.
// 2. 다음 가능한 간선들의 비용은 [6, 1, 5, 4, 6]이다. 정점 1에 연결된 비용이 1인 간선을 선택한다.
// 3. 정점 2와 정점 1 사이의 간선을 제거할 수 있다(이미 신장 트리의 일부).
//정점 3과 정점 1을 연결한다.
// 1. 탐색된 정점은 {2, 3, 5, 1} 이다.
// 2. 탐색된 정점에서 가장 비용이 적은 다음 간선을 선택한다. 각 비용이 [5, 5, 4, 6]인 간선들이 있다. 정점 6에 연결된 비용 4의 간선을 선택한다.
// 3. 정점 5와 정점 6 사이의 간선을 제거할 수 있다(이미 신장 트리의 일부).
//정점 3과 정점 6을 연결한다.
// 1. 탐색된 정점은 {2, 3, 5, 1, 6} 이다.
// 2. 탐색된 정점에서 가장 비용이 적은 다음 간선을 선택한다. 각 비용이 [5, 5, 2]인 간선들이 있다. 정점 4에 연결된 비용 2의 간선을 선택한다.
// 3. 정점 1과 정점 4(비용 5), 정점 1과 정점 3(비용 5)에 연결된 간선을 제거할 수 있다(이미 신장 트리의 일부).
//모든 간선의 비용이 같으면 그 중 하나를 선택할 수 있다.
//Prim’s Algorithm으로 생성된 최소 신장 트리는 위와 같다. 코드로 이를 구현한다.




//Implementation
//최소 우선 순위 큐(min- priority queue)는 탐색된 정점의 간선을 저장하는 데 사용된다. 최소 우선 순위 큐는 최소 비용의 간선을 dequeue 한다.
public class Prim<T: Hashable> {
    public typealias Graph = AdjacencyList<T> //AdjacencyList를 typealias로 정의 된다. 필요한 경우 인접 행렬(adjacency matrix)로 바꿀 수 있다.
    public init() {}
}

//Helper methods
//알고리즘을 구축하기 전에 중복 코드를 체계적으로 정리하고 통합할 수 있는 몇 가지 helper method를 만든다.

//Copying a graph
//최소 신장 트리는 원본 그래프의 모든 정점을 포함해야 한다.
extension AdjacencyList {
    public func copyVertices(from graph: AdjacencyList) { //모든 정점이 새로운 그래프에 복사된다.
        for vertex in graph.vertices {
            adjacencies[vertex] = []
        }
    }
}

//Finding edges
//그래프의 정점을 복사하는 것 외에에도, 탐색하는 모든 정점의 간선을 찾아 저장해야 한다.
extension Prim {
    internal func addAvailableEdges(for vertex: Vertex<T>, in graph: Graph, check visited: Set<Vertex<T>>, to priorityQueue: inout PriorityQueue<Edge<T>>) {
        //4개의 매개변수를 사용한다.
        //1. 현재 정점, 2. 현재 정점을 포함하고 있는 그래프, 3. 방문한 정점 set, 4. 가능한 인접 간선을 추가하는 우선 순위 큐
        for edge in graph.edges(from: vertex) { //현재 정점에 인접한 모든 간선을 가져와 반복한다.
            if !visited.contains(edge.destination) { //간선의 목적 정점이 이미 방문한 적 있는 지 확인한다.
                priorityQueue.enqueue(edge) //방문 한 적 없는 경우, 우선 순위 큐에 간선을 추가한다.
            }
        }
    }
}

//Producing a minimum spanning tree
extension Prim {
    public func produceMinimumSpanningTree(for graph: Graph) -> (cost: Double, mst: Graph) {
        //무 방향 그래프를 매개변수로 받아, 최소 신장 트리와 그 비용을 반환한다.
        var cost = 0.0 //최소 신장 트리에서 간선의 총 비용을 추적한다.
        let mst = Graph() //최소 신장 트리가 될 그래프이다.
        var visited: Set<Vertex<T>> = [] //방문한 모든 정점을 저장한다.
        var priorityQueue = PriorityQueue<Edge<T>>(sort: { //간선을 저장하는 최소 우선 순위 큐(min-priority queue)
            $0.weight ?? 0.0 < $1.weight ?? 0.0 //비용이 적을 수록 먼저 dequeue 된다.
        })
        
        mst.copyVertices(from: graph) //원본 그래프의 모든 정점을 최소 신장 트리로 복사한다.
        
        guard let start = graph.vertices.first else { //그래프의 시작 정점을 얻는다.
            return (cost: cost, mst: mst)
        }
        
        visited.insert(start) //시작 정점을 방문한 것으로 표시한다.
        addAvailableEdges(for: start, in: graph, check: visited, to: &priorityQueue)
        //잠재적인 간선(시작 정점과 연결된 모든 간선 중 방문하지 않은 간선)을 우선 순위 큐에 추가한다.
        
        while let smallestEdge = priorityQueue.dequeue() { //우선 순위 큐가 빌 때까지 Prim’s Algorithm을 반복한다.
            let vertex = smallestEdge.destination //목적지 정점을 가져온다.
            guard !visited.contains(vertex) else { //이 정점을 방문한 경우
                continue //loop를 다시 시작한다. priorityQueue에서 다음으로 비용이 적은 간선이 dequeue된다.
            }
            visited.insert(vertex) //목적지 정점을 방문한 것으로 표시한다.
            cost += smallestEdge.weight ?? 0.0 //총 비용에 간선의 비용을 추가한다.
            
            mst.add(.undirected, from: smallestEdge.source, to: smallestEdge.destination, weight: smallestEdge.weight)
            //구성 중인 최소 신장 트리에 앞에서 찾은 최소 비용 간선을 추가한다.
            addAvailableEdges(for: vertex, in: graph, check: visited, to: &priorityQueue)
            //현재 정점(목적지 정점)에서 잠재적인 간선(시작 정점과 연결된 모든 간선 중 방문하지 않은 간선)을 우선 순위 큐에 추가한다.
        }
        
        return (cost: cost, mst: mst) //우선 순위 큐가 비어 loop가 종료되면, 최소 비용 및 최소 신장 트리를 반환한다.
    }
}




//Testing your code
var graph = AdjacencyList<Int>()
let one = graph.createVertex(data: 1)
let two = graph.createVertex(data: 2)
let three = graph.createVertex(data: 3)
let four = graph.createVertex(data: 4)
let five = graph.createVertex(data: 5)
let six = graph.createVertex(data: 6)

graph.add(.undirected, from: one, to: two, weight: 6)
graph.add(.undirected, from: one, to: three, weight: 1)
graph.add(.undirected, from: one, to: four, weight: 5)
graph.add(.undirected, from: two, to: three, weight: 5)
graph.add(.undirected, from: two, to: five, weight: 3)
graph.add(.undirected, from: three, to: four, weight: 5)
graph.add(.undirected, from: three, to: five, weight: 6)
graph.add(.undirected, from: three, to: six, weight: 4)
graph.add(.undirected, from: four, to: six, weight: 2)
graph.add(.undirected, from: five, to: six, weight: 6)

print(graph)
//Example 그래프를 구성한다.
let (cost, mst) = Prim().produceMinimumSpanningTree(for: graph)
print("cost: \(cost)") // cost: 15.0
print("mst:")
print(mst)
// 5 ---> [ 2 ]
// 6 ---> [ 3, 4 ]
// 3 ---> [ 2, 1, 6 ] 1 ---> [ 3 ]
// 2 ---> [ 5, 3 ]
// 4 ---> [ 6 ]




//Performance
//위의 알고리즘은에서 세 가지 자료구조를 유지한다.
// 1. 최소 신장 트리를 작성하기 위한 인접 목록 리스트(adjacency list graph).
//  인접 목록에 정점과 간선을 추가하는 것은 O(1)이다.
// 2. 방문한 모든 정점을 저장하는 집합(Set).
//  Set에 정점을 추가하고, 해당 정점이 Set에 포함되어 있는지 확인하는 것은 O(1)이다.
// 3. 정점 탐색을 위해 간선을 저장하는 최소 우선 순위 큐(min-priority queue)
//  우선 순위 큐는 Heap으로 구성되며, 삽입에 O(log E)가 필요하다.
//Prim’s Algorithm에서 최악의 경우에는 시간복잡도가 O(E log E)이다.
//우선 순위 큐에서 최소 비용 간선을 dequeue할 때마다, 대상 정점의 모든 간선을 통과하고(O(E)) 간선을 우선 순위 큐에 삽입(O(log E))해야 하기 때문이다.




//Key points
// • 신장 트리는 무방향 그래프의 하위 그래프로, 최소의 간선으로 모든 정점을 연결한다.
// • Prim’s Algorithm은 최소 신장 트리를 구성하는 욕심쟁이 알고리즘이다.
// • Prim’s Algorithm을 구성하기 위해 우선 순위 큐(Priority queue), 집합(Set), 인접 리스트(Adjacency List) 세 가지 자료 구조를 활용한다.
