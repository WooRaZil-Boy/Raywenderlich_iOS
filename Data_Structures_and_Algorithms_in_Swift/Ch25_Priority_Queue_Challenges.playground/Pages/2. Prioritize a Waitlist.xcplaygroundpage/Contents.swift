// Copyright (c) 2019 Razeware LLC
// For full license & permission details, see LICENSE.markdown.
/*:
 [Previous Challenge](@previous)
 ## 2. Prioritize a Waitlist
 
 Your favorite T-Swift concert was sold out. Fortunately there is a waitlist for people who still want to go! However the ticket sales will first prioritize someone with a **military background**, followed by **seniority**. Write a `sort` function that will return the list of people on the waitlist by the priority mentioned.
 */

public struct Person: Equatable {
  let name: String
  let age: Int
  let isMilitary: Bool
}




//티켓 판매를 위한 대기자 명단에서 군인을 먼저 우대하고, 이후 나이순서 대로 우선 순위를 줘서 정렬한다.
//우선 순위 큐 자료구조를 사용하면 우선 순위대로 처리할 수 있다.
func tswiftSort(person1: Person, person2: Person) -> Bool { //두 요소를 비교한다.
    if person1.isMilitary == person2.isMilitary { //둘 다 군 경력이 있다면 나이로 정렬한다.
        return person1.age > person2.age
    }
    
    return person1.isMilitary //군 경력이 있는 사람에 우선권을 준다.
}
//이 함수를 우선 순위 큐의 정렬 함수로 사용한다.

let p1 = Person(name: "Josh", age: 21, isMilitary: true)
let p2 = Person(name: "Jake", age: 22, isMilitary: true)
let p3 = Person(name: "Clay", age: 28, isMilitary: false)
let p4 = Person(name: "Cindy", age: 28, isMilitary: false)
let p5 = Person(name: "Sabrina", age: 30, isMilitary: false)

let waitlist = [p1, p2, p3, p4, p5]

var priorityQueue = PriorityQueue(sort: tswiftSort, elements: waitlist)
while !priorityQueue.isEmpty {
    print(priorityQueue.dequeue()!)
}


