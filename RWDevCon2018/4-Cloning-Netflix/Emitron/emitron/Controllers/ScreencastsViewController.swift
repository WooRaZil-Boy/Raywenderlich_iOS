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

class ScreencastsViewController: UIViewController, LayoutLoading {
  typealias DependencyProvider = StoreProvider & ViewControllerProvider
  private let provider: DependencyProvider
  private var changeToken: Any?
  
  private lazy var store = provider.store
  private lazy var videos = store.getScreencasts()
  
  @IBOutlet weak var collectionView: UICollectionView! {
    didSet {
      collectionView?.registerLayout(named: "CardCollectionViewCell.xml",
                                     state: EmptyCardState,
                                     constants: ["imageHeight": Double(GLOBAL_CONSTANTS.sizes.collectionTileWidth) / 16 * 9],
                                     forCellReuseIdentifier: "CardCell")
    }
  }
  
  init(dependencyProvider: DependencyProvider) {
    self.provider = dependencyProvider
    super.init(nibName: .none, bundle: .none)
    self.title = "Screencasts"
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension ScreencastsViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    loadLayout(named: "Screencasts.xml",
               constants: GLOBAL_CONSTANTS.dictionary)
    
    // TODO: Add screencasts observer
    changeToken = videos.observe { [weak self] (change) in
      //videos는 Betamax에서 getScreencasts()로 가져온 lazy 변수. Realm의 Results<Video>타입이다.
      //옵저버로 스크린 캐스트 비디오 객체가 Realm에 저장되면 콜백이 호출되어 컬렉션 뷰가 다시 로드된다.
      self?.collectionView.reloadData()
    }
    //스크린 캐스트 목록을 추가해 준다.
  }
}

extension ScreencastsViewController: UICollectionViewDataSource {
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return videos.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let node = collectionView.dequeueReusableCellNode(withIdentifier: "CardCell", for: indexPath)
    if let cell = node.view as? CardCollectionViewCell {
      cell.data = videos[indexPath.item]
    }
    return node.view as! UICollectionViewCell
  }
}

extension ScreencastsViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard collectionView == self.collectionView else { return }
    let video = videos[indexPath.item]
    
    let videoVC = provider.createViewController(for: video)
    show(videoVC, sender: self)
  }
}
