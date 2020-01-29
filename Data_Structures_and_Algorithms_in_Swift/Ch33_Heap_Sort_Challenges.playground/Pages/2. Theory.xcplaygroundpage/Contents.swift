//: [Previous](@previous)
/*:
 ## 2. Theory
 When performing a heap sort in ascending order, which of these starting
 arrays requires the fewest comparisons?
 - `[1,2,3,4,5]`
 - `[5,4,3,2,1]`
*/
//오름차순으로 힙 정렬을 구현할 때, 비교 횟수가 더 적은 Array는 무엇인가?




//힙 정렬을 사용하여 요소를 오름차순으로 정렬할 때, max heap을 사용한다. 따라서 살펴봐야 할 것은 max heap을 구성할 때 발생하는 비교 횟수이다.
//[5, 4, 3, 2, 1]은 이미 max heap이고, swap이 없기 때문에 비교 횟수가 가장 적다.
//max heap을 만들 때 parent node만을 확인한다. 따라서, [5, 4, 3, 2, 1]는 두 개의 parent node가 있으며 2번의 비교가 있다. //p.313
//반면, [1, 2, 3, 4, 5]는 비교 횟수가 가장 많다. 두 개의 parent node가 있지만, 3번의 비교를 해야 한다. //p.313
//: [Next](@next)
