/// Copyright (c) 2017 Razeware LLC
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

class OptionsController: UIViewController {
  
  private var currentPage = 0
  @IBOutlet weak var readingModeSegmentedControl: UISegmentedControl!
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var titleAlignmentSegmentedControl: UISegmentedControl!
  @IBOutlet weak var pageControl: UIPageControl!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    guard let optionsView = UINib(nibName: "OptionsView", bundle: nil).instantiate(withOwner: self, options: nil).first as? UIView else { return }
    scrollView.scrollsToTop = false
    
    view.addSubview(optionsView)
    NSLayoutConstraint.activate([
      view.centerXAnchor.constraint(equalTo: optionsView.centerXAnchor),
      view.centerYAnchor.constraint(equalTo: optionsView.centerYAnchor)
      ])
    
    view.backgroundColor = .clear //전체 뷰의 background 색상을 투명하게 한다.
    //Blur를 추가해도 뷰 뒤의 요소들을 희미하게 보여진다.
    let blurEffect = UIBlurEffect(style: .light) //BlurEffect 생성
    let blurView = UIVisualEffectView(effect: blurEffect) //BlurEffect를 가지는 뷰를 생성한다.
    blurView.translatesAutoresizingMaskIntoConstraints = false //오토 레이아웃 해제
    view.insertSubview(blurView, at: 0) //BlurView를 view stack의 가장 밑에 추가한다.
    
    NSLayoutConstraint.activate([
        blurView.heightAnchor.constraint(equalTo: view.heightAnchor),
        blurView.widthAnchor.constraint(equalTo: view.widthAnchor)])
    //오토 레이아웃 제약 조건을 추가해 준다.
    
    //iOS 7에서 Apple은 많은 디자인을 바꾼 이후, Blur 효과는 굉장히 많은 앱에서 사용된다.
    //ex. Control Center : background를 모두 Blur 처리 한다.
    //  Notification Center : 각 notification message를 Blur 처리한다.
    //UIVisualEffectView 를 사용해서, Blur 효과를 쉽게 구현할 수 있다.
    //Blur를 구현하는 알고리즘은 여러 개가 있다. 가장 흔하게 하용되는 것은 Gaussian blur로 여기서도 이를 사용한다.
    //해당 픽셀의 값을 범위 안의 다른 픽셀들의 값을 평균한 값으로 나타내서 구현한다.
    //이를 모든 픽셀에 반복하면, Blurre image를 얻을 수 있다.
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    let theme = Theme.shared
    readingModeSegmentedControl.selectedSegmentIndex = theme.readingMode.rawValue
    titleAlignmentSegmentedControl.selectedSegmentIndex = theme.titleAlignment.rawValue
    currentPage = theme.font.rawValue
    pageControl.currentPage = currentPage
    synchronizeViews(scrolled: false)
  }
  
  @IBAction func pageControlPageDidChange() {
    synchronizeViews(scrolled: false)
  }
  
  @IBAction func readingModeDidChange(_ segmentedControl: UISegmentedControl) {
    Theme.shared.readingMode = ReadingMode(rawValue: segmentedControl.selectedSegmentIndex) ?? .dayTime
  }
  
  @IBAction func titleAlignmentDidChange(_ segmentedControl: UISegmentedControl) {
    Theme.shared.titleAlignment = TitleAlignment(rawValue: segmentedControl.selectedSegmentIndex) ?? .left
  }
  
  private func synchronizeViews(scrolled: Bool) {
    let pageWidth = scrollView.bounds.width
    var page: Int = 0
    var offset: CGFloat = 0
    
    if scrolled {
      offset = scrollView.contentOffset.x
      page = Int(offset / pageWidth)
      pageControl.currentPage = page
    } else {
      page = pageControl.currentPage
      offset = CGFloat(page) * pageWidth
      scrollView.setContentOffset(CGPoint(x: offset, y: 0), animated: true)
    }
    
    if page != currentPage {
      currentPage = page
      Theme.shared.font = Font(rawValue: currentPage) ?? .firaSans
    }
  }
}

extension OptionsController: UIScrollViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    if scrollView.isDragging || scrollView.isDecelerating {
      synchronizeViews(scrolled: true)
    }
  }
}


