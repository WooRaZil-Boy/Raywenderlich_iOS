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

#if EXAMS_V1_0

let appVersion = 1.0

  //
  // Realm object schema and view models
  // used in version 1.0 of the Exams app
  //

  // MARK: - Object Schema 1

  @objcMembers final class Subject: Object {
    enum Property: String {
      case name, credits
    }

    dynamic var name = ""
    dynamic var credits = 1

    convenience init(name: String) {
      self.init()
      self.name = name
    }

    override static func primaryKey() -> String? {
      return Subject.Property.name.rawValue
    }

    override static func indexedProperties() -> [String] {
      return [Subject.Property.credits.rawValue]
    }
  }

  @objcMembers final class Exam: Object {
    enum Property: String {
      case date, subject
    }

    dynamic var date: Date?
    dynamic var subject: Subject?

    convenience init(subject: Subject) {
      self.init()
      self.subject = subject
    }
  }

  // MARK: - Realm Provider exams
  extension RealmProvider {
    public static var exams: RealmProvider = {
      // Configuration
      let provider = RealmProvider(config: Realm.Configuration(
        fileURL: try! Path.inLibary("default.realm"),
        schemaVersion: 1,
        objectTypes: [Subject.self, Exam.self]))

      // Remove artifacts
      try? provider.removeFiles()

      // Create initial data
      let realm = provider.realm
      try! realm.write {
        realm.add(Exam(subject: Subject(name: "Math 101")))
        realm.add(Exam(subject: Subject(name: "Medieval Literature (multiple choice)")))
      }
      return provider
    }()
  }

#endif

//Version 1.0은 기본적으로 두 가지 Exam 객체를 생성한다. Exam의 이름과 점수가 표시된다. p.239

