//: Please build the scheme 'RxSwiftPlayground' first
import UIKit
import RxSwift
import RxCocoa





// Support code -- DO NOT REMOVE
class TimelineView<E>: TimelineViewBase, ObserverType where E: CustomStringConvertible {
  static func make() -> TimelineView<E> {
    return TimelineView(width: 400, height: 100)
  }
  public func on(_ event: Event<E>) {
    switch event {
    case .next(let value):
      add(.Next(String(describing: value)))
    case .completed:
      add(.Completed())
    case .error(_):
      add(.Error())
    }
  }
}
/*:
 Copyright (c) 2014-2017 Razeware LLC
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

let button = UIButton(type: .system)
button.setTitle("Press me now!", for: .normal)
button.sizeToFit()

let tapsTimeLine = TimelineView<String>.make()

let stack = UIStackView.makeVertical([
    button,
    UILabel.make("Taps on button above"),
    tapsTimeLine
    ])

let _ = button
    .rx.tap //TouchUpInside 래핑
    .map { _ in "•" }
    //.timeout(5, scheduler: MainScheduler.instance)
    //실제 타이머를 시간 초과를 판단하는 데 주로 쓰인다.
    //5초 안에 버튼을 눌러야만 유효. 5초가 지나면 오류 표시가 뜬다.
    .timeout(5, other: Observable.just("X"), scheduler: MainScheduler.instance)
    //유효 시간이 지나면 해당 이벤트(Observable.just("X"))가 emit
    .subscribe(tapsTimeLine) //구독

let hostView = setupHostView()
hostView.addSubview(stack)
hostView

