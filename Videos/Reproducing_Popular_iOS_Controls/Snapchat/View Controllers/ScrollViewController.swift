/// Copyright (c) 2018 Razeware LLC
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

protocol ScrollViewControllerDelegate {
  var viewControllers: [UIViewController?] { get } //ScrollViewController가 표시할 하위 뷰 컨트롤러
  var initialViewController: UIViewController { get } //default로 보여줄 뷰 컨트롤러
  func scrollViewDidScroll()
}

class ScrollViewController: UIViewController {
  //MainViewController 위에서 각각의 CameraView Controller, LensViewController, DiscoverViewController를 보여 주는 역할을 하는 뷰 컨트롤러.
  //MainViewController에서 각각의 아이콘을 선택하면, 스크롤 뷰 컨트롤러 위의 해당 뷰 컨트롤러 위치로 스크롤이 된다.
  
  // MARK: - Properties
  var scrollView: UIScrollView {
    return view as! UIScrollView
  }
  
  var pageSize: CGSize { //스크롤 뷰 프레임
    return scrollView.frame.size
  }
  
  var viewControllers: [UIViewController?]! //하위 뷰 컨트롤러
  var delegate: ScrollViewControllerDelegate?
  
  // MARK: - View Life Cycle
  override func loadView() {
    let scrollView = UIScrollView()
    scrollView.bounces = false
    scrollView.showsHorizontalScrollIndicator = false
    scrollView.delegate = self
    scrollView.isPagingEnabled = true
    
    view = scrollView
    view.backgroundColor = .clear
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    viewControllers = delegate?.viewControllers //delegate의 ViewControllers를 할당
    
    // add view controllers as children
    for (index, controller) in viewControllers.enumerated() {
      if let controller = controller {
        addChild(controller) //자식 뷰 컨트롤러로 추가한다.
        controller.view.frame = frame(for: index)
        scrollView.addSubview(controller.view) //자식 뷰로 추가한다.
        controller.didMove(toParent: self) //뷰 컨트롤러가 컨테이너 뷰 컨트롤러에 추가 되거나 제거 된 후 호출
      }
    }
    
    scrollView.contentSize = CGSize(width: pageSize.width * CGFloat(viewControllers.count),
                                    height: pageSize.height)
    //스크롤 뷰의 콘텐츠 사이즈 설정
    
    // set initial position of scroll view
    if let controller = delegate?.initialViewController {
      setController(to: controller, animated: false)
      //ViewDidLoad에서, 해당 뷰 컨트롤러(initialViewController)를 보여주게 된다.
    }
  }
}

// MARK: - Private methods
fileprivate extension ScrollViewController {
  
  func frame(for index: Int) -> CGRect { //각 ViewController의 프레임. 인덱스로 해당 영역을 가져온다.
    return CGRect(x: CGFloat(index) * pageSize.width,
                  y: 0,
                  width: pageSize.width,
                  height: pageSize.height)
  }
  
  func indexFor(controller: UIViewController?) -> Int? { //해당 뷰 컨트롤러가 존재하면 index를 반환한다.
    return viewControllers.index(where: {$0 == controller } )
    //Array에서 index 메서드를 사용해서 해당 요소의 인덱스를 반환할 수 있다.
  }
}

// MARK: - Public methods
extension ScrollViewController {
  
  public func setController(to controller: UIViewController, animated: Bool) {
    guard let index = indexFor(controller: controller) else { return }
    //해당 뷰 컨트롤러가 존재하지 않으면 return
    
    let contentOffset = CGPoint(x: pageSize.width * CGFloat(index), y: 0)
    //그냥 단순히 ScrollViewController를 MainViewController의 자식 뷰 컨트롤러로 추가하면
    //0, 0의 offset으로 추가되기 때문에 원하는 위치만큼 이동해 줘야 한다(여기서는 중간 뷰 컨트롤러).
    
    if animated {
      UIView.animate(withDuration: 0.2, delay: 0, options: [UIView.AnimationOptions.curveEaseOut], animations: {
        self.scrollView.setContentOffset(contentOffset, animated: false)
        //콘텐츠의 위치를 이동 시켜 준다.
      })
    } else {
      scrollView.setContentOffset(contentOffset, animated: animated)
    }
  }
  
  public func isControllerVisible(_ controller: UIViewController?) -> Bool {
    //해당 뷰 컨트롤러가 현재 스크롤 뷰 위에서 보이는 상태인지 판단한다.
    guard controller != nil else { return false }
    for i in 0..<viewControllers.count {
      if viewControllers[i] == controller {
        let controllerFrame = frame(for: i)
        return controllerFrame.intersects(scrollView.bounds)
        //두 프레임이 교차하면 true, 아니면 false
      }
    }
    return false
  }
}

// MARK: - UIScrollViewDelegate
extension ScrollViewController: UIScrollViewDelegate {
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    delegate?.scrollViewDidScroll() //프로토콜로 구현한 메서드
  }
}

