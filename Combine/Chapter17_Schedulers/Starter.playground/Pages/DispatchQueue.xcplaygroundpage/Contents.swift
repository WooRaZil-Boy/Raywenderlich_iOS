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

let serialQueue = DispatchQueue(label: "Serial queue")
let sourceQueue = DispatchQueue.main
//let sourceQueue = serialQueue //변경

let source = PassthroughSubject<Void, Never>()
//타이머가 작동될 때 Subject를 사용하여 값을 내보낸다. 실제 출력 타입은 신경 쓰지 않으므로 Void를 사용한다.
let subscription = sourceQueue.schedule(after: sourceQueue.now, interval: .seconds(1)) { //즉시 시작하고 Cancellable를 반환한다.
    //이전 11장에서 배운대로, queues는 타이머를 생성할 수 있지만, 이를 위한 Publisher API가 따로 없다.
    //따라서 schedule() 메서드의 variant를 사용하여 직접 구현해야 한다
    source.send()
    //Void 값을 내보낸다.
}

let setupPublisher = { recorder in
    source
        .recordThread(using: recorder)
//        .receive(on: serialQueue)
        .receive(on: serialQueue, options: DispatchQueue.SchedulerOptions(qos: .userInteractive)) //qos 설정
        .recordThread(using: recorder)
        .eraseToAnyPublisher()
}

let view = ThreadRecorderView(title: "Using DispatchQueue", setup: setupPublisher)
//다양한 기록 지점에서 스레드 간의 값을 표시하는 ThreadRecorderView를 인스턴스화 한다.
PlaygroundPage.current.liveView = UIHostingController(rootView: view)


//: [Next](@next)


