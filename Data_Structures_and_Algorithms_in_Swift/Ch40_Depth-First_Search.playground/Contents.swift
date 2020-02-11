// Copyright (c) 2019 Razeware LLC
// For full license & permission details, see LICENSE.markdown.

//Chapter 40: Depth-First Search

//이전 장에서 다음 level로 가기 전에 해당 정점의 모든 인접 정점을 탐색해야 하는 너비 우선 탐색(Breadth-First Search, BFS)을 살펴 보았다.
//이 장에서는 그래프를 탐색하거나 검색하기 위한 또 다른 알고리즘인 깊이 우선 탐색(Depth-First Search, DFS)를 살펴 본다.
//DFS는 다음과 같은 문제를 해결하는 프로그램 작성에 사용할 수 있다.
// • 위상 정렬(Topological sorting)
//  위상 정렬은 방향 그래프의 정점이 간선의 방향을 거스르지 않도록 나열하는 것을 의미한다. //ex. 선수과목이 있는 대학 과목
//  https://ko.wikipedia.org/wiki/%EC%9C%84%EC%83%81%EC%A0%95%EB%A0%AC
// • 사이클(Cycle) 감지
// • 미로 퍼즐(maze puzzle)과 같은 경로 찾기
// • 희소 그래프(sparse graph, 간선이 얼마 없는 그래프)에서 연결된 구성 요소 찾기
//DFS를 수행하려면, 주어진 source 정점에서 시작하여 끝까지 도달할 때까지 가능한 멀리 하나의 분기를 탐색해야 한다.
//원하는 정점을 찾거나, 모든 정점을 방문할 때까지 역추적(backtrack, 한 단계 뒤로 이동한다)한 후, 가능한 다음 정점을 탐색한다.




//Example
//이전 장과 같은 Graph를 예로 사용한다. 이를 통해 BFS 와 DFS의 차이점을 알 수 있다. //p.378
//: ![sampleGraph](sampleGraph.png)
//DFS에서는 Stack을 사용해, 이동하는 level을 추적한다. Stack의 후입선출(last-in-first-out) 특성은 backtracking에 도움이 된다.
//Stack에 push할 때마다, 한 level 더 깊이 이동한 것을 의미한다. 막 다른 경로에 도달하면, pop 해서 이전 level로 돌아갈 수 있다.
// 1. 이전 BFS 구현과 같이, 시작 정점으로 A를 선택한다. A를 stack에 추가한다.
// 2. Stack이 비어 있지 않다면, Stack에서 가장 위의 정점을 방문하고, 해당 정점에서 아직 방문하지 않은 첫 번째 인접 정점을 push한다.
//  이 경우에는 A를 방문하고, B를 push한다.
//  이제, Stack은 [A, B]가 된다.
//  간선을 추가한 순서가 검색 결과에 영향을 미친다. 이 경우에는 A에 추가된 첫 번째 간선은 B를 연결하는 간선이므로 B가 먼저 push 된다.
// 3. A는 이미 방문했으므로, B를 방문하고 E를 Stack에 push한다.
//  이제, Stack은 [A, B, E]가 된다.
// 4. E를 방문하고, F를 Stack에 push한다.
//  이제, Stack은 [A, B, E, F]가 된다.
//  Stack에 push할 때마다, 해당 분기를 더 멀리 탐색하게 된다.
//  인접한 모든 정점을 방문하는 대신(BFS), 끝에 도달할 때까지 경로를 따라가고, 막다른 곳에 도달하면 backtrack해 다음 경로를 검색하면 된다(DFS).
// 5. F를 방문하고, G를 Stack에 push한다.
//  이제, Stack은 [A, B, E, F, G]가 된다.
// 6. G를 방문하고, C를 Stack에 push한다.
//  이제, Stack은 [A, B, E, F, G, C]가 된다.
// 7. 다음 방문할 정점은 C이다. C는 인접 정점 [A, F, G]가 있지만, 모두 이전에 방문한 정점이다.
//  이는 막다른 곳에 도달했다는 의미이므로 Stack에서 C를 pop해 backtrack을 진행한다.
//  이제, Stack은 [A, B, E, F, G]가 된다.
// 8. backtrack해 G로 돌아온다.
//  인접 정점 [F, C]가 있지만 모두 이전에 방문한 정점이므로 또 다른 막다른 곳이다. 따라서 G를 pop해 backtrack을 진행한다.
//  이제, Stack은 [A, B, E, F]가 된다.
// 9. backtrack해 F로 돌아온다.
//  F 또한 방문하지 않은 인접 정점이 남아 있지 않으므로 막다른 곳이다. 따라서 F를 pop해 backtrack을 진행한다.
//  이제, Stack은 [A, B, E]가 된다.
// 10. backtrack해 E로 돌아온다.
//  인접 정점 중 H는 아직 방문하지 않았으므로, Stack에서 H를 push 한다.
//  이제, Stack은 [A, B, E, H]가 된다.
// 11. H를 방문하면, 또 다른 막다른 곳이다.
//  H를 Stack에서 pop해 backtrack을 진행한다.
//  이제, Stack은 [A, B, E]가 된다.
// 12. backtrack해 E로 돌아온다.
//  E 또한 방문하지 않은 인접 정점이 남아 있지 않으므로 막다른 곳이다. 따라서 E를 pop해 backtrack을 진행한다.
//  이제, Stack은 [A, B]가 된다.
// 13. backtrack해 B로 돌아온다.
//  B 또한 방문하지 않은 인접 정점이 남아 있지 않으므로 막다른 곳이다. 따라서 B를 pop해 backtrack을 진행한다.
//  이제, Stack은 [A]가 된다.
// 14. backtrack해 A로 돌아온다.
//  A에서 방문하지 않은 인접 정점인 D가 남아 있으므로, D를 Stack에 push 한다.
//  이제, Stack은 [A, D]가 된다.
// 15. D를 방문하면, 또 다른 막다른 곳이므로, Stack에서 D를 pop해 backtrack을 진행한다.
// 16. A로 다시 돌아왔지만, 이번에는 이전과 달리 push할 인접 정점이 없다.
//  따라서 막다른 곳이므로, Stack에서 A를 pop 한다.
//  이제, Stack은 비게 되고, DFS가 완료된다.
//정점을 탐색할 때 방문한 경로를 확인할 수 있는 tree를 구성할 수 있다. BFS와 비교하여 DFS가 얼마나 깊이 탐색하는 지 알 수 있다. //p.381




//Implementation
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
//위의 example을 그래프로 구현한다.

extension Graph where Element: Hashable {
    func depthFirstSearch(from source: Vertex<Element>) -> [Vertex<Element>] {
        //해당 정점으로 DFS를 구현하는 메서드
        var stack: Stack<Vertex<Element>> = [] //경로를 저장하는 데에 stack이 사용된다.
        var pushed: Set<Vertex<Element>> = [] //어떤 정점이 push 되었는지 기억해, 같은 정점을 두 번 방문하는 것을
        //Stack에 동일한 정점을 여러 번 push 하는 것을 방지하기 위해, 어떤 정점이 Stack에 추가 된 적이 있었는지 기억한다.
        //Set을 사용하면, lookup연산 O(1)이 보장한다.
        var visited: [Vertex<Element>] = [] //정점을 방문한 순서를 저장하는 Array이다.
        
        stack.push(source)
        pushed.insert(source)
        visited.append(source)
        //source 정점을 stack, pushed, visited에 추가한다.
        
        outer: while let vertex = stack.peek() { //Stack이 비워질 대까지 Stack 상단의 정점을 계속해서 확인한다.
            //중첩 loop 내에서 다음 정점으로 계속 진행할 수 있도록 label을 지정해 준다.
            let neighbors = edges(from: vertex) //현재 정점의 모든 간선을 가져온다.
            guard !neighbors.isEmpty else { //현재 정점의 간선이 없다면(막다른 곳), Stack을 pop 하고 다음 정점으로 이동한다.
                stack.pop()
                continue
            }
            for edge in neighbors { //현재 정점에 연결된 모든 간선을 반복한다.
                if !pushed.contains(edge.destination) {
                    //해당 간선의 목적 정점이 Stack에 추가 된 적이 있는 지 확인한다. //추가 된 적이 없다면, Stack에 추가한다.
                    stack.push(edge.destination)
                    pushed.insert(edge.destination)
                    visited.append(edge.destination)
                    //해당 정점을 방문한 것으로 표시하는 것이 시기상조일 수 있지만(아직 peek하지 않은 경우),
                    //정점을 Stack에 추가한 순서대로 방문하므로, 올바른 순서가 보장된다.
                    continue outer //다음 방문할 인접 정점을 찾았으므로 외부 loop를 계속 진행해, 새로 push된 인접 정점으로 이동한다.
                }
            }
            stack.pop() //현재 정점에서 아직 방문하지 않은 인접 정점이 없으면 막다른 곳에 도달한 것이므로, Stack을 pop 한다.
        }
        
        return visited
    }
}
//Stack이 비워지면 DFS 알고리즘이 완료된다. 방문한 정점을 순서대로 반환한다.
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




//Performance
//DFS는 모든 정점을 적어도 한 번 방문한다. 이것의 시간 복잡도는 O(V)이다.
//DFS로 그래프를 탐색할 때, 방문할 수 있는 정점을 찾기 위해 모든 인접 정점을 확인해야 한다.
//최악의 경우 그래프의 모든 단일 간선을 방문해야 하기 때문에 이 작업의 시간 복잡도는 O(E)가 된다.
//따라서 전체적인 깊이 우선 검색(Depth-First Search, DFS)의 시간 복잡도는 O(V + E)이다.
//DFS의 공간 복잡도는 정점을 stack, pushed, visited의 세 가지 구조로 저장해야 하기 때문에 O(V)이다.




//Key points
// • DFS는 그래프를 탐색하거나 검색하는 또 다른 알고리즘이다.
// • DFS는 가능한 한 끝까지 한 경로를 탐색한다.
// • Stack 자료 구조를 사용하여 그래프가 얼마나 깊은지 추적한다. 막 다른 곳에 도달했을 때에만 Stack에서 pop한다.
