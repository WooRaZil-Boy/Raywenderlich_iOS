// Copyright (c) 2019 Razeware LLC
// For full license & permission details, see LICENSE.markdown.
/*:
 # AVL Tree Challenges
 ## Challenge 1
 How many **leaf** nodes are there in a perfectly balanced tree of height 3? What about a perfectly balanced tree of height `h`?
 */
//height가 3인 완벽하게 균형 잡힌(포화) tree에는 몇 개의 leaf node가 있는가?
//height가 h인 완벽하게 균형 잡힌(포화) tree에는 몇 개의 leaf node가 있는가?




//완벽하게 균형 잡힌 tree는 모든 leaf가 같은 level에 있고 그 level이 완전히 채워진다(포화 이진 트리). //p.196
//root만 있는 tree의 height는 0이다. 따라서 height가 3인 tree에는 8개의 leaf node가 있다.
//각 node에는 두 개의 child가 있으므로, height가 증가함에 따라 leaf node 수는 두 배씩 증가한다.
//따라서 leaf node의 수는 간단한 방정식으로 계산할 수 있다.
import Foundation

func leafNodes(inTreeOfHeight height: Int) -> Int {
    Int(pow(2.0, Double(height))) //2^height
}

leafNodes(inTreeOfHeight: 3)

//: [Next Challenge](@next)
