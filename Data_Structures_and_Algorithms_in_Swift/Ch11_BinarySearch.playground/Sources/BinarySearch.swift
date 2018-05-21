public extension RandomAccessCollection where Element: Comparable {
    //이진 검색은 RandomAccessCollection에서만 실행할 수 있다. 컬렉션의 요소는 Comparable를 구현해야 한다.
    func binarySearch(for value: Element, in range: Range<Index>? = nil) -> Index? {
        //이진 검색은 재귀적으로 호출된다. range는 optional이므로 인자 없이 호출될 수 있다(이 경우는 전체 컬렉션 범위에 대한 검색).

        let range = range ?? startIndex..<endIndex
        //컬렉션에서는 양끝을 startIndex, endIndex으로 나타낸다(cf. lowerBound, upperBound이 아니다).
        //range가 nil인지 확인한다. nil이라면 범위는 컬렉션(self)의 전체가 된다.
        
        guard range.lowerBound < range.upperBound else {
            //range의 양 끝은 각각 lowerBound, upperBound이다(cf. startIndex, endIndex가 아니다).
            //range에는 최소 하나 이상의 요소가 있어야 한다. 없다면 nil 반환
            return nil
        }
        
        let size = distance(from: range.lowerBound, to: range.upperBound)
        //distance로 두 인덱스 사이의 거리를 반환한다.
        let middle = index(range.lowerBound, offsetBy: size / 2)
        //size에서 중간 값을 찾는다.
        
        if self[middle] == value {
            //중간 값이 찾으려는 값과 같다면
            return middle
            //중간 값 반환
            
            //같지 않다면
        } else if self[middle] > value {
            //중간 값이 찾으려는 값보다 크다면
            return binarySearch(for: value, in: range.lowerBound..<middle)
            //왼쪽 시퀀스 영역으로 이진 검색을 호출
        } else {
            //중간 값이 찾으려는 값보다 작다면
            return binarySearch(for: value, in: index(after: middle)..<range.upperBound)
            //오른쪽 시퀀스 영역으로 이진 검색을 호출
        }
    }
}

//이진 검색은 시간 복잡도가 O(log n)인 가장 효율적인 검색 알고리즘 중 하나이다.
//이는 균형잡힌 이진 검색 트리 내에서 요소를 검색하는 것과 유사하다.
//이진 검색을 사용하려면 다음 두 가지 조건이 충족되어야 한다.
//• 컬렉션은 일정 시간 동안 인덱스 조작을 할 수 있어야 한다(이 컬렉션이 RandomAccessCollection(순차 접근과 반대)이어야 한다).
//• 컬렉션을 정렬해야 한다.
//이진 검색은 선형 검색과 자주 비교된다. //Swift의 Array은 선형 검색을 사용하여 index(of :) 메서드를 구현한다(요소를 찾을 때까지). p.127
//이진 검색은 정렬되어 있기 때문에 다르게 접근 한다. p.128
//Step 1: 가운데 index를 찾는다. p.128
//Step 2: 가운데 index에 저장된 요소의 값을 확인한다. 찾으려는 값과 일치하면 index를 반환한다. 그렇지 않으면 다음 Step으로 넘어간다.
//Step 3: 검색하려는 값이 중간 값보다 작으면 왼쪽, 크면 오른쪽 시퀀스를 대상으로 이진 검색을 재귀적으로 호출한다(절반씩 검색해야할 대상이 줄어든다). p.129
//이 세 단계를 왼쪽, 오른쪽 반으로 나눌 수 없거나, 해당 값을 찾을 때 까지 반복한다. O(log n)

