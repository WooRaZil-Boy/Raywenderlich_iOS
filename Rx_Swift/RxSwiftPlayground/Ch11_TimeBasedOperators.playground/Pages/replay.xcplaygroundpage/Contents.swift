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
//버퍼로 과거 요소를 새로운 구독자에게 전달해 줄 수 있다.
//요소가 전달되는 방법과 시기를 제어할 수 있다.

//시퀀스가 항목을 내보낼 때 구독자가 과거의 메시지를 수신하는 지 확인해야 한다.

let elementsPerSecond = 1
let maxElements = 5
let replayedElements = 1
let replayDelay: TimeInterval = 3

//let sourceObservable = Observable<Int>.create { observer in
//    var value = 1
//    let timer = DispatchSource.timer(interval: 1.0 / Double(elementsPerSecond), queue: .main) {
//        //DispatchSource는 저 수준 시스템 객체를 모니터링하면서 비동기 처리
//        //extension으로 반복 타이머의 생성을 단순화 시켜 놓았다.
//        //elementsPerSecond의 빈도로 요소를 emit하는 observable 작성
//        if value <= maxElements { //value가 maxElements보다 작으면
//            observer.onNext(value) //.next 이벤트 발생
//            value = value + 1
//        }
//    }
//    //Observable이 completed 되는 것에 신경 쓰지 않는다
//    //단순지 원소를 emit하고 결코 completed 되지 않는다.
//
//    return Disposables.create {
//        timer.suspend()
//    } //장기적인 구독은 항상 DisposeBag에 보관해야 한다.
//    //여기서는 플레이그라운드가 새로고침 시 마다 삭제한다.
//}

let sourceObservable = Observable<Int>
    .interval(RxTimeInterval(1.0 / Double(elementsPerSecond)), scheduler: MainScheduler.instance)
    //Observable.interval(_ : scheduler :)로 지정된 스케줄러에서
    //선택된 간격으로 전송된 Int값에서 시퀀스를 생성한다.
    //Observable.interval(_ : scheduler :)는 Observable을 생성하기 때문에
    //내부에서 간단히 dispose() 시키고 타이머를 중지 시킬 수 있다.
    //Observable.interval(_ : scheduler :)로 생성된 값은 0부터 시작한다.
    //다른 값이 필요하면 map(_:)으로 매핑시켜 줘야 한다.
    //대부분은 타이머에서 방출된 값은 무시된므로 매핑할 필요는 없다.
    .replay(replayedElements)

//.replay(replayedElements) //replay연산자는 sourceObservable에서
//emit된 마지막 replayedElements를 기록하는 새 시퀀스를 생성한다.
//새로운 구독이 생성될 때마다, 버퍼된 요소(있을 경우)를 즉시 수신한 후,
//새로운 요소를 계속 받는다.

//.replayAll() //이전의 모든 요소를 가져온다.
//repalyAll 연산자는 주의해서 사용해야 한다. 전체 버퍼 요소가 합리적으로 유지될 때만 사용.
//ex. HTTP 요청 컨텍스트에서 replayAll ()을 사용하는 것은 적절하다.
//쿼리에서 반환하는 데이터를 유지하는 경우 메모리에 미치는 영향을 알 수 있다.
//하지만, 종료되지 않고 많은 데이터를 생성 하는 시퀀스에서 사용하면 빠르게 메모리가 누수된다.

let sourceTimeline = TimelineView<Int>.make()
let replayedTimeline = TimelineView<Int>.make()
//TimelineView는 시각화 위한 helper

let stack = UIStackView.makeVertical([
    UILabel.makeTitle("replay"),
    UILabel.make("Emit \(elementsPerSecond) per second:"),
    sourceTimeline,
    UILabel.make("Replay \(replayedElements) after \(replayDelay) sec:"),
    replayedTimeline
    ])
//시각화 위해 자체적으로 만들어 놓은 extension들을 stackView에 쌓는다.

_ = sourceObservable.subscribe(sourceTimeline) //구독

DispatchQueue.main.asyncAfter(deadline: .now() + replayDelay) {
    //replayDelay 시간 만큼 지연되서 구독
    _ = sourceObservable.subscribe(replayedTimeline)
    //이 구독은 3초 뒤부터(4부터) 시작 되게 된다.
    //하지만 replay(_:) 연산자를 사용했기 때문에 4부터 시작될 때
    //버퍼의 값(이전 값)인 3(여기선 버퍼 크기가 1)을 받고 4부터 시작한다.
}

_ = sourceObservable.connect() //replay는 connect 해 줘야 한다.
//replay(_:)가 connectable observable을 생성하기 때문에 항목을 받으려면
//기본 소스에 연결해야 한다. 이 작업을 하지 않으면 구독자는 아무 값도 받지 못한다.

//Connectable observable은 특수한 observable이다.
//구독에 상관없이 connect() 메서드를 호출 할 때까지 항목을 방출하지 않는다.
//replay(_:), replayAll(), multicast(_:), publish()
//위 4 연산자가 ConnectableObservable을 반환한다.

let hostView = setupHostView()
hostView.addSubview(stack)
hostView
//시각화 위한 코드
