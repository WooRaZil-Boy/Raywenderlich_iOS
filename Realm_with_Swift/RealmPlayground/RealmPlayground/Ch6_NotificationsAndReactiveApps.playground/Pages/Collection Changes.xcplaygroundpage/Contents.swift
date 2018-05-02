//: # 🙎‍♂️💁‍♀️👶👨‍👨‍👦‍👦 Collection Changes
//: [Home](Start) |
//: [Previous](@previous) |
//: [Next](@next)

import RealmSwift
import PlaygroundSupport

Example.of("Collection Changes")
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

//클로저의 매개변수를 세분화하여 필요한 항목만 선별해 사용할 수 있다.
//ex. TableView에서 변경이 필요한 셀만 새로 고침

let article = Article()
article.title = "New Article"

try! realm.write {
    realm.add(article)
}

let token = article.people.observe { changes in
    //article의 people List 속성에 대한 구독
    switch changes {
    case .initial(let people):
        //컬렉션 변경 사항을 처음 관찰 했을 때 Realm이 내는 알림
        //컬렉션 변경 자체에 의해 트리거되지는 않지만, UI 초기화할 수 있는 초기 상태를 제공
        print("Initial count: \(people.count)")
    case .update(let people, let deletions, let insertions, let updates):
        //컬렉션의 모든 변경 사항에 의해 트리거 되는 알림
        //뒤의 세 매개변수는 [Int]타입이며, 삭제, 삽입, 업데이트된 컬렉션의 인덱스
        //ex. 객체를 이동하면 새 위치에 삽입된 항목과 이전 항목에서 삭제된 항목이 생성된다.
        print("Current count: \(people.count)")
        print("Inserted \(insertions), Updated \(updates), Deleted \(deletions)")
    case .error(let error):
        //유요한 변경 집합을 생성하지 못하면 에러가 트리거된다.
        //구독 오류가 발생하면 추가 변경 사항에 대한 observe를 취소한다.
        print("Error: \(error)")
    }
}

try! realm.write {
    article.people.append(Person())
    article.people.append(Person())
    article.people.append(Person())
} //한 트랜잭션 후, .update로 호출된다.
//Initial count: 0
//Current count: 3
//Inserted [0, 1, 2], Updated [], Deleted []

try! realm.write {
    article.people[1].isVIP = true //updated
} //.update의 update

try! realm.write {
    article.people.remove(at: 0) //deleted
    article.people[1].firstName = "Joel" //updated
    //여기선 updated된 객체의 index가 1이 아닌 2로 출력된다.
    //먼저 index 0의 객체를 삭제하였기 때문에, 삭제 후, 객체들은 하나씩 앞으로 당겨진다.
    //그 후, index 1의 객체를 업데이트 했는데, 이는 트랜잭션이 있기 전의 index 2 객체이다.
    //Realm의 Results 집합은 사용자가 마지막으로 변경 알림을 받은 이후 변경된 인덱스 이다.
    //따라서 여기서는 트랜잭션 전의 index인 2를 출력하게 된다.
    
    //복잡해 보이지만, Realm의 Results 집합은 UIKit의 API에 맞춰지므로 변경 사항이
    //UI에 거의 자동으로 적용이 된다. 따라서 사용자가 수동으로 제어해야하는 경우는 매우 드물다.
} //.update의 updated, deleted

try! realm.write {
    article.people.removeAll()
}
