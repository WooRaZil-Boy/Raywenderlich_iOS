/// Copyright (c) 2019 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit
import PlaygroundSupport

/*:
 Tell the playground to continue running, even after it thinks execution has ended.
 You need to do this when working with background tasks.
 */

PlaygroundPage.current.needsIndefiniteExecution = true

let group = DispatchGroup()
let queue = DispatchQueue.global(qos: .userInitiated)

queue.async(group: group) {
    print("Start job 1")
    Thread.sleep(until: Date().addingTimeInterval(10))
    print("End job 1")
}

queue.async(group: group) {
    print("Start job 2")
    Thread.sleep(until: Date().addingTimeInterval(2))
    print("End job 2")
}

if group.wait(timeout: .now() + 5) == .timedOut { //5초 제한
    print("I got tired of waiting")
} else {
    print("All the jobs have completed")
}

PlaygroundPage.current.finishExecution()

// Start job 1
// Start job 2
// End job 2
// I got tired of waiting
// End job 1

//작업 2는 2초 동안만 sleep 하기 때문에, 5초 내에 완료된다. 이후, 제한 시간 초과가 출력되고, 이어 작업 1이 완료된다.




func myAsyncAdd(
    lhs: Int,
    rhs: Int,
    completion: @escaping (Int) -> Void) {
    // Lots of cool code here
    completion(lhs + rhs)
}

func myAsyncAddForGroups(
    group: DispatchGroup,
    lhs: Int,
    rhs: Int,
    completion: @escaping (Int) -> Void) { //래핑하는 메서드의 인수와 일치해야 한다.
    group.enter()
    
    myAsyncAdd(lhs: lhs, rhs: rhs) { result in
        defer { group.leave() }
        
        completion(result)
    }
}


