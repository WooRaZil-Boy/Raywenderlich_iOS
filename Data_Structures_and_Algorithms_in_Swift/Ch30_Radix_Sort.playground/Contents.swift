//Chapter 30: Radix Sort

//지금까지 정렬 알고리즘은 정렬 순서를 결정하기 위해 비교에 의존했다. Radix Sort(기수 정렬)은 linear time(선형 시간)으로 정수를 정렬하기 위한 비 비교 알고리즘(non-comparative algorithm) 이다.
//기수 정렬은 해결하고자 하는 문제에 따라 여러 가지 구현 방법이 있다.
//여기서는 least significant digit(LSD, 가장 작은 자리수 부터 정렬)를 이용하는 정렬에 초점을 둔다.




//Example
//기수 정렬의 작동 방식을 알아보기 위해 다음과 같은 배열을 선언한다.
var array = [88, 410, 1772, 20]
//기수 정렬은 정수의 위치 표기법에 의존한다. //p.294
//먼저, Array를 가장 작은 자리수를 기준으로 하는 bucket들로 나눈다.
//위의 array를 나누면, (0 : 410, 20 | 2 : 1772 | 8 : 88)이 된다(일의 자리 정수를 기준으로 나눈다).
//그런 다음 bucket을 순서대로 비우면 다음과 같이 부분적으로 정렬된 Array가 생성된다.
array = [410, 20, 1772, 88] //일의 자리(가장 작은 자리수) 숫자 기준으로 정렬한다.
//다음으로 다음 자리수(10의 자리)로 위의 절차를 반복한다. (1 : 410 | 2 : 20 | 7 : 1772 | 8 : 88)
array = [410, 20, 1772, 88] //순서가 변경되진 않았다.
//다음으로 다시 다음 자리수(100의 자리)로 위의 절차를 반복한다. (0 : 20, 88 | 4 : 410 | 7 : 1772)
array = [20, 88, 410, 1772] //100의 자리가 없는 경우에는 0으로 간주된다.
//마지막으로 1000의 자리수를 고려한다. (0 : 20, 88, 410 | 1 : 1772)
array = [20, 88, 410, 1772]
//여러 개의 숫자가 동일한 bucket에 있으면 상대적인 순서는 변경되지 않는다.
//ex. 100자리수에서 0 bucket의 경우, 20이 88보다 먼저 온다. 이전 단계에서 20을 80보다 낮은 bucket에 넣었으므로, 이 순서대로 100 자리수 bucket에 넣어준다.




//Implementation
extension Array where Element == Int { //요소가 Int인 Array에 radixSort()를 추가한다.
    public mutating func radixSort() {
        let base = 10 //10의 자리 기준으로 정렬한다. 알고리즘에서 이 값을 여러번 반복해서 사용하게 되므로 상수로 선언해 준다.
        var done = false //정렬이 완료되었는지 여부를 결정. 기수 정렬은 여러 pass에 거쳐서 반복되므로 정렬 완료 여부를 추적하는 속성이 필요하다.
        var digits = 1
        while !done {
            done = true
            var buckets: [[Int]] = .init(repeating: [], count: base) //2차원 배열을 사용하여 Bucket을 초기화한다. 10 단위 자리수를 기준으로 하기에 10개의 bucket이 필요하다.
            forEach { //각 숫자를 올바른 bucket에 넣는다. //Array(self)의 forEach
                number in
                let remainingPart = number / digits //자리수로 나눈다.
                let digit = remainingPart % base //나머지를 가져와
                buckets[digit].append(number) //bucket에 넣는다.
                if remainingPart > 0 { //forEach는 모든 정수(요소)를 반복하므로, 정수 중 하나에 정렬되지 않은 숫자가 있다면 계속 진행해야 한다.
                  done = false
                }
            }
            digits *= base //검사할 다음 자리수로 업데이트 한다.
            self = buckets.flatMap { $0 } //bucket을 사용해 Array를 업데이트 한다.
            //flatMap는 2차원 배열을 1차원 배열로 병합(평탄화, flatten)한다.
        }
    }
}

//Bucket Sort
//bucket을 생성하여 정렬을 구현한다.

//When do you stop?
//while loop에 종료 조건을 추가해 줘야 한다.
example(of: "radix sort") {
    var array = [88, 410, 1772, 20]
    print("Original array: \(array)") // Original: [88, 410, 1772, 20]
    array.radixSort()
    print("Radix sorted: \(array)") // Radix sorted: [20, 88, 410, 1772]
}
//기수 정렬은 가장 빠른 정렬 알고리즘 중 하나이다. 기수 정렬의 평균 시간 복잡도는 O(k * n)이다. 여기서 k는 가장 큰 숫자의 유효한 자리수이고, n은 Array의 정수(요소 수)이다.
//기수 정렬은 k가 일정할 때 가장 잘 작동하며, 이는 Array의 모든 숫자(요소)가 동일한 유효 자리수를 가질 때이다. 이 경우 시간 복잡도는 O(n)이 된다.
//기수 정렬은 각 bucket을 저장할 공간이 필요하기 때문에 공간 복잡도는 O(n)이다.
//여기서는 least significant digit로 구현했지만, most significant digit 로 구현할 수도 있다.
//이 방법은 반대로 가장 큰 자리수를 우선시하여 정렬하며, 대표적인 예로 문자열 정렬이 있다.
