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

class CommentFeedModel {
  var commentModels = [CommentModel]()
  var photoID: Int
  
  private var urlString: String
  private var currentPage:UInt = 0
  private var totalPages: UInt = 0
  private var totalItems: UInt = 0
  
  private var fetchPageInProgress = false
  private var refreshFeedInProgress = false
  
  init(photoID: Int) {
    self.photoID = photoID
    urlString = "https://api.500px.com/v1/photos/%@/comments?\(photoID)"
  }
  
  func numberOfItemsInFeed() -> Int {
    return 0
  }
  
  func object(at index: Int) -> CommentModel? {
    if commentModels.count < index && index >= 0 {
      return commentModels[index]
    }
    return nil
  }
  
  func numberOfComments() -> Int {
    return 0
  }
  
  func numberOfCommentsForPhotoExceeds(number: Int) -> Bool {
    return true
  }
  
  func viewAllCommentsAttributedString() -> NSAttributedString {
    return NSAttributedString()
  }
  
  func requestPage(with completion: (([CommentModel]) -> Void)) {
    
  }
  
  func refreshFeed(with completion: (([CommentModel]) -> Void)) {
    
  }
}
