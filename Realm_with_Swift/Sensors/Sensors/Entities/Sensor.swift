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

private let maxReadings = 10_000

@objc(Sensor)
@objcMembers class Sensor: Object {

  // MARK: - Properties
  enum Property: String {
    case symbol
  }

  enum Symbol: String {
    case o3, no2, aqi

    static var allRawValues: [String] {
      return [Symbol.o3.rawValue, Symbol.no2.rawValue, Symbol.aqi.rawValue]
    }
  }

  dynamic var symbol = ""
  let readingHistory = List<Reading>()

  // MARK: - Init
  convenience init(_ symbol: String) {
    self.init()
    self.symbol = symbol
  }

  // MARK: - Meta
  override class func primaryKey() -> String? {
    return Sensor.Property.symbol.rawValue
  }

  // MARK: - Reading data
  typealias SensorMap = [String: Sensor]
  static func sensorMap(in realm: Realm) -> SensorMap {
    return realm.objects(Sensor.self).reduce(SensorMap(), { dict, sensor -> SensorMap in
      return dict.merging([sensor.symbol: sensor], uniquingKeysWith: { s1, _ in return s1 })
    })
  }

  // MARK: - Write data
  static private(set) var totalWrites: Int64 = 0

  func addReadings(_ set: [Reading]) {
    guard let realm = realm else { return }

    let block = {
      self.readingHistory.append(objectsIn: set)
      Sensor.totalWrites += Int64(set.count)

      guard self.readingHistory.count > maxReadings else { return }

      let excess = self.readingHistory.count - maxReadings
      realm.delete( self.readingHistory[0...excess] )
      Sensor.totalWrites += Int64(excess)
    }

    if realm.isInWriteTransaction {
      block()
    } else {
      try! realm.write(block)
    }
  }
}
