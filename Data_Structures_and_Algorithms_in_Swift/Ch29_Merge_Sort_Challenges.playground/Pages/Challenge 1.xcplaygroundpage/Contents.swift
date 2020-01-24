// Copyright (c) 2019 Razeware LLC
// For full license & permission details, see LICENSE.markdown.
//:
//: # Merge Sort Challenges
//: ## Challenge 1: Speeding up appends
let size = 1024
var values: [Int] = []
// 1
for i in 0 ..< size {
  values.append(i)
}
//이 코드는 재할당이 반복된다.
//1에 단일 할당으로 줄일 수 있는 코드를 추가한다.



var values1: [Int] = []
values1.reserveCapacity(size) //reserveCapacity를 사용하면, append 속도를 높일 수 있다.
for i in 0 ..< size {
  values1.append(i)
}
//Array에 추가할 요소의 수를 알고 있다면, reserveCapacity를 사용해 Array의 용량을 미리 설정해 줄 수 있다.
//Array에 요소를 추가할 때, 해당 Array가 예약된 용량을 초과하면, Array는 더 큰 메모리 영역을 할당하고, 요소를 복사한다.
//이때 새로운 Storage는 이전 Storage 크기의 2배 이다.
//하지만, reserveCapacity를 사용해 Array의 용량을 미리 설정하면, 재할당 및 복사연산을 수행할 필요가 없어지므로 속도가 빨라진다.
//https://zeddios.tistory.com/117


//: [Next Challenge](@next)
