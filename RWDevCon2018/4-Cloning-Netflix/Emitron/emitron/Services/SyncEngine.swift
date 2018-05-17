/*
 * Copyright (c) 2018 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import Foundation
import RealmSwift

class SyncEngine {
  typealias DependencyProvider = StoreProvider
  private let provider: DependencyProvider
  private let realm = try! Realm()
  private var userId: String?
  private var dirtyViewings: Results<Viewing>?
  private var dirtyNotificationToken: NotificationToken?
  
  private lazy var store = provider.store
  
  init(dependencyProvider: DependencyProvider) {
    self.provider = dependencyProvider
  }
}

extension SyncEngine {
  func startSync(for userId: String) {
    self.userId = userId
    setupEngine()
  }
  
  func stopSync() { //프로세스 중지
    dirtyNotificationToken?.invalidate()
    dirtyNotificationToken = .none
    userId = .none
  }
}

extension SyncEngine {
  private func setupEngine() {
    // Pull down the latest viewings from the API and sync with the local datastore
    syncFromApi()
    
    // Configure the listeners that will sync back to the API when local viewings are updated
    configureListeners()
  }
  
  private func syncFromApi() {
    guard let userId = userId else { return }
    store.requestViewingsForUser(userId: userId) { (viewings) in
      DispatchQueue(label: "com.razeware.emitron.syncengine", qos: .background).async {
        autoreleasepool {
          do {
            let realm = try Realm()
            let localViewings = realm.objects(Viewing.self)
            try realm.write {
              for viewing in viewings {
                // Does a local equivalent exist?
                if let localViewing = localViewings.filter("videoId == %@", viewing.videoId).first { //루프에서 최신 것을 찾는다.
                  // If the local one is dirty, keep the most recent
                  if localViewing.dirty && localViewing.updatedAt > viewing.updatedAt {
                    // NO-OP—it'll get synced to the API later
                  } else {
                    // Update the local one with the details from the remote on
                    //동기화
                    localViewing.updateFrom(remote: viewing)
                  }
                } else {
                  // Not seem this before—make a local version
                  realm.add(viewing)
                }
              }
            }
          } catch (let error) {
            print(error)
          }
        }
      }
    }
  }
  
  private func configureListeners() {
    //local의 변경 사항을 API로 푸시
    let result = realm.objects(Viewing.self).filter("dirty == TRUE")
    //변경 될때 마다 트리거. 옵저버 설정
    dirtyNotificationToken = result.observe { (_) in
      for viewing in result {
        self.syncToApi(viewing: viewing)
      }
    }
    dirtyViewings = result
  }
  
  private func syncToApi(viewing: Viewing) {
    guard let userId = userId else { return }
    store.syncViewingToAPI(viewing: viewing, userId: userId) { (viewing) in
      DispatchQueue.main.async { //Realm에 쓴다.
        do {
          try self.realm.write {
            viewing.dirty = false
          }
        } catch (let error) {
          print(error)
        }
      }
    }
  }
}
