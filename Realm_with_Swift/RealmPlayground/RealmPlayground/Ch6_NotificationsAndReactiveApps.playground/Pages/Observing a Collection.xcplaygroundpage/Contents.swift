//: # 👨‍👨‍👦‍👦  Observing a Collection
//: [Home](Start) |
//: [Previous](@previous) |
//: [Next](@next)

import RealmSwift
import PlaygroundSupport

Example.of("Observing a Collection")
PlaygroundPage.current.needsIndefiniteExecution = true

//: **Setup Realm and preload some data**
let configuration = Realm.Configuration(inMemoryIdentifier: "TemporaryRealm")
let realm = try! Realm(configuration: configuration)

try! TestDataSet.create(in: realm)



//: [Next](@next)
/*:
 Copyright (c) 2018 Razeware LLC

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
 distribute, sublicense, create a derivative work, and/or sell copies of the
 Software in any work that is designed, intended, or marketed for pedagogical or
 instructional purposes related to programming, coding, application development,
 or information technology.  Permission for such use, copying, modification,
 merger, publication, distribution, sublicensing, creation of derivative works,
 or sale is expressly withheld.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

//Observing a collection
//객체 컬렉션은 객체의 List, 필터링 또는 정렬된 Results 집합, linking 객체 중 하나이다.
//컬렉션 변경을 트리거 하는 알림은 다음 중 하나일 수 있다.
//• List나 Results Set의 객체에 삽입 또는 삭제
//• List의 move() 메서드로 다른 인덱스로 객체를 이동하거나 Results의 다른 인덱스로 정렬하여
//  객체를 다른 인덱스로 이동. 이전 인덱스에서 객체를 제거하고, 새로운 위치에 객체를 삽입하여
//  두 가지 별도의 변경 사항을 생성한다.
//• 컬렉션에 포함된 객체의 속성 값을 수정
//• 컬렉션에 포함된 객체에서 링크된 객체의 속성을 수정
//• 컬렉션의 일부인 객체의 List 속성에 속한 객체의 속성 수정
let people = realm.objects(Person.self) //Person 객체 가져오기
    .sorted(byKeyPath: "firstName") //firstName 속성으로 정렬
let token = people.observe { changes in //observe(_)는 객체 처럼 작동한다.
    //클로저의 작업을 수행하고, 구독의 수명 주기를 제어하는 데 사용하는 알림 토큰을 반환
    //클로저의 매개변수는 ObjectChanger가 아니라 RealmCollectionChange 유형이다.
    print("Current count: \(people.count)")
    //컬렉션을 관찰하기 시작할 때 컬렉션의 초기 상태에 대한 알림을 즉시 전송한다.
}

try! realm.write { //write 트랜잭션
    realm.add(Person()) //알림 클로저가 트리거된다.
}

try! realm.write { //write 트랜잭션
    realm.add(Person()) //알림 클로저가 트리거된다.
}

DispatchQueue.global(qos: .background).sync { //백 그라운드 큐에서 실행 //동기
    let realm = try! Realm(configuration: configuration)
    
    try! realm.write { //다른 스레드에서 실행하더라도 알림은 제대로 관리된다.
        realm.add(Person())
    }
}

DispatchQueue.global().asyncAfter(deadline: .now() + 1) { //백 그라운드. 비동기
    token.invalidate() //알림 구독 해제
}

DispatchQueue.main.asyncAfter(deadline: .now() + 2) { //메인 스레드. 비동기
    try! realm.write {
        realm.add(Person())
        //위에서 백그라운드 스레드에서 알림 구독을 해제하였기 때문에
        //더 이상 알림이 생성되지 않는다. //다른 스레드에서 한 작업이 영향을 미친다.
    }
}
