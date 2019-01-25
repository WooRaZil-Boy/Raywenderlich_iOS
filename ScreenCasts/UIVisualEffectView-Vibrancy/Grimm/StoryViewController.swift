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

class StoryViewController: UIViewController {
  
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var storyView: StoryView!
  @IBOutlet weak var optionsContainerView: UIView!
  @IBOutlet weak var optionsContainerViewBottomConstraint: NSLayoutConstraint!
  
  private var showingOptions = false
  
  var story: Story?
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    NotificationCenter.default.addObserver(self, selector: #selector(StoryViewController.themeDidChange), name: ThemeDidChangeNotification, object: nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let image = UIImage(named: "Bull")
    let imageView = UIImageView(image: image)
    navigationItem.titleView = imageView
    reloadTheme()
    guard let story = story else {
      fatalError("Missing critical dependencies!")
    }
    storyView.story = story
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    setOptionsHidden(true, animated: false)
  }
  
  @IBAction func optionsButtonTapped() {
    setOptionsHidden(showingOptions, animated: true)
  }
  
  private func setOptionsHidden(_ hidden: Bool, animated: Bool) {
    showingOptions = !hidden
    let height = optionsContainerView.bounds.height
    var constant = optionsContainerViewBottomConstraint.constant
    constant = hidden ? (constant - height) : (constant + height)
    view.layoutIfNeeded()
    
    if animated {
      UIView.animate(withDuration: 0.2,
                                 delay: 0,
                                 usingSpringWithDamping: 0.95,
                                 initialSpringVelocity: 1,
                                 options: [.allowUserInteraction,
                                           .beginFromCurrentState],
                                 animations: {
                                  self.optionsContainerViewBottomConstraint.constant = constant
                                  self.view.layoutIfNeeded()
      }, completion: nil)
    } else {
      optionsContainerViewBottomConstraint.constant = constant
    }
  }
  
  @objc func themeDidChange() {
    reloadTheme()
    storyView.reloadTheme()
  }
  
}

extension StoryViewController: ThemeAdopting {
  func reloadTheme() {
    let theme = Theme.shared
    scrollView.backgroundColor = theme.textBackgroundColor
    for viewController in children {
      viewController.view.tintColor = theme.tintColor
    }
  }
}
