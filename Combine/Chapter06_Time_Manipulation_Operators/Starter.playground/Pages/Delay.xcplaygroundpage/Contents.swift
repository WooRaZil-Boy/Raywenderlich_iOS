/*:
Copyright (c) 2019 Razeware LLC

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
distribute, sublicense, create a derivative work, and/or sell copies of the
Software in any work that is designed, intended, or marketed for pedagogical or
instructional purposes related to programming, coding, application development,
or information technology.  Permission for such use, copying, modification,
merger, publication, distribution, sublicensing, creation of derivative works,
or sale is expressly withheld.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

import Combine
import SwiftUI
import PlaygroundSupport

let valuesPerSecond = 1.0 //초당 내보내는 값의 수
let delayInSeconds = 1.5 //지연 시간

let sourcePublisher = PassthroughSubject<Date, Never>()
//Timer가 내보내는 날짜를 입력하는 간단한 Subject
//여기서 값의 type은 그다지 중요하지 않다. publisher가 값을 내보내는 경우와 delay될 때의 값에만 집중하면 된다.

let delayedPublisher = sourcePublisher.delay(for: .seconds(delayInSeconds), scheduler: DispatchQueue.main)
//sourcePublisher가 내보내는 값을 지연시켜 메인 스케줄러에서 내보낸다.
//scheduler에 관한 것은 17장에서 더 자세하게 배운다. 지금은 값이 메인 큐에서 작동해야 한다는 것을 기억하면 된다.

let subscription = Timer
    .publish(every: 1.0 / valuesPerSecond, on: .main, in: .common)
    //메인 스레드에 초당 1개의 값을 내보내는 타이머를 생성한다.
    .autoconnect() //즉시 시작
    .subscribe(sourcePublisher) //구독
    //sourcePublisher에서 내보낼 값을 가져온다.

let sourceTimeline = TimelineView(title: "Emitted values (\(valuesPerSecond) per sec.):")
//timer에서 내보내는 값을 표시할 TimelineView를 생성한다.
//TimelineView는 SwiftUI view로, Sources/Views.swift 에서 해당 코드를 확인할 수 있다.

let delayedTimeline = TimelineView(title: "Delayed values (with a \(delayInSeconds)s delay):")
//지연된 값을 표시할 TimelineView를 생성한다.

let view = VStack(spacing: 50) { //SwiftUI의 vertical stack을 생성한다.
    sourceTimeline
    delayedTimeline
}

PlaygroundPage.current.liveView = UIHostingController(rootView: view)
//playground page의 liveView를 설정한다.

sourcePublisher.displayEvents(in: sourceTimeline)
delayedPublisher.displayEvents(in: delayedTimeline)
//내보낸 값을 표시한다.

//: [Next](@next)
