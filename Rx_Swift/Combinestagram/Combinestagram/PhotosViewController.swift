/*
 * Copyright (c) 2016-present Razeware LLC
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
import Photos
import RxSwift

class PhotosViewController: UICollectionViewController {

  // MARK: public properties

  // MARK: private properties
  private lazy var photos = PhotosViewController.loadPhotos()
  private lazy var imageManager = PHCachingImageManager()

  private lazy var thumbnailSize: CGSize = {
    let cellSize = (self.collectionViewLayout as! UICollectionViewFlowLayout).itemSize
    return CGSize(width: cellSize.width * UIScreen.main.scale,
                  height: cellSize.height * UIScreen.main.scale)
  }()

  static func loadPhotos() -> PHFetchResult<PHAsset> {
    let allPhotosOptions = PHFetchOptions()
    allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
    return PHAsset.fetchAssets(with: allPhotosOptions)
  }
    
    private let selectedPhotosSubject = PublishSubject<UIImage>() //PublishSubject
    //PhotosViewController에서만 사용하므로 private //다른 클래스에서 .next 이벤트 발생 시키는 것을 방지
    //구독 이후의 이벤트만 전달한다.
    var selectedPhotos: Observable<UIImage> { //다른 클래스에서 접근 가능
        //이 속성을 구독해 다른 클래스에서 PhotosViewController에서 선택한 사진 시퀀스에 접근할 수 있다.
        return selectedPhotosSubject.asObservable() //PublishSubject 가져와 반환
    }

  // MARK: View Controller
  override func viewDidLoad() {
    super.viewDidLoad()

  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    selectedPhotosSubject.onCompleted() //뷰가 없어질 때 완료 이벤트 emit
    //메모리가 해제되어 누수를 막을 수 있다. //dispose를 위한 알림을 모든 구독자에게 보낼 수 있다.
  }

  // MARK: UICollectionView

  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return photos.count
  }

  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

    let asset = photos.object(at: indexPath.item)
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PhotoCell

    cell.representedAssetIdentifier = asset.localIdentifier
    imageManager.requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
      if cell.representedAssetIdentifier == asset.localIdentifier {
        cell.imageView.image = image
      }
    })

    return cell
  }

  override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let asset = photos.object(at: indexPath.item) //해당 객체 가져오기

    if let cell = collectionView.cellForItem(at: indexPath) as? PhotoCell {
      cell.flash() //선택 표시
    }

    imageManager.requestImage(for: asset, targetSize: view.frame.size, contentMode: .aspectFill, options: nil, resultHandler: { [weak self] image, info in
      guard let image = image, let info = info else { return }
        
        if let isThumbnail = info[PHImageResultIsDegradedKey as NSString] as? Bool, !isThumbnail {
            self?.selectedPhotosSubject.onNext(image) //.next 이벤트
            //선택한 사진으로 이벤트를 emit
            //따로 delegate를 선언해 메서드를 구현할 필요 없다. 또 이렇게 구현하면 컨트롤러 관계가 직관적이 된다.
        }
    })
  }
}

//Rx의 Variable, PublishSubject, Obsevable로 기본 API 대신 더 간결하고 명확한게 구현했다.
