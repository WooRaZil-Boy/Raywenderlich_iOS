//Chapter 34: Quicksort

//Merge Sort(합병 정렬), Heap Sort(힙 정렬)는 비교 기반 정렬 알고리즘(comparison-based sorting algorithm)이다.
//Quick Sort(퀵 정렬) 또한 비교 기반 정렬 알고리즘으로, 합병 정렬과 마찬가지로 분할 정복 전략(divide and conquer)을 사용한다.
//퀵 정렬(Quick Sort)에서의 중요한 작업 중 하나는 피벗(Pivot)을 선택하는 것이다.
//피벗(pivot)은 Collection을 세 개의 부분을 나눈다. 피벗(pivot)은 배열(array)dmf 세 개의 부분(partition)으로 나눈다. [ elements < pivot | pivot | elements > pivot ]




//Example
public func quicksortNaive<T: Comparable>(_ a: [T]) -> [T] {
    guard a.count > 1 else { //하나 이상의 요소가 있어야 한다.
        return a
    }
    
    let pivot = a[a.count / 2] //중간 요소를 pivot으로 선택한다.
    let less = a.filter { $0 < pivot }
    let equal = a.filter { $0 == pivot }
    let greater = a.filter { $0 > pivot }
    //pivot을 사용해, 3개의 부분으로 분할한다.
    
    return quicksortNaive(less) + equal + quicksortNaive(greater)
    //재귀적으로 정렬한 다음 결합한다.
}
//Array를 3개의 부분나눠 재귀적으로 filtering 한다.
//예시를 들어보면 다음과 같다.
// [12, 0, 3, 9, 2, 18, 8(*), 27, 1, 5, 8, -1, 21] //pivot : 8
//이 구현에서 구분(partition)을 나누는 전략(strategy)은 항상 중간(middle) 요소를 pivot으로 선택하는 것이다. 이 경우에서는 8이 된다.
//이 피벗(pivot, 8)을 사용해 배열(array)을 세 부분(partition)으로 분할하면 다음과 같다.
// less: [0, 3, 2, 1, 5, -1]
// equal: [8, 8]
// greater: [12, 9, 18, 27, 21]
//분할 된 3개의 각 부분(partition)이 정렬되지 않았다. 퀵 정렬은(quick sort) 모든 부분(partition)을 재귀적으로(recursively) 더 작은 부분(partition)으로 나눈다.
//재귀(recursion)는 모든 부분(partition)의 요소(element)가 0 또는 1 개가 될 때 중단된다. //p.317
//각 level은 재귀 호출(recursive call)로 퀵 정렬(quicksort)을 수행한다. 재귀(recursion)가 끝나면, 나눠진 최소 부분들(leaf)을 다시 결합해 정렬된 배열을 만든다.
// [-1, 1, 2, 3, 5, 8, 8, 9, 12, 18, 21, 27]
//이 Naive 구현은 이해하기 쉽지만, 몇 가지 문제가 있다.
// • 동일한 Array에서 filter를 세 번 호출하는 것은 비효율적이다.
// • 모든 부분에 대해 새 Array를 생성하는 것은 공간효율적이지 않다. 새 배열(array)를 사용하지 않고, in-place로 정렬할 수 있으면 공간이 낭비되지 않는다.
// • 중간 요소를 pivot으로 선택하는 것이 최선이 아닐 수 있다.




//Partitioning strategies
//위의 Naive 구현을 좀 더 효율적으로 변경할 수 있다. Lomuto’s algorithm을 사용하면, 분할(partitioning)을 좀 더 효율적으로 구현할 수 있다.

//Lomuto’s partitioning
//Lomuto’s partitioning algorithm은 항상 마지막 요소를 pivot으로 선택한다.
public func partitionLomuto<T: Comparable>(_ a: inout [T], low: Int, high: Int) -> Int {
    //세 개의 매개 변수를 사용한다.
    // • a : 분할 중인 Array
    // • low, high : 분할할 Array 내의 범위를 설정한다. 이 범위는 재귀가 반복될 때 마다 점점 작아진다.
    //이 함수는 pivot의 index를 반환한다.
    let pivot = a[high] //pivot을 설정한다. Lomuto 알고리즘은 항상 마지막 요소를 pivot으로 선택한다.
    var i = low //변수 i는 pivot보다 작은 요소의 수를 나타낸다. 피벗보다 작은 요소를 만날 때마다 index i의 요소와 교체하고 i를 증가시킨다.
    for j in low..<high { //해당 범위를 반복한다.
        if a[j] <= pivot { //현재 요소가 피벗보다 작거나 같은지 확인한다.
            a.swapAt(i, j) //작거나 같다면 swap하고
            i += 1 //i를 증가시킨다.
        }
    }
    a.swapAt(i, high) //loop가 종료되면, i의 요소를 pivot으로 swap한다. pivot은 항상, 작은 부분과 큰 부분의 사이에 있다.
    return i //pivot의 index를 반환한다.
}
//이 알고리즘은 Array를 loop하면서, 4개의 영역으로 나눈다.
// 1. a[low..<i] : 피벗보다 작거나 같은 요소
// 2. a[i...j-1] : 피벗보다 큰 요소
// 3. a[j...high-1] : 아직 비교하지 않은 요소
// 4. a[high] : pivot
//  [ values <= pivot | values > pivot | not compared yet | pivot ]
//     low       i-1       i      j-1     j         high-1   high

//Step-by-step
//알고리즘(algorithm)이 어떻게 작동하는지 명확하게 이해하기 위해 아래와 같이 정렬되지 않은(unsorted) 배열(Array)을 예시로 들면 다음과 같다.
// [12, 0, 3, 9, 2, 21, 18, 27, 1, 5, 8, -1, 8]
//여기서 마지막 요소인 8이 pivot이 된다.
// [12, 0, 3, 9, 2, 21, 18, 27, 1, 5, 8, -1, | 8 ]
//  low                                       high
//   i
//   j
//그리고 첫번째 요소(element)인 12를 pivot과 비교한다. pivot(8)보다 크므로 다음 요소로 넘어간다.
// [12, 0, 3, 9, 2, 21, 18, 27, 1, 5, 8, -1, | 8 ]
//  low                                       high
//   i
//      j
//두 번째 요소(element)인 0은 pivot보다 작으므로, index i에 있는 12와 교체(swap)되고, i는 1 증가한다.
// [0, 12, 3, 9, 2, 21, 18, 27, 1, 5, 8, -1, | 8 ]
// low                                        high
//     i
//         j
//세 번째 요소(element)인 3 또한 pivot보다 작으므로, 교체(swap)한다.
// [0, 3, 12, 9, 2, 21, 18, 27, 1, 5, 8, -1, | 8 ]
// low                                        high
//         i
//            j
//이와 같은 작업을 pivot을 제외한 모든 요소(element)를 비교하여 반복한다. loop 종료 이후, 결과는 다음과 같다.
// [0, 3, 2, 1, 5, 8, -1, 27, 9, 12, 21, 18, | 8 ]
// low                                        high
//                        i
//마지막으로, pivot 요소는 현재 index i의 요소와 swap된다.
// [0, 3, 2, 1, 5, 8, -1, | 8 |, 9, 12, 21, 18, | 27 ]
// low                                           high
//                          i
//Lomuto’s partitioning 이후, pivot의 위치를 확인해 봐야 한다. pivot보다 작거나 같은 부분과, pivot보다 큰 부분의 사이에 위치하게 된다.
//세 부분의 정렬되지 않은 Array를 생성하고, 필터링 한 naïve 구현에 비해, Lomuto’s algorithm은 제자리 분할을 수행하므로 더 효율적이다.
//제자리 분할(partitioning in place) 알고리즘(algorithm)을 구현한 퀵 정렬(quick sort)은 다음과 같이 구현할 수 있다.
public func quicksortLomuto<T: Comparable>(_ a: inout [T], low: Int, high: Int) {
    if low < high {
        let pivot = partitionLomuto(&a, low: low, high: high)
        quicksortLomuto(&a, low: low, high: pivot - 1)
        quicksortLomuto(&a, low: pivot + 1, high: high)
    }
}
//Lomuto’s partitioning algorithm을 적용하여 Array를 두 부분으로 분할 한 후, 재귀적으로 정렬한다. 각 부분의 요소가 2개 미만이면 재귀가 종료된다.
var list = [12, 0, 3, 9, 2, 21, 18, 27, 1, 5, 8, -1, 8]
quicksortLomuto(&list, low: 0, high: list.count - 1)
print(list) // [-1, 0, 1, 2, 3, 5, 8, 8, 9, 12, 18, 21, 27]

//Hoare’s partitioning
//Hoare’s partitioning algorithm은 항상 첫 번째 요소를 pivot으로 선택한다.
public func partitionHoare<T: Comparable>(_ a: inout [T], low: Int, high: Int) -> Int {
    let pivot = a[low] //첫 요소를 pivot으로 선택한다.
    var i = low - 1
    var j = high + 1
    //index i, j의 영역을 정의한다.
    //index i 이전의 모든 index는 pivot보다 작거나 같다. j 다음의 모든 index는 pivot보다 크거나 같다.
    
    while true {
        repeat { j -= 1 } while a[j] > pivot //pivot보다 크지 않은 요소에 도달할때까지 j를 줄인다
        repeat { i += 1 } while a[i] < pivot //pivot보다 작지 않은 요소에 도달할 때 까지 i를 증가시칸다.
        
        if i < j { //i보다 j가 크다면
            a.swapAt(i, j) //swap한다.
        } else {
            return j //두 부분을 구분하는 index를 반환한다.
        }
    }
}
//여기서는 반환된 index가 반드시 pivot의 index일 필요는 없다.

//Step-by-step
//아래와 같이 정렬되지 않은 Array를 예시로 들면 다음과 같다.
// [12, 0, 3, 9, 2, 21, 18, 27, 1, 5, 8, -1, 8]
//먼저 12를 pivot으로 설정한다. i(앞에서부터), j(뒤에서부터)는 배열(array)에서 각각 pivot보다 작지 않은 요소(i), pivot보다 크지않은 요소(j)를 찾는다.
//i는 12에서 멈출 것이고, j는 8에서 멈출 것이다.
// [12, 0, 3, 9, 2, 21, 18, 27, 1, 5, 8, -1, 8]
//  p
//  i                                        j
//i, j 요소들을 서로 swap해 준다.
// [8, 0, 3, 9, 2, 21, 18, 27, 1, 5, 8, -1, 12]
//  i                                        j
//계속해서 i와 j를 움직인다. 이번에는 21, -1에서 멈춘다.
// [8, 0, 3, 9, 2, 21, 18, 27, 1, 5, 8, -1, 12]
//                 i                     j
//swap 해준다.
// [8, 0, 3, 9, 2, -1, 18, 27, 1, 5, 8, 21, 12]
//                  i                    j
//다음으로 18과 8이 swap되고, 그 이후에는 27과 5과 swap된다.
//swap 이후에는 다음과 같다.
// [8, 0, 3, 9, 2, -1, 8, 5, 1, 27, 18, 21, 12]
//                        i      j
//이후, i와 j를 이동하면 다음과 같이 서로 겹치게 된다.
// [8, 0, 3, 9, 2, -1, 8, 5, 1, 27, 18, 21, 12]
//                           j,  i
//Hoare’s algorithm은 여기서 종료된다. 두 영역(region) 사이를 구분하는 index로 j가 반환된다. Lomuto's algorithm에 비해 교환(swap) 횟수가 훨씬 적다.
public func quicksortHoare<T: Comparable>(_ a: inout [T], low: Int, high: Int) {
    if low < high {
        let p = partitionHoare(&a, low: low, high: high)
        quicksortHoare(&a, low: low, high: p)
        quicksortHoare(&a, low: p + 1, high: high)
    }
}
var list2 = [12, 0, 3, 9, 2, 21, 18, 27, 1, 5, 8, -1, 8]
quicksortHoare(&list2, low: 0, high: list.count - 1)
print(list2) // [-1, 0, 1, 2, 3, 5, 8, 8, 9, 12, 18, 21, 27]




//Effects of a bad pivot choice
//퀵 정렬에서 가장 중요한 부분은 올바른 분할 전략(partitioning strategy)을 선택하는 것이다.
//지금까지 세 가지 다른 분할 전략을 살펴 보았다.
// 1. 중간 요소를 pivot으로 선택
// 2. Lomuto, 마지막 요소를 pivot으로 선택
// 3. Hoare, 첫 요소를 pivot으로 선택
//잘못된 pivot을 선택했을 때의 예는 다음과 같다.
// [8, 7, 6, 5, 4, 3, 2, 1]
//Lomuto’s algorithm을 사용하면 pivot은 마지막 요소(element)인 1이 된다.
// less: [ ]
// equal: [1]
// greater: [8, 7, 6, 5, 4, 3, 2]
//이상적인 pivot은 less와 greater의 요소를 균등하게 분할한다.
//이미 정렬된 Array의 첫 번째 또는 마지막 요소를 pivot으로 선택하면, 퀵 정렬(Quick Sort)이 삽입 정렬(Insertion Sort)과 매우 유사하게 수행되므로, 최악의 경우인 O(n^2)의 성능을 보인다.
//이 문제를 해결하는 한가지 방법은 위에서 소개한 세 가지 pivot 선택 전략의 중앙값을 사용하는 것이다. 위의 예에서는 Array의 첫 요소, 중간 요소, 마지막 요소의 중앙값을 찾아 pivot으로 사용한다.
//이렇게 하면, Array에서 가장 크거나 작은 요소를 선택할 수 없다.
public func medianOfThree<T: Comparable>(_ a: inout [T], low: Int, high: Int) -> Int {
    let center = (low + high) / 2
    
    if a[low] > a[center] {
        a.swapAt(low, center)
    }
    
    if a[low] > a[high] {
        a.swapAt(low, high)
    }
    
    if a[center] > a[high] {
        a.swapAt(center, high)
    }
    
    return center
}
//여기서 a[low], a[center], a[high]의 중앙값(median)을 정렬하여 구할 수 있다. 중앙값(median)은 index center가 되고 이를 반환한다. 이를 사용해 변형된 quick sort를 구현한다.

public func quickSortMedian<T: Comparable>(_ a: inout [T], low: Int, high: Int) {
    if low < high {
        let pivotIndex = medianOfThree(&a, low: low, high: high)
        a.swapAt(pivotIndex, high)
        
        let pivot = partitionLomuto(&a, low: low, high: high)
        
        quicksortLomuto(&a, low: low, high: pivot - 1)
        quicksortLomuto(&a, low: pivot + 1, high: high)
    }
}
//이 함수는 quicksortLomuto의 변형으로, 중앙값을 첫 단계에 추가한다.
var list3 = [12, 0, 3, 9, 2, 21, 18, 27, 1, 5, 8, -1, 8]
quickSortMedian(&list3, low: 0, high: list3.count - 1)
print(list3) // [-1, 0, 1, 2, 3, 5, 8, 8, 9, 12, 18, 21, 27]
//더 나은 구현이 되었다. 여기에서 더 최적화할 수 있다.

//Dutch national flag partitioning
//Lomuto’s algorithm과 Hoare’s algorithm의 문제점은 중복을 제대로 처리하지 못한다는 것이다.
//Lomuto’s algorithm에서 중복값(duplicate)은 less than 부분에서 끝이나며 함께 그룹화되지 않는다.
//Hoare’s algorithm의 경우에는, 모든 부분에서 중복값이 존재할 수 있기 때문에 더 문제가 심각하다.
//중복 요소를 정리하는 해결책은 Dutch national flag partitioning을 사용하는 것이다. 이 방법은 빨강, 흰색, 파랑 세 가지 색으로 나눠진 네덜란드 국기에서 이름을 가져왔다.
//이는 세 개의 구분을 만드는 것과 유사하며, Dutch national flag partitioning는 중복된 요소가 많을 때 사용하기 좋은 기법이다.
public func partitionDutchFlag<T: Comparable>(_ a: inout [T], low: Int, high: Int, pivotIndex: Int) -> (Int, Int) {
    let pivot = a[pivotIndex]
    var smaller = low //pivot보다 더 작은 요소를 발견할 때마다, index를 더 작은 요소로 이동한다. 이는, 해당 index 보다 앞에 오는 모든 요소가 pivot보다 작음을 의미한다.
    var equal = low //비교할 다음 요소 index. pivot과 동일한 요소는 건너 뛴다. 즉, smaller와 equal 사이의 모든 요소는 pivot과 동일한 값을 가진다.
    var larger = high //pivot보다 큰 요소를 발견할 때 마다, index를 더 큰 요소로 이동한다. 이는, 해당 index 다음에 오는 모든 요소가 pivot보다 큼을 의미한다.
    
    while equal <= larger { //요소를 비교하고, 필요한 경우 swap한다.
        if a[equal] < pivot {
            a.swapAt(smaller, equal)
            smaller += 1
            equal += 1
        } else if a[equal] == pivot {
            equal += 1
        } else {
            a.swapAt(equal, larger)
            larger -= 1
        }
    }
    return (smaller, larger) //smaller와 larger는 각각 중간 부분의 첫 요소와 마지막 요소를 가리킨다.
}
//마지막 요소를 pivot index로 선택하는 Lomuto 알고리즘과 동일한 전략을 사용한다.

//Step-by-step
//다음과 같은 정렬되지 않은 Array가 있다.
// [12, 0, 3, 9, 2, 21, 18, 27, 1, 5, 8, -1, 8]
//이 알고리즘은 pivot 선택 전략과는 무관하다. Lomuto 알고리즘을 채택해, 마지막 요소인 8을 pivot으로 선택한다.
//그리고, smaller, equal, larger의 index를 설정한다.
// [12, 0, 3, 9, 2, 21, 18, 27, 1, 5, 8, -1, 8]
//  s
//  e
//                                           l
//가장 먼저 비교할 요소는 12이다. pivot보다 크기 때문에 larger 와 swap되며, 해당 index는 감소한다. //위의 if 에서 else 구문
//equal index는 증가하지 않으므로, 교환(swap)된 요소(element)인 8과 비교한다.
// [8, 0, 3, 9, 2, 21, 18, 27, 1, 5, 8, -1, 12]
//  s
//  e
//                                       l
//선택한 pivot은 여전히 8이다. 다음 요소인 8은 pivot과 동일하므로, equal을 증가 시칸다. //위의 if 에서 else if 구문
// [8, 0, 3, 9, 2, 21, 18, 27, 1, 5, 8, -1, 12]
//  s
//     e
//                                       l
//0은 pivot보다 작으므로 equal, smaller와 교환(swap)하고, samller와 equal을 모두 증가시킨다 //위의 if에서 if 구문
// [0, 8, 3, 9, 2, 21, 18, 27, 1, 5, 8, -1, 12]
//     s
//        e
//                                       l
//smaller, equal, larger의 부분(partition)은 다음과 같다.
// • [low..<smaller] 의 요소는 pivot보다 작다.
// • [smaller..<equal] 의 요소는 pivot과 같다.
// • [larger>..high] 의 요소는 pivot보다 크다.
// • [equal...larger] 의 요소는 아직 비교하지 않았다.
//계속 진행하면, 다음과 같은 상태가 된다.
// [0, 3, -1, 2, 5, 8, 8, 27, 1, 18, 21, 9, 12]
//                  s
//                        e
//                            l
//여기서 27을 비교한다. pivot보다 크므로 1과 교환(swap)되고, lager의 index는 감소한다.
// [0, 3, -1, 2, 5, 8, 8, 1, 27, 18, 21, 9, 12]
//                  s
//                        e
//                        l
//equal과 large가 같아졌지만, loop 조건은 equal <= larger 이므로 계속 진행된다.
//equal 요소는 아직 비교하지 않았다. 여기서는 1으로 pivot보다 작으므로 8(smaller)와 swap되고, smaller의 index가 증가한다.
// [0, 3, -1, 2, 5, 1, 8, 8, 27, 18, 21, 9, 12]
//                     s
//                           e
//                        l
//smaller와 larger가 중간 부분의 첫 요소와 마지막 요소를 가리키게 된다. 해당 함수는 이를 반환해서 세 부분의 경계를 명확하게 할 수 있다.
//Dutch national flag partitioning 알고리즘을 사용해 퀵 정렬을 구현한다.
public func quicksortDutchFlag<T: Comparable>(_ a: inout [T], low: Int, high: Int) {
    if low < high {
        let (middleFirst, middleLast) = partitionDutchFlag(&a, low: low, high: high, pivotIndex: high)
        //middleFirst와 middleLast를 사용해, 재귀적으로 정렬해야 하는 부분을 결정한다. pivot과 동일한 요소가 함께 그룹화되기 때문에 재귀에서 제외할 수 있다.
        
        quicksortDutchFlag(&a, low: low, high: middleFirst - 1)
        quicksortDutchFlag(&a, low: middleLast + 1, high: high)
    }
}

var list4 = [12, 0, 3, 9, 2, 21, 18, 27, 1, 5, 8, -1, 8]
quicksortDutchFlag(&list4, low: 0, high: list4.count - 1)
print(list4) // [-1, 0, 1, 2, 3, 5, 8, 8, 9, 12, 18, 21, 27]




//Key points
// • naïve partitioning은 모든 필터(filter) 함수에서 새 배열(array)를 만든다. 제자리(in place)에서 분할하는 다른 방법들에 비해 비효율적이다.
// • Lomuto’s partitioning은 마지막(last) 요소(element)를 pivot으로 선택한다.
// • Hoare’s partitioning은 첫(first) 요소(element)를 pivot으로 선택한다.
// • 이상적인 pivot은 요소(element)의 수가 균등하게 되도록 각 부분(partition)을 나눈다.
// • pivot 선택을 잘못하게 되면, 퀵 정렬(quick sort)의 성능이 O(n^2)으로 떨어질 수 있다.
// • 3개의 중앙값(Median of three)은 첫(first) 요소, 중간(middle) 요소, 마지막(last) 요소의 중앙값(median)을 취해 pivot을 찾는다.
// • 네덜란드 국기 분할 전략(Dutch national flag partitioning strategy)을 사용하면, 중복(duplicate) 요소(element)를 효율적으로 구성할 수 있다.
