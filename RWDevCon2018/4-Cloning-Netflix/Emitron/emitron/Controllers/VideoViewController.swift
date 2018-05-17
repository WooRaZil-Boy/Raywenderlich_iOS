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

class VideoViewController: UIViewController, LayoutLoading {
  typealias DependencyProvider = StoreProvider & VideoPlayerProvider
  private let provider: DependencyProvider
  private let video: Video
  private var progressChangeToken: Any?
  
  private lazy var store = provider.store
  private lazy var videoPlayer = provider.videoPlayer

  @IBOutlet weak var imageView: UIImageView! {
    didSet {
      imageView?.sd_setImage(with: video.imageURL, placeholderImage: #imageLiteral(resourceName: "cardPlaceholder"))
    }
  }
  
  init(dependencyProvider: DependencyProvider, video: Video) {
    self.provider = dependencyProvider
    self.video = video
    super.init(nibName: .none, bundle: .none)
    self.progressChangeToken = video.observeProgressChange { [weak self] changeType in
      switch changeType {
      case .changed:
        self?.layoutNode?.setState(video.layoutState)
      case .deleted:
        self?.progressChangeToken = .none
      }
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension VideoViewController {
  struct LayoutState {
    let title: String
    let releaseDuration: String
    let categories: String
    let difficulty: String
    let technology: String
    let formattedDescription: NSAttributedString
    let formattedAuthorNotes: NSAttributedString
    let complete: Bool
    let proportionComplete: Double
    let labelText: String
    
    static var empty: LayoutState {
      return LayoutState(title: "",
                         releaseDuration: "",
                         categories: "",
                         difficulty: "",
                         technology: "",
                         formattedDescription: NSAttributedString(string: ""),
                         formattedAuthorNotes: NSAttributedString(string: ""),
                         complete: false,
                         proportionComplete: 0,
                         labelText: "")
    }
  }
  
  override func viewDidLoad() {
    loadLayout(named: "Video.xml",
               state: video.layoutState,
               constants: GLOBAL_CONSTANTS.dictionary)
    title = video.title
  }
  
  @IBAction func beginPlayback() {
    // Need to request video with clips
    videoPlayer.play(video: video)
  }
}

fileprivate var dateFormatter: DateFormatter = {
  let df = DateFormatter()
  df.dateStyle = .medium
  df.timeStyle = .none
  return df
}()

extension Video {
  private var paragraphStyle: NSParagraphStyle {
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineHeightMultiple = 1.3
    paragraphStyle.paragraphSpacing = 10
    return paragraphStyle
  }
  
  private var formattedDescription: NSAttributedString {
    return NSAttributedString(string: contentDescription,
                              attributes: [.paragraphStyle : paragraphStyle])
  }
  
  private var formattedAuthorNotes: NSAttributedString {
    return NSAttributedString(string: authorNotes ?? "",
                              attributes: [.paragraphStyle : paragraphStyle])
  }
  
  private var technology: String {
    return [platform, language, editor].compactMap({ $0 }).joined(separator: " | ")
  }
  
  fileprivate var layoutState: VideoViewController.LayoutState {
    return VideoViewController.LayoutState(
      title: title,
      releaseDuration: "\(dateFormatter.string(from: releasedAt)) | \(prettyDuration)",
      categories: categories.map{ $0.name }.joined(separator: " | "),
      difficulty: "Difficulty: \(difficulty?.description ?? "unknown")",
      technology: technology,
      formattedDescription: formattedDescription,
      formattedAuthorNotes: formattedAuthorNotes,
      complete: complete,
      proportionComplete: proportionComplete,
      labelText: labelText ?? ""
    )
  }
}
