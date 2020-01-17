//Chapter 20: Binary Search

//이진 탐색은 시간 복잡도가 O(log n)인 가장 효율적인 검색 알고리즘 중 하나이다.
//이것은 balanced binary search tree 내에서 요소를 검색하는 것과 비슷하다.
//이진 탐색을 사용하려면 다음 두 가지 조건을 충족해야 한다.
// • Collection은 상수 시간(constant time) 내에 index 작업을 할 수 있어야 한다.
//  이는 해당 Collection이 RandomAccessCollection이어야 함을 의미한다.
// • Collection은 정렬 되어 있어야 한다.




//Example
//선형 탐색(linear search)과 비교해 보면, 이진 탐색의 장점을 쉽게 알 수 있다.
//Swift의 Array 유형은 linear search를 사용하여 firstIndex(of:) 메서드를 구현한다.
//즉, 전체 Collection을 탐색하거나, 해당 요소를 찾을 때까지 탐색한다. //p.216
//이진 탐색은 Collection이 이미 정렬되어 있다는 있기 때문에 다르게 처리할 수 있다. //p.216
//다음과 같은 방식으로 탐색을 수행한다.

//Step 1: Find middle index
//Collection의 중간 index를 찾는다. //p.216

//Step 2: Check the element at the middle index
//다음 단계는 중간 index에 저장된 요소를 확인한다. 찾는 값과 일치하면 index를 반환하고 그렇지 않으면 다음 단계로 넘어간다.

//Step 3: Recursively call binary Search
//마지막 단계는 이진 탐색을 재귀적으로 호출하는 것이다. 하지만, 이번에는 찾는 값에 따라 중간 index의 왼쪽 또는 오른쪽에 있는 요소만 탐색한다.
//찾는 값이 중간값(중간 index의 value)보다 작은 경우 왼쪽의 하위 sequence를 탐색한다.
//찾는 값이 중간값(중간 index의 value)보다 큰 경우 오른쪽의 하위 sequence를 탐색한다.
//각 단계는 수행해야 하는 비교의 절반을 효과적으로 제거한다. //p.217
//Collection을 더 이상 왼쪽과 오른쪽으로 나눌 수 없거나, 원하는 값을 찾을 때까지 세 단계를 반복한다.
//이진 탐색(Binary search)은 이러한 방식으로 O(log n) 시간 복잡도를 달성한다.






//Implementation
public extension RandomAccessCollection where Element: Comparable {
    //이진 탐색은 RandomAccessCollection을 구현하는 type에 대해서만 구현할 수 있므로, RandomAccessCollection를 extension 해 구현한다.
    //해당 extension은 Element가 Comparable을 준수하는 경우로 제한된다.
    func binarySearch(for value: Element, in range: Range<Index>? = nil) -> Index? {
        //이진 탐색은 재귀적으로 검색 범위를 전달할 수 있어야 한다.
        //여기서 매개변수 range는 optional이므로 범위를 지정하지 않은 경우(nil)에는 전체 Collection을 검색한다.
        let range = range ?? startIndex..<endIndex //range가 nil(default)인지 확인한다.
        //nil이라면, 전체 collection을 range로 지정한다.
        
        guard range.lowerBound < range.upperBound else { //range에 하나 이상의 요소가 포함되어 있는 지 확인한다.
            return nil //해당 range에 요소가 하나도 없다면 nil을 반환한다(검색 실패, 찾는 값이 해당 collection에 없음).
        }
        
        let size = distance(from: range.lowerBound, to: range.upperBound)
        let middle = index(range.lowerBound, offsetBy: size / 2) //중간 index를 찾는다.
        
        //중간 index의 value를 찾는 value와 비교한다.
        if self[middle] == value { //일치
            return middle
        } else if self[middle] > value { //중간값보다 작은 경우
            return binarySearch(for: value, in: range.lowerBound..<middle)
        } else { //중간값보다 큰 경우
            return binarySearch(for: value, in: index(after: middle)..<range.upperBound) //middle + 1 부터 시작해야 한다.
        }
    }
}

let array = [1, 5, 15, 17, 19, 22, 24, 31, 105, 150]

let search31 = array.firstIndex(of: 31)
let binarySearch31 = array.binarySearch(for: 31)

print("firstIndex(of:): \(String(describing: search31))") // index(of:): Optional(7)
print("binarySearch(for:): \(String(describing: binarySearch31))") // binarySearch(for:): Optional(7)
//이진 탐색은 프로그래밍 인터뷰에 자주 나오는 효율적인 알고리즘이다. "정렬된 배열이며..." 라는 언급이 있을 때마다 이진 탐색 알고리즘을 고려하는 것이 좋다.
//또한, 주어진 문제에서 검색에 O(n^2)의 시간 복잡도가 걸릴 것 같다면,
//이진 탐색을 사용해 O(n log n) 까지 시간 복잡도를 줄일 수 있는 사전 정렬(up-front sorting)을 고려해 보는 것이 좋다.
//때로는, 이진 탐색을 사용하기 위해 Collection을 정렬하는 것이 유용할 수 있다.

