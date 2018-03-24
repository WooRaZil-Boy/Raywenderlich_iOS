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

import Foundation
import UIKit
import Photos
import RxSwift

class PhotoWriter {
  enum Errors: Error {
    case couldNotSavePhoto
  }
    
    static func save(_ image: UIImage) -> Observable<String> { //assetID를 반환하므로 반환형은 Observalble<String>
        return Observable.create({ observer in //새로운 Observable 생성. //create는 여러개의 next 이벤트 조합을 생성할 수 있다.
            var savedAssetId: String? //못 가져올 수 있으므로 optional
            PHPhotoLibrary.shared().performChanges({ //변경 사항을 수행하도록 하는 블록. 비동기
                let request = PHAssetChangeRequest.creationRequestForAsset(from: image) //새 사진 Asset 생성
                //PHAssetChangeRequest 사진의 생성, 삭제, 메타 데이터 변경 등의 편집 요청
                //creationRequestForAsset : 포토 라이브러리에 새 이미지 Asset을 추가하기 위한 요청을 만든다.
                //placeholderForCreatedAsset로 객체를 검색할 수 있다.
                savedAssetId = request.placeholderForCreatedAsset?.localIdentifier
                //동일한 블록 내에서 생성된 Asset을 참조하는 경우 사용
            }, completionHandler: { success, error in //완료 핸들러
                DispatchQueue.main.async { //완료 이벤트 생성
                    if success, let id = savedAssetId { //성공
                        observer.onNext(id) //AssetID로 next 이벤트 emit
                        observer.onCompleted() //completed 이벤트 emit
                    } else { //에러
                        observer.onError(error ?? Errors.couldNotSavePhoto) //error 이벤트 emit
                    }
                }
            })
            
            return Disposables.create() //dispose
        })
    }
}

//사진 저장시에도 PHPhotoLibrary에 확장을 해서 반응형으로 구현할 수도 있다. 여기서는 PhotoWriter 클래스 생성
//Observable을 생성하면 사진을 쉽게 저장할 수 있다. 이미지가 디스크에 성공적으로 저장되면(.next(assetID)) .completed 이벤트가 emit
//오류가 발생하면 .error가 emit 된다.

//• Observable.never() : Creates an observable sequences that never emits any elements.
//• Observable.just(_:) : Emits one element and a .completed event.
//• Observable.empty() : Emits no elements followed by a .completed event.
//• Observable.error(_) : Emits no elements and a single .error event.

