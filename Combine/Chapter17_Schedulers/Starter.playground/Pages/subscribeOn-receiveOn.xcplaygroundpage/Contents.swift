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

import Foundation
import Combine

let computationPublisher = Publishers.ExpensiveComputation(duration: 3)
//Sources/Computation.swift에 ExpensiveComputation이라는 특별한 publisher를 정의하고 있다.
//이 publisher는 지정된 지속시간 후에 문자열을 내보내는 장기 실행 작업을 시뮬레이션한다.

let queue = DispatchQueue(label: "serial queue")
//특정 스케줄러에서 작업을 실행하는데 사용할 serial queue
//DispatchQueue는 Scheduler 프로토콜을 준수한다.

let currentThread = Thread.current.number //현재 실행 스레드 번호를 가져온다.
print("Start computation publisher on thread \(currentThread)")
//main thread(1번 스레드)는 코드가 실행되는 기본 스레드이다.
//스레드 클래스의 number extension은 Sources/Thread.swift에 정의되어 있다.

let subscription = computationPublisher
    .subscribe(on: queue) //추가
    .receive(on: DispatchQueue.main) //추가
    .sink { value in
        let thread = Thread.current.number
        print("Received computation result on thread \(thread): '\(value)'")
    }

//: [Next](@next)

