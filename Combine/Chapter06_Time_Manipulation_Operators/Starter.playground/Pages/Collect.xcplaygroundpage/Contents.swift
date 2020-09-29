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
let collectTimeStride = 4 //수집 시간
let collectMaxCount = 2 //수집 값의 최대 개수

let sourcePublisher = PassthroughSubject<Date, Never>() //source publisher를 생성한다.
//timer로 게시되는 값을 내보내는 subject

let collectedPublisher = sourcePublisher
    .collect(.byTime(DispatchQueue.main, .seconds(collectTimeStride)))
    //collectTimeStride 동안에 방출된 값을 수집한다.
    //지정된 scheduler(여기서는 DispatchQueue.main)에 array로 수집된 값의 그룹을 내보낸다.
    .flatMap { dates in dates.publisher } //출력이 배열임을 확인하기 위해 추가한다.

let collectedPublisher2 = sourcePublisher
    .collect(.byTimeOrCount(DispatchQueue.main, .seconds(collectTimeStride), collectMaxCount))
    //collectTimeStride 동안에 방출된 값을 수집한다.
    //지정된 scheduler(여기서는 DispatchQueue.main)에 array로 수집된 값의 그룹을 내보낸다.
    //collectMaxCount 개수만큼 값을 받는다.
    .flatMap { dates in dates.publisher } //출력이 배열임을 확인하기 위해 추가한다.

let subscription = Timer
    .publish(every: 1.0 / valuesPerSecond, on: .main, in: .common)
    //메인 스레드에 초당 1개의 값을 내보내는 타이머를 생성한다.
    .autoconnect() //즉시 시작
    .subscribe(sourcePublisher) //구독
    //sourcePublisher에서 내보낼 값을 가져온다.

let sourceTimeline = TimelineView(title: "Emitted values:")
//timer에서 내보내는 값을 표시할 TimelineView를 생성한다.
//TimelineView는 SwiftUI view로, Sources/Views.swift 에서 해당 코드를 확인할 수 있다.
let collectedTimeline = TimelineView(title: "Collected values (every \(collectTimeStride)s):")
let collectedTimeline2 = TimelineView(title: "Collected values (at most \(collectMaxCount) every \(collectTimeStride)s):")
//수집된 값을 표시할 TimelineView를 생성한다.

let view = VStack(spacing: 40) { //SwiftUI의 vertical stack을 생성한다.
    sourceTimeline
    collectedTimeline
    collectedTimeline2
}

PlaygroundPage.current.liveView = UIHostingController(rootView: view)
//playground page의 liveView를 설정한다.

sourcePublisher.displayEvents(in: sourceTimeline)
collectedPublisher.displayEvents(in: collectedTimeline)
collectedPublisher2.displayEvents(in: collectedTimeline2)
//내보낸 값을 표시한다.

//: [Next](@next)


