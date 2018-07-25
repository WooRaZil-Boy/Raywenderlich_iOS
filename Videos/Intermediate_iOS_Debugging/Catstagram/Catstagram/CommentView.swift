/**
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
 * Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
 * distribute, sublicense, create a derivative work, and/or sell copies of the
 * Software in any work that is designed, intended, or marketed for pedagogical or
 * instructional purposes related to programming, coding, application development,
 * or information technology.  Permission for such use, copying, modification,
 * merger, publication, distribution, sublicensing, creation of derivative works,
 * or sale is expressly withheld.
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

class CommentView: UIView {
  static let maxCommentsToShow = 3

  var commentFeed: CommentFeedModel?
  var commentLabels = [UILabel]()

  class func height(forCommentFeed commentFeedModel: CommentFeedModel, withWidth width: CGFloat) -> CGFloat {
    var height: CGFloat = 0.0
    var rect = CGRect.zero
    var currentString = NSAttributedString()

    let boundingSize = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)

    if commentFeedModel.numberOfCommentsForPhotoExceeds(number: maxCommentsToShow) {
      currentString = commentFeedModel.viewAllCommentsAttributedString()
      rect = currentString.boundingRect(with: boundingSize, options: .usesLineFragmentOrigin, context: nil)
      height = height + rect.size.height
    }

    for i in 0 ..< commentFeedModel.numberOfItemsInFeed() {
      currentString = (commentFeedModel.object(at: i)?.commentAttributedString())!
      rect = currentString.boundingRect(with: boundingSize, options: .usesLineFragmentOrigin, context: nil)
      height += rect.size.height
    }

    return height
  }

  init() {
    super.init(frame: CGRect.zero)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func update(withCommentFeedModel commentFeedModel: CommentFeedModel?) {
  }

  func createCommentLabels() {
    guard let commentFeed = commentFeed else { return }
    let addViewAllCommentsLabel = commentFeed.numberOfCommentsForPhotoExceeds(number: 3)
    let numCommentsInFeed = commentFeed.numberOfItemsInFeed()

    let numLabelsToAdd = addViewAllCommentsLabel ? numCommentsInFeed + 1 : numCommentsInFeed

    for _ in 0 ..< numLabelsToAdd {
      let label = UILabel()
      label.numberOfLines = 3

      commentLabels.append(label)
      addSubview(label)
    }
  }

  func removeCommentLabels() {
    for commentLabel in commentLabels {
      commentLabel.removeFromSuperview()
    }
    commentLabels.removeAll()
  }
}
