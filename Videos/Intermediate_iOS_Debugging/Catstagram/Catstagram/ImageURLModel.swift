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

class ImageURLModel {
  
  class func imageParameter(forClosestImageSize size:CGSize) -> String {
    let squareImageRequested = size.width == size.height
    var imageParameterID:Int = 0
    if squareImageRequested {
      imageParameterID = imageParameter(forSquareCroppedSize: size)
    }
    return "&image_size=\(imageParameterID)"
  }
  
  class func imageParameter(forSquareCroppedSize size:CGSize) -> Int {
    var imageParameterID:Int = 0
    
    if size.height <= 70 {
      imageParameterID = 1
    } else if size.height <= 100 {
      imageParameterID = 100
    } else if size.height <= 140 {
      imageParameterID = 2
    } else if size.height <= 200 {
      imageParameterID = 200
    } else if size.height <= 280 {
      imageParameterID = 3
    } else if size.height <= 400 {
      imageParameterID = 400
    } else {
      imageParameterID = 600
    }
    
    return imageParameterID
  }
}
