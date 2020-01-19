//Chapter 26: O(n^2) Sorting Algorithms

//O(n^2) 시간 복잡도는 성능이 좋지 않지만, 이 알고리즘들은 이해하기 쉽고 일부 시나리오에서는 유용하다.
//이러한 알고리즘은 공간 효율적이며, 상수 O(1) 추가 메모리 공간만 필요하다. 작은 데이터 세트의 경우, 이러한 정렬들은 보다 복잡한 정렬들에 비해 매우 효과적이다.
//대표적인 O(n^2) 정렬 알고리즘은 다음과 같다.
// • Bubble sort (거품 정렬)
// • Selection sort(선택 정렬)
// • Insertion sort(삽입 정렬)
//이 알고리즘 모두 comparison-based(비교 기반) 정렬 방법이다. 요소를 정렬하기 위해 less-than operator(<) 등을 사용한다.
//이런 비교가 호출되는 횟수로 정렬기법의 일반적인 성능을 측정한다.




//Bubble sort
//가장 간단한 정렬 중 하나인 버블 정렬은 인접 value 반복적으로 비교하고, 필요한 경우 이를 교환하여 정렬을 수행한다.
//따라서 큰 값을 가진 요소들 일 수록 Collection이 끝까지 "bubble up" 된다(정렬 방향을 반대로 하면, 작은 값일 수록).

//Example
//[9, 4, 10, 3]이 있을 때, 버블 정렬 알고리즘의 단일 pass는 다음과 같은 단계로 구성된다. //p.267
// • Collection의 시작 부분에서 부터 시작한다. 9와 4를 비교해 보면, 큰 값이 앞서 나오므로 swap이 필요하다. 따라서, 교환 이후 Collection은 [4, 9, 10, 3]이 된다.
// • Collection의 다음 index로 이동한다. 9와 10일 비교해 보면 순서대로 되어 있다.
// • Collection의 다음 index로 이동한다. 10과 3을 비교해 보면, swap이 필요하다. 따라서 Collection은 [4, 9, 3, 10]이 된다.
//single pass를 완료해도, 전체 Collection이 완전히 정렬되는 경우는 거의 없다. 그러나 최대값(10)이 Collection의 끝으로 "bubble up" 되었다.
//이후 다음 pass는 다시 첫 번째 index에 대해 동일하게 진행된다. //p.267
//[4, 9, 3, 10] -> [4, 3, 9, 10] -> [3, 4, 9, 10]
//swap하지 않고도 Collection 전체를 pass 할 수 있을 때 버블 정렬은 완료된다. 최악의 경우 n-1 번의 pass가 필요하며, 여기서 n은 Collection의 요소 수 이다.

//Implementation
public func bubbleSort<Element>(_ array: inout [Element]) where Element: Comparable {
    guard array.count >= 2 else { //2개 이하의 요소를 가지고 있으면 정렬할 필요가 없다.
        return
    }
    
    for end in (1..<array.count).reversed() { //single pass는 Collection의 끝으로 가장 큰 value를 버블링 한다.
        //모든 pass는 이전 pass보다 하나 더 적은 수의 비교를 수행하므로(pass가 끝날 때마다 큰 값 순으로 하나씩 완전히 정렬된다),
        //기본적으로 각 pass마다 Array를 하나씩 줄인다.
        var swapped = false
        for current in 0..<end { //이 loop는 단일 pass를 수행한다.
            if array[current] > array[current + 1] { //인접한 값을 비교하고 필요한 경우 swap한다.
                array.swapAt(current, current + 1)
                swapped = true
            }
        }
        if !swapped { //해당 pass에서 교환한 값이 없다면, Collection이 완전히 정렬된 것이므로 빠르게 반환할 수 있다.
            return
        }
    }
}

example(of: "bubble sort") {
    var array = [9, 4, 10, 3]
    print("Original: \(array)") // Original: [9, 4, 10, 3]
    bubbleSort(&array)
    print("Bubble sorted: \(array)") // Bubble sorted: [3, 4, 9, 10]
}
//이미 정렬되어 있는 경우 버블 정렬의 시간 복잡도는 O(n)이다(최선). 최악과 평균의 경우 시간 복잡도는 O(n^2)으로 가장 매력적이지 않은 정렬 알고리즘 중 하나이다.




//Selection sort
//선택 정렬은 버블 정렬의 기본 개념을 따르지만, swapAt 연산 횟수를 줄여 알고리즘을 개선한다. 선택 정렬은 각 pass의 끝에서만 swap 한다.

//Example
//[9, 4, 10, 3]이 있을 때, 선택 정렬은 각 pass에서 정렬되지 않은 가장 낮은 값을 찾아 제자리로 swap 한다. //p. 269
// 1. 3이 가장 낮은 값이므로 9와 swap한다. [3, 4, 10, 9]
// 2. 그다음 가장 낮은 값은 4이다. 정렬된 위치에 있으므로 그대로 둔다. [3, 4, 10, 9]
// 3. 마지막으로 9와 10을 swap한다. [3, 4, 9, 10]

//Implementation
public func selectionSort<Element>(_ array: inout [Element]) where Element: Comparable {
    guard array.count >= 2 else {
        return
    }
    
    for current in 0..<(array.count - 1) { //마지막 요소를 제외한 Collection의 모든 요소에 대해 pass를 수행한다.
        //다른 모든 요소가 올바르게 정렬되어 있다면, 마지막 요소도 포함되므로, 여기에 마지막 요소를 포함할 필요는 없다.
        var lowest = current
        for other in (current + 1)..<array.count { //모든 pass마다, 남은 Collection에서 가장 낮은 값을 가진 요소를 찾는다.
            if array[lowest] > array[other] {
                lowest = other
            }
        }
        if lowest != current { //해당 요소가 current가 아닌 경우 swap 한다. //current가 최소값이 아닌 경우
            array.swapAt(lowest, current)
        }
    }
}

example(of: "selection sort") {
    var array = [9, 4, 10, 3]
    print("Original: \(array)") // Original: [9, 4, 10, 3]
    selectionSort(&array)
    print("Selection sorted: \(array)") // Selection sorted: [3, 4, 9, 10]
}
//버블 정렬과 마찬가지로 선택정렬은 최선, 최악, 평균 시간 복잡도는 O(n^2)이다(버블 정렬에선 이미 정렬된 경우에만 O(n)).
//좋지 않은 성능이지만, 이해하기 쉽고 버블 정렬보다는 성능이 좋다.




//Insertion sort
//삽입 정렬은 더 유용하다. 버블 정렬, 선택 정렬과 마찬가지로 시간 복잡도는 O(n^2)이지만, 성능은 더 뛰어나다.
//삽입 정렬은 데이터가 정렬되어 있을수록 할 작업이 적어진다. 데이터가 이미 정렬된 경우 삽입 정렬의 시간 복잡도는 O(n)이다.
//Swift standard library의 정렬 알고리즘은 정렬되지 않은 작은(20개 이하의 요소) partition의 경우, 삽입 정렬을 응용한 hybrid 방식을 사용한다.

//Example
//[9, 4, 10, 3]이 있을 때, 삽입 정렬은 왼쪽에서 오른쪽으로 반복된다. 각각의 요소는 정확한 위치에 도달할 때까지 왼쪽으로 이동한다. //p.272
// 1. 비교할 이전의 요소가 없기 때문에, 첫 번째 요소를 무시한다. [9, 4, 10, 3]
// 2. 4와 9를 비교하여 4를 왼쪽으로 바꾸면서 9와 위치를 swap한다. 이미 정렬된 부분과 비교해서 맞는 위치에 삽입한다. [4, 9, 10, 3]
// 3. 10은 이전 요소와 비교해 올바른 위치에 있으므로 이동할 필요가 없다. [4, 9, 10, 3]
// 4. 마지막으로 3을 각각 10, 9, 4와 비교하고 교환하여 가장 앞으로 이동시킨다. [3, 4, 9, 10]
//삽입 정렬에서 최상의 경우는 이미 정렬되어 있고, 왼쪽 이동(shift)필요하지 않을 때이다.

//Implementation
public func insertionSort<Element>(_ array: inout [Element]) where Element: Comparable {
    guard array.count >= 2 else {
        return
    }
    
    for current in 1..<array.count { //삽입 정렬은 왼쪽에서 오른쪽으로 한 번 반복해야 한다.
        for shifting in (1...current).reversed() { //current index를 역으로 하여, 필요할 때 왼쪽으로 shifting 할 수 있다.
            if array[shifting] < array[shifting - 1] { //필요한 만큼 요소를 왼쪽으로 계속 이동 시킨다.
                array.swapAt(shifting, shifting - 1)
            } else { //요소가 제자리에 오면, loop를 종료하고 다음 요소를 시작한다.
                break
            }
        }
    }
}

example(of: "insertion sort") {
    var array = [9, 4, 10, 3]
    print("Original: \(array)") // Original: [9, 4, 10, 3]
    insertionSort(&array)
    print("Insertion sorted: \(array)") // Insertion sorted: [3, 4, 9, 10]
}
//삽입 정렬은 데이터가 이미 정렬되어 있는 경우 가장 빠른 알고리즘 중 하나이다. 정렬이 되어 있는 경우 빠르다는 것이 당연하다고 생각할 수 있지만, 모든 정렬 알고리즘이 그런 것은 아니다.
//실제로 많은 요소가 이미 정렬되어 있는 경우, 삽입 정렬은 좋은 성능을 보인다.




//Generalization
//Array 이외의 Collection에서도 사용할 수 있도록 정렬 알고리즘을 일반화한다. 하지만, 어떤 Collection type을 사용하는 지는 알고리즘에 따라 달라진다.
// • Insertion sort(삽입 정렬)은 요소를 이동할 때, Collection을 역 방향으로 순회한다. 따라서, collection은 반드시 BidirectionalCollection type이어야 한다.
// • Bubble sort(거품 정렬)과 Selection sort(선택 정렬)은 Collection을 일방향으로만 순회하므로, 모든 Collection type에서 사용할 수 있다.
// • 모든 경우에, 요소를 swap해야 하므로 MutableCollection type이어야 한다.
//Bubble sort를 구현한다.
public func bubbleSort<T>(_ collection: inout T) where T: MutableCollection, T.Element: Comparable {
    guard collection.count >= 2 else {
        return
    }
    
    for end in collection.indices.reversed() {
        var swapped = false
        var current = collection.startIndex
        while current < end {
            let next = collection.index(after: current)
            if collection[current] > collection[next] {
                collection.swapAt(current, next)
                swapped = true
            }
            current = next
        }
        if !swapped {
            return
        }
    }
}
//알고리즘은 동일하게 유지된다. Collection의 index를 사용하도록 loop를 업데이트하면 된다.
//선택 정렬을 구현한다.
public func selectionSort<T>(_ collection: inout T) where T: MutableCollection, T.Element: Comparable {
    guard collection.count >= 2 else {
        return
    }
    
    for current in collection.indices {
        var lowest = current
        var other = collection.index(after: current)
        while other < collection.endIndex {
            if collection[lowest] > collection[other] {
                lowest = other
            }
            other = collection.index(after: other)
        }
        if lowest != current {
            collection.swapAt(lowest, current)
        }
    }
}
//삽입 정렬을 구현한다.
public func insertionSort<T>(_ collection: inout T) where T: BidirectionalCollection & MutableCollection, T.Element: Comparable {
    guard collection.count >= 2 else {
        return
    }
    
    for current in collection.indices {
        var shifting = current
        while shifting > collection.startIndex {
            let previous = collection.index(before: shifting)
            if collection[shifting] < collection[previous] {
                collection.swapAt(shifting, previous)
            } else {
                break
            }
            shifting = previous
        }
    }
}
//약간의 코드 변경으로 알고리즘을 일반화할 수 있다.
