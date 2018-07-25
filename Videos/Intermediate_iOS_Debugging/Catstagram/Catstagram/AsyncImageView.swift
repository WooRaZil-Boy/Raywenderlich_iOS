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

class AsyncImageView: UIView {
  private var _image: UIImage?

  var image: UIImage? {
    set {
      _image = newValue
      layer.contents = nil;
      guard let image = newValue else { return }
      DispatchQueue.global(qos: .userInitiated).async {
        let decodedImage = self.decodedImage(image)
        DispatchQueue.main.async {
          self.layer.contents = decodedImage?.cgImage
        }
      }
    }

    get {
      return _image
    }
  }

  func decodedImage(_ image: UIImage) -> UIImage? {
    guard let newImage = image.cgImage else { return nil }

    let width = newImage.width
    let height = newImage.height

    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width*4, space: colorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
    context?.draw(newImage, in: CGRect(x: 0, y: 0, width: width, height: height))
    let drawnImage = context?.makeImage()
    if let drawnImage = drawnImage {
      let image = UIImage(cgImage: drawnImage)
      return image
    }
    return nil
  }
}
