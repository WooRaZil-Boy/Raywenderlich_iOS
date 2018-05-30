/**
 * Copyright (c) 2017 Razeware LLC
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

import UIKit

protocol BillboardViewDelegate: class {
  func billboardViewDidSelectPlayVideo(_ view: BillboardView)
}

class BillboardView: UIView {
  @IBOutlet weak var currentImageView: UIImageView!
  @IBOutlet weak var previousButton: UIButton!
  @IBOutlet weak var nextButton: UIButton!
  
  weak var delegate: BillboardViewDelegate?
  
  private var currentIndex: Int = 0
  
  func showPreviousImage() {
    let currentX = currentImageView.frame.origin.x
    let newIndex: Int = {
      var index = (self.currentIndex - 1) % self.images.count
      if index < 0 {
        index = self.images.count + index
      }
      return index
    }()

    UIView.animate(withDuration: 0.2, animations: {
      self.currentImageView.frame.origin.x += self.bounds.width
    }, completion: { (finished) in
      self.currentImageView.frame.origin.x = -self.currentImageView.frame.width
      self.showImage(at: newIndex)
      UIView.animate(withDuration: 0.5, animations: {
        self.currentImageView.frame.origin.x = currentX
      })
    })
  }
  
  func showNextImage() {
    let currentX = currentImageView.frame.origin.x
    let newIndex: Int = (currentIndex + 1) % images.count
    
    UIView.animate(withDuration: 0.2, animations: {
      self.currentImageView.frame.origin.x -= self.bounds.width
    }, completion: { (finished) in
      self.currentImageView.frame.origin.x = self.currentImageView.frame.width + currentX
      self.showImage(at: newIndex)
      UIView.animate(withDuration: 0.5, animations: {
        self.currentImageView.frame.origin.x = currentX
      })
    })
  }
  
  private func showImage(at index: Int) {
    currentIndex = index
    currentImageView.image = images[currentIndex]
  }
  
  var images: [UIImage]! {
    didSet {
      showImage(at: 0)
    }
  }
  
  @IBAction func didTapPrevious() {
    showPreviousImage()
  }
  
  @IBAction func didTapNext() {
    showNextImage()
  }
  
  @IBAction func didTapPlayVideo() {
    self.delegate?.billboardViewDidSelectPlayVideo(self)
  }
}

