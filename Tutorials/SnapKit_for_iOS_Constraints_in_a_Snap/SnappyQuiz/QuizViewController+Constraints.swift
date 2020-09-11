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
import SnapKit

extension QuizViewController {
  func setupConstraints() {
//    guard let navView = navigationController?.view else { return }

//    viewProgress.translatesAutoresizingMaskIntoConstraints = false
    
//    NSLayoutConstraint.activate([
//      viewProgress.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//      viewProgress.heightAnchor.constraint(equalToConstant: 32),
//      viewProgress.leadingAnchor.constraint(equalTo: view.leadingAnchor)
//    ])
    //제거 //새로운 updateProgress(to:) 메서드를 사용하면서 불필요해진다.

    updateProgress(to: 0)

//    lblTimer.translatesAutoresizingMaskIntoConstraints = false
//    NSLayoutConstraint.activate([
//        lblTimer.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.45),
//        lblTimer.heightAnchor.constraint(equalToConstant: 45),
//        lblTimer.topAnchor.constraint(equalTo: viewProgress.bottomAnchor, constant: 32),
//        lblTimer.centerXAnchor.constraint(equalTo: view.centerXAnchor)
//    ])
    
//    lblTimer.snp.makeConstraints { make in
//      make.width.equalToSuperview().multipliedBy(0.45)
//      //lblTimer의 너비를 superview 너비의 0.45배(45%)로 설정한다.
//      make.height.equalTo(45) //lblTimer의 높이를 정적으로 45로 설정한다.
//      make.top.equalTo(viewProgress.snp.bottom).offset(32)
//      //lblTimer 상단을 viewProgress의 하단으로 제약조건을 설정하고 offset 값은 32로 한다.
//      make.centerX.equalToSuperview()
//      //X 축을 superview의 X축 중앙에 배치한다. lblTimer은 수평 중앙에 배치된다.
//      make.centerY.equalToSuperview() //디버깅을 위해 일부러 맞지 않는 제약 조건을 추가
//    }
    
    lblTimer.snp.makeConstraints { make in
      make.width.equalToSuperview().multipliedBy(0.45).labeled("timerWidth")
      make.height.equalTo(45).labeled("timerHeight")
      make.top.equalTo(viewProgress.snp.bottom).offset(32).labeled("timerTop")
      make.centerX.equalToSuperview().labeled("timerCenterX")
//      make.centerY.equalToSuperview().labeled("timerCenterY") //디버깅을 위해 일부러 맞지 않는 제약 조건을 추가
    }
    //label을 추가할 수 있다.

    
    
//    lblQuestion.translatesAutoresizingMaskIntoConstraints = false
//    NSLayoutConstraint.activate([
//        lblQuestion.topAnchor.constraint(equalTo: lblTimer.bottomAnchor, constant: 24),
//        lblQuestion.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
//        lblQuestion.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
//    ])
    
    lblQuestion.snp.makeConstraints { make in
      make.top.equalTo(lblTimer.snp.bottom).offset(24)
//      make.leading.equalToSuperview().offset(16)
//      make.trailing.equalToSuperview().offset(-16)
      
//      make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(16) //둘을 합쳐 표현해 줄 수 있다.
      make.leading.trailing.equalTo(view.safeAreaLayoutGuide)
        .inset(UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16))
      //반드시 숫자를 사용할 필요는 없다.
    }

//    lblMessage.translatesAutoresizingMaskIntoConstraints = false
//    NSLayoutConstraint.activate([
//        lblMessage.topAnchor.constraint(equalTo: navView.topAnchor),
//        lblMessage.bottomAnchor.constraint(equalTo: navView.bottomAnchor),
//        lblMessage.leadingAnchor.constraint(equalTo: navView.leadingAnchor),
//        lblMessage.trailingAnchor.constraint(equalTo: navView.trailingAnchor)
//    ])
    
    lblMessage.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }

//    svButtons.translatesAutoresizingMaskIntoConstraints = false
//    NSLayoutConstraint.activate([
//        svButtons.leadingAnchor.constraint(equalTo: lblQuestion.leadingAnchor),
//        svButtons.trailingAnchor.constraint(equalTo: lblQuestion.trailingAnchor),
//        svButtons.topAnchor.constraint(equalTo: lblQuestion.bottomAnchor, constant: 16),
//        svButtons.heightAnchor.constraint(equalToConstant: 80)
//    ])
    
    svButtons.snp.makeConstraints { make in
      make.leading.trailing.equalTo(lblQuestion)
      make.top.equalTo(lblQuestion.snp.bottom).offset(16)
      make.height.equalTo(80)
    }
  }
  
//  func updateProgress(to progress: Double) {
//    if let constraint = progressConstraint {
//      constraint.isActive = false
//    }
//
//    progressConstraint = viewProgress.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: CGFloat(progress))
//    progressConstraint.isActive = true
//  }
  
  func updateProgress(to progress: Double) {
    viewProgress.snp.remakeConstraints { make in
      make.top.equalTo(view.safeAreaLayoutGuide)
      make.width.equalToSuperview().multipliedBy(progress)
      make.height.equalTo(32)
      make.leading.equalToSuperview()
    }
  }
}

// MARK: - Orientation Transition Handling
extension QuizViewController {
  override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
    super.willTransition(to: newCollection, with: coordinator)
    
    let isPortrait = UIDevice.current.orientation.isPortrait
    //기기의 현재 방향을 알아낸다.
    
    lblTimer.snp.updateConstraints { make in //updateConstraints(_:)는 제약조건 상수를 업데이트 한다.
      make.height.equalTo(isPortrait ? 45 : 65)
      //세로 방향인 경우 lblTimer의 높이를 45로 업데이트 하고, 그렇지 않으면 65로 설정한다.
    }
    
    lblTimer.font = UIFont.systemFont(ofSize: isPortrait ? 20 : 32, weight: .light)
    //방향에 따라 글꼴 크기를 결정한다.
  }
}
