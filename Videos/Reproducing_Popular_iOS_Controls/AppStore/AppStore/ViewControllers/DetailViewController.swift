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

class DetailViewController: UIViewController {
  
  private let snapshotView = UIImageView() //스냅샷 이미지 뷰
  
  private let scrollView = UIScrollView()
  private let closeButton = UIButton(type: UIButton.ButtonType.custom)
  private let cardViewModel: CardViewModel
  private(set) var cardView: CardView?
  private let textLabel = UILabel()
    
  var viewsAreHidden: Bool = false { //Computed property로 여러 뷰들의 hidden 상태를 관리할 수 있다.
    didSet {
      closeButton.isHidden = viewsAreHidden
      cardView?.isHidden = viewsAreHidden
      textLabel.isHidden = viewsAreHidden
      
      view.backgroundColor = viewsAreHidden ? .clear : .white
    }
  }
  
  init(cardViewModel: CardViewModel) {
    self.cardViewModel = cardViewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override var prefersStatusBarHidden: Bool {
    return true
  }
  
  override func viewDidLoad() {
    setNeedsStatusBarAppearanceUpdate()
    setUpViews()
    
    createSnapshotOfView()
  }
  
  private func setUpViews() {
    view.backgroundColor = .white
    view.addSubview(scrollView)
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    
    let leftScroll =  NSLayoutConstraint(item: scrollView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 0)
    let rightScroll =  NSLayoutConstraint(item: scrollView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1.0, constant: 0)
    let topScroll =  NSLayoutConstraint(item: scrollView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0)
    let bottomScroll =  NSLayoutConstraint(item: scrollView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: 0)
    
    view.addConstraints([leftScroll, rightScroll, topScroll, bottomScroll])
    
    let appView = AppView(cardViewModel.app)
    let cardModel = cardViewModel
    cardViewModel.viewMode = .full
    cardView = CardView(cardModel: cardModel, appView: appView)
    scrollView.addSubview(cardView!)
    
    cardView!.pinToSuperview(forAtrributes: [.centerX, .top], multiplier: 1.0, constant: 0.0)
    cardView!.pin(attribute: .height, toView: nil, toAttribute: .notAnAttribute, multiplier: 1.0, constant: 450)
    cardView!.pin(attribute: .width, toView: nil, toAttribute: .notAnAttribute, multiplier: 1.0, constant: UIScreen.main.bounds.size.width)
    
    view.addSubview(closeButton)
    closeButton.pin(toView: cardView!, attributes: [.trailing], multiplier: 1.0, constant: -20)
    closeButton.pin(toView: cardView!, attributes: [.top], multiplier: 1.0, constant: 20)
    closeButton.pin(attribute: .width, toView: nil, toAttribute: .notAnAttribute, multiplier: 1.0, constant: 30)
    closeButton.pin(attribute: .height, toView: nil, toAttribute: .notAnAttribute, multiplier: 1.0, constant: 30)
    
    closeButton.setImage(UIImage(named: "close-darkOnLight")!, for: UIControl.State.normal)
    closeButton.addTarget(self, action: #selector(close), for: UIControl.Event.touchUpInside)
    
    let firstString = "Lorem Ipsum is simply "
    let firstAttributes: [NSAttributedString.Key: Any] = [
      NSAttributedString.Key.font : UIFont.systemFont(ofSize: 20, weight: .medium),
      NSAttributedString.Key.foregroundColor: UIColor.black
    ]
    let firstAttributedString = NSMutableAttributedString(string: firstString, attributes: firstAttributes)
    
    let secondString = "dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.\n\nIt has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.\n\nContrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC, making it over 2000 years old. Richard McClintock, a Latin professor at Hampden-Sydney College in Virginia, looked up one of the more obscure Latin words, consectetur, from a Lorem Ipsum passage, and going through the cites of the word in classical literature, discovered the undoubtable source. \n\nLorem Ipsum comes from sections 1.10.32 and 1.10.33 of 'de Finibus Bonorum et Malorum' (The Extremes of Good and Evil) by Cicero, written in 45 BC. This book is a treatise on the theory of ethics, very popular during the Renaissance. The first line of Lorem Ipsum, 'Lorem ipsum dolor sit amet..', comes from a line in section 1.10.32. The standard chunk of Lorem Ipsum used since the 1500s is reproduced below for those interested. Sections 1.10.32 and 1.10.33 from 'de Finibus Bonorum et Malorum' by Cicero are also reproduced in their exact original form, accompanied by English versions from the 1914 translation by H. Rackham. Where can I get some? There are many variations of passages of Lorem Ipsum available, but the majority have suffered alteration in some form, by injected humour, or randomised words which don't look even slightly believable. If you are going to use a passage of Lorem Ipsum, you need to be sure there isn't anything embarrassing hidden in the middle of text. All the Lorem Ipsum generators on the Internet tend to repeat predefined chunks as necessary, making this the first true generator on the Internet. It uses a dictionary of over 200 Latin words, combined with a handful of model sentence structures, to generate Lorem Ipsum which looks reasonable. The generated Lorem Ipsum is therefore always free from repetition, injected humour, or non-characteristic words etc."
    
    let secondAttributes: [NSAttributedString.Key: Any] = [
      NSAttributedString.Key.font : UIFont.systemFont(ofSize: 20, weight: .regular),
      NSAttributedString.Key.foregroundColor: UIColor.gray
    ]
    let secondAttributedString = NSMutableAttributedString(string: secondString, attributes: secondAttributes)
    
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineSpacing = 1.2
    
    let attributedString = NSMutableAttributedString(attributedString: firstAttributedString)
    attributedString.append(secondAttributedString)
    attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attributedString.length))
    
    textLabel.attributedText = attributedString
    textLabel.textAlignment = .left
    textLabel.numberOfLines = 0
    
    scrollView.addSubview(textLabel)
    textLabel.translatesAutoresizingMaskIntoConstraints = false
    let centerX =  NSLayoutConstraint(item: textLabel, attribute: .centerX, relatedBy: .equal, toItem: scrollView, attribute: .centerX, multiplier: 1.0, constant: 0.0)
    let width =  NSLayoutConstraint(item: textLabel, attribute: .width, relatedBy: .equal, toItem: scrollView, attribute: .width, multiplier: 1.0, constant: -40)
    let top =  NSLayoutConstraint(item: textLabel, attribute: .top, relatedBy: .equal, toItem: cardView, attribute: .bottom, multiplier: 1.0, constant: 40)
    
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    scrollView.addConstraints([centerX, width, top])
    scrollView.pin(toView: textLabel, attributes: [.bottom], multiplier: 1.0, constant: 0.0)
    
    scrollView.delegate = self
  }
  
  @objc func close() {
    dismiss(animated: true, completion: nil)
  }
    
  private func createSnapshotOfView() {
    snapshotView.clipsToBounds = true
    snapshotView.backgroundColor = .white
    snapshotView.isUserInteractionEnabled = true
    
    snapshotView.layer.shadowColor = UIColor.black.cgColor
    snapshotView.layer.shadowOpacity = 0.2
    snapshotView.layer.shadowRadius = 10
    snapshotView.layer.shadowOffset = CGSize(width: -1, height: 2)
    //shadow 설정
    
    let snapshotImage = view.createImage()
    snapshotView.image = snapshotImage
    
    scrollView.addSubview(snapshotView)
    snapshotView.frame = view.frame
    snapshotView.isHidden = true
    
    
  }
}

//MARK: UIScrollViewDelegate
extension DetailViewController: UIScrollViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let yPositionForDismissal: CGFloat = 20
    let yContentOffset = scrollView.contentOffset.y
    
    if yContentOffset < 0 && scrollView.isTracking { //위쪽 끝까지 스크롤 한 경우 dismiss
      viewsAreHidden = true //원본 뷰를 가리고
      snapshotView.isHidden = false //캡쳐한 이미지 뷰가 보이게 한다.
        
      let scale = (100 + yContentOffset) / 100
        
      snapshotView.transform = CGAffineTransform(scaleX: scale, y: scale) //축소
      //detailView 스크린을 캡쳐한 snapshotView를 축소
      snapshotView.layer.cornerRadius = -yContentOffset > yPositionForDismissal ? yPositionForDismissal : -yContentOffset
        
      if yPositionForDismissal + yContentOffset <= 0 {
        let contentOffset = CGPoint(x: 0, y: -yPositionForDismissal)
        scrollView.setContentOffset(contentOffset, animated: false)
        //너무 급히 애니메이션이 종료되는 것을 보정
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.close() //디테일 뷰를 닫는다.
        }
      }
    } else {
      viewsAreHidden = true
      snapshotView.isHidden = false
    }
  }
}


