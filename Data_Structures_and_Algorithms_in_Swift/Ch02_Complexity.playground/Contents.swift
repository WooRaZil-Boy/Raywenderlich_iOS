//:Chapter2: Complexity

//아키텍처 관점에서 확장성은 앱을 쉽게 변경할 수 있는 것이다.
//데이터베이스 관점에서 확장성은 데이터를 데이터베이스에 저장하거나 검색하는 데 걸리는 시간에 관한 것이다.
//그리고 알고리즘 관점에서의 확장성은 입력의 크기가 증가함에 따라 실행 시간 및 메모리 사용량 측면에서의 성능을 나타낸다.
//작은 양의 데이터로 작업할 때에는 저성능의 알고리즘도 빠르게 느껴질 수 있지만, 데이터의 양의 늘어남에 따라 성능 저하가 두드러진다.
//따라서 얼마나 성능이 저하되는지 정량화하는 방법을 이해하는 것은 중요하다.
//여기에는 실행 시간과 메모리 사용이라는 두 가지 차원에서 알고리즘의 확장성을 측정하는 Big O 표기법이 있다.




//Time complexity
//최신 하드웨어의 성능 덕분에 소량의 데이터의 경우에는 저성능의 알고리즘도 빠르게 보일 수 있지만, 데이터의 크기가 증가할 수록 늘어나는 비용이 명백해진다.
//시간 복잡도(Time complexity)는 입력의 크기가 증가함에 따라 알고리즘을 실행하는 데 필요한 시간을 측정한 것이다.

//Constant time
//상수 시간 (constant time) 알고리즘은 입력의 크기에 관계없이 동일한 실행 시간을 갖는 알고리즘이다.
func checkFirst(names: [String]) {
    if let first = names.first {
        print(first)
    } else {
        print("no names")
    }
}
//이 경우에는 names 배열의 크기가 함수의 실행 시간에 영향을 미치지 않는다. 입력에 10개의 항목이 있든 1천 만개의 항목이 있든 관계없이 배열의 첫 요소만 검사한다.
//data와 time 사이의 그래프를 그려보면(p.29), 입력 데이터가 증가해도 알고리즘에 걸리는 시간은 변하지 않고 일정하다.
//Big O notation로 다양한 크기의 시간 복잡성을 나타낸다. 일정한 상수의 시간이 걸리는 알고리즘의 Big O 표기법은 O(1)이다.

//Linear time
func printNames1(names: [String]) {
    for name in names {
        print(name)
    }
}
//이 함수는 문자열의 모든 요소를 출력한다. 입력 배열의 크기가 증가함에 따라 같은 양만큼 for-loop의 반복 횟수는 증가한다.
//이러한 것을 선형 시간(Linear time) 복잡도라고 한다.
//data와 time 사이의 그래프를 그려보면(p.30), 데이터의 양이 증가하는 만큼 실행 시간도 같은 양만큼 증가하는 것을 알 수 있다.
//선형 시간에 대한 Big O 표기법은 O(n)이다.
//시간 복잡도는 비용이 큰 것을 우선한다. ex. 2 개의 loop와 6개의 O(1) 복잡도 메서드를 호출하는 함수가 있다고 할 때,
//시간 복잡도를 O(2n+6)으로 나타내지 않는다. 모든 상수는 Big O 표기법에서 삭제되어 O(n)이 된다.
//하지만, Big O 표기법과 다르게, 절대적인 효율성을 최적화 하는 것이 중요할 수도 있다.
//여러 기업에서는 Big O 표기법에서 무시되는 상수(constant) 시간을 줄이기 위해 수 백만 달러를 R&D에 투자한다.
//ex. 최적화 알고리즘이 구현된 GPU는 CPU보다 100 배 이상 빠르지만, Big O 표기법으로는 그대로 O(n)이다.

//Quadratic time
//n squared(n의 제곱)이라고도 하는 이차 시간(Quadratic time) 복잡도는 입력 크기의 제곱에 비례하는 시간이 걸리는 알고리즘이다.
func printNames2(names: [String]) {
    for _ in names {
        for name in names {
            print(name)
        }
    }
}
//이 함수에서는 배열에 10개의 요소가 있다면 100개가 출력이 된다. 입력을 1 늘려, 11개의 요소가 된다면, 출력은 121번 된다.
//n 제곱 알고리즘은 데이터 크기가 증가할 때, 제어할 수 없게 되는 시점이 선형 시간보다 더 이르다.
//data와 time 사이의 그래프를 그려보면(p.31), 데이터의 크기가 증가함에 따라 알고리즘을 실행하는 데 걸리는 시간이 크게 증가한다.
//따라서, n 제곱(이차 시간) 알고리즘은 성능이 좋지 않다. Big O 표기법은 O(n²)이다.
//선형 시간 알고리즘이 아무리 비효율적으로 작성되어도, 충분히 큰 n 입력에 대해선 가장 최적화된 이차 시간 알고리즘 보다 항상 빠르게 실행된다.

//Logarithmic time
//Linear, Quadratic 시간복잡도 알고리즘은 모두 각 요소를 한 번 이상 검사한다. 입력에 대해 sub set만 검사해도 된다면, 속도가 더 빨라 질 것이다.
//이 범주에 속하는 알고리즘은 입력 데이터에 대한 몇 가지 가정을 기반으로 일부 검사를 뛰어 넘길 수 있는 알고리즘들이다.
//ex. 정렬된 정수 배열에 특정 값이 존재하는지 찾는 경우, 처음부터 끝가지 하나씩 모든 요소를 확인한다면 O(n)이 된다.
//하지만, 입력이 정렬되어 있으므로 최적화할 수 있다.
let numbers = [1, 3, 56, 66, 68, 80, 99, 105, 450]
func naiveContains1(_ value: Int, in array: [Int]) -> Bool {
    for element in array {
        if element == value {
            return true
        }
    }
    return false
}
//위 함수는 naive algorithm으로, 순차적으로 배열의 처음부터 끝까지 반복한다. 하지만, 배열이 정렬되어있으므로 중간값을 확인하여 불필요한 절반을 제거할 수 있다.
func naiveContains2(_ value: Int, in array: [Int]) -> Bool {
    guard !array.isEmpty else { return false }
    let middleIndex = array.count / 2
    if value <= array[middleIndex] { //찾으려는 값이 중간값보다 작거나 같은 경우
        for index in 0...middleIndex { //배열의 중간값 이후의 절반은 skip할 수 있다.
            if array[index] == value {
                return true
            }
        }
    } else {
        for index in middleIndex..<array.count { //찾으려는 값이 중간값보다 큰 경우
            if array[index] == value { //배열의 중간값 이전의 절반은 skip할 수 있다.
                return true
            }
        }
    }
    return false
}
//위의 함수는 최적화를 수행하여, 배열의 절반만 검사하므로 비교 횟수를 절반으로 줄인다. 이 방법을 반복적으로 적용한 알고리즘이 Binary Search 이다.
//필요한 부분을 절반씩 줄여나가는 알고리즘은 로그 시간(Logarithmic time) 복잡도를 가진다.
//data와 time 사이의 그래프를 그려보면(p.33), 입력 데이터가 증가함에 따라 알고리즘 실행 시간이 느리게 증가한다.
//입력 크기가 100인 경우 50번의 비교를 하고, 입력의 크기가 100,000인 경우에는 50,000번의 비교를 한다. 데이터가 많을수록 절반이 줄어든다.
//따라서 데이터가 증가할수록 그래프는 수평에 가까워진다. Logarithmic time 알고리즘은 제한적이지만, 적용할 수 있는 상황에서는 매우 효율적이다.
//로그 시간(Logarithmic time) 복잡도의 Big O 표기법은 O(log n)이다.

//Quasilinear time
//또 다른 일반적인 시간 복잡도로 유사 선형 시간(Quasilinear time) 복잡도가 있다.
//유사 선형 시간 복잡도는 선형(Linear) 시간보다는 성능이 떨어지지만, 이차(Quadratic) 시간보다는 훨씬 뛰어나다.
//가장 일반적인 알고리 중 하나로, 대표적인 예는 Swift의 sort 메서드이다.
//유사 선형 시간(Quasilinear time) 복잡도의 Big O 표기법은 선형(linear)과 로그(logarithmic)의 곱인 O(n log n)이다.
//선형(Linear) 시간보다는 느리지만, 대다수의 다른 시간 복잡도보다는 성능이 뛰어나다.
//data와 time 사이의 그래프를 그려보면(p.34), 이차 (Quadratic) 시간 복잡도와 비슷하지만, 큰 입력 데이터에 대해 탄력적이다.

//Other time complexities
//다른 시간 복잡도도 존재하지만, 위에서 설명한 5가지 시간 복잡도가 일반적이다.
//이런 시간 복잡도에는 다항 시간(polynomial time), 지수 시간(exponential time), 팩토리얼 시간(factorial time) 등이 있다.
//시간 복잡도는 성능에 대한 높은 수준의 개요(high-level overview) 일뿐, 일반적인 순위 체계를 넘어 알고리즘 속도를 판단하지 않는다는 점을 유의해야 한다.
//ex. 동일한 시간 복잡도의 알고리즘에서 하나의 알고리즘이 다른 하나보다 훨씬 빠를 수 있다.
//또한, 데이터 크기가 작을 경우, 시간 복잡도로 실제 속도를 정확하게 측정하지 못할 수 있다.
//ex. 이차(quadratic) 알고리즘인 삽입 정렬(insertion sort)의 경우 데이터가 작다면, 합병 정렬(merge sort)와 같은 유사 선형 시간(Quasilinear time)보다 빠를 수 있다.
//삽입 정렬은 알고리즘 수행을 위한 추가 메모리를 할당할 필요가 없지만, 병합 정렬은 여러 배열을 할당해야 하기 때문이다.
//입력 데이터가 작은 경우, 메모리 할당은 알고리즘이 사용해야하는 요소 수에 비해 비용이 비쌀 수 있다.

//Comparing time complexity
//1에서 n까지의 숫자를 더하는 코드를 작성한다.
func sumFromOne1(upto n: Int) -> Int {
    var result = 0
    for i in 1...n {
        result += i
    }
    return result
}
sumFromOne1(upto: 10000)
//위의 코드는 loop가 10,000 번 반복되고, 50,005,000을 반환한다. 시간 복잡도는 O(n)이다.
//playground에서 해당 함수를 실행하는 데에 약간의 시간이 걸린다.
func sumFromOne2(upto n: Int) -> Int {
    (1...n).reduce(0, +)
}
sumFromOne2(upto: 10000)
//standard library에서 컴파일된 코드를 호출하기 때문에 이 코드가 이전 코드보다 빠르다.
//하지만, reduce()는 n번의 덧셈을 하기 때문에 여전히 시간 복잡도는 O(n)이다. 동일한 Big O이지만, 코드를 컴파일하기 때문에 상수가 더 작다.
func sumFromOne3(upto n: Int) -> Int {
    (n + 1) * n / 2
}
sumFromOne3(upto: 10000)
//위의 함수는 Fredrick Gauss가 발견한 법칙을 사용한다. 간단한 산술을 사용해 합계를 계산할 수 있다.
//이 알고리즘의 시간 복잡도는 O(1)으로 O(n)알고리즘은 이 보다 빠르게 완료될 수 없다.
//항상 상수 시간 (constant time) 알고리즘이 권장된다(하지만, 현실적으로 많지 않다).
//이 최적화된 코드도 loop 안에 있다면, Linear time이 되어 버린다. 이전의 O(n) 버전은 이차 시간(quadratic time)에서 하나의 외부(outer) loop이다.




//Space complexity
//시간 복잡도(Time complexity)가 알고리즘의 확장성을 예측하는 유일한 방법은 아니다.
//공간 복잡도(Space complexity)는 알고리즘을 실행하는 데 필요한 리소스를 측정한다. 컴퓨터에서 알고리즘 리소스는 메모리이다.
func printSorted1(_ array: [Int]) {
    let sorted = array.sorted()
    for element in sorted {
        print(element)
    }
}
//위 함수는 정렬된 배열의 사본을 변수에 할당하고, 배열의 요소를 출력한다. 여기서 할당되는 메모리를 분석해 보면,
//array.sorted()는 동일한 크기의 새로운 배열을 생성하므로, printSorted() 함수의 공간 복잡도는 O(n)이다.
//해당 함수는 단순해 사용하기 편하지만, 메모리 할당량을 줄여야 하는 상황이 종종 있을 것이다.
func printSorted2(_ array: [Int]) {
    guard !array.isEmpty else { return } //배열이 비어 있는지 확인한다.
    
    var currentCount = 0 //출력문의 수를 저장한다.
    var minValue = Int.min //출력된 마지막 값을 저장한다.
    
    for value in array {
        if value == minValue { //minValue와 일치하는 모든 값을 출력하고, currentCount를 업데이트한다.
            print(value)
            currentCount += 1
        }
    }
    
    while currentCount < array.count {
        var currentValue = array.max()!
        
        for value in array {
            if value < currentValue && value > minValue { //minValue보다 큰 값 중 가장 작은 값을 currentValue에 저장한다.
                currentValue = value
            }
        }
        
        var printCount = 0 //??
        for value in array {
            if value == currentValue { //배열에서 currentCount와 일치하는 모든 값을 출력하고, currentCount를 업데이트한다.
                print(value)
                currentCount += 1
            }
        }
        
        minValue = currentValue //minValue를 currentValue로 설정하여 다음 loop에서 그 다음의 최소값을 찾는다.
    }
}
//이 구현의 공간 복잡도는 상수(constraint) 이다. 배열을 여러 번 반복하여, 각 반복에서 다음으로 작은 값을 출력한다.
//위의 알고리즘은 몇개의 변수만 메모리에 할당하므로 공간 복잡도는 O(1)이 된다. 정렬된 배열을 순서대로 출력하기 위해 전체 배열을 할당하는 이전 함수와 대조적이다.




//Other notations
//Big O 표기법이 알고리즘을 평가하는 가장 일반적인 척도이지만, 다른 표기법도 있다.
// - Big Omega : Big O와는 반대로 최상의 소요시간을 측정한다. 하지만, 이를 얻는 것이 불가능한 경우도 있기 때문에 Big O 만큼 유용하지는 않다.
// - Big Theta : 최상의 경우와 최악의 경우가 동일한 알고리즘의 소요시간을 측정하는 데 사용된다.




//Key points
// • 시간 복잡도(Time complexity)는 입력 크기가 증가함에 따라 알고리즘을 실행하는 데 필요한 시간을 측정한 것이다.
// • 상수 시간(Constant time), 선형 시간(Linear time), 이차 시간(Quadratic time), 로그 시간(Logarithmic time), 유사 선형 시간(Quasilinear time)에 대해 알고,
//  해당 시간 복잡도의 비용 순서를 정렬할 수 있어야 한다.
// • 공간 복잡도(Space complexity)는 알고리즘 실행에 필요한 자원(resource, 메모리)를 측정하는 것이다.
// • Big O 표기법은 시간 복잡도와 공간 복잡도의 일반적인 형태를 나타내기 위해 사용된다.
// • 시간 복잡도와 공간 복잡도는 high-level 확장성 척도로, 알고리즘 자체의 실제 속도를 측정하지는 않는다.
// • 데이터가 적은 경우, 일반적으로 시간 복잡도는 무관해 진다. 유사 선형 시간(quasilinear time) 알고리즘이 선형 시간(linear time) 알고리즘보다 느릴 수 있다.
