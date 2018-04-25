/// Copyright (c) 2018 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    testBackLinks()
    return true
  }

  func testBackLinks() {
    // setup realm
    let realm = try! Realm(configuration:
      Realm.Configuration(deleteRealmIfMigrationNeeded: true))
    SyncManager.shared.logLevel = .off

    // your code
    let myLittleShop = RepairShop("My Little Shop")
    let car = Car(brand: "BMW", year: 1980)
    car.shop = myLittleShop //LinkingObjects를 위한 속성 설정
    
    try! realm.write { //Realm write 트랜잭션 내에서 실행되어야 한다.
        realm.add(car)
        realm.add(myLittleShop)
    }
    //Linking objects
    //지금까지 한 객체에서 다른 객체(또는 여러 객체)와 relationship을 만들었다.
    //하지만 때로는 반대로, 누가 특정 객체에 연결되어 있는지 알 필요가 있다.
    //객체 A가 B를 링크하면, A는 B에 대한 포인터를 가지지만, B는 어떤 단서도 없다.
    //때때로 이 것이 DB를 정리할 때 문제가 될 수 있다. B를 가리키는 객체가 없으면
    //B를 삭제하여 디스크를 관리할 수 있기 때문이다.
    
    //여기서 Car는 특정 RepairShop에 연결된다는 걸 알고 있다. 하지만, RepairShops는 어느 Car가 연결되었는지 모른다.
    //RepairShop에서 List <Car>를 생성하고, 수동으로 관리할 수는 있지만, 관리하기 어렵고 동기화가 원활하지 않을 것이다.
    //LinkingObject를 사용해 훨씬 쉽게 구현할 수 있다.
    
    print("Cars maintained at \(myLittleShop.name)")
    print(myLittleShop.maintainedCars) //LinkingObjects 출력
  }
}

