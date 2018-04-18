/*
 * Copyright (c) 2014-2016 Razeware LLC
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
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import RxSwift
import Gifu

class GifTableViewCell: UITableViewCell {
    
  @IBOutlet weak var gifImageView: UIImageView!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  
  var disposable = SingleAssignmentDisposable()
    //SingleAssignmentDisposable : 단일 할당만 허용하는 일회용 리소스
    //하나의 셀에 하나의 구독만 가능하도록 보장해 리소스 낭비를 막아준다.
    
  override func prepareForReuse() {
    super.prepareForReuse()
    gifImageView.prepareForReuse()
    gifImageView.image = nil
    
    //만약 Gif를 다운로드 시작했을 때 사용자가 스크롤을 내리거나 뒤로 가기 버튼을 누른다면, 다운로드를 멈추도록 해야 한다.
    //따라서 재사용될 때 SingleAssignmentDisposable를 해제하고, 다시 생성해 준다.
    disposable.dispose()
    disposable = SingleAssignmentDisposable()
  }
  
  func downloadAndDisplay(gif stringUrl: String) {
    guard let url = URL(string: stringUrl) else { return }
    let request = URLRequest(url: url)
    activityIndicator.startAnimating()
    
    let s = URLSession.shared.rx.data(request: request) //extension에서 구현 했기에 .rx 사용가능
        .observeOn(MainScheduler.instance) //지정된 스케줄러(메인)에서 옵저버 콜백 실행 위한 시퀀스 래핑
        //스케줄러에서 옵저버 콜백만 호출. side-effect가 필요한 경우에는 subscribeOn을 사용한다.
        .subscribe(onNext: { imageData in
            self.gifImageView.animate(withGIFData: imageData)
            self.activityIndicator.stopAnimating()
        })
    disposable.setDisposable(s)
  }
}

extension UIImageView: GIFAnimatable {
  private struct AssociatedKeys {
    static var AnimatorKey = "gifu.animator.key"
  }
  
  override open func display(_ layer: CALayer) {
    updateImageIfNeeded()
  }
  
  public var animator: Animator? {
    get {
      guard let animator = objc_getAssociatedObject(self, &AssociatedKeys.AnimatorKey) as? Animator else {
        let animator = Animator(withDelegate: self)
        self.animator = animator
        return animator
      }
      
      return animator
    }
    
    set {
      objc_setAssociatedObject(self, &AssociatedKeys.AnimatorKey, newValue as Animator?, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }
}
