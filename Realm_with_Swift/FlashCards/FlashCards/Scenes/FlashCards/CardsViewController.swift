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

class CardsViewController: UIViewController {

  private var viewModel: CardsViewModel!

  @IBOutlet private var cardView: UIView!
  @IBOutlet private var cardLabel: UILabel!
  @IBOutlet private var progressLabel: UILabel!
  @IBOutlet private var flagLabel: UILabel!
  
  // MARK: - Create view controller

  static func createWith(_ storyboard: UIStoryboard,
                         viewModel: CardsViewModel) -> CardsViewController {
    let vc = storyboard.instantiateViewController(CardsViewController.self)
    vc.viewModel = viewModel
    vc.title = viewModel.set.name
    return vc
  }

  // MARK: - View controller life-cycle

  override func viewDidLoad() {
    super.viewDidLoad()

    let tap = UITapGestureRecognizer(target: self, action: #selector(didTap))
    cardView.addGestureRecognizer(tap)

    let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(didSwipe))
    swipeLeft.direction = .left
    cardView.addGestureRecognizer(swipeLeft)

    let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(didSwipe))
    swipeRight.direction = .right
    cardView.addGestureRecognizer(swipeRight)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    updateCard()
  }

  // MARK: - UI

  func updateCard() {
    cardLabel.text = viewModel.text
    progressLabel.text = viewModel.details
    flagLabel.text = viewModel.flag
  }

  // MARK: - Actions

  @objc func didTap() {
    viewModel.toggle()
    UIView.transition(with: cardView,
                      duration: 0.33,
                      options: .transitionFlipFromBottom,
                      animations: updateCard,
                      completion: nil)
  }

  @objc func didSwipe(recognizer: UISwipeGestureRecognizer) {
    switch recognizer.direction {
    case .right:
      viewModel.advance(by: -1)
      UIView.transition(with: cardView,
                        duration: 0.33,
                        options: .transitionFlipFromLeft,
                        animations: updateCard,
                        completion: nil)
    case .left:
      viewModel.advance(by: 1)
      UIView.transition(with: cardView,
                        duration: 0.33,
                        options: .transitionFlipFromRight,
                        animations: updateCard,
                        completion: nil)
    default: break
    }
  }
}
