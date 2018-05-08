//Arrays
// An array of `String` elements
var people = ["Brian", "Stanley", "Ringo"]
//배열은 모든 요소를 추상화한다. 요소의 유형은 제한이 없으며, Swift에서는 protocol을 사용해 배열을 정의한다.
//iterate할 수 있는 Sequence, subscript operator를 사용할 수 있는 Collection, RandomAccessCollection 등을 구현한다.
//ex. 배열의 count는 O(1)로 작성된 상수로 보장된다. 즉, 배열 크기에 관계없이 count는 항상 동일한 시간이 걸린다.

//Order
//배열을 요소를 명시적으로 정렬한다. 배열의 모든 요소에는 0부터 시작하는 정수 인덱스가 있어, 검색 등에 사용할 수 있다.
people[0] // "Brian"
people[1] // "Stanley"
people[2] // "Ringo"
//oder는 배열의 구조에 의해 정의되지만, Dictionary, Set등과 같은 구조에서는 그렇지 않다.

//Random-access
//해당 데이터 구조가 O(1)의 시간으로 요소 검색을 처리할 수 있는 경우, 임의 접근라 한다.
//인덱스로 각 원소에 접근할 수 있으므로 배열은 Random-access가 가능한 자료구조이다.

//Array performance
//데이터의 양이 증가할 때 데이터 구조가 얼마나 효율적으로 관리되는 지. 배열의 경우에는 두 가지 요소가 영향을 끼친다.

//Insertion location
//배열 안에 새 요소를 추가할 때의 위치가 중요한 영향을 끼친다. 가장 효율적인 위치는 배열의 마지막에 추가하는 것이다.
people.append("Charles")
print(people) // prints ["Brian", "Stanley", "Ringo", "Charles"]
//append()로 요소를 추가하면, 새 요소가 배열의 끝에 위치하게 된다. O(1)
people.insert("Andy", at: 0)
// ["Andy", "Brian", "Stanley", "Ringo", "Charles"]
//하지만, 배열의 특정 위치에 요소를 삽입하는 경우에는 O(n)이 된다.
//삽입하는 요소의 위치 이후의 요소들을 하나씩 뒤로 이동시키는 단계를 거치기 때문이다.

//효율성에 영향을 미치는 두 번째 요소는 배열의 용량이다.
//배열이 사전에 할당된 공간(용량)을 초과하면, 스토리지를 재 할당하고, 현재 요소를 복사한다.
//즉, n단계의 작업이 필요하다. 하지만 실제 표준 라이브러리는 효율적인 트릭을 사용해 O(n) 보다는 조금 낮다.




//Dictionary
//딕셔너리는 Key-Value로 이루어진 콜렉션이다.
var scores: [String: Int] = ["Eric": 9, "Mark": 12, "Wayne": 1]
//딕셔너리는 순서를 보장하지 않으며, subscript operator를 사용할 수 없다.
//Key는 Hashable protocol을 구현한 객체여야 한다(거의 모든 표준 유형이 구현하고 있다).
scores["Andrew"] = 0 //["Eric": 9, "Mark": 12, "Andrew": 0, "Wayne": 1]
//insert는 항상 O(1), search도 O(1)로 배열의 O(n)보다 빠르다.


