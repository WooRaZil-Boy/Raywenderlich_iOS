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
  
  func stopSync() {
    // TODO
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
    // TODO
  }
  
  private func configureListeners() {
    // TODO
  }
  
  private func syncToApi(viewing: Viewing) {
    guard let userId = userId else { return }
    store.syncViewingToAPI(viewing: viewing, userId: userId) { (viewing) in
      DispatchQueue.main.async {
        // TODO
      }
    }
  }
}
