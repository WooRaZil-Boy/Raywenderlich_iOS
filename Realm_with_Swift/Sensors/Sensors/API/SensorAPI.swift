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

private let frequency = 1.0 / 10000.0 // 10Khz sensor

final class SensorAPI {
  typealias Symbol = String
  typealias Value = Double

  let symbol: String

  init(symbol: String) {
    self.symbol = symbol
  }

  func connect(callback: @escaping (Symbol, Value) -> Void) -> Self {
    print("connected sensor '\(symbol)'")

    Timer.scheduledTimer(withTimeInterval: frequency, repeats: true) { [weak self] timer in
      guard let symbol = self?.symbol else {
        timer.invalidate()
        return
      }

      callback(symbol, Double(random(min: 0, max: 100)))
    }

    return self
  }

  deinit {
    print("disconnected sensor '\(symbol)'")
  }
}

private func random(min: UInt32, max: UInt32) -> Int {
  return Int(arc4random_uniform(max) + min)
}
