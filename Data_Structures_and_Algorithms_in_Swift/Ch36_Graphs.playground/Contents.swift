//Chapter 36: Graphs

//SNS와 저가 항공권을 예약하는 것의 공통점은 두 모델 모두 그래프(Graph)로 나타낼 수 있다는 것이다.
//그래프는 객체 간의 관계를 나타내는 자료구조이다. 이는 간선(edge, edges)으로 연결된 정점(vertex, vertices)로 이루어진다. //p.338
//정점은 객체로, 간선은 객체간의 관계로 생각해 구현한다.




//Weighted graphs
//가중 그래프(weighted graph)에는 모든 간선에 이를 사용하는데 필요한 비용 가중치가 있다.
//이를 사용하면, 두 정점 사이에서 가장 저렴하거나 짧은 경로를 선택할 수 있다. ex. 비행 경로 네트워크 //p.339

//Directed graphs
//그래프에 방향이 있을 수 있다. 방향 그래프(유향 그래프, Directed graph, digraph)는 한 방향으로 이동하기 때문에 더 제한적이다. //p.339

//Undirected graphs
//무방향 그래프(무향 그래프, Undirected graph)는 모든 간선이 양방향인 방향 그래프로 생각할 수 있다. //p.340
// • 연결된 두 정점은 앞뒤로 간선을 가진다.
// • 간선의 weight(가중치)는 양방향에 적용된다.




//Common operation
public enum EdgeType {
    case directed
    case undirected
}

public protocol Graph {
    associatedtype Element
    
    func createVertex(data: Element) -> Vertex<Element>
    //정점을 생성하고 그래프에 추가한다.
    func addDirectedEdge(from source: Vertex<Element>, to destination: Vertex<Element>, weight: Double?)
    //두 정점 사이에 방향을 가진 간선을 추가한다.
    func addUndirectedEdge(between source: Vertex<Element>, and destination: Vertex<Element>, weight: Double?)
    //두 정점 사이에 무방향(또는 양방향) 간선을 추가한다.
    func add(_ edge: EdgeType, from source: Vertex<Element>, to destination: Vertex<Element>, weight: Double?)
    //EdgeType을 사용해 두 정점 사이에 방향이 있거나 혹은 무방향의 간선을 추가한다.
    func edges(from source: Vertex<Element>) -> [Edge<Element>]
    //특정 정점에서 출발하는 간선의 목록을 반환한다.
    func weight(from source: Vertex<Element>, to destination: Vertex<Element>) -> Double?
    //두 정점 사이의 간선 weight를 반환한다.
}
//인접 리스트(adjacency list)를 사용하거나 인접 행렬(adjacency matrix)을 사용해 해당 protocol을 구현할 수 있다.




//Defining a vertex
public struct Vertex<T> {
    public let index: Int
    public let data: T
}
//정점(Vertex)는 그래프 내에서 고유한 index를 가지고 있으며, 데이터를 보유한다.
//Dictionary의 key로 정점을 사용하므로, Hashable을 준수해야 한다.
extension Vertex: Hashable where T: Hashable {}
extension Vertex: Equatable where T: Equatable {}
//Hashable protocol은 Equatable부터 상속되므로, Equatable도 구현해야 한다.
//컴파일러는 두 protocol을 준수하도록 합성할 수 있기 때문에, 위의 extension이 비어있다.
//정점에서 CustomStringConvertible를 구현한다.
extension Vertex: CustomStringConvertible {
    public var description: String {
        "\(index): \(data)"
    }
}




//Defining an edge
//간선은 두 정점을 연결한다.
public struct Edge<T> {
    public let source: Vertex<T>
    public let destination: Vertex<T>
    public let weight: Double?
}
//두 개의 정점을 연결하며 weight는 optional이다.




//Adjacency list
//그래프는 인접 리스트(adjacency list) 혹은 인접 행렬(adjacency matrix)을 사용해 구현한다.
//인접 리스트로 구현하는 경우에는 그래프의 모든 정점에 대해 나가는 간선 목록을 저장한다. //p.343
//해당 정보들을 저장하기 위해 dictionary of arrays를 만든다. Dictionary의 각 key는 정점이며, 해당 정점에서 나가는 간선의 Array를 value로 가진다.




//Implementation
public class AdjacencyList<T: Hashable>: Graph { //T는 Dictionary에서 key로 사용되므로 Hashable이어야 한다.
    private var adjacencies: [Vertex<T>: [Edge<T>]] = [:] //Dictionary에서 각 정점에서의 나가는 간선을 저장한다.
    public init() {}
}

//Creating a vertex
//Graph protocol의 요구사항을 구현한다.
extension AdjacencyList {
    public func createVertex(data: T) -> Vertex<T> { //새 정점을 생성하고 반환한다.
        let vertex = Vertex(index: adjacencies.count, data: data)
        adjacencies[vertex] = [] //새 정점과 인접한 간선들의 목록을 빈 Array로 설정해 준다.
        return vertex
    }
}

//Creating a directed edge
//방향 그래프와 무방향 그래프가 있다는 것을 생각해야 한다.
extension AdjacencyList {
    public func addDirectedEdge(from source: Vertex<T>, to destination: Vertex<T>, weight: Double?) { //새 간선을 생성하고, 출발 정점의 인접 리스트에 저장한다.
        let edge = Edge(source: source, destination: destination, weight: weight)
        adjacencies[source]?.append(edge)
    }
}

//Creating an undirected edge
//무방향 그래프는 양방향 그래프로 생각할 수 있다. 무방향 그래프의 모든 간선은 양방향이다. 이것이 addDirectedEdge(from:to:weight:)를 먼저 작성한 이유이다.
//addDirectedEdge(from:to:weight:)를 재사용해, addUndirectedEdge(between:and:weight:)를 구현할 수 있다.
extension Graph { //AdjacencyList이 아닌 Graph에서 구현한다.
    public func addUndirectedEdge(between source: Vertex<Element>, and destination: Vertex<Element>, weight: Double?) { //무방향 간선을 추가한다.
        addDirectedEdge(from: source, to: destination, weight: weight)
        addDirectedEdge(from: destination, to: source, weight: weight)
    }
    //무방향 간선을 추가하는 것은 두 개의 방향 간선을 추가하는 것과 같다.
}
//addDirectedEdge와 addUndirectedEdge를 구현했으므로, 둘 중 하나의 메서드를 사용해 add를 구현할 수 있다.
extension Graph {
    public func add(_ edge: EdgeType, from source: Vertex<Element>, to destination: Vertex<Element>, weight: Double?) {
        switch edge {
        case .directed:
            addDirectedEdge(from: source, to: destination, weight: weight)
        case .undirected:
            addUndirectedEdge(between: source, and: destination, weight: weight)
        }
    }
}
//구체적인 구현은 addDirectedEdge와 addUndirectedEdge에 위임한다.
//Graph 프로토콜을 구현할 때 addDirectedEdge만 구현하면, aaddUndirectedEdge와 add도 사용할 수 있게 된다.

//Retrieving the outgoing edges from a vertex
extension AdjacencyList {
     public func edges(from source: Vertex<T>) -> [Edge<T>] { //해당 정점에서 출발하는 간선들의 목록을 반환한다.
        adjacencies[source] ?? []
    }
}

//Retrieving the weight of an edge
extension AdjacencyList {
    public func weight(from source: Vertex<T>, to destination: Vertex<T>) -> Double? { //weight를 반환한다.
        edges(from: source) //해당 정점에서
            .first { $0.destination == destination }? //첫 번째 간선을 가져온다. weight가 있다면(가중 그래프) 각 정점을 연결하는 간선은 하나여야 한다.
            .weight
    }
}

//Visualizing the adjacency list
//그래프에 대한 출력을 추가한다.
extension AdjacencyList: CustomStringConvertible {
    public var description: String {
        var result = ""
        for (vertex, edges) in adjacencies { //인접한 모든 key-value 쌍을 반복한다.
            var edgeString = ""
            for (index, edge) in edges.enumerated() { //모든 정점에서 나가는 모든 간선을 반복하고, 출력 문자열에 추가한다.
                if index != edges.count - 1 {
                    edgeString.append("\(edge.destination), ")
                } else {
                    edgeString.append("\(edge.destination)")
                }
            }
            result.append("\(vertex) ---> [ \(edgeString) ]\n") //정점마다 정점 자체와 나가는 간선을 모두 출력한다.
        }
        return result
    }
}

//Building a network
//가중치가 있는 항공 네트워크를 구성해 본다. //p.349
let graphList = AdjacencyList<String>()
let singapore1 = graphList.createVertex(data: "Singapore")
let tokyo1 = graphList.createVertex(data: "Tokyo")
let hongKong1 = graphList.createVertex(data: "Hong Kong")
let detroit1 = graphList.createVertex(data: "Detroit")
let sanFrancisco1 = graphList.createVertex(data: "San Francisco")
let washingtonDC1 = graphList.createVertex(data: "Washington DC")
let austinTexas1 = graphList.createVertex(data: "Austin Texas")
let seattle1 = graphList.createVertex(data: "Seattle")
graphList.add(.undirected, from: singapore1, to: hongKong1, weight: 300)
graphList.add(.undirected, from: singapore1, to: tokyo1, weight: 500)
graphList.add(.undirected, from: hongKong1, to: tokyo1, weight: 250)
graphList.add(.undirected, from: tokyo1, to: detroit1, weight: 450)
graphList.add(.undirected, from: tokyo1, to: washingtonDC1, weight: 300)
graphList.add(.undirected, from: hongKong1, to: sanFrancisco1, weight: 600)
graphList.add(.undirected, from: detroit1, to: austinTexas1, weight: 50)
graphList.add(.undirected, from: austinTexas1, to: washingtonDC1, weight: 292)
graphList.add(.undirected, from: sanFrancisco1, to: washingtonDC1, weight: 337)
graphList.add(.undirected, from: washingtonDC1, to: seattle1, weight: 277)
graphList.add(.undirected, from: sanFrancisco1, to: seattle1, weight: 218)
graphList.add(.undirected, from: austinTexas1, to: sanFrancisco1, weight: 297)
print(graphList)
// 0: Singapore ---> [ 2: Hong Kong, 1: Tokyo ]
// 4: San Francisco ---> [ 2: Hong Kong, 5: Washington DC, 7: Seattle, 6: Austin Texas ]
// 1: Tokyo ---> [ 0: Singapore, 2: Hong Kong, 3: Detroit, 5: Washington DC ]
// 3: Detroit ---> [ 1: Tokyo, 6: Austin Texas ]
// 6: Austin Texas ---> [ 3: Detroit, 5: Washington DC, 4: San Francisco ]
// 5: Washington DC ---> [ 1: Tokyo, 6: Austin Texas, 4: San Francisco, 7: Seattle ]
// 2: Hong Kong ---> [ 0: Singapore, 1: Tokyo, 4: San Francisco ]
// 7: Seattle ---> [ 5: Washington DC, 4: San Francisco ]
//각 도시에서 출발하는 항공편을 명확하게 확인해 볼 수 있다. 추가적으로 다음과 같은 정보를 얻을 수도 있다.
// • 싱가포르 발 도쿄행 비행편의 요금
graphList.weight(from: singapore1, to: tokyo1) // 500
// • 샌프란시스코에서 출발하는 모든 항공편
print("San Francisco Outgoing Flights:")
print("--------------------------------")
for edge in graphList.edges(from: sanFrancisco1) {
    print("from: \(edge.source) to: \(edge.destination)")
}
// from: 4: San Francisco to: 2: Hong Kong
// from: 4: San Francisco to: 5: Washington DC
// from: 4: San Francisco to: 7: Seattle
// from: 4: San Francisco to: 6: Austin Texas




//Adjacency matrix
//인접 행렬(adjacency matrix)은 사각형 행렬을 사용해 그래프를 나타낸다. 이 행렬은 2차원 Array 이며, matrix[row][column]의 값은 행(row)과 열(column) 정점 사이의 접선 weight 이다.
//가중치(비용)이 있는 항공 네트워크를 인접 행렬로 나타낼 수 있다. //p.351
//존재하지 않는 간선은 가중치도 없으므로 인접행렬에서 0으로 표시한다. 인접 리스트(adjacency list)보다 읽기가 좀 더 힘들다.
//행과 열이 같다면, 정점과 그 자신의 접선을 의미하는데, 이는 허용되지 않으므로 0이 된다.




//Implementation
public class AdjacencyMatrix<T>: Graph {
    private var vertices: [Vertex<T>] = [] //정점
    private var weights: [[Double?]] = [] //가중치
    
    public init() {}
}
//Graph의 요구사항을 구현해야 한다.

//Creating a Vertex
extension AdjacencyMatrix {
    public func createVertex(data: T) -> Vertex<T> {
        let vertex = Vertex(index: vertices.count, data: data)
        vertices.append(vertex) //새 정점을 Array에 추가한다.
        for i in 0..<weights.count { //현재 정점 중 어느 것도 새 정점에 간선을 가지지 않으므로, 가중치 행렬에 weight를 nil로 추가한다. //p.353
            weights[i].append(nil)
        }
        let row = [Double?](repeating: nil, count: vertices.count) //행렬에 새 행을 추가한다. 이 행(row)는 생성한 새 정점에서 나가는 간선들이다. //p.354
        weights.append(row)
        return vertex
    }
}

//Creating edges
//간선을 만드는 것을 행렬을 채우는 것과 같다.
extension AdjacencyMatrix {
    public func addDirectedEdge(from source: Vertex<T>, to destination: Vertex<T>, weight: Double?) {
        weights[source.index][destination.index] = weight
    }
}
//addUndirectedEdge과 add는 Graph의 extension에서 addDirectedEdge를 사용하도록 구현했다. 따라서 addDirectedEdge만 구현하면, addUndirectedEdge과 add도 사용할 수 있다.

//Retrieving the outgoing edges from a vertex
extension AdjacencyMatrix {
    public func edges(from source: Vertex<T>) -> [Edge<T>] { //해당 정점에서 나가는 간선의 목록을 반환한다.
        var edges: [Edge<T>] = []
        for column in 0..<weights.count {
            if let weight = weights[source.index][column] { //정점에서 나가는 간선을 찾으려면, 행렬에서 해당 정점의 행을 검색하여 가중치(weight)가 nil이 아닌 것을 찾아야 한다.
                edges.append(Edge(source: source, destination: vertices[column], weight: weight))
                //해당 가중치를 가진 간선의 도착지는 가중치의 열(column)이다.
            }
        }
        return edges
    }
}

//Retrieving the weight of an edge
//간선의 weight는 해당 인접 행렬의 값과 같다.
extension AdjacencyMatrix {
    public func weight(from source: Vertex<T>, to destination: Vertex<T>) -> Double? {
        weights[source.index][destination.index]
    }
}

//Visualize an adjacency matrix
//그래프에 대한 출력을 추가한다.
extension AdjacencyMatrix: CustomStringConvertible {
    public var description: String {
        let verticesDescription = vertices.map { "\($0)" }.joined(separator: "\n") //정점의 목록을 만든다.
        var grid: [String] = []
        for i in 0..<weights.count { //행별로 가중치 그리드를 구성한다.
            var row = ""
            for j in 0..<weights.count {
                if let value = weights[i][j] {
                    row += "\(value)\t"
                } else {
                    row += "ø\t\t"
                }
            }
            grid.append(row)
        }
        let edgesDescription = grid.joined(separator: "\n")
        return "\(verticesDescription)\n\n\(edgesDescription)" //정점의 목록의 설명글과 가중치 그리드의 설명글을 결합해 반환한다.
    }
}

//Building a network
//AdjacencyList에서 사용한 동일한 예로 그래프를 작성한다. //p.356
let graphMatrix = AdjacencyMatrix<String>()
let singapore2 = graphMatrix.createVertex(data: "Singapore")
let tokyo2 = graphMatrix.createVertex(data: "Tokyo")
let hongKong2 = graphMatrix.createVertex(data: "Hong Kong")
let detroit2 = graphMatrix.createVertex(data: "Detroit")
let sanFrancisco2 = graphMatrix.createVertex(data: "San Francisco")
let washingtonDC2 = graphMatrix.createVertex(data: "Washington DC")
let austinTexas2 = graphMatrix.createVertex(data: "Austin Texas")
let seattle2 = graphMatrix.createVertex(data: "Seattle")
graphMatrix.add(.undirected, from: singapore2, to: hongKong2, weight: 300)
graphMatrix.add(.undirected, from: singapore2, to: tokyo2, weight: 500)
graphMatrix.add(.undirected, from: hongKong2, to: tokyo2, weight: 250)
graphMatrix.add(.undirected, from: tokyo2, to: detroit2, weight: 450)
graphMatrix.add(.undirected, from: tokyo2, to: washingtonDC2, weight: 300)
graphMatrix.add(.undirected, from: hongKong2, to: sanFrancisco2, weight: 600)
graphMatrix.add(.undirected, from: detroit2, to: austinTexas2, weight: 50)
graphMatrix.add(.undirected, from: austinTexas2, to: washingtonDC2, weight: 292)
graphMatrix.add(.undirected, from: sanFrancisco2, to: washingtonDC2, weight: 337)
graphMatrix.add(.undirected, from: washingtonDC2, to: seattle2, weight: 277)
graphMatrix.add(.undirected, from: sanFrancisco2, to: seattle2, weight: 218)
graphMatrix.add(.undirected, from: austinTexas2, to: sanFrancisco2, weight: 297)
print(graphMatrix)
// 0: Singapore
// 1: Tokyo
// 2: Hong Kong
// 3: Detroit
// 4: San Francisco
// 5: Washington DC
// 6: Austin Texas
// 7: Seattle
//
// ø        500.0    300.0    ø        ø        ø        ø        ø
// 500.0    ø        250.0    450.0    ø        300.0    ø        ø
// 300.0    250.0    ø        ø        600.0    ø        ø        ø
// ø        450.0    ø        ø        ø        ø        50.0    ø
// ø        ø        600.0    ø        ø        337.0    297.0    218.0
// ø        300.0    ø        ø        337.0    ø        292.0    277.0
// ø        ø        ø        50.0    297.0    292.0    ø        ø
// ø        ø        ø        ø        218.0    277.0    ø        ø
//다음과 같은 추가정보들을 얻을 수도 있다.
// • 싱가포르 발 도쿄행 비행편의 요금
graphMatrix.weight(from: singapore2, to: tokyo2) // 500
// • 샌프란시스코에서 출발하는 모든 항공편
print("San Francisco Outgoing Flights:")
print("--------------------------------")
for edge in graphMatrix.edges(from: sanFrancisco2) {
  print("from: \(edge.source) to: \(edge.destination)")
}
// from: 4: San Francisco to: 2: Hong Kong
// from: 4: San Francisco to: 5: Washington DC
// from: 4: San Francisco to: 6: Austin Texas
// from: 4: San Francisco to: 7: Seattle
//AdjacencyMatrix와 AdjacencyList는 동일한 Graph 프로토콜을 준수하므로, 나머지 코드는 동일하게 유지된다.
//adjacency list를 사용한 구현이, adjacency matrix를 사용한 구현 보다, 추적하기 훨씬 더 쉽다.




//Graph analysis
//구현 방법에 따른 그래프의 요약은 다음과 같다. //p.358
//Operations            | Adjacency List             | Adjacency Matrix
//-----------------------------------------------------------------------
//Storage Space         | O(V + E)                   | O(V^2)
//Add Vertex            | O(1)                       | O(V^2)
//Add Edge              | O(1)                       | O(1)
//Find Edges and Weight | O(V)                       | O(1)
//여기서 V는 정점(vertex)를, E는 간선(Edge)를 나타낸다.
//Adjacency List는 Adjacency Matrix보다 저장 공간을 적게 사용한다. Adjacency List은 단순히 필요한 정점과 간선의 수를 저장한다.
//Adjacency Matrix에서 행(row)과 열(column)의 수가 정점의 수와 같다. 따라서 공간 복잡도는 O(V^2)가 된다.
//Adjacency List에서 정점을 추가하는 것은 효율적이다. 정점을 만들고 dictionary에 key-value 쌍을 설정하므로, O(1)이다.
//Adjacency Matrix에서 정점을 추가할 때는 모든 행(row)에 열(column)을 추가하고, 새 정점에 대한 새로운 행(row)을 만들어야 한다.
//이 작업은 최소 O(V)이며, 연속된 메모리 공간에 행렬을 나타내도록 한 경우에는 O(V^2)일 수 있다.
//간선 추가는 두 자료구조에서 모두 constant time이므로 효율적이다. Adjacency List에서는 나가는 간선 Array로 추가된다. Adjacency Matrix에서는 2차원 배열의 값이다.
//특정 간선(Edge)이나 가중치(weight)를 찾아야 할 때, Adjacency List는 비효율적이다.
//Adjacency List에서 간선을 찾으려면, 나가는 간선 목록을 가져온 후에, 모든 간선을 반복하여 일치하는 대상을 찾아야 한다. 이는 O(V)이다.
//Adjacency Matrix의 경우, 간선 또는 가중치를 찾는 것은 2차원 배열에서 해당 값에 접근하는 것이므로 constant time이다.
//그래프에 간선이 거의 없는 경우, 희소 그래프(sparse graph)라 하며, 이 경우에는 Adjacency List를 사용하여 구현하는 것이 효과적이다.
//Adjacency Matrix로 구현하면, 간선이 많지 않아 많은 메모리가 낭비된다.
//그래프에 간선이 많은 경우, 밀집 그래프(dense graph)라 하며, 이 경우에는 가중치와 간선에 빨리 액세스할 수 있는 Adjacency Matrix로 구현하는 것이 더 적합하다.
//https://ko.wikipedia.org/wiki/%EB%B0%80%EC%A7%91_%EA%B7%B8%EB%9E%98%ED%94%84
