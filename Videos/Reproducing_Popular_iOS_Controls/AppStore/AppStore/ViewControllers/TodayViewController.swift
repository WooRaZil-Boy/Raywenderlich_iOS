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

import Foundation
import UIKit

class TodayViewController: UIViewController {
  let tableView = UITableView()
  private let cardViewData: [CardViewModel] = CustomData().cardTiles
  override var prefersStatusBarHidden: Bool {
    return true
  }
  
  private let transitionManager = TransitionManager()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setUpViews()
  }
  
  private func setUpViews() {
    tableView.delegate = self
    tableView.dataSource = self
    tableView.separatorStyle = .none
    tableView.registerCell(GenericTableViewCell<CardView>.self)
    
    view.addSubview(tableView)
    tableView.pinEdgesToSuperview()
  }
}

//MARK: UITableViewDelegate, UITableViewDataSource
extension TodayViewController: UITableViewDelegate, UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return cardViewData.count
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 450
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cardCell = tableView.dequeueReusableCell(forIndexPath: indexPath) as GenericTableViewCell<CardView>
    
    let cardViewModel = cardViewData[indexPath.row]
    
    guard let cellView = cardCell.cellView else {
      
      let appView = AppView(cardViewModel.app)
      if let appViewModel = cardViewModel.app {
        appView?.configure(with: appViewModel)
      }
      let cardView = CardView(cardModel: cardViewModel, appView: appView)
      cardCell.cellView = cardView
      
      return cardCell
    }
    
    cellView.configure(with: cardViewModel)
    cardCell.clipsToBounds = false
    cardCell.contentView.clipsToBounds = false
    cardCell.cellView?.clipsToBounds = false
    
    cardCell.layer.masksToBounds = false
    cardCell.contentView.layer.masksToBounds = false
    cardCell.cellView?.layer.masksToBounds = false
    
    return cardCell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    let cardViewModel = cardViewData[indexPath.row]
    let detailViewController = DetailViewController(cardViewModel: cardViewModel)
    
    detailViewController.transitioningDelegate = transitionManager
    //뷰 컨트롤러 전환 애니메이션를 관리하는 delegate 지정
    detailViewController.modalPresentationStyle = .overFullScreen
    //modal로 나타나는 뷰 컨트롤러의 표시 스타일
    //Transition 효과를 주지 않으면 아무런 애니메이션 없이 전환이 될 뿐이다.
    
    present(detailViewController, animated: true, completion: nil)
    
    //To wake up the UI, Apple issue with cells with selectionStyle = .none
    CFRunLoopWakeUp(CFRunLoopGetCurrent())
  }
  
  func selectedCellCardView() -> CardView? {
    guard let indexPath = tableView.indexPathForSelectedRow else { return nil }
    
    let cell = tableView.cellForRow(at: indexPath) as! GenericTableViewCell<CardView>
    guard let cardView = cell.cellView else { return nil }
    
    return cardView
  }
}

