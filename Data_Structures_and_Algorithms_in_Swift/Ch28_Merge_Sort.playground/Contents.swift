//Chapter 28: Merge Sort

//Merge Sort(합병 정렬)은 가장 효율적인 정렬 알고리즘 중 하나이다. 시간 복잡도는 O(n log n)으로, 모든 범용 정렬 알고리즘 중 가장 빠르다.
//합병 정렬의 기본 개념은 분할 정복(divide and conquer)이다. 큰 문제를 여러 개의 작고 해결 하기 쉬운 문제로 나눈 다음, 그 결과들을 최종 결과로 결합한다.
//합병 정렬 방식은 먼저 분할 하고, 그 후에 병합한다.




//Example
//[7, 2, 6, 3, 9] 가 있을 때, Merge Sort(합병 정렬) 알고리즘은 다음과 같이 작동한다. //p.282
// 1. 먼저 Collection을 반으로 나눈다(분할, divide). 이제 정렬되지 않은 두 개의 더미(pile)가 있다. [7, 2], [6, 3, 9]
// 2. 더 이상 나눠지지 않을 때까지 더미(pile)를 계속 나눈다(분할, divide). 결국에는 각 더미(pile)에 하나의 요소(sorted!)만 있게 된다. [7], [2], [6], [3], [9]
// 3. Collection을 분할한 역순으로 병합한다. 병합 할 때마다 순서를 정렬한다. 분할 된 개별 Collection이 이미 정렬되어 있기 때문에 쉽게 처리할 수 있다.
//  [2, 7], [3, 6], [9] -> [2, 3, 6, 7], [9] -> [2, 3, 6, 7, 9]




//Implementation
//Split
//배열(Array)를 반으로 나눈다. 하지만, 한 번 분할하는 것만으로는 충분하지 않다. 더 이상 분할할 수 없을 때까지 반복적으로(recursively) 분할해야 한다.
//즉, 각 더미(subdivision)마다 하나의 요소(element)만 남을 때까지 분할한다.
public func mergeSort<Element>(_ array: [Element]) -> [Element] where Element: Comparable {
    guard array.count > 1 else { //재귀 종료 조건. 하나의 요소만 남으면, 분할을 종료한다.
        return array
    }
    
    let middle = array.count / 2
    
    let left = mergeSort(Array(array[..<middle]))
    let right = mergeSort(Array(array[middle...]))
    //반으로 나눈다. 더 이상 분할 할 수 없을 때 까지(하나의 요소만 남을 때까지) 반복적으로 분할해야 한다.
    
    return merge(left, right) //병합
}
//분할(Split) 부분은 구현하였다. 이제 합병(Merge)을 구현해야 한다.

//Merge
//분할 이후, 왼쪽과 오른쪽으로 나눠진 Array를 병합해야 한다. 여기서는 코드 가독성을 위해 별도의 함수로 구현한다.
//병합 함수의 유일한 목적은 두 개의 정렬된 배열을 가져와 정렬 순서를 유지하면서 결합하는 것이다.
private func merge<Element>(_ left: [Element], _ right: [Element]) -> [Element] where Element: Comparable {
    var leftIndex = 0
    var rightIndex = 0
    //두 배열을 parse할 때 진행 상황을 추적한다.
    var result: [Element] = [] //결과 배열
    
    while leftIndex < left.count && rightIndex < right.count { //좌, 우 배열에 있는 요소를 순차적으로 비교한다. 두 배열의 끝에 도달했다면 loop를 종료한다.
        let leftElement = left[leftIndex]
        let rightElement = right[rightIndex]
        
        if leftElement < rightElement {
            result.append(leftElement)
            leftIndex += 1
        } else if leftElement > rightElement {
            result.append(rightElement)
            rightIndex += 1
        } else {
            result.append(leftElement)
            leftIndex += 1
            result.append(rightElement)
            rightIndex += 1
        }
        //두 요소 중 작은 요소를 result에 추가한다. 두 요소가 같다면, 둘 다 추가한다.
    }
    
    if leftIndex < left.count {
        result.append(contentsOf: left[leftIndex...])
    }
    if rightIndex < right.count {
        result.append(contentsOf: right[rightIndex...])
    }
    //while loop가 끝나면 왼쪽 혹은 오른쪽 중 하나가 비어 있음이 보장된다. 두 배열이 모두 정렬되어 있으므로, 남은 요소가 현재 결과 보다 크거나 같다.
    //여기서는 비교 없이 나머지 요소를 추가할 수 있다.
    
    return result
}

//Finishing up
//merge를 호출하여, mergeSort 함수를 완성한다. mergeSort가 재귀적으로 호출되기 때문에, 알고리즘은 병합 하기 전에 분할 및 정렬을 한다.
//합병 정렬에 대한 주요 절차에 대한 요약은 다음과 같다.
// 1. 합병 정렬의 전략은 분할 정복이다(divide and conquer). 하나의 큰 문제 대신 많은 작은 문제를 해결하기 위해 나누고 정복한다.
// 2. 초기 Array를 재귀적으로 나누고(divide), 두 배열을 병합(merge)하는 것이 핵심이다.
// 3. 병합 함수는 두 개의 정렬된 배열을 가져와 하나의 정렬된 배열을 생성한다.
example(of: "merge sort") {
    let array = [7, 2, 6, 3, 9]
    
    print("Original: \(array)")
    // Original: [7, 2, 6, 3, 9]
    print("Merge sorted: \(mergeSort(array))")
    // Merge sorted: [2, 3, 6, 7, 9]
}




//Performance
//합병 정렬의 최선, 최악, 평균 시간 복잡도는 O(n log n) 이며, 이는 나쁘지 않은 성능이다. 왜 n log n 인지 이해하기 위해서는 재귀의 작동 방식에 대해 생각해 봐야 한다.
// • 재귀적으로 단일 배열을 두 개의 작은 배열로 나눈다. 즉, 크기 2의 배열은 한 번의 재귀가 필요하고, 4일 경우에는 2 번, 8일 경우에는 3 번, 1024는 10 번의 재귀가 필요하다.
//  일반화 하면 n 크기의 배열의 경우, log_2(n) 이다.
// • 단일 재귀(recursion) 단계(level)는 n개의 요소를 병합(merge)한다. 병합된(merged) 요소(element)의 수는 각 level에서 여전히 n개가 된다. 이는 단일 재귀 비용이 O(n) 임을 의미한다.
//따라서, 총 시간 복잡도는 O(log n) * O(n) = O(n log n)이 된다.
//이전 장의 O(n^2) 정렬 알고리즘은 in-place 하며(추가적인 메모리 필요하지 않는다), 요소를 이동하기 위해 swapAt를 사용했다. 하지만, 합병 정렬은 추가적으로 메모리를 할당하여 작업을 수행한다.
//재귀에 log_2(n)개의 level이 있으며(2^10 = 1024, 10개의 level), 각 level에서 n개의 요소가 사용된다. 이는 공간 복잡도가 O(n log n)임을 뜻한다.
//합병 정렬은 hallmark(품질이 보증된) 정렬 알고리즘으로, 비교적 이해하기 쉽고 divide-and-conquer algorithms이 어떻게 작동하는지 기초적인 개념을 잡기 좋다.
//합병 정렬의 시간 복잡도는 O(n log n)이며, 일반적인 공간 복잡도 또한 O(n log n)이다. 하지만, 사용되지 않는 메모리를 정리하면서 구현하면 O(n)으로 공간 복잡도를 줄일 수 있다.




//Key points
// • 합병 정렬(Merge sort)은 분할 정복(divide-and-conquer) 알고리즘(algorithm)의 범주(category)에 속한다.
// • 합병 정렬(merge sort)의 구현 방법은 여러 가지가 있으며, 구현에 따라 성능(performance)이 달라질 수 있다.
