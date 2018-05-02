//: # ✋ Avoid notifications for given tokens
//: [Home](Start) |
//: [Previous](@previous) |
//: [Next](@next)

import RealmSwift
import PlaygroundSupport

Example.of("Avoid notifications for given tokens")
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

//변경에 대한 알림을 무시할 수도 있다. 다시 말해, DB에서 변경 시, 일부에게만 통지할 수 있다.
//ex. UISwitch로 토글해서 Realm을 업데이트 한 경우, 이미 UI가 업데이트 되었기 때문에
//  Realm 변경에 대한 알림이 필요하지 않다.

let people = realm.objects(Person.self) //Person 객체 모두 가져오기
let token1 = people.observe { changes in
    switch changes {
    case .initial: //처음 생성 시
        print("Initial notification for token1")
    case .update: //업데이트 시. 업데이트 되는 변수들을 let으로 바인딩할 수도 있다.
        print("Change notification for token1")
    default: break
    }
}

let token2 = people.observe { changes in
    switch changes {
    case .initial: //처음 생성 시
        print("Initial notification for token2")
    case .update: //업데이트 시. 업데이트 되는 변수들을 let으로 바인딩할 수도 있다.
        print("Change notification for token2")
    default: break
    }
}

realm.beginWrite() //write 트랜잭션 시작
realm.add(Person()) //Person 추가

try! realm.commitWrite(withoutNotifying: [token2])
//token2에 알림을 보내지 않고 write를 커밋한다.
