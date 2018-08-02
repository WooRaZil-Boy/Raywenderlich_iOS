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

enum TransitionType {
  case presentation
  case dismissal
  
  var blurAlpha: CGFloat { return self == .presentation ? 1 : 0 }
  var dimAlpha: CGFloat { return self == .presentation ? 0.1 : 0 }
  var cardMode: CardViewMode { return self == .presentation ? .card : .full }
  var cornerRadius: CGFloat { return self == .presentation ? 20 : 0 }
  var next: TransitionType { return self == .presentation ? .dismissal : .presentation }
  //관련 값들을 enum에서 활용하는 것이 좋다. property로 일일이 설정하면 복잡해지고 누락되기 쉽다.
}

class TransitionManager: NSObject, UIViewControllerAnimatedTransitioning {
  
  //MARK: Helpers
  let transitionDuration: Double = 0.8
  let shrinkDuration: Double = 0.2
  var transition: TransitionType = .presentation
  
  private let blurEffectView: UIVisualEffectView = {
    let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
    return UIVisualEffectView(effect: blurEffect)
  }()
  
  private let dimmingView: UIView = {
    let view = UIView()
    view.backgroundColor = .black
    return view
  }()
  
  private let whiteScrollView: UIView = { //카드를 선택 했을 때 애니메이션 후 잠시 나타나는 스크롤
    let view = UIView()
    view.backgroundColor = .white
    return view
  }()
  
  private func addBackgroundViews(containerView: UIView) {
    blurEffectView.frame = containerView.frame
    blurEffectView.alpha = transition.next.blurAlpha
    containerView.addSubview(blurEffectView)
    //블러 뷰 추가
    
    dimmingView.frame = containerView.frame
    dimmingView.alpha = transition.next.dimAlpha
    containerView.addSubview(dimmingView)
    //어두운 뷰 추가
  }
  
  private func createCardViewCopy(cardView: CardView) -> CardView {
    let cardModel = cardView.cardModel
    cardModel.viewMode = transition.cardMode
    let newAppView: AppView? = AppView(cardView.appView?.viewModel)
    let cardViewCopy = CardView(cardModel: cardModel, appView: newAppView)
    return cardViewCopy
  }
  
  //MARK: UIViewControllerAnimatedTransitioning protocol methods
  //UIViewControllerAnimatedTransitioning protocol을 구현하려면
  //transitionDuration(using:), animateTransition(using:) 이 두 메서드를 기본적으로 구현해야 한다.
  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return transitionDuration //뷰 컨트롤러 전환 지속 시간
  }
  
  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    //뷰 컨트롤러 전환 애니메이션 지정
    
    //이 더미 코드는 단순히 Modal 뷰 컨트롤러의 뷰를 add하는 것 뿐이다.
//    if let toVC = transitionContext.viewController(forKey: .to) as? DetailViewController {
//      transitionContext.containerView.addSubview(toVC.view)
//      transitionContext.completeTransition(true)
//    } else {
//      transitionContext.completeTransition(true)
//    }
    
    // Remove all views from container to start fresh and add the background views
    let containerView = transitionContext.containerView
    containerView.subviews.forEach{ $0.removeFromSuperview() } //컨터이너 뷰의 모든 서브뷰 삭제. 초기화
    addBackgroundViews(containerView: containerView) //blurEffectView와 dimmingView를 추가해 준다.
    
    let fromVC = transitionContext.viewController(forKey: .from)
    let toVC = transitionContext.viewController(forKey: .to)
    
    guard let cardView = transition == .presentation ? (fromVC as! TodayViewController).selectedCellCardView() : (toVC as! TodayViewController).selectedCellCardView() else { return }
    //transition 타입에 맞는 선택한 카드를 가져온다.
    
    // Hide the original cardView so that you can seamlessly scale the cardViewCopy to be smaller and add the copy
    cardView.isHidden = true //원본의 카드 뷰를 감춘다.
    let cardViewCopy = createCardViewCopy(cardView: cardView) //카드 뷰를 카피
    containerView.addSubview(cardViewCopy)
    //앱 스토어에서 해당 카드를 선택하면, 여러 애니메이션이 일어나면서 다음 뷰 컨트롤러로 전환된다.
    //이 때, 이전 뷰 컨트롤러의 카드(이미지)를 복사해와서 원본을 감추고, 복제본에 애니메이션을 줘서
    //확대 등의 여러 애니메이션이 일어나는 것처럼 보이게 만든다.
    
    // Get the absolute rect for your cardViewCopy to set the frame
    let absoluteCardViewFrame = cardView.convert(cardView.frame, to: nil)
    //하위 뷰 위 특정 위치를 상위 UIView에서 좌표 얻어 온다.
    //파라미터로 전달하는 view에 대한 절대 좌표 및 rect 값을 반환해 준다.
    cardViewCopy.frame = absoluteCardViewFrame
    
    // Configure and insert whiteStrip view to animate with the cardView
    whiteScrollView.frame = transition == .presentation ? cardView.containerView.frame : containerView.frame
    //전환 애니메이션에 따라 뷰의 초기 크기가 달라진다.
    whiteScrollView.layer.cornerRadius = transition.cornerRadius
    cardViewCopy.insertSubview(whiteScrollView, aboveSubview: cardViewCopy.shadowView)
    
    
    if transition == .presentation { //presentation 애니메이션
      let toVC = toVC as! DetailViewController
      containerView.addSubview(toVC.view) //Modal 형식으로 view를 추가해 준다.
      toVC.viewsAreHidden = true //뷰 들을 감춘다.
      
      moveAndConvertCardView(cardView: cardViewCopy, containerView: containerView, yOriginToMoveTo: 0) { //애니메이션이 완료되면 completion에서 밑의 코드가 실행된다.
        cardView.isHidden = false
        toVC.viewsAreHidden = false
        cardViewCopy.removeFromSuperview()
        transitionContext.completeTransition(true)
        //전환 애니메이션이 완료되었음을 시스템에 알린다.
      }
      
    } else { //dismiss 애니메이션
      
      let fromVC = fromVC as! DetailViewController
      cardViewCopy.frame = fromVC.cardView!.frame
      fromVC.viewsAreHidden = true
      
      moveAndConvertCardView(cardView: cardViewCopy, containerView: containerView, yOriginToMoveTo: absoluteCardViewFrame.origin.y) {
        
        cardView.isHidden = false
        transitionContext.completeTransition(true)
        //전환 애니메이션이 완료되었음을 시스템에 알린다.
      }
    }
  }
  
  private func makeShrinkAnimator(for cardView: CardView) -> UIViewPropertyAnimator {
    //shrink animation
    return UIViewPropertyAnimator(duration: shrinkDuration, curve: .easeOut, animations: {
      //뷰에 애니메이션 효과를 적용하고 해당 애니메이션을 동적으로 수정할 수 있게 하는 클래스
      
      cardView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95) //크기 축소
      self.dimmingView.alpha = 0.05
    })
  }
  
  private func makeExpandContractAnimator(for cardView: CardView, containerView: UIView, yOrigin: CGFloat) -> UIViewPropertyAnimator { //expand animation
    //shrink animation은 presentation에만 적용, Expand는 애니메이션에 따라 뷰 크기와 위치가 달라진다.
    
    let springTiming = UISpringTimingParameters(dampingRatio: 0.75, initialVelocity: CGVector(dx: 0, dy: 4))
    let animator = UIViewPropertyAnimator(duration: transitionDuration - shrinkDuration, timingParameters: springTiming)
    
    animator.addAnimations { //애니메이션이 완료 후 이 상태가 된다.
      cardView.transform = CGAffineTransform.identity
      cardView.containerView.layer.cornerRadius = self.transition.next.cornerRadius
      cardView.frame.origin.y = yOrigin
      
      self.blurEffectView.alpha = self.transition.blurAlpha
      self.dimmingView.alpha = self.transition.dimAlpha
      
      self.whiteScrollView.layer.cornerRadius = cardView.containerView.layer.cornerRadius
      
      containerView.layoutIfNeeded()
      
      self.whiteScrollView.frame = self.transition == .presentation ? containerView.frame : cardView.containerView.frame
    }
    
    return animator
  }
  
  //MARK: Animation methods
  private func moveAndConvertCardView(cardView: CardView, containerView: UIView, yOriginToMoveTo: CGFloat, completion: @escaping () ->()) {

    let shrinkAnimator = makeShrinkAnimator(for: cardView)
    let expandAnimator = makeExpandContractAnimator(for: cardView, containerView: containerView, yOrigin: yOriginToMoveTo)
    
    expandAnimator.addCompletion { (_) in //completion 클로저를 추가해 준다.
      completion() //애니메이션 종료
      //Shrink 후 expand 해 주므로 최종 completion 클로저는 expandAnimator에서 실행된다.
    }
    
    if self.transition == .presentation { //presentation 때에만 shrink Animation이 있다.
      shrinkAnimator.addCompletion { (_) in //completion 클로저를 추가해 준다.
        cardView.layoutIfNeeded() //초기화 해준다.
        cardView.updateLayout(for: self.transition.next.cardMode) //presentation 이므로 full
        
        expandAnimator.startAnimation() //애니메이션 시작
      }
      
      shrinkAnimator.startAnimation() //Shrink이 먼저 실행된다.
    } else {
      cardView.layoutIfNeeded()
      cardView.updateLayout(for: self.transition.next.cardMode) //dismiss 이므로 card
      expandAnimator.startAnimation() //애니메이션 시작
    }
  }
}

//MARK: UIViewControllerTransitioningDelegate
extension TransitionManager: UIViewControllerTransitioningDelegate {
  func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    //UIViewController가 present 될때 호출된다.
    transition = .presentation //transition 타입을 설정해 준다.
    return self
  }
  
  func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    //UIViewController가 dismiss 될때 호출된다.
    transition = .dismissal //transition 타입을 설정해 준다.
    return self
  }
}

//let detailViewController = DetailViewController(cardViewModel: CardViewModel)
//present(detailViewController, animated: true, completion: nil)
//일반적으로 이런 식으로 뷰 전환을 자주 사용하지만,

//let detailViewController = DetailViewController(cardViewModel: CardViewModel)
//detailViewController.modalTransitionStyle = .crossDissolve
//detailViewController.modalPresentationStyle = .overFullScreen
//present(detailViewController, animated: true, completion: nil)
//추가적인 애니메이션 포함한 클래스를 작성해 간단하면서 고급적인 뷰 전환을 만들 수 있다.
//이런 추가적인 작업에는 UIViewControllerAnimatedTransitioning과 delegate가 필요하다.

//다른 앱의 애니메이션을 참고할 때 너무 빨라서 잘 알아내기 힘들다면, 녹화한 후 프레임단위로 재생하며 살펴본다.
//앱 스토어 앱은 카드 선택 시, 배경이 어두워지면서 블러되고, 카드가 확대되면서 이미지가 꽉차고 텍스트가 나타난다.
//각 카드는 하나의 뷰가 아닌 content, shadow, container로 이루어져 있고(view hierachy에서 확인),
//카드의 모드는 enum으로 .card, .full로 나누어져 있다. 모드가 변경되면 constraint, corner radius가 변경된다.




//뷰 전환 애니메이션을 담당하는 UIViewControllerAnimatedTransitioning를 따라 클래스로 관리한다.





