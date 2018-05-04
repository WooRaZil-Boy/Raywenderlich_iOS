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

private let groupId = "group.com.razeware.FlashCards"

enum PathError: Error, LocalizedError {
  case notFound
  case containerNotFound(String)

  var errorDescription: String? {
    switch self {
      case .notFound: return "Resource not found"
      case .containerNotFound(let id): return "Shared container for group \(id) not found"
    }
  }
}

class Path {
  static func inLibrary(_ name: String) throws -> URL {
    return try FileManager.default
      .url(for: .libraryDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
      .appendingPathComponent(name)
  }

  static func inDocuments(_ name: String) throws -> URL {
    return try FileManager.default
      .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
      .appendingPathComponent(name)
  }

  static func inBundle(_ name: String) throws -> URL {
    guard let url = Bundle.main.url(forResource: name, withExtension: nil) else {
      throw PathError.notFound
    }
    return url
  }

  static func inSharedContainer(_ name: String) throws -> URL {
    guard let url = FileManager.default
      .containerURL(forSecurityApplicationGroupIdentifier: groupId) else {
        throw PathError.containerNotFound(groupId)
    }
    return url.appendingPathComponent(name)
  }

  static func documents() throws -> URL {
    return try FileManager.default
      .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
  }
}
