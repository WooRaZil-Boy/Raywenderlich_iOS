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
import RealmSwift

final class ReadingStats {
  // MARK: - Time tracking
  private let startTime = Date().timeIntervalSince1970

  let statsQueue = DispatchQueue(label: "stats", qos: .background)

  typealias RealmStats = [String: Double]
  typealias AuxStats = String

  func connect(callback: @escaping (RealmStats, AuxStats) -> Void) {
    Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
      self?.statsQueue.async {
        guard let this = self,
              let fileStats = RealmProvider.sensors.stats else {
          return
        }

        // Time tracking
        let totalSeconds = Date().timeIntervalSince1970 - this.startTime
        let minutes = Double(Int(totalSeconds / 60))
        let seconds = totalSeconds.truncatingRemainder(dividingBy: 60.0)

        // Realm stats
        let realm = RealmProvider.sensors.realm
        let realmStats = realm.objects(Sensor.self).reduce([:], { dict, sensor -> [String: Double] in
          return dict.merging(
            [sensor.symbol: sensor.readingHistory.average(ofProperty: Reading.Property.value.rawValue) ?? 0.0],
            uniquingKeysWith: { s1, _ -> Double in s1 })
          })

        // Aux stats
        let auxStats = String(format: """
                                      Time elapsed: %02.0f:%02.0f
                                      Objects count: %d
                                      Total writes: %d
                                      File size: %.2fMb
                                      """, locale: Locale.current,
                              minutes,
                              seconds,
                              fileStats.count,
                              Sensor.totalWrites,
                              fileStats.fileSize)

        callback(realmStats, auxStats)
      }
    }
  }

}
