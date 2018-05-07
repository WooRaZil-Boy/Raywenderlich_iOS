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

let appVersion = 2.0

  //
  // Realm object schema and view models
  // used in version 2.0 of the Exams app
  //

  // MARK: - Object Schema 3

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
      case id, date, subject, passed, isMultipleChoice
    }

    dynamic var id = UUID().uuidString
    dynamic var date: Date?
    dynamic var subject: Subject?
    dynamic var passed: Result? //2.0에서 변경
    dynamic var isMultipleChoice = false

    convenience init(subject: Subject) {
      self.init()
      self.subject = subject
    }
  }

  @objcMembers final class Result: Object { //2.0에서 추가
    enum Property: String { case result }
    enum Value: String { case notSet = "Not set", pass, fail}
    //Result에서 ( "실패", "통과" "설정하지 않음") 중 선택하도록 사용자에게 요청한다.
    
    dynamic var result = ""
    
    override static func primaryKey() -> String? {
      return Result.Property.result.rawValue
    }
    
    static func initialData() -> [[String: String]] { //기본 값
      //초기 Realm 객체를 만드는 데 필요한 세개의 dictionary
      //이 클래스는 Realm 인스턴스를 사용할 수 없는 Migration 블록 내부에서 호출되기 때문에
      //사용할 Realm을 지정하지 않는다.
      
      //2.0 마이그레이션에서는 Result.initialData()의 데이터를 사용하여 관련 마이그레이션 객체를 만들고
      //마이그레이션에 추가하여 최종 마이그레이션된 Realm 파일 및 사용자 정의 interactive migrations에서
      //사용할 수 있도록 한다.
      return [Value.notSet, Value.pass, Value.fail]
        .map{ [Property.result.rawValue: $0.rawValue] }
    }
  }

  @objcMembers class MigrationTask: Object { //2.0에서 추가
    struct Task {
      let type: TaskType
      let priority: TaskPriority

      static let askForExamResults = Task(type: .askForExamResults, priority: .askForExamResults)
    }

    enum TaskType: String {
      case askForExamResults
    }

    enum TaskPriority: Int {
      case askForExamResults = 100
    }

    enum Property: String { case name, priority }

    dynamic var name = ""
    dynamic var priority = 0

    @discardableResult
    static func create(task: Task, in migration: Migration) -> MigrationObject {
      //지정된 마이그레이션 인스턴스에 새 객체를 생성한다.
      return migration.create(
        String(describing: MigrationTask.self),
        value: [
          Property.name.rawValue: task.type.rawValue,
          Property.priority.rawValue: task.priority.rawValue
        ])
    }

    static func first(in realm: Realm) -> MigrationTask? {
      //주어진 Realm에 보류중인 작업이 있으면 반환한다.
      return realm.objects(MigrationTask.self).first
    }

    func complete() {
      //주어진 Realm에서 작업이 완료되면 객체를 제거한다.
      guard let realm = realm else { return }
      try? realm.write {
        realm.delete(self)
      }
    }

    override static func primaryKey() -> String? {
      return MigrationTask.Property.name.rawValue
    }
  }

  // MARK: - Realm Provider exams
  extension RealmProvider {
    public static var exams: RealmProvider = {
      // Configuration
      let provider = RealmProvider(config: Realm.Configuration(
        fileURL: try! Path.inLibary("default.realm"),
        schemaVersion: 3,
        migrationBlock: Migrator.migrate,
        objectTypes: [Subject.self, Exam.self, Result.self, MigrationTask.self]))
      return provider
    }()
  }

#endif

//Version 2.0에서는 Exam 클래스의 free-form  Strubg results를 대체하고, 별도의 Realm 모델을 사용한다.
//"fail", "pass", "pending"과 같은 미리 정의된 Result 객체를 DB에 포함시켜 검사를 그룹화하거나 필터링할 수 있다.
//Realm은 interactive migrations을 기본적으로 제공하지 않으므로, 사용자 정의 UI와 논리를 작성해야 한다.
//새로운 모델을 만들면서 사용자가 선택해서 값을 넣어줘야 하는 경우 사용할 수 있다.

//Version 2.0에서 사용하는 interactive migrations은 Realm의 표준 마이그레이션을 사용하지 않는다.
//Realm 마이그레이션 블록에서 자동으로 처리할 수 있는 변경 사항을 완료하고, 사용자를 별도의 워크 플로우로 유도하여
//나머지 마이그레이션 작업을 완료한다. p.245
//interactive migrations은 다른 모든 마이그레이션 단계를 수행한 후, 최후의 수단이어야 한다.

//이번 버전에서 migration은 다음과 같은 순서로 진행된다. p.248
//1. result value없이 모든 exam을 자동으로 마이그레이션 한다.
//2. 수동으로 마이그레이션할 exam의 경우, askForExamResults 유형으로 MigrationTask울 작성한다.
//3. 응용 프로그램이 시작되면, Realm 파일에서 보류 중인 마이그레이션이 작업이 있는지 확인한다.
//4. 보류 중인 작업이 있는 경우 기본 앱 UI로 이동하기 전에 관련 작업에 대한 맞춤 UI를 표시한다.
