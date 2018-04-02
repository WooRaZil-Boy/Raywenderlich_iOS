//: Please build the scheme 'RxSwiftPlayground' first
import UIKit
import RxSwift
import RxCocoa

let elementsPerSecond = 1
let delayInSeconds = 1.5

let sourceObservable = PublishSubject<Int>()

let sourceTimeline = TimelineView<Int>.make()
let delayedTimeline = TimelineView<Int>.make()

let stack = UIStackView.makeVertical([
  UILabel.makeTitle("delay"),
  UILabel.make("Emitted elements (\(elementsPerSecond) per sec.):"),
  sourceTimeline,
  UILabel.make("Delayed elements (with a \(delayInSeconds)s delay):"),
  delayedTimeline])

var current = 1
let timer = DispatchSource.timer(interval: 1.0 / Double(elementsPerSecond), queue: .main) {
  sourceObservable.onNext(current)
  current = current + 1
}

_ = sourceObservable.subscribe(sourceTimeline)


// Setup the delayed subscription
// ADD CODE HERE

//_ = sourceObservable
//    .delaySubscription(RxTimeInterval(delayInSeconds), scheduler: MainScheduler.instance) //지연된 구독
//    //구독의 요소를 받기 시작하는 시간을 지연 시킨다.
//    //구독 이전의 요소는 누락된다.
//    .subscribe(delayedTimeline) //구독

//Rx에는 "Hot"과 "Cold" Observable이 있다.
//"Hot"은 구독과 관계없이 이벤트를 emit하고, "Cold"는 구독할 때만 이벤트를 emit한다.

//_ = sourceObservable
//    .delay(RxTimeInterval(delayInSeconds), scheduler: MainScheduler.instance)
//    .subscribe(delayedTimeline) //구독
//전체 시퀀스를 지연 시킬 수도 있다. 지정된 시간 만큼 emit된 모든 요소를 지연시킨다.
//.delaySubscription와 달리 구독 이전의 요소도 누락시키지 않는다. //순수한 지연

_ = Observable<Int>
    .timer(3, scheduler: MainScheduler.instance) //다른 타이머를 트리거
    //Observable.timer(_ : period : scheduler :)은
    //Observable.interval (_ : scheduler :)과 유사하지만 추가 기능이 있다.
    //•구독 시점과 첫 번째 값 사이의 경과 시간으로 만기일을 지정할 수 있다.
    //•반복 시간을 선택해 줄 수 있다(optional). 지정하지 않으면 한 번만
    .flatMap { _ in
        sourceObservable.delay(RxTimeInterval(delayInSeconds), scheduler: MainScheduler.instance)
    }
    .subscribe(delayedTimeline)
//이렇게 구현하면, 전체 체인의 가독성을 높이고
//구독은 disposable을 반환하기 때문에 언제든지 취소할 수 있게 된다.
//flatMap(_:) 연산자로 비동기 클로저로 타이머 시퀀스를 생성할 수 있다.

let hostView = setupHostView()
hostView.addSubview(stack)
hostView

// Support code -- DO NOT REMOVE
class TimelineView<E>: TimelineViewBase, ObserverType where E: CustomStringConvertible {
  static func make() -> TimelineView<E> {
    let view = TimelineView(frame: CGRect(x: 0, y: 0, width: 400, height: 100))
    view.setup()
    return view
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

