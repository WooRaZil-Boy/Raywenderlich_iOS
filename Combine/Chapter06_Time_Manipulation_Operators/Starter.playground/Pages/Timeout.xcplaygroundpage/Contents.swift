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

enum TimeoutError: Error { //사용자 정의 오류 타입
    case timedOut
}

//let subject = PassthroughSubject<Void, Never>()
let subject = PassthroughSubject<Void, TimeoutError>()

//let timedOutSubject = subject.timeout(.seconds(5), scheduler: DispatchQueue.main)
//timedOutSubject는 업 스트림 publisher가 5초간 어떠한 값도 내보내지 않으면, timeout 된다.
//이러한 timeout 형식은 publisher가 실패없이 완료되도록 강제된다.
let timedOutSubject = subject.timeout(.seconds(5), scheduler: DispatchQueue.main, customError: { .timedOut })
//timeout(_:scheduler:options:customError:)
//사용자 지정 오류형을 추가해 준다.


let timeline = TimelineView(title: "Button taps")

let view = VStack(spacing: 100) { //SwiftUI의 vertical stack을 생성한다.
    Button(action: { subject.send() }) { //SwiftUI로 Button을 생성한다.
        //버튼을 누르면, subject로 새 값을 보낸다.
        //버튼을 누를 때마다 action 클로저가 실행된다.
        Text("Press me within 5 seconds")
        //버튼에 Text를 추가한다.
    }
    timeline
}

PlaygroundPage.current.liveView = UIHostingController(rootView: view)
//playground page의 liveView를 설정한다.

timedOutSubject.displayEvents(in: timeline)
//내보낸 값을 표시한다.

//: [Next](@next)


