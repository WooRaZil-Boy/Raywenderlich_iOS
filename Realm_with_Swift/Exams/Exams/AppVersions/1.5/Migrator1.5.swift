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

#if EXAMS_V1_5

struct Migrator {
  static func migrate(migration: Migration, oldVersion: UInt64) {
    if oldVersion < 2 { //스키마 버전 1에서 2로 마이그레이션 하는 동안 필요한 상수 추가
      print("Migrate to Realm Schema 2")
      
      let multipleChoiceText = " (multiple choice)"
      
      enum Key: String { case isMultipleChoice, subject, name }
      //액세스하거나 수정할 모든 객체 키를 나열
      //이미 Exam.Property.isMultipleChoice가 있지만, 다음 버전에선 어떻게 사용되고 삭제될지 알 수 없다.
      //해당 클래스 내에서 정의된 속성 이름을 사용할 수 있지만, 마이그레이션 논리를 외부 종속성에서 자유롭게 유지하려면
      //마이그레이션 코드 내에서 상수를 별도로 선언하는 것이 좋다.
      
      var migratedExamCount = 0
      
      migration.enumerateObjects(ofType: String(describing: Exam.self)) { _, newExam in
        //마이그레이션 실행할 코드
        guard let newExam = newExam, let subject = newExam[Key.subject.rawValue] as? MigrationObject, let subjectName = subject[Key.name.rawValue] as? String else {
          return
        }
        
        if subjectName.contains(multipleChoiceText) {
          //multipleChoiceText이 포함되어 있는 경우 업데이트
          newExam[Key.isMultipleChoice.rawValue] = true
          subject[Key.name.rawValue] = subjectName.replacingOccurrences(of: multipleChoiceText, with: "")
          //해당 범위 문자열 replace //불필요한 텍스트 제거
        }
        
        migratedExamCount += 1 //카운터 증가
      }
      
      print("Schema 2: Migrated \(migratedExamCount) exams")
    }
  }
}

#endif

//마이그레이션 로직 작성
