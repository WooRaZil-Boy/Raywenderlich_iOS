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

#if EXAMS_V2_0

struct Migrator {

  static func schema(_ schema: Schema, includesProperty name: String, for className: String) -> Bool {
    return schema.objectSchema.reduce(false, { result, object in
      return result || (object.className == className && object.properties.first(where: { $0.name == name}) != nil)
    })
  }

  static func migrate(migration: Migration, oldVersion: UInt64) {
    if oldVersion < 2 {
      print("Migrate to Realm Schema 2")

      let multipleChoiceText = " (multiple choice)"
      enum Key: String { case isMultipleChoice, subject, name }

      var migratedExamCount = 0

      migration.enumerateObjects(ofType: String(describing: Exam.self)) { _, newExam in
        guard let newExam = newExam,
          let subject = newExam[Key.subject.rawValue] as? MigrationObject,
          let subjectName = subject[Key.name.rawValue] as? String else { return }

        if subjectName.contains(multipleChoiceText) {
          newExam[Key.isMultipleChoice.rawValue] = true
          subject[Key.name.rawValue] = subjectName.replacingOccurrences(of: multipleChoiceText, with: "")
        }

        migratedExamCount += 1
      }

      print("Schema 2: Migrated \(migratedExamCount) exams")
    }
    
    if oldVersion < 3 {
      enum Key: String { case result, passed } //액세스할 필요 있는 모든 키
      //Exam.Property.result를 삭제했다. 따라서, 이전 Realm에서 값에 액세스하려면, key의 name이 필요하다.
      var isInteractiveMigrationNeeded = false
      
      let result = Result.initialData().map {
        return migration.create(String(describing: Result.self), value: $0)
        //새 record 생성. 마이그레이션이 완료되면 생성된 객체가 최종 Realm으로 병합된다.
      }
      
      let noResult = result.first!
      
      let examClassName = String(describing: Exam.self)
      
      migration.enumerateObjects(ofType: examClassName) { oldExam, newExam in
        guard let oldExam = oldExam, let newExam = newExam else { return }
        
        if schema(migration.oldSchema, includesProperty: Key.result.rawValue, for: examClassName), oldExam[Key.result.rawValue] as? String != nil {
          //이전 스키마에 Results.result 속성이 있는 지 확인한다. 1.0 에서 2.0으로 직접 마이그레이션 하는 경우
          //객체 스키마 1에 Exam.result 속성이 없기 때문에 Result를 설정할 수 없다.
          isInteractiveMigrationNeeded = true
        } else {
          newExam[Key.passed.rawValue] = noResult
        }
        
        if isInteractiveMigrationNeeded { //수동 마이그레이션이 필요하다면
          MigrationTask.create(task: .askForExamResults, in: migration) //작업
        }
      }
    }

  }
}

#endif
