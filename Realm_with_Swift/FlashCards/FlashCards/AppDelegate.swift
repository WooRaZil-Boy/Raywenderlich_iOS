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
    Tools.runIfNeeded() //번들 생성
    
    setupRealm()
    return true
  }

  private func setupRealm() {
    let cardsRealm = RealmProvider.cards.realm //일반적으로 사용할 Realm
    let bundledSetsRealm = RealmProvider.bundled.realm //번들 Realm
    
    print(cardsRealm.configuration.fileURL!)
    
    //처음 앱을 실행 했을 때에는 일반 Realm에 cards가 없을 것이다.
    //이때는 번들을 복사해 덮어쓴다.
    
    var setsToCopy = [FlashCardSet]()
    for bundledSet in bundledSetsRealm.objects(FlashCardSet.self) where cardsRealm.object(ofType: FlashCardSet.self, forPrimaryKey: bundledSet.name) == nil {
      //번들 Realm에서 모든 FlashCardSet 객체를 가져 온다.
      //그 중(where) cardsRealm에 있지 않은 객체만 추가한다
          setsToCopy.append(bundledSet)
        //이전 챕터에서 처음 앱을 실행할 때, 번들 파일을 라이브러리 폴더에 복사 하는 방법은
        //번들 데이터를 한 번만 복사하거나 기존 파일을 완전히 여러 번 바꿔야 하는 경우 합리적이다.
        //여기서는, 초기 데이터를 반복적으로 추가한다.
        //각 앱을 업데이트 한 후에 새로운 데이터만 앱의 작업 파일에 복사한다.
    }
    
    guard setsToCopy.count > 0 else { return }
    
    try! cardsRealm.write {
      for cardSet in setsToCopy {
        cardsRealm.create(FlashCardSet.self, value: cardSet, update: false)
        //create로 기존 객체를 복사해 새 객체를 생성한다.
      }
    }
  } //이 메서드로, 새로운 세트(ex. 앱 업데이트)가 어플리케이션 시작 시 작업 파일로 복사 된다.
}

// MARK: - Constants

let primaryColor = UIColor(red: 33/255.0, green: 61/255.0, blue: 78/255.0, alpha: 1)
let secondaryColor = UIColor(red: 103/255.0, green: 176/255.0, blue: 239/255.0, alpha: 1)

//MVVM. 앱의 전체 로직은 p.159

//Xcode의 extension을 사용할 수 있다(target에서 바꾼다). 위젯에 표시되는 등 다른 방법으로 사용할 수 있다.
