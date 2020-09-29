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

let throttleDelay = 1.0 //지연 시간

let subject = PassthroughSubject<String, Never>()
//문자열을 내보내는 source publisher를 생성한다.

let throttled = subject
//    .throttle(for: .seconds(throttleDelay), scheduler: DispatchQueue.main, latest: false)
    //latest를 false로 설정했기 때문에 1초(throttleDelay) 간격으로, 수신된 첫 번째 값만 방출한다.
    .throttle(for: .seconds(throttleDelay), scheduler: DispatchQueue.main, latest: true)
    .share()
    //debounce와 마찬가지로, share()를 사용하면 모든 subscribers가 동일한 출력을 동시에 확인할 수 있다.

let subjectTimeline = TimelineView(title: "Emitted values")
let throttledTimeline = TimelineView(title: "Throttled values")
//timer에서 내보내는 값을 표시할 TimelineView를 생성한다.
//TimelineView는 SwiftUI view로, Sources/Views.swift 에서 해당 코드를 확인할 수 있다.

let view = VStack(spacing: 100) { //SwiftUI의 vertical stack을 생성한다.
    subjectTimeline
    throttledTimeline
}

PlaygroundPage.current.liveView = UIHostingController(rootView: view)
//playground page의 liveView를 설정한다.

subject.displayEvents(in: subjectTimeline)
throttled.displayEvents(in: throttledTimeline)
//내보낸 값을 표시한다.

let subscription1 = subject
    .sink { string in
        print("+\(deltaTime)s: Subject emitted: \(string)")
        //시간과 값 출력
    }

let subscription2 = throttled
    .sink { string in
        print("+\(deltaTime)s: Throttled emitted: \(string)")
        //시간과 값 출력
    }

subject.feed(with: typingHelloWorld)
//데이터 세트를 가져와 사전에 정의된 간격으로 subject에 데이터를 내보낸다.





//: [Next](@next)


