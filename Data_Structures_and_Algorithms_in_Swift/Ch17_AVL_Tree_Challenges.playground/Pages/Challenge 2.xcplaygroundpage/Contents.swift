// Copyright (c) 2019 Razeware LLC
// For full license & permission details, see LICENSE.markdown.
/*:
 [Previous Challenge](@previous)
 
 ## Challenge 2
 
 How many **nodes** are there in a perfectly balanced tree of height 3? What about a perfectly balanced tree of height `h`?
*/
//높이(height)가 3인 완벽하게 균형 잡힌(포화) 트리(tree)에는 몇 개의 노드(node)가 있는가?
//높이(height)가 h인 완벽하게 균형 잡힌(포화) 트리(tree)는 어떤가?




import Foundation

func nodes1(inTreeOfHeight height: Int) -> Int {
    var totalHeight = 0
    for currentHeight in 0...height {
        totalHeight += Int(pow(2.0, Double(currentHeight)))
    }
    return totalHeight
}
//확실하게 정답을 확인할 수 있지만, 더 효과적인 방법이 있다.
//일련의 height 입력 결과를 살펴 보면, 총 node의 수는 다음 level의 leaf 노드 수보다 하나 적다.
//이를 활용한 방법은 다음과 같다.
func nodes(inTreeOfHeight height: Int) -> Int {
    Int(pow(2.0, Double(height + 1))) - 1
}

nodes(inTreeOfHeight: 3)

//: [Next Challenge](@next)
