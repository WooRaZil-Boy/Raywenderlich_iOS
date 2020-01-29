// Copyright (c) 2019 Razeware LLC
// For full license & permission details, see LICENSE.markdown.
/*:
 # Quicksort Challenges
 ## 1. Iterative Quicksort
 
 Implement Quicksort iteratively. Choose any partition strategy you learned in this chapter.
 */

//지금까지 퀵 정렬을 재귀적(recursively)으로 구현했다.
//이와 달리, partition strategy를 사용해 퀵 정렬을 반복적(recursively)으로 구현할 수 있다.




//Lomuto’s partition strategy를 사용해 구현한다.
//Array의 low 와 high 사이를 range로 한다. Stack을 사용하여, start와 end의 value 쌍을 저장한다.
public func quicksortIterativeLomuto<T: Comparable>(_ a: inout [T], low: Int, high: Int) {
    var stack = Stack<Int>() //index를 저장하는 stack을 생성한다.
    stack.push(low)
    stack.push(high)
    //stack에 하한(low)과 상한(high)를 push한다.
    
    while !stack.isEmpty { //stack이 비어 있으면, 퀵 정렬이 완료된 것이다.
        guard let end = stack.pop(), let start = stack.pop() else {
            //stack에서 시작(start)과 끝(end) index 쌍을 가져온다.
            continue
        }
        
        let p = partitionLomuto(&a, low: start, high: end)
        //현재의 start와 end index로 Lomuto’s partitioning을 실행한다.
        //Lomuto 알고리즘은 마지막 요소를 pivot으로 선택해, pivot보다 작은요소, pivot 보다 큰 요소로 3등분 한다.
        
        if (p - 1) > start { //분할이 완료되면, 하한의 start와 end index를 Stack에 추가하여 분할한다.
            stack.push(start)
            stack.push(p - 1)
        }
        
        if (p + 1) < end { //분할이 완료되면, 상한의 start와 end index를 Stack에 추가하여 분할한다.
            stack.push(p + 1)
            stack.push(end)
        }
    }
}
//Stack을 사용해 구분하기 위해, start와 end index 쌍을 저장한다.
var list = [12, 0, 3, 9, 2, 21, 18, 27, 1, 5, 8, -1, 8]
quicksortIterativeLomuto(&list, low: 0, high: list.count - 1)
print(list)
// [-1, 0, 1, 2, 3, 5, 8, 8, 9, 12, 18, 21, 27]

//: [Next Challenge](@next)
