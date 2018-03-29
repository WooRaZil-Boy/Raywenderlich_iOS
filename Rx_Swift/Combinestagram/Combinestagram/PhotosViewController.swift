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
    private let bag = DisposeBag()

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
    
    let authorized = PHPhotoLibrary.authorized //extension
        .share() //변수가 공유된다.
    
    authorized //true의 경우 //필터링과 구독을 해준다. //share()로 공유
        .skipWhile { $0 == false } //takeWhile은 skipWhile의 반대이다. p.113
        //지정된 조건이 true인 경우 이벤트가 발생하고, 처음 false가 나오면 그 때부터 skip 된다.
        //여기서는 authorized가 false인 경우, true가 될 때까지 onNext()이벤트를 받을 수 없게 된다.
        .take(1) //take는 skip과 반대이다. 요소를 가져온다. p.112
        //skip과 같이 1부터 count가 시작한다. 여기서는 authorized가 true가 되어 onNext가 발생하면, 1개의 요소를 가져온다.
        //사실 true는 항상 마지막 이벤트(이자 하나 밖에 없는 이벤트)이므로 .take(1)을 사용하지 않아도 되지만, 명확하게 하기 위해.
        
        //처음 앱을 열었을 때는 false가 나온다. 그리고, 승인하면 false - true - .completed 순으로 진행된다.
        //이후에는 바로 true - .completed 된다.
        .subscribe(onNext: { [weak self] _ in //구독
            self?.photos = PhotosViewController.loadPhotos()
            
            DispatchQueue.main.async { //메인 스레드에서 UI를 업데이트 한다.
                //extension에서 구현한 requestAuthorization(_:)에서, 실행될 스레드를 보장하지 않으므로, 백그라운드에서 실행될 수도 있다.
                //그 경우, onNext 이벤트가 발생하면 같은 스레드에서 호출이 일어나게 된다. 항상 UI업데이트 시 메인 스레드에 있는지 확인해야 한다.
                //Rx에서는 GCD를 권장하지 않는다. Schedulers를 통해 같은 로직을 구현해 줄 수 있다.
                self?.collectionView?.reloadData()
                //alert에서 OK를 눌러 true를 입력받게 되면, onNext가 emit 되므로 collectionView가 리로드 되면서 사진을 불러오게 된다.
                //일반적으로 처음에 엑서스 허가를 받으면서 PHPhotoLibrary에 엑서스 하게 되면, 다시 로드하지 않을 시 앨범이 따로 보이지 않게 된다.
                //Rx로 구현을 매끄럽게 할 수 있다.
            }
        })
        .disposed(by: bag) //메모리 해제
    
    authorized //false의 경우 //share()로 공유
        .skip(1) //skip을 사용하면, 매개변수로 전달한 숫자까지 무시한다. //따라서 여기선 하나만 무시
        //처음 앱을 열고, 승인을 거부한 경우에는, false - false - .completed 순으로 진행된다.
        //이후 앱을 열고 승인을 다시 거부한 경에도 똑같이 false - false - .completed가 된다.
        //이 경우에는 시퀀스의 첫 째 요소는 항상 무시할 수 있고, 마지막 요소가 false인지만 확인하면 된다.
        .takeLast(1) //마지막 요소를 가져온다.
        //사실 위에서 .skip(1)이나 .takeLast(1) 중 하나만 써도 코드는 잘 작동한다. 마지막 false요소만 가져오면 되기 때문
        //혹은 연속되는 중복 항목을 필터링해주는 distinctUntilChanged()를 사용할 수도 있다.
        //하지만 버전이 업데이트 되고, UIKit 로직이 바뀌는 경우도 있으므로 유지보수 쉽게 적절하게 코드를 써주는 것이 좋다.
        .filter { $0 == false }  //filter를 이용해 해당 요소만 통과하도록 할 수 있다. p.107
        //filter { !$0 }, filter{ ! } 로 쓸수도 있다.
        .subscribe(onNext: { [weak self] _ in //구독
            guard let errorMessage = self?.errorMessage else { return } //errorMessage 타입은 ()->()
            
            DispatchQueue.main.async(execute: errorMessage) //비동기 메인 스레드에서 해당 메서드 실행
        })
        .disposed(by: bag) //메모리 해제
    
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    selectedPhotosSubject.onCompleted() //뷰가 없어질 때 완료 이벤트 emit
    //메모리가 해제되어 누수를 막을 수 있다. //dispose를 위한 알림을 모든 구독자에게 보낼 수 있다.
  }
    
    private func errorMessage() {
        alert(title: "No access to Camera Roll", text: "You can grant access to Combinestagram from the Settings app") //Observable
            .asObservable() //Observable 시퀀스로 만든다. 
            .take(5.0, scheduler: MainScheduler.instance)
            //take(_ : scheduler :)는 주어진 시간 동안에만 시퀀스의 이벤트를 받는다. 시간이 지나면 시퀀스는 .completed 된다.
            //시간 기반 연산자는 스케줄러를 사용한다. MainScheduler.instance는 앱의 메인 스레드에서 코드를 실행하는 공유 스케줄러이다.
            //일정 시간이 지난 후 구독을 종료시켜 사용자가 반드시 입력을 주지 않아도 알림 창이 사라지도록 한다.
            .subscribe(onCompleted: { [weak self] in
                self?.dismiss(animated: true, completion: nil) //alert을 닫는다.
                _ = self?.navigationController?.popViewController(animated: true)
                //PhotosViewController를 닫는다.
            })
            .disposed(by: bag)
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
