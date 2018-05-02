//: # 🙆‍♂️ Observing an Object
//: [Home](Start) |
//: [Previous](@previous) |
//: [Next](@next)

import RealmSwift
import PlaygroundSupport

Example.of("Observing an Object")
PlaygroundPage.current.needsIndefiniteExecution = true

//: **Setup Realm**
let configuration = Realm.Configuration(inMemoryIdentifier: "TemporaryRealm")
let realm = try! Realm(configuration: configuration)



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

let article = Article()
article.id = "new-article"

try! realm.write {
    realm.add(article)
}

let token = article.observe { change in //Realm의 옵저버
    //Object.observe(_)는 단일 Realm 객체에서 변경 사항을 관찰할 수 있게 해 주는 API
    //클로저에서 알림을 처리한다. Realm은 특정 객체에 대해 변경이 발생할 때마다
    //클로저를 호출한다. 클로저의 매개변수로 변경된 프로퍼티에 대한 정보가 포함된다.
    //토큰에 알림이 할당된다.
    switch change { //클로저의 매개변수는 3가지 case의 enum이다.
    case .change(let properties):
        //속성 값이 변경되었을 때, 속성은 PropertyChange 유형이며,
        //변경된 값인 old, new와 함께 어떤 속성이 변경되었는지 정보를 제공한다.
        //change에서 UI를 업데이트해야 하는 것을 알 수 있다.
        for property in properties {
            switch property.name {
            case "title": //title 속성
                print("📝 Article title changed from \(property.oldValue ?? "nil") to \(property.newValue ?? "nil")")
                //.change enum 내이므로, 해당 값이 확실히 변경되었다.
                //oldValue로 이전 값, newValue로 새 값을 가져올 수 있다.
            case "author": //author 속성
                print("👤 Author changed to \(property.newValue ?? "nil")")
                //oldValue로 이전 값, newValue로 새 값을 가져올 수 있다.
            default: break
            }
        }
        
        if properties.contains(where: { $0.name == "date" }) { //date 속성
            //속성 list를 반복하는 것 외에도 contains(where:)을 사용할 수 있다.
            print("date has changed to \(article.date)")
        }
        
        break
    case .error(let error):
        //오류가 발생한 경우
        print("Error occurred: \(error)")
    case .deleted:
        //객체가 삭제되고 더 이상 관찰할 수 없는 경우
        print("Article was deleted")
    }
}

print("Subscription token: \(token)") //토큰 검사
//playground에서는 상관없지만, 실제 앱에서는 ViewController나 View Model에서
//토큰을 유지해 줘야 한다. ViewController에 속성을 사용하는 것이 가장 쉬운 방법이다.

//Notification Token의 목적은 알림 구독의 수명을 제어하는 것이다.
//invalidate()으로 토큰을 해제하고, 구독을 취소할 수 있다.

try! realm.write {
    article.title = "Work in progress"
} //위에서 알림을 구독했기 때문에 트랜잭션 즉시, 해당 알림이 나온다.

//사실 단순한 데이터 변경에 반응하는 것은 큰 의미가 없다.
//동일한 스레드, 다른 스레드, 다른 프로세스에서 발생하는 변경사항을 통보 받는 것이 중요하다.
DispatchQueue.global(qos: .background).async {
    //GCD로 백 그라운드 큐에서 비동기 작업 생성
    let realm = try! Realm(configuration: configuration)
    //백 그라운드 큐에서 Realm을 생성한다. //같은 구성 매개 변수
    
    if let article =  realm.object(ofType: Article.self, forPrimaryKey: "new-article") {
        //이전의 Article 객체를 가져온다.
        
        try! realm.write { //업데이트
            article.title = "Actual title"
            article.author = Person()
        }
    }
}
