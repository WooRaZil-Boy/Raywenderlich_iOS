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

private extension CGFloat {
  // Spring animation
  static let springDampingRatio: CGFloat = 0.7
  static let springInitialVelocityY: CGFloat =  10
}

private extension Double {
  // Spring animation
  static let animationDuration: Double = 0.8
}

enum DragDirection { //방향
  case up
  case down
}

enum DraggablePosition { //상태
  case collapsed
  case open
    
    var heightmultiplier: CGFloat {
        switch self {
        case .collapsed: return 0.2
        case .open: return 1
        }
    }
    
    var downBoundary: CGFloat { //down 액션의 경계선
        switch self {
        case .collapsed: return 0.0
        case .open: return 0.8
        }
    }
    
    var upBoundary: CGFloat { //up 액션의 경계선
        switch self {
        case .collapsed: return 0.0
        case .open: return 0.65
        }
    }
    
    var dimAlpha: CGFloat {
        switch self {
        case .collapsed: return 0.0
        case .open: return 0.45
        }
    }
    
    func yOrigin(for maxHeight: CGFloat) -> CGFloat {
        return maxHeight - (maxHeight * heightmultiplier)
    }
    
    func nextPosition(for direction: DragDirection) -> DraggablePosition {
        switch (self, direction) {
        case (.collapsed, .up): return .open
        case (.collapsed, .down): return .collapsed
        case (.open, .up): return .open
        case (.open, .down): return .collapsed
            //collapsed 상태의 바를 드래그 업하면, open 상태가 된다.
        }
    }
}

final class DraggablePresentationController: UIPresentationController {
  
  // MARK: Private
  private var dimmingView = UIView()
  private var draggablePosition: DraggablePosition = .collapsed
  
  private let springTiming = UISpringTimingParameters(dampingRatio: .springDampingRatio, initialVelocity: CGVector(dx: 0, dy: .springInitialVelocityY))
  private var animator: UIViewPropertyAnimator?
  
  private var dragDirection: DragDirection = .up
  private let maxFrame = CGRect(x: 0, y: 0, width: UIWindow.root.bounds.width, height: UIWindow.root.bounds.height + UIWindow.key.safeAreaInsets.bottom)
  private var panOnPresented = UIGestureRecognizer()
  
  override var frameOfPresentedViewInContainerView: CGRect {
    let presentedOrigin = CGPoint(x: 0, y: draggablePosition.yOrigin(for: maxFrame.height))
    let presentedSize = CGSize(width: maxFrame.width, height: maxFrame.height + 40)
    let presentedFrame = CGRect(origin: presentedOrigin, size: presentedSize)
    
    return presentedFrame
  }
  
  override func presentationTransitionWillBegin() {
    //프레젠테이션 애니메이션이 시작될 것임을 프레젠테이션 컨트롤러에 알린다.
    //Default는 빈 메서드로 아무 것도 실행하지 않는다.
    guard let containerView = containerView else { return }
    
    containerView.insertSubview(dimmingView, at: 1) //dimmingView 추가
    dimmingView.alpha = 0
    dimmingView.backgroundColor = .black
    dimmingView.frame = containerView.frame
  }
  
  override func presentationTransitionDidEnd(_ completed: Bool) {
    //프레젠테이션 애니메이션이 끝났음을 프레젠테이션 컨트롤러에 알린다.
    //Default는 빈 메서드로 아무 것도 실행하지 않는다.
    animator = UIViewPropertyAnimator(duration: .animationDuration, timingParameters: self.springTiming)
    animator?.isInterruptible = true
    panOnPresented = UIPanGestureRecognizer(target: self, action: #selector(userDidPan(panRecognizer:))) //제스처 추가
    presentedView?.addGestureRecognizer(panOnPresented)
  }
  
  override func containerViewWillLayoutSubviews() {
    //프레젠테이션 컨트롤러에 컨테이너 View의 레이아웃이 조정되기 전에 이 메서드를 호출한다.
    //이 메서드와 containerViewDidLayoutSubviews()를 사용해 프레젠테이션 컨트롤러에서
    //관리하는 프레젠테이션 컨트롤러를 업데이트 한다.
    presentedView?.frame = frameOfPresentedViewInContainerView //프레임 반환
  }
  
  @objc private func userDidPan(panRecognizer: UIPanGestureRecognizer) {
    let translationPoint = panRecognizer.translation(in: presentedView)
    //presentedView의 pan Recognizer의 포인트를 가져온다.
    let currentOriginY = draggablePosition.yOrigin(for: maxFrame.height)
    let newOffset = currentOriginY + translationPoint.y
    
    //???
    //터치는 항상 0, 0에서 시작한다. 유저가 탭을 하고 움직이면, 그 포인트에 맞춰 업데이트 된다.
    
    dragDirection = newOffset > currentOriginY ? .down : .up
    //offset의 좌표가 현재 보다 낮으면 down. 높으면 up
    
    let nextOriginY = draggablePosition.nextPosition(for: dragDirection).yOrigin(for: maxFrame.height)
    //다음 이동하는 위치의 origin y를 가져온다.
    
    let canDragInProposedDirection = dragDirection == .up && draggablePosition == .open ? false : true
    if newOffset >= 0 && canDragInProposedDirection { //open되는 작업이라면
        switch panRecognizer.state {
        case .changed, .began: //제스처가 진행 중이면, 위치를 업데이트 한다.
            presentedView?.frame.origin.y = newOffset
        case .ended: //제스처가 끝났다면, 애니메이션을 적용한다.
            animate(newOffset)
        default: break
        }
      }
    
    }
  
  private func animate(_ dragOffset: CGFloat) {
    let distanceFromBottom = maxFrame.height - dragOffset
    
    switch dragDirection {
    case .up:
        if (distanceFromBottom > maxFrame.height * DraggablePosition.open.upBoundary) {
            //up 액션의 경계선을 지났다면
            animate(to: .open)
        } else {
            animate(to: .collapsed)
        }
    case .down:
        if (distanceFromBottom > maxFrame.height * DraggablePosition.open.downBoundary) {
            //down 액션의 경계선을 지났다면
            animate(to: .open)
        } else {
            animate(to: .collapsed)
        }
      }
    }
  private func animate(to position: DraggablePosition) {
    guard let animator = animator else { return }
    
    animator.addAnimations { //애니메이션 추가
        self.presentedView?.frame.origin.y = position.yOrigin(for: self.maxFrame.height)
        self.dimmingView.alpha = position.dimAlpha
    }
    
    animator.addCompletion { (animatingPosition) in //완료 클로저
        if animatingPosition == .end {
            self.draggablePosition = position
        }
    }
    
    animator.startAnimation()
    }
}

// MARK: Public
extension DraggablePresentationController {
  func animateToOpen() {
    animate(to: .open)
  }
}

//View Controller Presentation
//Instantiate a UIPresentationController
//Attach the presented view controller
//Present with built-in modal presentation styles

//Presentation Breakdown
//가장 축소 됐을 때는 20%, 한번 drag-up 하면 50%, 다시 drag-up하면 90%의 영역을 차지하게 된다.

