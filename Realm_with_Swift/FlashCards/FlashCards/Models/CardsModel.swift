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

import Foundation
import RealmSwift

class CardsModel {
  
  private let provider: RealmProvider
  
  init(provider: RealmProvider = .cards) {
    self.provider = provider
    //Realm이 기본적으로 .cards를 사용할 수 있고, 테스트에서는 다른 Realm을 주입해 줄 수 있다.
    //RealmProvider는 구조체이기 때문에, 스레드를 넘어서 전달할 수 있다. Model이 과도한 작업을 수행하고
    //다른 스레드로 전환해야 하는 경우, provider 속성에 항상 액세스해서 스레드에 안전한 Realm 인스턴스를 얻을 수 있다.
    //이전에 사용하던 RealmProvider.cards에 대한 명시적인 내부 종속성이 제거되고, init에 삽입된 provider를 사용한다.
    //필요한 작업에 적합한 Realm을 RealmProvider로 제공할 수 있다.
    
    //더 유연하고, 테스트 가능하며, iOS, extension, watchOS, tvOS 등에서도 사용하능하다.
  }

  func sets() -> Results<FlashCardSet> {
//    let realm = try! Realm()
//    let realm = RealmProvider.cards.realm //기본 Realm 대신 cards Realm을 사용
    return provider.realm
            .objects(FlashCardSet.self)
            .sorted(by: [
              SortDescriptor(keyPath: FlashCardSet.Properties.isAvailable.rawValue, ascending: false),
              SortDescriptor(keyPath: FlashCardSet.Properties.name.rawValue)])
  }

  func setWith(_ name: String) -> FlashCardSet? {
//    let realm = try! Realm()
//    let realm = RealmProvider.cards.realm //기본 Realm 대신 cards Realm을 사용
    return provider.realm.object(ofType: FlashCardSet.self, forPrimaryKey: name)
    //name으로 객체 가져온다.
  }
}

//CardsModel은 cards.realm에서 엔티티를 읽는 모델 클래스
