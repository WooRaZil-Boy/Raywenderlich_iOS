// Copyright (c) 2019 Razeware LLC
// For full license & permission details, see LICENSE.markdown.

/*:
 # Prim's Algorithm Challenges
 
 ## 1. Construct a MST with points
 
 Given a set of points, construct a minimum spanning tree connecting the points into a graph.
 ![Graph](challenge1.png)
 */
//주어진 좌표를 그래프(Graph)로 연결하는 최소 신장 트리(Minimum spanning tree)를 구성한다.




import UIKit
//점들을 그래프에서의 정점(vertex, vertices)으로 생각할 수 있다.
//최소 신장 트리를 구성하려면, 먼저 두 정점 사이 간선(edge)의 가중치를 알아야 한다.
//Vertex는 Hashable이어야 한다. CGPoint를 extension해 구현한다.
extension CGPoint: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(x)
    hasher.combine(y)
  }
}

//모든 정점은 CGPoint를 가지고 있다. 다른 정점에 대한 간선을 형성하려면, 정점 사이의 거리를 계산해야 한다.
extension CGPoint {
    func distanceSquared(to point: CGPoint) -> CGFloat { //각 변의 제곱을 더하여 빗변의 제곱 값을 계산한다.
        let xDistance = (x - point.x)
        let yDistance = (y - point.y)
        
        return xDistance * xDistance + yDistance * yDistance
    }
    
    func distance(to point: CGPoint) -> CGFloat { //제곱근으로 빗변의 길이를 반환한다.
        distanceSquared(to: point).squareRoot()
    }
}
//두 점 사이의 거리를 계산했으므로, 최소 신장 트리 구성할 수 있다.
//최소 신장 트리를 구성하는 방법은 임의의 정점을 선택하고, 모든 정점이 간선으로 연결될 때까지 가장 가중치가 높은(비용이 낮은) 이웃 간선을 선택한다(욕심쟁이 알고리즘).
//프림 알고리즘을 사용하려면, 주어진 점 set를 완전 그래프(complete graph)로 형성해야 한다. 완전 그래프는 모든 정점 쌍이 고유한 간선으로 연결된 무향 그래프이다.
//ex. 5개의 정점이 있는 오각형. 각 정점은 별 모양을 형성하며 다른 정점으로 연결된다.
extension Prim where T == CGPoint { //요소가 CGPoint이어야 한다.
    public func createCompleteGraph(with points: [CGPoint]) -> Graph {
        let completeGraph = Graph() //비어있는 새 그래프 생성
        
        points.forEach { point in //각 점을 순회하여 정점을 만든다.
            completeGraph.createVertex(data: point)
        }
        
        //각 정점을 반복하면서, 해당 정점이 아니라면, 다른 정점을 반복한다.
        completeGraph.vertices.forEach { currentVertex in
            completeGraph.vertices.forEach { vertex in
                if currentVertex != vertex {
                    let distance = Double(currentVertex.data.distance(to: vertex.data)) //두 정점 사이의 거리 계산
                    completeGraph.addDirectedEdge(from: currentVertex, to: vertex, weight: distance)
                    //두 정점 사이에 유향 간선을 추가한다.
                }
            }
        }
        return completeGraph //완성된 그래프를 반환한다.
    }
}

//완전 그래프를 생성하고, 프림 알고리즘을 사용해 최소 신장 트리를 만들 수 있다.
extension Prim where T == CGPoint {
  
  public func produceMinimumSpanningTree(with points: [CGPoint]) -> (cost: Double, mst: Graph) {
    let graph = Graph()
    // Implement solution
    return produceMinimumSpanningTree(for: graph)
  }
}

let points = [CGPoint(x: 4, y: 0), // 0
              CGPoint(x: 6, y: 16), // 1
              CGPoint(x: 10, y: 1), // 2
              CGPoint(x: 3, y: 17), // 3
              CGPoint(x: 18, y: 7), // 4
              CGPoint(x: 5, y: 14)] // 5

let (cost,mst) = Prim().produceMinimumSpanningTree(with: points)

print(mst)
print(cost)

//샘플은 다음과 같다.
//: ### Sample Test Case
//: ![Table](challenge1_final.png)

