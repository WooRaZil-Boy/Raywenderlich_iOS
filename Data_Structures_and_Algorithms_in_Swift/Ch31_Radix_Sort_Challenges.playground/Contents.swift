// Copyright (c) 2019 Razeware LLC
// For full license & permission details, see LICENSE.markdown.
//: # Radix Sort Challenges
//: ## Challenge 1: Most significant digit
//:
//: The implementation discussed in the chapter used a *least significant digit*
//: radix sort. Your task is to implement a *most significant digit* radix sort.
//: This sorting behavior is called **lexicographical sorting** and is also used
//: for `String` sorting.
//:
//:  For example:
//:
//: ```swift
//: var array = [500, 1345, 13, 459, 44, 999]
//: array.lexicographicalSort()
//: print(array) // outputs [13, 1345, 44, 459, 500, 999]
//: ```
//이전에는 least significant digit radix sort를 사용했다. most significant digit를 사용하는 radix sort를 구현한다.
//most significant digit radix sort는 사전식 정렬(lexicographical sort)이라고도 하며, 문자열 정렬에 사용할 수 있다.




//MDS 기수 정렬(most significant digit radix sort)은 bucket 정렬을 사용한다는 점이 LSD 기수 정렬과 유사하다.
//차이점은 MSD 기수 정렬은 bucket 정렬의 후속 pass를 신중하게 선별해야 한다는 것이다.
//LSD 기수 정렬에서 bucket 분류는 모든 pass에 대해 전체 Array를 사용하여 반복적으로 실행한다.
//하지만, MSD 기수 정렬에서는 전체 Array와 bucket 분류를 한 번만 실행하고, 이후 pass는 각 bucket을 반복적으로 정렬한다.
//MSD 기수 정렬은 작은 구성 요소부터 시작하여 하나씩 개별적으로 구현한다.

//Digits
import Foundation

extension Int {
    var digits: Int { //Int의 자리수를 반환하는 computed property //ex. 1024는 4를 반환한다.
        var count = 0
        var num = self
        while num != 0 {
            count += 1
            num /= 10
        }
        return count
    }
    
    func digit(atPosition position: Int) -> Int? {
        guard position < digits else {
            return nil
        }
        var num = self
        let correctedPosition = Double(position + 1)
        while num / Int(pow(10.0, correctedPosition)) != 0 { //position 숫자에 도달할때까지 반복적으로 잘라낸다.
            num /= 10
        }
        return num % 10 //마지막으로 나머지 연산자를 사용해 추출한다.
    }
    //digit(atPosition:) 는 주어진 위치의 숫자를 반환한다. Array와 마찬가지로 가장 왼쪽은 0이다.
    //ex. 1024에서 0에 대한 위치의 숫자는 1, 3에 대한 숫자는 4이 된다. 5에 대한 숫자는 nil을 반환한다.
}

//Lexicographical sort
//helper 메서드룰 사용해, MSD 기수 정렬을 구현할 수 있다.
extension Array where Element == Int {
    private var maxDigits: Int { //재귀 종료를 위한 조건
        self.max()?.digits ?? 0
        //재귀를 종료하는 조건을 추가해 줘야 한다. 현재 자리수가 Array에서 가장 큰 유효 자리수보다 큰 경우, 재귀가 중단된다.
    }
    
    mutating func lexicographicalSort() {
        //lexicographicalSort로 MSD 기수 정렬을 구현한다.
        self = msdRadixSorted(self, 0)
    }
    
    private func msdRadixSorted(_ array: [Int], _ position: Int) -> [Int] {
        guard position < array.maxDigits else { //재귀 종료 조건
            //현재 자리수가 Array에서 가장 큰 유효 자리수보다 큰 경우, 재귀가 중단된다.
            //현재 자리수가 maxDigits보다 크거나 같으면 재귀가 종료된다.
            return array
        }
        
        //MSD 기수 정렬을 재귀적으로 구현한다.
        var buckets: [[Int]] = .init(repeating: [], count: 10)
        //LSD 기수 정렬과 마찬가지로, bucket에 대한 2차원 배열을 생성한다.
        var priorityBucket: [Int] = []
        //현재 자리수 보다 작은 자리수를 저장하는 특수 bucket. priorityBucket에 들어가는 값이 먼저 정렬된다.
        
        //Array의 모든 숫자에 대해, 현재 숫자를 찾아 해당 bucket에 넣는다.
        array.forEach { number in
            guard let digit = number.digit(atPosition: position) else {
                priorityBucket.append(number)
                return
            }
            buckets[digit].append(number)
        }
        
        //개별 bucket에 대해, MSD 기수정렬을 재귀적으로 호출한다.
        priorityBucket.append(contentsOf: buckets.reduce(into: []) { result, bucket in
            guard !bucket.isEmpty else {
                return
            }
            result.append(contentsOf: msdRadixSorted(bucket, position + 1))
        })
        //reduce(into:)를 호출하여, 재귀결과를 모으로 priorityBucket에 추가한다.
        //이런 식으로 priorityBucket가 항상 우선하게 된다.
        
        return priorityBucket
    }
}

//Base case
//재귀를 종료하는 조건을 추가해 줘야 한다. 현재 자리수가 Array에서 가장 큰 유효 자리수보다 큰 경우, 재귀가 중단된다.
var array: [Int] = (0...10).map { _ in Int(arc4random()) }
array.lexicographicalSort()
print(array)
// [1049613636, 1152103285, 1233893644, 2567986728, 2682366897, 3369800165, 3516188652, 3962379748, 4239312617, 4271303906, 779048765]

//숫자는 무작위로 생성되기 때문에 매번 실행할 때마다 다른 결과를 얻게 된다.
//중요한 것은 값(value)이 사전 순서(lexicographical ordering)대로 정렬된다는 것이다.
