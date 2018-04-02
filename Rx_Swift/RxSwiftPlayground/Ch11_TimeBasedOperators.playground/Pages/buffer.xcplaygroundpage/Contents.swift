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
//********** Chapter 11: Time Based Operators **********

//Rx의 핵심은 시간의 흐름에 따라 비동기 데이터를 모델링하는 것이다.
//시퀀스를 시간 차원에서 관리하는 것이 중요하다.

let bufferTimeSpan: RxTimeInterval = 4 //TimeInterval
let bufferMaxCount = 2

let sourceObservable = PublishSubject<String>()

let sourceTimeline = TimelineView<String>.make()
let bufferedTimeline = TimelineView<Int>.make()

let stack = UIStackView.makeVertical([
    UILabel.makeTitle("buffer"),
    UILabel.make("Emitted elements:"),
    sourceTimeline,
    UILabel.make("Buffered elements (at most \(bufferMaxCount) every \(bufferTimeSpan) seconds):"),
    bufferedTimeline
    ])

_ = sourceObservable.subscribe(sourceTimeline) //구독

sourceObservable
    .buffer(timeSpan: bufferTimeSpan, count: bufferMaxCount, scheduler: MainScheduler.instance)
    //스케줄러로 Observable의 각 요소를 버퍼가 찼거나 주어진 시간이 경과할 때 버퍼에 투영
    //bufferTimeSpan이 되기 전에 요소 수가 넘어가면, 버퍼를 emit하고 타이머 재설정
    //bufferTimeSpan을 넘어서면, 버퍼를 emit
    //timeSpan : 버퍼 최대 시간
    //count : 버퍼의 최대 요소 수
    //scheduler : 스케줄러(타이머)
    .map { $0.count } //emit된 요소의 수
    .subscribe(bufferedTimeline) //구독

let hostView = setupHostView()
hostView.addSubview(stack)
hostView

//buffer(_:scheduler:) 연산자는 Observable에서 아무 것도 수신하지 않은 경우
//일정한 간격으로 빈 배열을 emit한다(0).

//DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
//    sourceObservable.onNext("🐱")
//    sourceObservable.onNext("🐱")
//    sourceObservable.onNext("🐱")
//}
//0을 출력하다가(수신한 것이 없기 때문에) 5초 뒤에 위의 3요소를 수신해 .next를 emit한다.
//여기서는 bufferTimeSpan은 4, bufferMaxCount가 2 이기 때문에 3개의 요소를 수신하면
//버퍼가 꽉차 바로 2개를 emit하고, 나머지 1개는 버퍼에 있다가 4초 뒤에 emit 되게 된다.
//버퍼는 용량이 꽉 차면 즉시 요소 배열을 내보내고, 다음 지정된 배열을 기다린다.

let elementsPerSecond = 0.7
let timer = DispatchSource.timer(interval: 1.0 / Double(elementsPerSecond), queue: .main) {
    sourceObservable.onNext("🐱")
}
//여기서는 0.7초마다 요소가 계속 들어오므로, 버퍼가 채워질 때마다 emit 된다.

