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

class SetsViewModel {
  private var _sets: Results<FlashCardSet>?
  private var _setsToken: NotificationToken?

  private let model: CardsModel
  //속성을 클래스가 초기화될 때 바로 생성하는 대신 생성자로 초기화한다.
  private let api: CardsAPI

  var sets: [FlashCardSet] {
    guard let sets = _sets else { return [] }
    return Array(sets)
  }

  init(cards: RealmProvider = .cards, api: CardsAPI) {
    model = CardsModel(provider: cards)
    //Realm과 직접 상호작용하지 않기 때문에 provider를 View Model 자체에 저장할 필요 없다(Model에서 할 일).
    //각 상황 별로(ex. 테스트) 필요한 Realm 파일의 Model을 생성할 수 있다.
    self.api = api
    _sets = model.sets()
  }

  typealias DeletedIndex = Int
  typealias InsertedIndex = Int
  typealias UpdatedIndex = Int
  typealias ChangesCallback = ([DeletedIndex], [InsertedIndex], [UpdatedIndex]) -> Void

  var didUpdate: ChangesCallback? = nil {
    didSet {
      guard let didUpdate = didUpdate,
            let sets = _sets else {
        _setsToken?.invalidate()
        return
      }

      _setsToken = sets.observe { changes in
        switch changes {
        case .initial:
          didUpdate([], [], [])
        case .update(_, let deletions, let insertions, let updates):
          didUpdate(deletions, insertions, updates)
        case .error: break
        }
      }
    }
  }

  func downloadSet(named setName: String, callback: @escaping (Bool) -> Void) {
    api.downloadSet(named: setName) { [weak self] name, words in
      guard let set = self?.model.setWith(name) else {
        callback(false)
        return
      }

      set.append(fromStrings: words)
      callback(true)
    }
  }
}
