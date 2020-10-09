/// Copyright (c) 2019 Razeware LLC
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
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import Foundation
import UIKit
import Photos

import Combine

class PhotoWriter {
  enum Error: Swift.Error {
    case couldNotSavePhoto
    case generic(Swift.Error)
  }
  
    static func save(_ image: UIImage) -> Future<String, PhotoWriter.Error> {
        //비동기적으로 이미지를 저장한다.
        return Future { resolve in //Future 반환 //Future는 비동기적으로 단일 결과를 반환하는 publisher.
            //Future의 클로저는 비동기적으로 실행되므로, 메인 스레드 차단을 걱정할 필요없다.
            do { //저장
                try PHPhotoLibrary.shared().performChangesAndWait {
                    //PHPhotoLibrary.performChangesAndWait(_)는 포토 라이브러리에 동기적으로 접근한다.
                    let request = PHAssetChangeRequest.creationRequestForAsset(from: image)
                    //이미지 저장 요청을 생성한다.
                    
                    guard let savedAssetID = request.placeholderForCreatedAsset?.localIdentifier else {
                        //생성된 이미지 asset의 식별자를 가져온다.
                        return resolve(.failure(.couldNotSavePhoto))
                        //이미지 생성에 실패하여 식별자를 가져오지 못하는 경우, future는 해당 오류를 발생시킨다.
                    }
                    
                    resolve(.success(savedAssetID))
                    //이미지 저장이 제대로 된 경우(식별자를 가져오는 경우) future는 success를 발생시킨다.
                }
            } catch { //오류
                resolve(.failure(.generic(error)))
                //발생한 오류를 정확히 알 수 없기 때문에 래핑한다.
            }
        }
    }
}
