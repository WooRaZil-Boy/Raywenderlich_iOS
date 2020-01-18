// Copyright (c) 2019 Razeware LLC
// For full license & permission details, see LICENSE.markdown.

/*:
 [Previous Challenge](@previous)
 ### Challenge 2: Searching for a range
 Write a function that searches a **sorted** array and that finds the range of indices for a particular element. For example:

```swift
let array = [1, 2, 3, 3, 3, 4, 5, 5]
findIndices(of: 3, in: array)
```

`findIndices` should return the range `2..<5`, since those are the start and end indices for the value `3`.
*/
//정렬된 Array를 검색하고 특정 요소의 index range를 찾는 함수를 작성한다.
//위의 예에서 findIndices는 2..<5 범위를 반환한다. 찾는 값인 3의 시작 및 종료 index 이다.




//최적화되지 않은 간단한 해결 방법은 매우 간단하게 구현할 수 있다.
//  func findIndices(of value: Int, in array: [Int]) -> Range<Int>? {
//      guard let leftIndex = array.firstIndex(of: value) else {
//          return nil
//      }
//      guard let rightIndex = array.lastIndex(of: value) else {
//          return nil
//      }
//
//      return leftIndex..<rightIndex
//  }
//이 알고리즘의 시간 복잡도는 O(n)이며, 나쁘지 않은 것처럼 보인다. 하지만, O(log n)으로 최적화 할 수 있다.
//이진 탐색은 정렬된 Collection의 value를 식별하는 알고리즘으로, 정렬된 Collection이 보장되는 경우 항상 염두에 둬야 한다.
//이전 장에서 구현한 이진 탐색(Ch20)은 해당 index가 시작 index인지, 종료 index인지 알수가 없다. 따라서 이를 보완해 이진 탐색을 수정한다.
func findIndices(of value: Int, in array: [Int]) -> CountableRange<Int>? {
    //이진 탐색을 수정하여 어떤 index(start index 인지 end index 인지)를 찾고 있는지에 따라 인접값이 현재값과 다른지 검사할 수 있다.
    guard let startIndex = startIndex(of: value, in: array, range: 0..<array.count) else { return nil }
    guard let endIndex = endIndex(of: value, in: array, range: 0..<array.count) else { return nil }
    return startIndex..<endIndex
}

func startIndex(of value: Int, in array: [Int], range: CountableRange<Int>) -> Int? { //helper
    let middleIndex = range.lowerBound + (range.upperBound - range.lowerBound) / 2 //중간값의 index를 가져온다.
    //Ch20의 구현과는 range type이 달라서 코드가 다를 뿐 찾는 방법은 같다.
    
    if middleIndex == 0 || middleIndex == array.count - 1 {
        //중간 index가 array의 첫 번째 또는 마지막 index인 경우 더 이상 이진 탐색을 계속할 필요가 없다.
        if array[middleIndex] == value { //현재 index가 찾는 value가 맞는지 확인한다.
            return middleIndex
        } else {
            return nil
        }
    }
    
    //중간 index의 value를 확인하고 재귀 호출한다.
    if array[middleIndex] == value { //중간값이 찾는 값과 같다면
        if array[middleIndex - 1] != value { //이전 index의 value도 같은지 확인한다.
            //다르다면, 새로운 start index의 경계를 찾은 것이므로 반환한다.
            return middleIndex
        } else { //같다면, 재귀적으로 startIndex를 호출하여 계속 반복한다.
            return startIndex(of: value, in: array, range: range.lowerBound..<middleIndex)
        }
    } else if value < array[middleIndex] { //중간값보다 작은 경우
        return startIndex(of: value, in: array, range: range.lowerBound..<middleIndex)
    } else { //중간값보다 큰 경우
        return startIndex(of: value, in: array, range: middleIndex..<range.upperBound)
    }
}

func endIndex(of value: Int, in array: [Int], range: CountableRange<Int>) -> Int? { //helper
    let middleIndex = range.lowerBound + (range.upperBound - range.lowerBound) / 2 //중간값의 index를 가져온다.
    //Ch20의 구현과는 range type이 달라서 코드가 다를 뿐 찾는 방법은 같다.
    
    if middleIndex == 0 || middleIndex == array.count - 1 {
        //중간 index가 array의 첫 번째 또는 마지막 index인 경우 더 이상 이진 탐색을 계속할 필요가 없다.
        if array[middleIndex] == value { //현재 index가 찾는 value가 맞는지 확인한다.
            return middleIndex + 1 //CountableRange는 ..< 으로 표현되기 때문에 endIndex는 +1 을 해줘야 한다.
        } else {
            return nil
        }
    }
    
    //중간 index의 value를 확인하고 재귀 호출한다.
    if array[middleIndex] == value { //중간값이 찾는 값과 같다면
        if array[middleIndex + 1] != value { //이전 index의 value도 같은지 확인한다.
            //다르다면, 새로운 end index의 경계를 찾은 것이므로 반환한다.
            return middleIndex + 1
        } else { //같다면, 재귀적으로 endIndex를 호출하여 계속 반복한다.
            return endIndex(of: value, in: array, range: middleIndex..<range.upperBound)
        }
    } else if value < array[middleIndex] { //중간값보다 작은 경우
        return endIndex(of: value, in: array, range: range.lowerBound..<middleIndex)
    } else { //중간값보다 큰 경우
        return endIndex(of: value, in: array, range: middleIndex..<range.upperBound)
    }
}

let array = [1, 2, 3, 3, 3, 4, 5, 5]
if let indices = findIndices(of: 3, in: array) {
    print(indices) // 2..<5
}
//이 알고리즘의 시간 복잡도는 O(log n)으로 이전의 O(n) 보다 빠르다.
