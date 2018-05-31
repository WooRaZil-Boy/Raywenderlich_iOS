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

import UIKit
import ARKit

private enum Section: Int {
  case images = 1
  case video = 0
  case webBrowser = 2
}

private enum Cell: String {
  case cellWebBrowser
  case cellVideo
  case cellImage
}

class BillboardViewController: UICollectionViewController {
  var sceneView: ARSCNView?
  var billboard: BillboardContainer?
  weak var mainViewController: AdViewController?
  weak var mainView: UIView?
  //상위 뷰 컨트롤러 및 슈퍼 뷰에 대한 참조를 유지한다. 전체 화면 모드를 종료할 때 복원해야 되기 때문

  var images: [String] = ["logo_1", "logo_2", "logo_3", "logo_4", "logo_5"]
  let doubleTapGesture = UITapGestureRecognizer() //탭 제스처에 대한 참조 유지

  override func viewDidLoad() {
    super.viewDidLoad()

    doubleTapGesture.numberOfTapsRequired = 2 //이중 탭을 인식한다.
    doubleTapGesture.addTarget(self, action: #selector(didDoubleTap))
    view.addGestureRecognizer(doubleTapGesture) //제스처 추가
  }

  @objc func didDoubleTap() { //이중 탭을 할 경우 이 메서드가 트리거 된다.
    guard let billboard = billboard else { return }
    if billboard.isFullScreen {
      restoreFromFullScreen()
    } else {
      showFullScreen()
    }
  }
}

// UICollectionViewDelegate
extension BillboardViewController {

}

// UICollectionViewDataSource
extension BillboardViewController {
  override func numberOfSections(in collectionView: UICollectionView) -> Int {
    //컬렉션 뷰 섹션 수
    return 3
  }

  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    //컬렉션 뷰 각 섹션당 아이템 수
    guard let currentSection = Section(rawValue: section) else { return 0 }
    //enum으로 섹션을 관리한다.

    switch currentSection {
    case .images:
      return images.count
    case .video:
      return 1
    case .webBrowser:
      return 1
    }
  }

  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    //컬렉션 뷰 각 아이템 셀
    guard let currentSection = Section(rawValue: indexPath.section) else { fatalError("Unexpected collection view section") }
    //enum으로 Section을 관리한다.
    //rawValue로 인식할 수 없는 Section인 경우 fatalError가 발생한다.

    let cellType: Cell //cell을 식별하는 데 사용되는 enum
    switch currentSection {
    case .images:
      cellType = .cellImage
    case .video:
      cellType = .cellVideo
    case .webBrowser:
      cellType = .cellWebBrowser
    }

    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellType.rawValue, for: indexPath)
    //셀 열거형은 셀 식별자를 정의하는 String타입 rawValue를 사용한다.
    //지정된 indexPath의 셀이 Queue에서 dequeue된다.

    switch cell { //셀 유형에 따라 적절한 데이터로 셀을 구성한다.
    case let imageCell as ImageCell:
      let image = UIImage(named: images[indexPath.row])!
      imageCell.show(image: image)

    case let videoCell as VideoCell:
      let videoUrl = "https://www.rmp-streaming.com/media/bbb-360p.mp4"
      if let sceneView = sceneView, let billboard = billboard {
        videoCell.configure(videoUrl: videoUrl, sceneView: sceneView, billboard: billboard)
      }
      break

    case let webBrowserCell as WebBrowserCell:
      webBrowserCell.go(to: "https://www.raywenderlich.com")

    default:
      fatalError("Unrecognized cell")
    }

    return cell
  }
}

extension BillboardViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return collectionView.bounds.size
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    return .zero
  }
}

extension BillboardViewController {
  func showFullScreen() {
    guard let billboard = billboard else { return }
    guard billboard.isFullScreen == false else { return }

    guard let mainViewController = parent as? AdViewController else { return }
    self.mainViewController = mainViewController //상위 뷰 컨트롤러 참조 유지
    mainView = view.superview //슈퍼 뷰 참조 유지
    //상위 뷰 컨트롤러 및 슈퍼 뷰에 대한 참조를 유지한다. 전체 화면 모드를 종료할 때 복원해야 되기 때문

    willMove(toParentViewController: nil)
    //willMove는 뷰 컨트롤러가 컨테이너 뷰 컨트롤러에 추가 되거나 제거되기 바로 전에 호출된다.
    view.removeFromSuperview() //뷰를 부모 뷰에서 제거
    removeFromParentViewController() //뷰 컨트롤러를 부모 뷰 컨트롤러에서 제거

    willMove(toParentViewController: mainViewController)
    //willMove는 parentVC가 childVC를 추가할 때 childVC에서 불리게 되며 이 때 ParentView는 NavigationVC, TabBarVC가 될 수 있다.
    mainViewController.view.addSubview(view) //뷰를 이전 부모 뷰에 다시 추가
    mainViewController.addChildViewController(self) //뷰 컨트롤러를 이전 부모 뷰 컨트롤러에 다시 추가
    
    billboard.isFullScreen = true //전체 화면 플래그 설정
  }

  func restoreFromFullScreen() {
    //showFullScreen의 반대 순서대로 수행된다.
    guard let billboard = billboard else { return }
    guard billboard.isFullScreen == true else { return }
    guard let mainViewController = mainViewController else { return }
    guard let mainView = mainView else { return }

    willMove(toParentViewController: nil)
    view.removeFromSuperview()
    removeFromParentViewController()
    //superView(AdViewController)에서 BillboardViewController의 뷰와 뷰 컨트롤러를 제거한다.

    willMove(toParentViewController: mainViewController)
    mainView.addSubview(view)
    mainViewController.addChildViewController(self)
    //저장해둔 mainView와 mainViewController을 원래 대로 되돌린다.

    billboard.isFullScreen = false //전체 화면 플래그 설정
    self.mainViewController = nil
    self.mainView = nil
    //참조 해제
  }
}
