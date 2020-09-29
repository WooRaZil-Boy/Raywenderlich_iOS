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
//문자열을 내보내는 source publisher를 생성한다.

let debounced = subject
    .debounce(for: .seconds(1.0), scheduler: DispatchQueue.main)
    //debounce를 사용하여 subject에서 나오는 값에 대해 1초간 대기한다.
    //그런 다음, 1초 간격으로 방출된 마지막 값을 내보낸다.
    //다시 말해 초당 최대 1개의 값을 내보내게 된다.
    .share()
    //debounced를 여러번 구독할 것이다.
    //결과의 일관성 보장을 위해 share()을 사용한다.
    //모든 구독자에게 동시에 동일한 결과를 보여주는 단일 구독 지점을 debounce 한다.

let subjectTimeline = TimelineView(title: "Emitted values")
let debouncedTimeline = TimelineView(title: "Debounced values")
//timer에서 내보내는 값을 표시할 TimelineView를 생성한다.
//TimelineView는 SwiftUI view로, Sources/Views.swift 에서 해당 코드를 확인할 수 있다.

let view = VStack(spacing: 100) { //SwiftUI의 vertical stack을 생성한다.
    subjectTimeline
    debouncedTimeline
}

PlaygroundPage.current.liveView = UIHostingController(rootView: view)
//playground page의 liveView를 설정한다.

subject.displayEvents(in: subjectTimeline)
debounced.displayEvents(in: debouncedTimeline)
//내보낸 값을 표시한다.

let subscription1 = subject
    .sink { string in
        print("+\(deltaTime)s: Subject emitted: \(string)")
        //시간과 값 출력
    }

let subscription2 = debounced
    .sink { string in
        print("+\(deltaTime)s: Debounced emitted: \(string)")
        //시간과 값 출력
    }

subject.feed(with: typingHelloWorld)
//데이터 세트를 가져와 사전에 정의된 간격으로 subject에 데이터를 내보낸다.

//: [Next](@next)


