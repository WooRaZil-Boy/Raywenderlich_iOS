
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

// MARK: - Realm entities

@objcMembers class Exam: Object {
  enum Property: String { case name }
  dynamic var name = ""
  override var description: String {
    return "Exam {name: \"\(name)\"}"
  }
}

@objcMembers class Mark: Object {
  enum Property: String { case mark }
  dynamic var mark = ""
  override var description: String {
    return "Mark {mark: \"\(mark)\"}"
  }
}

func migrateFrom1To2(_ migration: Migration) {
    print("Migration from 1 to version 2")
    
    migration.enumerateObjects(ofType: String(describing: Exam.self)) { from , to in
        //Realm에 있는 특정 유형의 모든 객체를 열거해 각 객체의 이전 버전과 새 버전 가져온다.
        //Migration.enumerateObjects (ofType : _ :)로 모든 Exam 항목을 열거해,
        //업데이트가 필요한 항목을 찾는다. 스키마에 따라, from과 to에 해당 객체가
        //없을 수도 있다.
        //ex. Exam 객체 제거한 경우 to에 객체가 없다.
        guard let from = from, let to = to, let name = from[Exam.Property.name.rawValue] as? String, name.isEmpty else {
            return
        }
        //MigrationObject는 Dictionary와 비슷하게 사용하면 된다.
        
        to[Exam.Property.name.rawValue] = "n/a"
        //버전 1의 Exam의 객체의 name에는 빈 문자열이 들어가 있다.
        //이것을 버전 2에서는 "n/a"로 설정
    }
}

func migrateFrom2to3(_ migration: Migration) {
    print("Migration from 2 to version 3")
    
    migration.enumerateObjects(ofType: String(describing: Mark.self)) { from, to in
        //Realm에 있는 특정 유형의 모든 객체를 열거해 각 객체의 이전 버전과 새 버전 가져온다.
        //Migration.enumerateObjects (ofType : _ :)로 모든 Exam 항목을 열거해,
        //업데이트가 필요한 항목을 찾는다. 스키마에 따라, from과 to에 해당 객체가
        //없을 수도 있다.
        //ex. Exam 객체 제거한 경우 to에 객체가 없다.
        guard let from = from, let to = to, let mark = from[Mark.Property.mark.rawValue] as? String, mark.isEmpty else {
            return
        }
        //MigrationObject는 Dictionary와 비슷하게 사용하면 된다.

        to[Mark.Property.mark.rawValue] = "F"
        //버전 2에서 Mark 객체를 추가 했다.
        //이것을 버전 3에서는 mark 속성을 "F"로 설정
    }
}

// MARK: - Migrations code
print("Ready to play...")

//Modifying an object schema
//Realm 파일의 객체 스키마를 정의하려면, Realm.Configuration 구조체를 사용하거나
//특정 Realm에 포함된 객체를 나열하는 objectSchema 속성을 사용한다.
//앱이 시작되면, Realm은 코드에서 정의한 클래스를 조사하고, Object를 서브 클래싱하는
//클래스를 찾은 다음 세부적인 맵을 만든다. 나중에 Configuration을 사용해 디스크에서 Realm을
//열면, Realm은 코드에 정의된 객체의 스키마를 file-persisted schema와 일치시킨다. p.217

//스키마를 업데이트 하면, DB에 저장되어 있는 객체들의 스키마와 일치하지 않기 때문에, 앱을
//실행 시키면, Realm은 오류를 일으킨다. Realm.Configuration의
//deleteRealmIfMigrationNeeded 속성을 사용해, Realm이 현재 코드 스키마와 일치하지
//않은 경우, 새 Realm을 만들기 전에 기존 Realm을 삭제하도록 할 수도 있다.
//let conf = Realm.Configuration(fileURL: fileUrl, deleteRealmIfMigrationNeeded: true)
//이 옵션을 사용하면, 개발 중 스키마 불일치 오류가 발생하지 않는다.
//App Store 출시 시에는 반드시 비활성화 해야 한다. 그렇지 않으면, 새로운 스키마가 포함된
//앱 버전이 출시될 때마다 사용자의 데이터가 삭제되어 버린다.
//deleteRealmIfMigrationNeeded 사용의 또 다른 사례는 앱의 데이터가 임시적이며, 언제든
//다시 작성할 수 있는 경우이다. 이 경우, 한 버전에서 다른 버전으로 마이그레이션을 수행하는 대신
//전체 DB를 삭제하고 데이터를 다시 만든다(흔히 개발 중에 사용할 수 있다).




//What’s a schema migration, anyway?
//Realm.Configuration에서 스키마 버전을 지정할 수 있다. Realm 파일을 열 때, 디스크의
//이전 버전을 감지해야만 기존 데이터를 새 스키마로 마이그레이션할 수 있다. p.220
//처음으로 이전 파일을 열 때, 정확히 한 번 실행되는 마이그레이션 중에는 이전 스키마와
//새 스키마에 모두 액세스할 수 있다. 일반적으로 마이그레이션에서는 다음과 같은 작업을 한다.
//• 스키마에 새 객체 모델을 추가하면, 새 코드는 DB에 이러한 객체 중 하나 이상이 항상
//  있을 것으로 예상한다. 마이그레이션 시, 새 앱 버전이 실행되기 전에 해당 객체를 만들어
//  DB에 저장한다.
//• 새로운 속성을 추가하고 default 값을 설정해 준 경우, 이전 스키마의 객체들을 모두 루프하여
//  속성을 추가하고, default 값을 설정해 주어야 새 스키마와 호환될 수 있다.
//• 기존 모델 객체에서 속성명을 변경한 경우, 바뀐 속성명이 이전 속성명을 가리켜야 하고
//  값을 복사해 두어야 한다.




//Automatic migrations
//Realm에서 대부분의 스키마 변경 사항을 자동 처리할 수 있다. 스키마에서 객체를 추가, 삭제하거나
//객체의 속성을 추가, 삭제, 인덱스를 추가 하는 등의 변경은 자동으로 마이그레이션할 수 있다.
//사용자 정의 데이터를 추가하고 한 객체에서 다른 객체로 값을 복사하는 것과 같이 Realm에서
//추론할 수 없는 작업만 사용자가 해 주면 된다.
//Realm의 오토 마이그레이션이 지원하는 작업은 다음과 같다.
//• 스키마 버전 번호 증가
//• 새 Realm 객체를 스키마에 추가
//• 스키마에서 기존 Realm 객체 제거
//• 기존 Realm 객체에 속성 추가
//• 기존 Realm 객체에서 속성 제거
//• 기본 키 추가
//• 기본 키 제거
//• 인덱싱된 속성 추가
//• 인덱싱된 속성 제거
//Realm은 마이그레이션 중 모든 변경 사항을 기존 파일 구조에 자동으로 적용한다.
//파일이 오류 없이 성공적으로 열리면, 새 스키마 버전 번호가 부여되고,
//완전히 마이그레이션 된 것으로 간주한다.




//Custom migrations
//변경 사항을 Realm 오토 마이그레이션 여부와 관계없이 Configuration 객체에 마이그레이션
//블록을 제공해야 한다. 마이그레이션 블록에는 스키마 마이그레이션 중에 한 번 실행되는 코드가
//포함되어 있으며, "이전" 스키마와 "새" 스키마에 모두 액세스할 수 있다.
//let conf = Realm.Configuration(
//    fileURL: fileUrl,
//    schemaVersion: 2,
//    migrationBlock: { migration, oldVersion in
//        // do nothing
//} )
//위의 Configuration은 응용 프로그램에 객체 스키마 버전 2를 사용해야 함을 알려준다.
//이전 스키마 버전 1에서 새 버전으로 업데이트하면, Realm은 제공된 migrationBlock을
//호출하여 버전 2로 마이그레이션을 수행한다.
//migrationBlock은 두 개의 클로저 파라미터를 제공한다.
//1. migration : "이전" 및 "새" 객체 스키마에 대한 액세스를 제공하고,
//  "이전" 과 "새" Realm 파일의 데이터에 액세스하는 방법을 제공하는 마이그레이션 helper
//2. oldVersion : 기존 파일의 스키마 버전
//이 블록 내에서(do nothing 주석) Realm이 자동으로 수행할 수 있는 마이그레이션 항목을
//적용하면 된다(위의 Automatic migrations 목록).
//앱이 커지면서 마이그레이션 코드 또한 복잡해질 수 있으므로, 해당 코드를 별도의 파일이나
//클래스로 떼어 놔야될 때도 있다.




//Realm Migration class
//마이그레이션 클로저에 파라미터로 제공되는 migration 객체가 핵심적인 역할을 한다.
//다음은 migration 클래스를 사용하여 수행할 몇 가지 일반적인 작업들이다.

//Schemas
//마이그레이션은 "기존" 스키마(현재 사용자 디바이스에 있는 스키마)와 "새" 스키마에 newSchema,
//oldSchema 속성을 사용해 액세스할 수 있다. 두 속성은 모두 스키마 유형이며, 모든 객체 목록,
//해당 속성 목록 및 각각에 대한 형식, 메타 정보에 대한 액세스를 제공한다.
//Schemas 인스턴스에는 다음과 같은 정보가 있다. p.223
//포함된 객체와 해당 속성 List을 iterate할 수 있다. 또한 어떤 키가 기본키인지, 인덱싱된
//속성, 각 속성의 유형 및 optional 여부를 확인할 수 있다.

//Data access
//이전 스키마와 새 스키마는 데이터 구조에 대한 정보를 제공하지만, 실제 데이터 자체에 대한 액세스를
//제공하지는 않는다. Migration 클래스에는 이전 Realm과 새 Realm 모두에 있는 객체에 액세스
//할 수 있게 해주는 메서드 세트가 있다.

//Enumerating objects
//특정 유형의 모든 객체를 열거하여 기존 데이터에 액세스할 수 있다. API는 Realm.objects(_)와
//유사하다. 주요 차이점은 이전 Realm과 새 Realm의 객체를 동시에 제공한다는 것이다.
//Migration.enumerateObjects(ofType : _ :)는 필수 유형의 레코드를 반복하고,
//이전 객체와 새 객체가 일치하는 쌍을 제공하여 클로저를 호출한다.
//migration.enumerateObjects(ofType: "Exam") { old, new in
//    if old?["result"] == nil {
//        new?["result"] = "n/a"
//    }
//}
//두 클로저 인수(old, new)는 MigrationObject 타입이다. 일반적인 Dictionary와 비슷하다.
//MigrationObject는 마이그레이션 중에 사용할 기본 유형이다. Realm은 클래스의 이전 버전과
//새 버전을 제공할 수 없다. 앱에는 현재 버전의 코드만 표시되므로 특정 클래스의 이전 버전 객체를
//만들 방법이 없다.

//Adding and deleting objects
//새 데이터를 추가하거나 기존 데이터를 삭제해야 하는 경우에 API를 사용할 수 있다.
//Migration.create(_:value:)는 새 MigrationObject를 만든다.
//로컬 Realm 객체(String)와 일치하는 클래스 이름과 Dictionary를 사용해서 객체를
//초기화한다. Realm 파일을 열고 마이그레이션이 완료되면, MigrationObject 대신
//지정된 유형의 객체가 반환되므로, 평소와 같이 작업할 수 있다.
//migration.create("Exam", value: [
//    "subject": "Computer Science",
//    "result": "C++"
//])
//삭제 시에는 Migration.delete(_)를 사용한다.
//migration.enumerateObjects(ofType: "Exam") { _, new in
//    if let new = new, new["name"] == nil {
//        migration.delete(new)
//    }
//}

//Deleting all objects and metadata of a type
//Migration.deleteData(forType:)를 사용하면 특정 유형의 모든 기존 객체를 한번에
//삭제할 수 있다. 모델이 스키마에서 모두 제거된 경우, 이 메서드는 해당 유형과 관련된
//기존 메타 데이터를 모두 지운다.

//Renaming a property
//Migration.renameProperty(onType : from : to :)를 사용해, 속성의 이름을 바꾼다.
//코드에서 속성의 이름이 바뀌면, Realm은 다른 이름을 가진 속성이 동일한 것인지 알 수 없다.
//Realm이 아는 정보는 단지 예전 속성이 삭제되고, 새로운 이름의 속성이 추가된 것이다.
//따라서 속성명을 바꾸려면, 이전 모든 데이터를 삭제하고, 새 속성을 추가해야 한다.
//migration.renameProperty(
//    onType: "Exam",
//    from: "completed",
//    to: "isCompleted"
//)




//Basic migrations

//App version 1.0

// Initially install & run the 1.0 version app
Example.of("Run app ver. 1.0") {
    //클로저 내부의 코드는 1.0 버전에서 실행되는 코드로 간주
    let conf = Realm.Configuration(schemaVersion: 1, deleteRealmIfMigrationNeeded: true, objectTypes: [Exam.self])
    //버전 1.0은 Realm 스키마 버전 1을 사용하고, Exam 유형의 객체를 DB에 사용한다.
    
    let realm = try! Realm(configuration: conf)
    
    try! realm.write { //하나의 Exam 객체 트랜잭션
        realm.add(Exam())
    }
    
    print("Exams: \(Array(realm.objects(Exam.self)))")
    //1.0 버전은 마이그레이션 관련 코드 없이, 일부 데이터를 생성하는 것이 목표
}

//App version 1.5

// Simulate running the 1.5 version of the app,
// comment this one to simulate non-linear migration
Example.of("Run app ver. 1.5") {
    func migrationBlock(migration: Migration, oldVersion: UInt64) {
        //단순히 새 객체를 추가하는 것은 Realm이 자동으로 처리하므로,
        //migrationBlock을 비워둬도 된다. 추가적인 작업이 필요하다면 작성이 필요.
        if oldVersion < 2 { //이전 버전의 스키마가 2보다 작다면(1)
            //단순히 1에서 2로 버전 업 할 때는 크게 유용한 방법이 아니지만,
            //계속해서 스키마 버전이 늘어날 것이므로 이런 식으로 관리해 주는 것이 좋다.
            migrateFrom1To2(migration)
        }
    }
    
    let conf = Realm.Configuration(schemaVersion: 2, migrationBlock: migrationBlock, objectTypes: [Exam.self, Mark.self])
    //1.0 버전과 비교해서, 스키마 버전이 2로 바뀌었고, Mark라는 새 클래스가 추가된다. p.228
    
    let realm = try! Realm(configuration: conf)
    
    print("Exams: \(Array(realm.objects(Exam.self)))")
    print("Marks: \(Array(realm.objects(Mark.self)))")
    
    try! realm.write { //Mark 객체 트랜잭션 쓰기
        realm.add(Mark())
    }
}

//App version 2.0
Example.of("Run app ver. 2.0") {
    func migrationBlock(migration: Migration, oldVersion: UInt64) {
        if oldVersion < 2 {
            migrateFrom1To2(migration)
        }
        
        if oldVersion < 3 {
            migrateFrom2to3(migration)
        }
        //사용자가 오랫동안 앱을 켜지 않은 경우, 바로 스키마 버전 1.0에서 3.0으로
        //업데이트해야할 수도 있으므로, 순차적 마이그레이션을 구현해 두어야 한다.
        //위와 같이 구현하면 1 - 2 - 3으로 순차적으로 업데이트 되게 된다. p.233
        //이렇게 순차적으로 구현하지 않은 경우, 1에서 바로 3으로 업데이트 되는 경우도 있어
        //문제가 생기게 된다.
    }
    
    let conf = Realm.Configuration(schemaVersion: 3, migrationBlock: migrationBlock, objectTypes: [Exam.self, Mark.self])
    //버전 2.0에서는 객체 스키마를 변경한다. //스키마 버전 3
    
    let realm = try! Realm(configuration: conf)
    
    print("Exams: \(Array(realm.objects(Exam.self)))")
    print("Marks: \(Array(realm.objects(Mark.self)))")
}




//Known issues
//Realm 마이그레이션에 관련된 몇 가지 알려진 문제들이 있다.
//• 스키마 버전을 낮추는 것은 지원되지 않는다. 디스크의 Realm 파일보다 낮은 스키마 버전을
//  지정하려고 하면 오류가 발생한다.
//• 추가된 속성에는 기본값이 적용되지 않는다.
//  ex. dynamic var title = "Default" 로 새 속성을 추가하면,
//  기존 모든 객체에 새 속성이 추가되지만, 해당 값은 "Default" 대신 빈 문자열이 된다.
//• 추가된 기본키는 마이그레이션 중에 새 스키마에 반영되지 않는다. 마이그레이션이 완료되고,
//  Realm이 파일을 열면 기본 키가 제대로 적용된다.
//• 마이그레이션 중에 기본 유형 목록에 액세스하는 것은 불가능 하다.
//  List<DynamicObject>에 String, Int, Date 등과 같은 Realm 이외의
//  목록에 액세스할 수 없다.

