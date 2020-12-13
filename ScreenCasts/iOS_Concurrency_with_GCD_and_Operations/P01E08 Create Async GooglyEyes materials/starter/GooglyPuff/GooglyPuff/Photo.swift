/// Copyright (c) 2020 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit
import Photos

typealias PhotoDownloadCompletionBlock = (_ image: UIImage?, _ error: NSError?) -> Void
typealias PhotoDownloadProgressBlock = (_ completed: Int, _ total: Int) -> Void

enum PhotoStatus {
  case downloading
  case goodToGo
  case failed
}

private let scale = UIScreen.main.scale
private let cellSize = CGSize(width: 64, height: 64)
private let thumbnailSize = CGSize(width: cellSize.width * scale, height: cellSize.height * scale)
private let imageManager = PHImageManager()

protocol Photo {
  var statusImage: PhotoStatus { get }
  var statusThumbnail: PhotoStatus { get }
  var image: UIImage? { get }
  var thumbnail: UIImage? { get }
}

class AssetPhoto: Photo {
  var statusImage: PhotoStatus = .downloading
  var statusThumbnail: PhotoStatus = .downloading
  var image: UIImage?
  var thumbnail: UIImage?
  
  let asset: PHAsset
  let representedAssetIdentifier: String
  private let targetSize = CGSize(width:600, height:600)
  
  init(asset: PHAsset) {
    self.asset = asset
    representedAssetIdentifier = asset.localIdentifier
    fetchThumbnailImage()
    fetchImage()
  }
  
  private func fetchThumbnailImage() {
    let options = PHImageRequestOptions()
    options.isNetworkAccessAllowed = true
    imageManager.requestImage(for: asset, targetSize: thumbnailSize,
        contentMode: .aspectFill, options: options) { image, info in
      if let image = image {
        if self.representedAssetIdentifier == self.asset.localIdentifier {
          self.thumbnail = image
          self.statusThumbnail = .goodToGo
        }
      } else if let info = info,
        let _ = info[PHImageErrorKey] as? NSError {
        self.statusThumbnail = .failed
      }
    }
  }
  
  private func fetchImage() {
    let options = PHImageRequestOptions()
    options.deliveryMode = .highQualityFormat
    options.isNetworkAccessAllowed = true
    
    PHImageManager.default().requestImage(for: asset, targetSize: targetSize,
        contentMode: .aspectFill, options: options) { image, info in
      if let image = image {
        if image.size.width < self.targetSize.width / 2 {
          DispatchQueue.main.asyncAfter(deadline: .now(), execute: self.fetchImage)
        }
        if self.representedAssetIdentifier == self.asset.localIdentifier {
          self.image = image
          self.statusImage = .goodToGo
        }
      } else if let info = info,
        let _ = info[PHImageErrorKey] as? NSError {
        self.statusImage = .failed
      }
    }
  }
}

private let downloadSession = URLSession(configuration: URLSessionConfiguration.ephemeral)

class DownloadPhoto: Photo {
  var statusImage: PhotoStatus = .downloading
  var statusThumbnail: PhotoStatus = .downloading
  var image: UIImage?
  var thumbnail: UIImage?
  
  let url: URL
  
  init(url: URL, completion: PhotoDownloadCompletionBlock?) {
    self.url = url
    downloadImage(completion)
  }
  
  convenience init(url: URL) {
    self.init(url: url, completion: nil)
  }
  
  private func downloadImage(_ completion: PhotoDownloadCompletionBlock?) {
    let task = downloadSession.dataTask(with: url) { data, response, error in
      if let data = data {
        self.image = UIImage(data: data)
      }
      if error == nil && self.image != nil {
        self.statusImage = .goodToGo
        self.statusThumbnail = .goodToGo
      } else {
        self.statusImage = .failed
        self.statusThumbnail = .failed
      }
      
      self.thumbnail = self.image?.thumbnailImage(Int(cellSize.width), transparentBorder: 0,
          cornerRadius: 0, interpolationQuality: CGInterpolationQuality.default)
      
      completion?(self.image, error as NSError?)
      
      DispatchQueue.main.async {
        NotificationCenter.default.post(name: PhotoManagerNotification.contentUpdated, object: nil)
      }
    }
    
    task.resume()
  }
}
