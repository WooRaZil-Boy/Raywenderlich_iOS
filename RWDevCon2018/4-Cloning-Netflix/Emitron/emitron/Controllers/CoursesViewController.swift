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
import Layout

class CoursesViewController: UIViewController, LayoutLoading {
  typealias DependencyProvider = StoreProvider & DataSourceProvider & ViewControllerProvider
  private let provider: DependencyProvider
  private let domainSelector: UISegmentedControl
  
  private lazy var store = provider.store
  private lazy var dataSource = provider.createCourseCategoryShelfDataSource(collectionView: shelvesCollectionView, selectionDelegate: self)
  
  @IBOutlet weak var shelvesCollectionView: UICollectionView! {
    didSet {
      configureCollectionView()
    }
  }
  
  init(dependencyProvider: DependencyProvider) {
    self.provider = dependencyProvider
    self.domainSelector = UISegmentedControl(items: [
      "All",
      "iOS",
      "Android",
      "Other"
    ])
    self.domainSelector.selectedSegmentIndex = 0
    super.init(nibName: .none, bundle: .none)
    self.title = "Courses"
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension CoursesViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    loadLayout(named: "Courses.xml",
               constants: GLOBAL_CONSTANTS.dictionary)
    domainSelector.addTarget(self, action: #selector(handleDomainSelected(_:)), for: .valueChanged)
    domainSelector.selectedSegmentIndex = 0
    navigationItem.titleView = domainSelector
  }
  
  private func configureCollectionView() {
    if let shelvesCollectionView = shelvesCollectionView {
      dataSource.domain = currentDomain
      shelvesCollectionView.dataSource = dataSource
    }
  }
  
  @objc func handleDomainSelected(_ sender: Any) {
    dataSource.domain = currentDomain
  }
  
  private var currentDomain: Betamax.Domain {
    return Betamax.Domain(rawValue: domainSelector.titleForSegment(at: domainSelector.selectedSegmentIndex)!)!
  }
}

extension CoursesViewController: ShelfSelectionDelegate {
  func didSelect(cardViewModel: CardViewModel) {
    guard let collection = cardViewModel as? Collection else {
      print("Unable to create CourseViewController for this CardViewModel")
      return
    }
    let courseVC = provider.createViewController(for: collection)
    show(courseVC, sender: self)
  }
}
