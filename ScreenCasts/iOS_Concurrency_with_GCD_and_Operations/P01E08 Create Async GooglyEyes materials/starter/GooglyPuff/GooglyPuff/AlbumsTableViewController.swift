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

private let reuseIdentifier = "AlbumsCell"

class AlbumsTableViewController: UITableViewController {

  var selectedAssets: SelectedAssets?
  var assetPickerDelegate: AssetPickerDelegate?
  
  private let sectionNames = ["","Albums"]
  private var userLibrary: PHFetchResult<PHAssetCollection>!
  private var userAlbums: PHFetchResult<PHCollection>!
  
  private var doneButton: UIBarButtonItem!
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    if selectedAssets == nil {
      selectedAssets = SelectedAssets()
    }
    PHPhotoLibrary.requestAuthorization { status in
      DispatchQueue.main.async {
        switch status {
        case .authorized:
          self.fetchCollections()
          self.tableView.reloadData()
        default:
          self.showNoAccessAlertAndCancel()
        }
      }
    }
    doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(donePressed(_:)))
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    updateDoneButton()
  }
  
  // MARK: - Navigation

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    let destination = segue.destination
      as! AssetsCollectionViewController
    // Set up AssetCollectionViewController
    destination.selectedAssets = selectedAssets
    let cell = sender as! UITableViewCell
    destination.title = cell.textLabel!.text
    destination.assetPickerDelegate = self
    let options = PHFetchOptions()
    options.sortDescriptors =
      [NSSortDescriptor(key: "creationDate", ascending: true)]
    let indexPath = tableView.indexPath(for: cell)!
    switch (indexPath.section) {
    case 0:
      // Camera Roll
      let library = userLibrary[indexPath.row]
      destination.assetsFetchResults =
        PHAsset.fetchAssets(in: library,
                            options: options) as? PHFetchResult<AnyObject>
    case 1:
      // Albums
      let album = userAlbums[indexPath.row] as! PHAssetCollection
      destination.assetsFetchResults =
        PHAsset.fetchAssets(in: album,
                            options: options) as? PHFetchResult<AnyObject>
    default:
      break
    }
  }

  @IBAction func cancelPressed(_ sender: Any) {
    assetPickerDelegate?.assetPickerDidCancel()
  }
  
  @IBAction func donePressed(_ sender: Any) {
    // Should only be invoked when there are selected assets
    if let assets = selectedAssets?.assets {
      assetPickerDelegate?.assetPickerDidFinishPickingAssets(assets)
      // Clear out selections
      selectedAssets?.assets.removeAll()
    }
  }
  
}

// MARK: - Private Methods

extension AlbumsTableViewController {
  func fetchCollections() {
    userAlbums = PHCollectionList.fetchTopLevelUserCollections(with: nil)
    userLibrary = PHAssetCollection.fetchAssetCollections(
      with: .smartAlbum,
      subtype: .smartAlbumUserLibrary,
      options: nil)
  }
  
  func showNoAccessAlertAndCancel() {
    let alert = UIAlertController(title: "No Photo Permissions", message: "Please grant photo permissions in Settings", preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { _ in
      UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
      return
    }))
    
    self.present(alert, animated: true, completion: nil)
  }
  
  private func updateDoneButton() {
    guard let selectedAssets = selectedAssets else { return }
    // Add a done button when there are selected assets
    if selectedAssets.assets.count > 0 {
      navigationItem.rightBarButtonItem = doneButton
    } else {
      navigationItem.rightBarButtonItem = nil
    }
  }
}

// MARK: - Table view data source

extension AlbumsTableViewController {
  override func numberOfSections(in tableView: UITableView) -> Int {
    sectionNames.count
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch (section) {
    case 0:
      return userLibrary?.count ?? 0
    case 1:
      return userAlbums?.count ?? 0
    default:
      return 0
    }
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
    cell.textLabel!.text = ""
    
    switch(indexPath.section) {
    case 0:
      let library = userLibrary[indexPath.row]
      var title = library.localizedTitle!
      if (library.estimatedAssetCount != NSNotFound) {
        title += " (\(library.estimatedAssetCount))"
      }
      cell.textLabel!.text = title
    case 1:
      let album = userAlbums[indexPath.row] as! PHAssetCollection
      var title = album.localizedTitle!
      if (album.estimatedAssetCount != NSNotFound) {
        title += " (\(album.estimatedAssetCount))"
      }
      cell.textLabel!.text = title
    default:
      break
    }
    
    cell.accessoryType = .disclosureIndicator
    
    return cell
  }

}

// MARK: - AssetPickerDelegate

extension AlbumsTableViewController: AssetPickerDelegate {
  func assetPickerDidCancel() {
    assetPickerDelegate?.assetPickerDidCancel()
  }
  
  func assetPickerDidFinishPickingAssets(_ selectedAssets: [PHAsset])  {
    assetPickerDelegate?.assetPickerDidFinishPickingAssets(selectedAssets)
    // Clear out selections
    self.selectedAssets?.assets.removeAll()
  }
}
