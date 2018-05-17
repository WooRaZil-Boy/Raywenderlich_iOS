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

class CourseViewController: UIViewController, LayoutLoading {
  typealias DependencyProvider = StoreProvider & ViewControllerProvider & VideoPlayerProvider
  private let provider: DependencyProvider
  private let collection: Collection
  private var collectionChangeToken: Any?
  private var progressChangeToken: Any?
  
  private lazy var store = provider.store
  private lazy var videoPlayer = provider.videoPlayer
  
  @IBOutlet weak var videosCollectionView: UICollectionView! {
    didSet {
      videosCollectionView?.registerLayout(named: "CardCollectionViewCell.xml",
                                           state: EmptyCardState,
                                           constants: ["imageHeight": Double(GLOBAL_CONSTANTS.sizes.videoTileWidth) / 16 * 9],
                                           forCellReuseIdentifier: "CardCell")
    }
  }
  @IBOutlet weak var imageView: UIImageView! {
    didSet {
      imageView?.sd_setImage(with: collection.imageURL, placeholderImage: #imageLiteral(resourceName: "cardPlaceholder"))
    }
  }
  
  init(dependencyProvider: DependencyProvider, collection: Collection) {
    self.provider = dependencyProvider
    self.collection = collection
    super.init(nibName: .none, bundle: .none)
    checkCollection()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension CourseViewController {
  struct LayoutState {
    let title: String
    let releaseDuration: String
    let categories: String
    let difficulty: String
    let technology: String
    let formattedDescription: NSAttributedString
    let complete: Bool
    let proportionComplete: Double
    let labelText: String
  }
  
  override func viewDidLoad() {
    loadLayout(named: "Course.xml",
               state: collection.layoutState,
               constants: GLOBAL_CONSTANTS.dictionary)
    self.title = collection.title
  }
  
  private func checkCollection() {
    store.refresh(collection: collection)
    collectionChangeToken = collection.observe { [weak self] (change) in
      self?.updateFullUI()
    }
    progressChangeToken = collection.observeProgressChange { [weak self] changeType in
      switch changeType {
      case .changed:
        self?.updateProgressUI()
      case .deleted:
        self?.progressChangeToken = .none
      }
      
    }
  }

  var nextVideoIndex: Int? {
    if let video = collection.videos.first(where: { !$0.complete }) {
      return collection.videos.index(of: video)
    }
    return .none
  }
  
  private func updateFullUI() {
    self.title = collection.title
    self.imageView?.sd_setImage(with: collection.imageURL, placeholderImage: #imageLiteral(resourceName: "cardPlaceholder"))
    self.videosCollectionView?.reloadData()
    updateProgressUI()
  }
  
  private func updateProgressUI() {
    self.layoutNode?.setState(collection.layoutState)
    if let nextVideoIndex = nextVideoIndex {
      self.videosCollectionView.scrollToItem(at: IndexPath(item: nextVideoIndex, section: 0), at: .left, animated: true)
    }
  }
  
  override func viewDidAppear(_ animated: Bool) {
    if let nextVideoIndex = nextVideoIndex {
      self.videosCollectionView.scrollToItem(at: IndexPath(item: nextVideoIndex, section: 0), at: .left, animated: animated)
    }
  }
}

extension CourseViewController: UICollectionViewDataSource {
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return collection.videos.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let node = collectionView.dequeueReusableCellNode(withIdentifier: "CardCell", for: indexPath)
    if let cell = node.view as? CardCollectionViewCell {
      cell.data = collection.videos[indexPath.item]
    }
    return node.view as! UICollectionViewCell
  }
}

extension CourseViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard collectionView == videosCollectionView else { return }
    let video = collection.videos[indexPath.item]

    let videoVC = provider.createViewController(for: video)
    show(videoVC, sender: self)
  }
}

extension CourseViewController {
  @IBAction func handleResumeCourse() {
    if let nextVideoIndex = nextVideoIndex {
      let nextVideo = collection.videos[nextVideoIndex]
      videoPlayer.play(video: nextVideo)
    }
  }
}


fileprivate var dateFormatter: DateFormatter = {
  let df = DateFormatter()
  df.dateStyle = .medium
  df.timeStyle = .none
  return df
}()

extension Collection {
  fileprivate var formattedDescription: NSAttributedString {
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineHeightMultiple = 1.3
    paragraphStyle.paragraphSpacing = 10
    return NSAttributedString(string: contentDescription,
                              attributes: [.paragraphStyle : paragraphStyle])
  }
  
  fileprivate var technology: String {
    return [platform, language, editor].compactMap({ $0 }).joined(separator: " | ")
  }
  
  fileprivate var layoutState: CourseViewController.LayoutState {
    return CourseViewController.LayoutState(
      title: title,
      releaseDuration: "\(dateFormatter.string(from: releasedAt)) | \(prettyDuration)",
      categories: categories.map{ $0.name }.joined(separator: " | "),
      difficulty: "Difficulty: \(difficulty?.description ?? "unknown")",
      technology: technology,
      formattedDescription: formattedDescription,
      complete: complete,
      proportionComplete: proportionComplete,
      labelText: labelText ?? ""
    )
  }
}
