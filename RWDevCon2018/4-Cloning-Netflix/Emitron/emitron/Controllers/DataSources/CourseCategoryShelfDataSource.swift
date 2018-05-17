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

import UIKit
import RealmSwift

class CourseCategoryShelfDataSource: NSObject {
  typealias DependencyProvider = StoreProvider
  private let provider: DependencyProvider
  private weak var collectionView: UICollectionView?
  private weak var selectionDelegate: ShelfSelectionDelegate?
  
  private var data: Results<Collection>?
  private var mappedData: [ShelfViewModel]?
  private var collectionChangeToken: NotificationToken?
  var domain: Betamax.Domain = .all {
    didSet {
      if oldValue != domain {
        requestData()
      }
    }
  }
  
  private lazy var store = provider.store
  
  init(dependencyProvider: DependencyProvider, collectionView: UICollectionView, selectionDelegate: ShelfSelectionDelegate) {
    self.provider = dependencyProvider
    self.collectionView = collectionView
    self.selectionDelegate = selectionDelegate
    super.init()
    requestData()
  }
  
  private func requestData() {
    let collections = store.getCollections(for: domain)
    self.data = collections
    collectionChangeToken = collections.observe { [weak self] (change) in
      self?.redrawUI()
    }
    self.redrawUI()
  }
  
  private func redrawUI() {
    guard let collections = self.data else { return }
    let groupedByCategory = Dictionary.init(grouping: collections, by: { $0.primaryCategory ?? "Other" })
    self.mappedData = groupedByCategory.map { (name, collections) in return CourseShelf(title: name, cards: collections) }
    self.collectionView?.reloadData()
  }
}

extension CourseCategoryShelfDataSource: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return mappedData?.count ?? 0
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let node = collectionView.dequeueReusableCellNode(withIdentifier: "ShelfCell", for: indexPath)
    let vm = mappedData?[indexPath.item]
    if let cell = node.view as? ShelfCollectionViewCell {
      cell.data = vm
      cell.delegate = selectionDelegate
    }
    
    node.setState([
      "title": vm?.title ?? "Other",
      ])
    return node.view as! UICollectionViewCell
  }
}
