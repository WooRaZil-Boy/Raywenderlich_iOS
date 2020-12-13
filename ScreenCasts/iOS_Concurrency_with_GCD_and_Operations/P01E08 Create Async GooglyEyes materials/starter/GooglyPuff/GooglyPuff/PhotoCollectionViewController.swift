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

private let reuseIdentifier = "photoCell"
private let backgroundImageOpacity: CGFloat = 0.1

final class PhotoCollectionViewController: UICollectionViewController {
  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let backgroundImageView = UIImageView(image: UIImage(named:"background"))
    backgroundImageView.alpha = backgroundImageOpacity
    backgroundImageView.contentMode = .center
    collectionView?.backgroundView = backgroundImageView
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(contentChangedNotification(_:)),
      name: PhotoManagerNotification.contentUpdated,
      object: nil)
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(contentChangedNotification(_:)),
      name: PhotoManagerNotification.contentAdded,
      object: nil)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    //    showOrHideNavPrompt()
  }

  // MARK: - IBAction Methods
  @IBAction func addPhotoAssets(_ sender: Any) {
    let viewController = self.storyboard?.instantiateViewController(withIdentifier: "AlbumsStoryboard") as? UINavigationController
    if let viewController = viewController,
      let albumsTableViewController = viewController.topViewController as? AlbumsTableViewController {
      albumsTableViewController.assetPickerDelegate = self
      self.present(viewController, animated: true, completion: nil)
    }
  }
}

// MARK: - Private Methods
private extension PhotoCollectionViewController {
  func showOrHideNavPrompt() {
    let delayInSeconds = 2.0
    DispatchQueue.main.asyncAfter(deadline: .now() + delayInSeconds) { [weak self] in
      guard let self = self else {
        return
      }
      
      if PhotoManager.shared.photos.count > 0 {
        self.navigationItem.prompt = nil
      } else {
        self.navigationItem.prompt = "Add photos with faces to Googlyify them!"
      }
      self.navigationController?.viewIfLoaded?.setNeedsLayout()
    }
  }
  
  func downloadImageAssets() {
    PhotoManager.shared.downloadPhotos() { [weak self] error in
      
      let message = error?.localizedDescription ?? "The images have finished downloading"
      let alert = UIAlertController(title: "Download Complete", message: message, preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
      self?.present(alert, animated: true, completion: nil)
    }
  }
}

// MARK: - Notification handlers
extension PhotoCollectionViewController {
  @objc func contentChangedNotification(_ notification: Notification!) {
    collectionView?.reloadData()
    //    showOrHideNavPrompt()
  }
}

// MARK: - UICollectionViewDataSource
extension PhotoCollectionViewController {
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    PhotoManager.shared.photos.count
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoCollectionViewCell
    
    let photoAssets = PhotoManager.shared.photos
    let photo = photoAssets[indexPath.row]
    
    switch photo.statusThumbnail {
    case .goodToGo:
      cell.thumbnailImage = photo.thumbnail
    case .downloading:
      cell.thumbnailImage = UIImage(named: "photoDownloading")
    case .failed:
      cell.thumbnailImage = UIImage(named: "photoDownloadError")
    }
    
    return cell
  }
}

// MARK: - UICollectionViewDelegate
extension PhotoCollectionViewController {
  override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let photos = PhotoManager.shared.photos
    let photo = photos[indexPath.row]
    
    switch photo.statusImage {
    case .goodToGo:
      let viewController = storyboard?.instantiateViewController(withIdentifier: "PhotoDetailStoryboard") as? PhotoDetailViewController
      if let viewController = viewController {
        viewController.image = photo.image
        navigationController?.pushViewController(viewController, animated: true)
      }
      
    case .downloading:
      let alert = UIAlertController(title: "Downloading",
                                    message: "The image is currently downloading",
                                    preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
      present(alert, animated: true, completion: nil)
      
    case .failed:
      let alert = UIAlertController(title: "Image Failed",
                                    message: "The image failed to be created",
                                    preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
      present(alert, animated: true, completion: nil)
    }
  }
}

// MARK: - AssetPickerDelegate

extension PhotoCollectionViewController: AssetPickerDelegate {
  func assetPickerDidCancel() {
    dismiss(animated: true, completion: nil)
  }
  
  func assetPickerDidFinishPickingAssets(_ selectedAssets: [PHAsset])  {
    for asset in selectedAssets {
      let photo = AssetPhoto(asset: asset)
      PhotoManager.shared.addPhoto(photo)
    }

    dismiss(animated: true, completion: nil)
  }
}
