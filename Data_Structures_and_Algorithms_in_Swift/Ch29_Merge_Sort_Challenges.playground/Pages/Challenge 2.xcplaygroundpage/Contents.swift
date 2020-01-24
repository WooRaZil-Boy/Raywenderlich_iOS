// Copyright (c) 2019 Razeware LLC
// For full license & permission details, see LICENSE.markdown.
//: [Previous Challenge](@previous)
//: ## Challenge 2: Merge two sequences
//두 개의 정렬된 sequence를 가져와 단일 sequence로 병합하는 함수를 작성한다.




func merge<T: Sequence>(first: T, second: T) -> AnySequence<T.Element> where T.Element: Comparable {
    //AnySequence는 구체적인 세부 구현 사항을 추상화하는 유형이다.
    var result: [T.Element] = [] //병합된 sequence를 저장할 컨테이너
    
    var firstIterator = first.makeIterator()
    var secondIterator = second.makeIterator()
    //Sequence type은 makeIterator()를 사용해, Iterator를 얻을 수 있다.
    //Iterator는 next 메서드를 사용해, 순차적으로 Sequence의 value를 분배한다.
    
    var firstNextValue = firstIterator.next()
    var secondNextValue = secondIterator.next()
    //next 메서드를 사용해, Iterator를 첫 번째 값으로 초기화 한다.
    //next는 Sequence의 optional 요소를 반환한다. 만약 nil이라면, Sequence의 모든 요소가 분배 됐음을 의미한다.
    
    //각 Iterator를 사용해, firstNextValue와 secondNextValue를 비교하고, Array에 추가할 요소를 결정한다.
    while let first = firstNextValue, let second = secondNextValue { //Merge
        //firstNextValue와 secondNextValue를 가져와 optional을 해제하고, Array에 삽입할 요소를 결정한다.
        //두 개의 Iterator 중 어느 하나라도 분배할 요소가 없어질 때 까지 loop된다.
        if first < second { //first가 second보다 작으면
            result.append(first) //first를 추가하고
            firstNextValue = firstIterator.next() //firstIterator에서 next를 호출해, 다음 값으로 이동한다.
        } else if second < first { //second가 first보다 작으면
            result.append(second) //second를 추가하고
            secondNextValue = secondIterator.next() //secondIterator에서 next를 호출해, 다음 값으로 이동한다.
        } else { //값이 같으면
            result.append(first)
            result.append(second)
            //first와 second를 모두 추가하고
            firstNextValue = firstIterator.next()
            secondNextValue = secondIterator.next()
            //firstIterator, secondIterator 모두 next를 호출해, 다음 값으로 이동한다.
        }
    }
    //두 Sequence가 정렬되어 있으므로, 요소가 남아 있는 Iterator는 현재 값보다 크거나 같은 요소가 있다.
    
    while let first = firstNextValue {
        result.append(first)
        firstNextValue = firstIterator.next()
    }
    
    while let second = secondNextValue {
        result.append(second)
        secondNextValue = secondIterator.next()
    }
    //Iterator가 분배하지 못한 남은 sequnce가 있다면, 추가해 준다.
    
    return AnySequence<T.Element>(result)
}
//이 구현의 까다로운 부분은 Sequence가 제한된 공간을 가지고 있다는 것이다.
//따라서 전형적인 해결책은 index를 추적하는 Array와 같은 Collection을 사용하는 것이다.
//Sequence type은 index 개념이 없으므로, iterator를 사용해야 한다.
//https://academy.realm.io/kr/posts/try-swift-soroush-khanlou-sequence-collection/

var array1 = [1, 2, 3, 4, 5, 6, 7, 8]
var array2 = [1, 3, 4, 5, 5, 6, 7, 7]
for element in merge(first: array1, second: array2) {
    print(element)
    // 1
    // 1
    // 2
    // 3
    // 3
    // 4
    // 4
    // 5
    // 5
    // 5
    // 6
    // 6
    // 7
    // 7
    // 7
    // 8
}
