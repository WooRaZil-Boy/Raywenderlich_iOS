// Copyright (c) 2019 Razeware LLC
// For full license & permission details, see LICENSE.markdown.
/*:
 # Depth-First Search Challenges
 ## 1. BFS or DFS
 
 For each of the following two examples, which traversal (depth-first or
 breadth-first) is better for discovering if a path exists between the
 two nodes? Explain why.
 
 ![Graph](dfschallenge1.png)
 */
//다음 두 예에 대해, 두 node 사이에 경로가 있는 지 확인하는데 어떤 순회(BFS, DFS)가 더 나은가?
/*:
 Path from **A** to **F**.
 */
//찾고자 하는 경로가 Graph에서 깊기 때문에 DFS(depth-first search)를 사용하는 것이 좋다.
/*:
 Path from **A** to **G**.
 */
//찾고자 하는 경로가 Root에 가까이 있으므로, BFS(breadth-first search)를 사용하는 것이 좋다.
//: [Next Challenge](@next)
