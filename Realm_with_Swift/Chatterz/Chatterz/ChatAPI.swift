/// Copyright (c) 2018 Razeware LLC
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

import Foundation
import UIKit

class ChatAPI {

  typealias MessagesCallback = ([(String, String)]) -> Void
  private var callback: MessagesCallback?

  // "connects" to chat api and starts periodically fetch messages
  // and feed them to the provided callback
  func connect(withMessagesCallback callback: @escaping MessagesCallback) {
    self.callback = callback
    receiveMessages()
  }

  private func receiveMessages() {
    var messages = [(String, String)]()

    for _ in 0...random(min: 1, max: 3) {
      messages.append((from.randomElement(), phrases.randomElement()))
    }

    // simulate fetching data from network
    UIApplication.shared.isNetworkActivityIndicatorVisible = true

    DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
      self?.callback?(messages)
      UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }

    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(random(min: 5, max: 10))) {[weak self] in
      self?.receiveMessages()
    }
  }

  private let phrases = ["hello everyone", "hey hey hey", "anyone around?", "Bye", "I'm outta here", "I have a question", "testing testing ... 1, 2, 3", "wubalubadubdub"]
  private let from = ["Josh", "Jane", "Peter", "Sam", "Ray", "Paul", "Adam", "Lana", "Derek", "Patrick"]
}

private func random(min: UInt32, max: UInt32) -> Int {
  return Int(arc4random_uniform(max) + min)
}

extension Array {
  func randomElement() -> Element {
    return self[random(min: 0, max: UInt32(count-1))]
  }
}
