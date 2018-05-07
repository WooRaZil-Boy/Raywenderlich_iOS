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
  internal init(config: Realm.Configuration) {
    self.configuration = config
  }

  var realm: Realm {
    return try! Realm(configuration: configuration)
  }

  // MARK: - Bundled Realm
  private static let bundledConfig = Realm.Configuration(
    fileURL: try! Path.inBundle("default.realm"),
    readOnly: true,
    objectTypes: [Subject.self, Exam.self])

  public static var bundled: RealmProvider = {
    return RealmProvider(config: bundledConfig)
  }()

  // MARK: - Util

  /// Delete existing Realm files/folders

  func removeFiles() throws {
    guard let fileUrl = configuration.fileURL,
      let files = FileManager.default.enumerator(at: fileUrl.deletingLastPathComponent(), includingPropertiesForKeys: []),
      let fileName = fileUrl.lastPathComponent.components(separatedBy: ".").first else {
      return
    }

    for file in files.allObjects {
      guard let url = file as? URL,
        url.lastPathComponent.hasPrefix("\(fileName).") else { continue }
      try FileManager.default.removeItem(at: url)
    }
  }
}
