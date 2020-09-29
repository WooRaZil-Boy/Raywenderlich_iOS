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

let subject = PassthroughSubject<String, Never>()

let measureSubject = subject.measureInterval(using: DispatchQueue.main)
//지정한 스케쥴러에서 측정 값을 내보낸다. 여기서는 메인 큐를 사용한다.
let measureSubject2 = subject.measureInterval(using: RunLoop.main)
//RunLoop 스케쥴러를 사용한다.

let subjectTimeline = TimelineView(title: "Emitted values")
let measureTimeline = TimelineView(title: "Measured values")

let view = VStack(spacing: 100) {
    subjectTimeline
    measureTimeline
}

PlaygroundPage.current.liveView = UIHostingController(rootView: view)
//playground page의 liveView를 설정한다.

subject.displayEvents(in: subjectTimeline)
measureSubject.displayEvents(in: measureTimeline)
//내보낸 값을 표시한다.

let subscription1 = subject.sink { //DispatchQueue 스케쥴러 구독
    print("+\(deltaTime)s: Subject emitted: \($0)")
}

let subscription2 = measureSubject.sink { //DispatchQueue 스케쥴러 구독
//    print("+\(deltaTime)s: Measure emitted: \($0)")
    print("+\(deltaTime)s: Measure emitted: \(Double($0.magnitude) / 1_000_000_000.0)")
    //좀 더 읽기 쉽도록 출력을 변경한다.
}

let subscription3 = measureSubject2.sink { //RunLoop 스케쥴러 구독
    print("+\(deltaTime)s: Measure2 emitted: \($0)")
}

subject.feed(with: typingHelloWorld)
//데이터 세트를 가져와 사전에 정의된 간격으로 subject에 데이터를 내보낸다.

