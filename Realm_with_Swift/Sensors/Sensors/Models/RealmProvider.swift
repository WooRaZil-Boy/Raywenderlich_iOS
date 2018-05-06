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

struct RealmProvider {
  let configuration: Realm.Configuration

  private init(config: Realm.Configuration) {
    configuration = config
  }

  var realm: Realm {
    return try! Realm(configuration: configuration)
  }

  // MARK: - Sensors realm
  private static let sensorsConfig = Realm.Configuration()
  public static var sensors: RealmProvider = {
    return RealmProvider(config: sensorsConfig)
  }()

  // MARK: - Util methods
  var stats: (count: Int, fileSize: Double)? {
    guard let url = configuration.fileURL,
          let attr = try? FileManager.default.attributesOfItem(atPath: url.path),
          let fileSize = attr[FileAttributeKey.size] as? Int64 else {
        return nil
    }

    let objectCount = realm.schema.objectSchema.reduce(0) { count, schema -> Int in
      guard let objectType = NSClassFromString(schema.className) as? Object.Type else { return count }

      return count + realm.objects(objectType).count
    }

    return (count: objectCount, fileSize: Double(fileSize) / 1_000_000.00)
  }

  public static func resetSensorData() {
    // delete existing realm file
    let folder = sensorsConfig.fileURL!.deletingLastPathComponent()
    let files = FileManager.default.enumerator(
      at: folder, includingPropertiesForKeys: [])!

    for file in files.allObjects {
      guard let url = file as? URL,
            url.lastPathComponent.hasPrefix("default.") else { continue }

      try? FileManager.default.removeItem(at: url)
    }

    // add sensors
    let realm = try! Realm(configuration: sensorsConfig)
    try! realm.write {
      realm.add([
        Sensor(Sensor.Symbol.o3.rawValue),
        Sensor(Sensor.Symbol.no2.rawValue),
        Sensor(Sensor.Symbol.aqi.rawValue)
      ])
    }
  }
}
