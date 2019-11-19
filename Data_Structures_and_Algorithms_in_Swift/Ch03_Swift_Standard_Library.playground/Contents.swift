//Chapter 3: Swift Standard Library

//Swift standard library는 Swift의 핵심 구성 요소를 포함하는 framework로, Swift 앱을 구축하는 데 도움이 되는 다양한 tool과 type 들이 있다.
//사용자 정의 자료구조를 구축하기 전에 Swift standard library가 이미 제공하는 기본 자료구조를 이해하는 것이 중요하다.




//Array
//배열은 순서가 지정된 요소 모음을 저장하기 위한 범용 container이며, 모든 Swift 프로그램에서 자주 사용된다.
//요소를 쉼표로 구분하고 대괄호로 묶어 array literal을 생성할 수 있다.
let people = ["Brian", "Stanley", "Ringo"]
//Swift는 protocol을 사용하여 배열을 정의한다. 각 protocol은 배열에서 더 많은 기능을 계층화한다.
//ex. Array는 Sequence이다(Sequence protocol을 구현). 즉, 배열을 한 번이상 반복(iterate)할 수 있다.
//또한, Array는 Collection이므로(Collection protocol을 구현) 여러번 순회할 수 있고, 비파괴적이며 subscript 연산자를 사용할 수 있다.
//Swift의 Array는 어떠한 type으로도 생성할 수 있기 때문에 generic collection이라 한다.
//사실 대부분의 Swift standard library는 generic code로 만들어져 있다.

//Order
//배열의 요소는 명시적으로 정렬된다. ex. 위의 people 배열에서 Brian이 Stanley 앞에 온다.
//배열의 모든 요소에는 0부터 시작하는 정수 index가 있다.
people[0] // "Brian"
people[1] // "Stanley"
people[2] // "Ringo"
//순서는 배열 자료구조에 의해 정의되며, 순서의 개념이 없는 Dictionary와 같은 자료구조들도 있다.

//Random-access
//Random-access는 자료구조가 상수 시간(constant time) 내에 요소 검색을 처리할 수 있는 특성이다.
//ex. 위의 people 배열에서 "Ringo" 요소를 가져오는 데 상수 시간(constant time)이 걸린다(subscript 연산자 사용).
//linked list나 tree 같은 자료 구조에서는 상수 시간(constant time)으로 요소에 접근할 수 없다.

//Array performance
//데이터의 양이 증가할 때, 다른 자료구조들과의 성능을 비교해 본다.

//Insertion location
//배열에 하나의 요소를 삽입(insert)할 때, 가장 효율적인 방법은 배열의 끝에 추가하는 것이다.
people.append("Charles")
print(people) // prints ["Brian", "Stanley", "Ringo", "Charles"]
//append 메서드를 사용하여 "Charles"를 삽입하면, 배열의 끝에 추가 된다.
//이는 상수 시간(constant time) 작업이므로, 배열의 크기에 관계없이 작업 수행에 동일한 시간이 소요된다.
//하지만, 배열의 중간과 같이 특정 위치에 요소를 삽입해야 하는 경우에는 소요 시간이 달라진다.
//ex. 극장에서 관객들이 줄지어 앉아 있을 때, 다음 관객은 가장 끝에 앉는 것이 좋다.
//배열의 끝을 제외한 어느 위치에서든 새 요소를 삽입하려면 다른 요소를 뒤로 움직여 공간을 만들어야 한다.
people.insert("Andy", at: 0)
// ["Andy", "Brian", "Stanley", "Ringo", "Charles"]
//배열의 가장 앞에 요소를 추가한 경우, 모든 요소는 하나의 index 만큼 뒤로 이동해야 하며, n 단계가 걸린다.
//이 경우, 배열의 요소가 두 배가 되면, insert에 걸리는 시간 또한 두 배가 된다.
//따라서, Collection의 가장 앞에 요소를 삽입하는 것이 일반적인 작업인 프로그램의 경우, 다른 자료 구조를 고려해야 한다.
//insert 작업의 속도를 결정하는 또 다른 요소는 배열의 용량(capacity)이다.
//Swift array에는 해당 요소를 위한 미리 결정된 공간이 할당된다. 최대 용량에 도달한 배열에 새 요소를 추가하려는 경우,
//공간을 확보하기 위해 배열 자체를 재구성한다. 이는 배열의 모든 요소를 더 큰 container에 복사하여 수행한다.
//하지만, 이 작업은 각 요소를 복사해야 하기 때문에 비용이 추가적으로 발생한다.
//즉, 배열이 최대 용량에 도달한 경우에는 새로운 요소를 끝에 추가할지라도, n단계의 추가 작업이 발생한다.
//Swift standard library는 이 경우, 복사 시간을 최소화하기 위한 알고리즘을 가지고 있다.
//용량이 부족해, 배열을 복사해야 할 때마다 새 용량은 이전의 두 배가 된다.




//Dictionary
//Dictionary는 key-value를 쌍으로 보유하는 generic collection이다.
var scores: [String: Int] = ["Eric": 9, "Mark": 12, "Wayne": 1]
//Dictionary는 순서를 보장하지 않으며, 특정 index로 insert할 수 없다.
//또한, Key는 Hashable을 구현한 type이어야 한다.
//Swift의 거의 모든 standart type은 Hashable를 구현했으며, 최신 Swift 버전에서는 Hashable protocol 구현이 매우 쉬워졌다.
scores["Andrew"] = 0 //Dictionary에 새 항목 추가
// ["Eric": 9, "Mark": 12, "Andrew": 0, "Wayne": 1]
//Dictionary는 순서가 없기 때문에, 출력이 달라질 수 있다.
//Dictionary는 Collection protocol을 구현 했기 때문에, key-value 쌍을 여러 번 탐색할 수 있다.
//Dictionary에는 순서가 없지만, collection이 변경 되기 전 까지는, 순회 때마다 동일하다.
//Array와 달리, Dictionary는 요소의 삽입(insert)에 상수 시간(constant time)이 걸린다.
//조회 작업 또한, key로 바로 찾을 수 있기 때문에, 상수 시간(constant time)이다. 따라서, 처음부터 순회하며 특정 요소를 찾아야 하는 배열보다 훨씬 빠르다.




//Set
//Set은 고유한 값을 보유하는 container이다.
var bag: Set<String> = ["Candy", "Juice", "Gummy"]
bag.insert("Candy") //Set은 고유한 값을 가지기 때문에, 요소를 중복으로 추가할 수 없다.
print(bag) // prints ["Candy", "Juice", "Gummy"]
//중복된 요소를 추가할 수 없기 때문에, 중복 요소를 찾는 방법으로 다양한 프로그램에 사용할 수 있다.
let values: [String] = [...]
var bag: Set<String> = []
for value in values {
    if bag.contains(value) {
        // bag already has it, therefore it is a duplicate
    }
    bag.insert(value)
}
//Array나 Dictionary만큼 Set를 자주 사용하지는 않지만, 중요한 자료구조이다.
//Set은 Dictionary와 유사하게 순서의 개념이 없다.

