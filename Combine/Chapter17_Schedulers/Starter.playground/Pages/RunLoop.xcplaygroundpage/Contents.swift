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

var threadRecorder: ThreadRecorder? = nil //추가

let source = Timer
  .publish(every: 1.0, on: .main, in: .common)
  .autoconnect()
  .scan(0) { (counter, _) in counter + 1 }

let setupPublisher = { recorder in
    //recorder를 수신하는 publisher를 생성한다.
    source
        .handleEvents(receiveSubscription: { _ in threadRecorder = recorder }) //추가
        //record를 캡쳐 한다.
        .receive(on: DispatchQueue.global()) //추가
//        .subscribe(on:DispatchQueue.global()) //모든 기록이 스레드 1에서 기록된다.
        //타이머가 기본 스레드에서 값을 내보내고, 이를 수신하기 때문이다.
        .recordThread(using: recorder)
        //recordThread(using:) 연산자는 현재 스레드 정보를 기록한다.
        //타이머가 값을 내보냈으므로 현재 스레드를 기록한다.
        .receive(on: RunLoop.current) //이 부분만 변경
        //RunLoop에서 값을 받는다.
        .recordThread(using: recorder)
        //현재 스레드 정보를 기록한다.
        .eraseToAnyPublisher()
        //클로저는 AnyPublisher 유형을 반환해야 한다.
}

let view = ThreadRecorderView(title: "Using RunLoop", setup: setupPublisher)
//다양한 기록 지점에서 스레드 간의 값을 표시하는 ThreadRecorderView를 인스턴스화 한다.
PlaygroundPage.current.liveView = UIHostingController(rootView: view)

RunLoop.current.schedule(after: .init(Date(timeIntervalSinceNow: 4.5)), tolerance: .milliseconds(500)) {
    threadRecorder?.subscription?.cancel()
    //캡처한 record 인스턴스를 취소한다.
}

//: [Next](@next)


