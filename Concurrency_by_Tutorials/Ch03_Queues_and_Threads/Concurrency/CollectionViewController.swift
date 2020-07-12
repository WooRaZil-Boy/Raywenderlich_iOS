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

import UIKit

final class CollectionViewController: UICollectionViewController {
  private let cellSpacing: CGFloat = 1
  private let columns: CGFloat = 3

  private var cellSize: CGFloat?
  private var urls: [URL] = []

  override func viewDidLoad() {
    super.viewDidLoad()

    guard let plist = Bundle.main.url(forResource: "Photos", withExtension: "plist"),
          let contents = try? Data(contentsOf: plist),
          let serial = try? PropertyListSerialization.propertyList(from: contents, format: nil),
          let serialUrls = serial as? [String] else {
      print("Something went horribly wrong!")
      return
    }

    urls = serialUrls.compactMap { URL(string: $0) }
  }
}

// MARK: - Data source
extension CollectionViewController {
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.urls.count
  }

  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "normal", for: indexPath) as! PhotoCell

//    if let data = try? Data(contentsOf: urls[indexPath.item]),
//      let image = UIImage(data: data) {
//      cell.display(image: image)
//    } else {
//      cell.display(image: nil)
//    }
    
    cell.display(image: nil)
//    downloadWithGlobalQueue(at: indexPath)
    downloadWithUrlSession(at: indexPath)

    return cell
  }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension CollectionViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    if cellSize == nil {
      let layout = collectionViewLayout as! UICollectionViewFlowLayout
      let emptySpace = layout.sectionInset.left + layout.sectionInset.right + (columns * cellSpacing - 1)
      cellSize = (view.frame.size.width - emptySpace) / columns
    }

    return CGSize(width: cellSize!, height: cellSize!)
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return cellSpacing
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return cellSpacing
  }
}

extension CollectionViewController {
  private func downloadWithGlobalQueue(at indexPath: IndexPath) {
    DispatchQueue.global(qos: .utility).async { [weak self] in //self를 캡쳐한다.
      guard let self = self else { return }
      
      let url = self.urls[indexPath.item] //이전에 사용한 코드를 그대로 사용할 수 있다.
      //동기 작업이지만, 별도의 스레드에서 실행되므로 UI에 영향을 미치지 않는다.
      
      guard let data = try? Data(contentsOf: url),
        let image = UIImage(data: data) else {
          return
      }
      
      DispatchQueue.main.async { //UI 업데이트는 기본 스레드에서만 실행할 수 있다.
        if let cell = self.collectionView.cellForItem(at: indexPath) as? PhotoCell {
          //indexPath를 가져오지 않고 그냥 PhotoCell을 가져와 작업하는 경우에는
          //이미지 로딩 중 스크롤 하면, 이미 해당 셀이 재사용되거나 파기되어 다른 이미지가 불려오는 오류가 발생할 수 있다.
          cell.display(image: image)
        }
      }
    }
  }
  
  private func downloadWithUrlSession(at indexPath: IndexPath) {
    URLSession.shared.dataTask(with: urls[indexPath.item]) { [weak self] data, response, error in
      //dispatch queue 대신 URLSession을 사용한다.
      //시스템에서 제공하는 메서드가 있는 경우에는 직접 비동기 코드를 구현하는 것보다, 해당 메서드를 사용하는 것이 좋다.
      guard let self = self,
        let data = data,
        let image = UIImage(data: data) else {
        return
      }
      
      DispatchQueue.main.async {
        if let cell = self.collectionView.cellForItem(at: indexPath) as? PhotoCell {
          cell.display(image: image)
        }
      }
    }.resume()
  }
}


