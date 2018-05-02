//: # 🌎 Realm-wide notifcations
//: [Home](Start) |
//: [Previous](@previous)

import RealmSwift
import PlaygroundSupport

Example.of("Realm wide notifications")
PlaygroundPage.current.needsIndefiniteExecution = true

//: **Setup Realm**
let configuration = Realm.Configuration(inMemoryIdentifier: "TemporaryRealm")
let realm = try! Realm(configuration: configuration)

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

//Realm 객체 자체에도 알림을 구독할 수 있다.
let token = realm.observe { notification, realm in
    print(notification)
}
//지정된 Realm의 모든 객체에 대한 변경사항을 구독한다.

try! realm.write { }
//Realm은 각 write 트랜잭션을 커밋할 때 Realm 전체의 변경 알림을 전송하므로
//실제로 변경할 필요는 없다.

//클로저의 알림 매개변수는 두 가지 열거 형 중 하나이다.
//• .didChange : 각 write 트랜잭션 이후에 전송된다.
//• .refreshRequired : Realm의 자동 새로고침 데이터(항상 최신 객체 유지)를 비활성화한
//  경우에 전송된다. 이 알림은 write 트랜잭션이 commit될 때마다 실행되기 때문에
//  UI를 적절하게 새로고칠 수 있다.

//전체 알림은 특정 변경 사항에 대한 세부 정보를 찾을 때는 유용하게 사용하기 어렵다.
//하지만, 훨씬 가볍게 사용할 수 있으므로, 변경된 데이터와 상관없이 각 write 시 마다 사용할 때
//유용하다. 또한, 여러 객의 Realm이 있는 경우에 사용할 수도 있다.
