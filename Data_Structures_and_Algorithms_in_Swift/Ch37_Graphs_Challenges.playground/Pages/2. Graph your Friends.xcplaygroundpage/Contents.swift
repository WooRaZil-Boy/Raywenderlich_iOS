// Copyright (c) 2019 Razeware LLC
// For full license & permission details, see LICENSE.markdown.
//: [Previous Challenge](@previous)

/*:
 # 2. Graph your Friends
 
 Vincent has three friends, Chesley, Ruiz, and Patrick. Ruiz has friends Ray, Sun, and a mutual friend with Vincent's. Patrick is friends with Cole, and Kerry. Cole is friends with Ruiz and Vincent. Create an adjacency list that represents this friendship graph. Which mutual friend do Ruiz and Vincent share?
 */
//Vincent는 Chesley, Ruiz, Patrick 세 명의 친구가 있다.
//Ruiz는 Ray, Sun, Vincent의 친구이다.
//Patrick은 Cole, Kerry의 친구이다.
//Cole은 Ruiz, Vincent의 친구이다.
//이 친구 관계 그래프를 나타내는 adjacency list를 작성한다.
//Ruiz와 Vincent 둘 모두의 친구는 누구인가?




//AdjacencyList API를 사용해 구현한다. 0이 아닌 어떤 값이든 가중치(weight)로 사용해도 좋지만, 가장 좋은 기본값은 1이다.
let graph = AdjacencyList<String>()

let vincent = graph.createVertex(data: "vincent")
let chesley = graph.createVertex(data: "chesley")
let ruiz = graph.createVertex(data: "ruiz")
let patrick = graph.createVertex(data: "patrick")
let ray = graph.createVertex(data: "ray")
let sun = graph.createVertex(data: "sun")
let cole = graph.createVertex(data: "cole")
let kerry = graph.createVertex(data: "kerry")

graph.add(.undirected, from: vincent, to: chesley, weight: 1)
graph.add(.undirected, from: vincent, to: ruiz, weight: 1)
graph.add(.undirected, from: vincent, to: patrick, weight: 1)
graph.add(.undirected, from: ruiz, to: ray, weight: 1)
graph.add(.undirected, from: ruiz, to: sun, weight: 1)
graph.add(.undirected, from: patrick, to: cole, weight: 1)
graph.add(.undirected, from: patrick, to: kerry, weight: 1)
graph.add(.undirected, from: cole, to: ruiz, weight: 1)
graph.add(.undirected, from: cole, to: vincent, weight: 1)
print(graph)
// 0: vincent ---> [ 1: chesley, 2: ruiz, 3: patrick, 6: cole ]
// 1: chesley ---> [ 0: vincent ]
// 2: ruiz ---> [ 0: vincent, 4: ray, 5: sun, 6: cole ]
// 3: patrick ---> [ 0: vincent, 6: cole, 7: kerry ]
// 4: ray ---> [ 2: ruiz ]
// 5: sun ---> [ 2: ruiz ]
// 6: cole ---> [ 3: patrick, 2: ruiz, 0: vincent ]
// 7: kerry ---> [ 3: patrick ]

//단순히 그래프를 확인해 서로 친구인지 확인할 수도 있다.
print("Ruiz and Vincent both share a friend name Cole")
//프로그램으로 이 문제를 해결하려면, 요소가 Hashable이라는 것을 사용해, Ruiz와 Vincent 간의 교집합(intersection)을 찾아 해결할 수 있다.
let vincentsFriends = Set(graph.edges(from: vincent).map { $0.destination.data })
let mutual = vincentsFriends.intersection(graph.edges(from: ruiz).map { $0.destination.data })
print(mutual) // ["cole"]
