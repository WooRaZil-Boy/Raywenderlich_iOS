//: Please build the scheme 'RxSwiftPlayground' first
import UIKit
import RxSwift
import RxCocoa




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

let elementsPerSecond = 3
let windowTimeSpan: RxTimeInterval = 4
let windowMaxCount = 10
let sourceObservable = PublishSubject<String>()

let sourceTimeline = TimelineView<String>.make()

let stack = UIStackView.makeVertical([
    UILabel.makeTitle("window"),
    UILabel.make("Emitted elements (\(elementsPerSecond) per sec.):"),
    sourceTimeline,
    UILabel.make("Windowed observables (at most \(windowMaxCount) every \(windowTimeSpan) sec):")
    ])

let timer = DispatchSource.timer(interval: 1.0 / Double(elementsPerSecond), queue: .main) {
    sourceObservable.onNext("🐱")
}

_ = sourceObservable.subscribe(sourceTimeline) //구독

_ = sourceObservable
    .window(timeSpan: windowTimeSpan, count: windowMaxCount, scheduler: MainScheduler.instance)
    //window(timeSpan:count:scheduler:)는
    //buffer(timeSpan:count:scheduler:)와 비슷하다.
    //차이점은 window(timeSpan:count:scheduler:)는 Observable를 emit하고
    //buffer(timeSpan:count:scheduler:)는 배열을 emit한다.
    .flatMap { windowedObservable -> Observable<(TimelineView<Int>, String?)> in //새로운 Observable을 가져올 때 마다 새 타임 라인 뷰 삽입
        let timeline = TimelineView<Int>.make()
        stack.insert(timeline, at: 4)
        stack.keep(atMost: 8)
        
        return windowedObservable
            .map { value in (timeline, value) } //튜플로 매핑
            .concat(Observable.just((timeline, nil))) //합치기
    }
    .subscribe(onNext: { tuple in //구독
        let (timeline, value) = tuple
        if let value = value {
            timeline.add(.Next(value))
        } else { //nil이면 시퀀스가 완료 된 것.
            timeline.add(.Completed(true))
        }
    })

let hostView = setupHostView()
hostView.addSubview(stack)
hostView
