// Copyright (c) 2019 Razeware LLC
// For full license & permission details, see LICENSE.markdown.
//: [Previous Challenge](@previous)
/*:
 ## 2. Merge Sort or Quicksort
 
 Explain when and why you would use merge sort over quicksort.
 */
//퀵 정렬(quick sort)보다, 합병 정렬(merge sort)을 사용해야 할 때(when)와 그 이유(why)를 설명한다.




// • 안정성(stability)이 필요한 경우, 퀵 정렬 보다 합병 정렬을 사용하는 것이 더 바람직하다. 합병정렬은 안정적인 정렬이며, O(n log n)을 보장한다.
//  퀵 정렬은 불안정 정렬이며, 최악의 경우 O(n^2)의 성능을 보인다.
//      안정적인 정렬(Stable Sort)  : 동일한 값에 대해 기존의 순서가 유지되는 정렬 방식 (버블 정렬, 삽입 정렬)
//      불안정한 정렬(Unstable Sort)  : 동일한 값에 대해 기존의 순서가 유지되지 않는 정렬 방식 (선택 정렬)
// • 합병정렬은 요소가 메모리에 분산되어 있는 큰 자료 구조의 경우 적합하다. 퀵 정렬은 요소가 인접한 블록에 저장되어 있을 때 가장 잘 작동한다.
//: [Next Challenge](@next)
