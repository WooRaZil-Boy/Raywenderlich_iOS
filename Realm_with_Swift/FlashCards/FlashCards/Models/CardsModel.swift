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

  func sets() -> Results<FlashCardSet> {
//    let realm = try! Realm()
    let realm = RealmProvider.cards.realm //기본 Realm 대신 cards Realm을 사용
    return realm
            .objects(FlashCardSet.self)
            .sorted(by: [
              SortDescriptor(keyPath: FlashCardSet.Properties.isAvailable.rawValue, ascending: false),
              SortDescriptor(keyPath: FlashCardSet.Properties.name.rawValue)])
  }

  func setWith(_ name: String) -> FlashCardSet? {
//    let realm = try! Realm()
    let realm = RealmProvider.cards.realm //기본 Realm 대신 cards Realm을 사용
    return realm.object(ofType: FlashCardSet.self, forPrimaryKey: name) //name으로 객체 가져온다.
  }
}

//CardsModel은 cards.realm에서 엔티티를 읽는 모델 클래스
