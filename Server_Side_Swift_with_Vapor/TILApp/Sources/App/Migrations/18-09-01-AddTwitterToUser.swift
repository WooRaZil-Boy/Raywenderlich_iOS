import FluentPostgreSQL
import Vapor

struct AddTwitterURLToUser: Migration {
    //새로운 필드를 모델에 추가하는 마이그레이션. User의 prepare(on:) 참고
    typealias Database = PostgreSQLDatabase //Migration에서 사용할 DB 유형 정의
    
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        //Migration 시 DB 변경 사항
        return Database.update(User.self, on: connection) { builder in
            //User 모델은 이미 DB에 있으므로 update 한다.
            builder.field(for: \.twitterURL)
            //업데이트는 클로저 내에서 이뤄진다. twitterURL 필드를 추가한다.
        }
    }
    
    static func revert(on connection: PostgreSQLConnection) -> Future<Void> {
        //prepare(on:)에서 했던 일을 취소해야 할 때
        return Database.update(User.self, on: connection) { builder in
            //기존 User 모델을 수정하기 때문에 update 한다.
            builder.deleteField(for: \.twitterURL)
            //업데이트는 클로저 내에서 이뤄진다. twitterURL 필드를 제거한다.
        }
    }
}




//Modifying tables
//기존 DB가 서비스 중일 때에는 단순히 테이블에서 속성을 추가하거나 제거할 수 없다.
//대신 Vapor의 Migration 프로토콜을 사용하여 수정 할 수 있다.
//이는 예상대로 진행되지 않았을 때 revert 하는 옵션을 포함하고 있다.
//중요한 데이터가 많은 경우 DB를 수정하기 전에 백업을 하는 것이 좋다.
//코드를 깨끗하게 유지하고 변경 사항을 순서대로 보려면 모든 마이그레이션이 포함된 디렉토리를 만들어야 한다.
//파일 이름의 경우 일관되고 유용한 이름을 사용한다. ex. YY-MM-DD-FriendlyName.swift

//Writing migrations
//마이그레이션은 일반적으로 기존 모델을 업데이트 하는 구조체로 작성된다. 이 구조체는 Migration을 구현해야 한다.
//마이그레이션을 수행하려면 다음 세 가지를 구현해야 한다.

//typealias Database: Fluent.Database
//static func prepare(on connection: Database.Connection) -> Future<Void>
//static func revert(on connection: Database.Connection) -> Future<Void>

// • Typealias Database
//마이그레이션을 실행할 수 있는 DB 유형을 지정해야 한다. 마이그레이션을 수행하려면 MigrationLog 모델을 쿼리할 수 있어야 하므로
//DB 연결이 올바르게 작동해야 한다. MigrationsLog에 액세스 할 수 없는 경우 마이그레이션이 실패하고 최악의 경우 응용 프로그램이 중단된다.

// • Prepare method
//prepare(on:) 에는 마이그레이션에 대한 DB 변경 사항이 들어 있다. 대개 새 테이블을 생성하거나 새 속성을 추가해 기존 테이블을 수정하는 것이다.

//static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
//    return Database.create( //DB에 새 Model 추가 //기존 모델에 속성을 추가하는 경우는 update(_:on:closure:)를 사용
//        NewTestUser.self,
//        on: connection
//        ) { builder in //실제 수정을 하는 클로저
//            builder.field(for: \.id, isIdentifier: true)
//            //field(for:)를 호출해 모델에 추가할 각 필드를 수정할 수 있다.
//            //일반적으로 Fluent가 필드를 유추할 수 있으므로 필드 유형을 포함할 필요는 없다.
//    }
//}

// • Revert method
//revert(on:)는 prepare(on:)의 역이다. prepare(on:)에서 했던 일을 취소한다.
//prepare(on:)에 create(_:on:closure:)를 사용해 생성했다면 revert(on:)에서는 delete(_:on:)를 사용해 테이블을 삭제한다.
//update(_:on:closure:)를 사용하여 필드를 추가했다면, revert(on:)에서는 deleteField(for:)를 사용해 필드를 제거한다.

//static func revert(on connection: PostgreSQLConnection) -> Future<Void> {
//    return Database.delete(NewTestUser.self, on: connection)
//}

//이는 --revert 옵션으로 앱을 부팅할 때 실행할 수 있다.

//마이그레이션이 제대로 됐는지 테이블을 확인하려면 터미널에서 p.378

//docker exec -it postgres psql -U vapor
//\d "User"
//\q
//를 입력해 보면 된다.




//Deploy to Vapor Cloud
//이전에는 모델을 변경할 때 마다 전체 DB를 삭제해야 했지만, 마이그레이션이 제대로 완료된 경우에는 그럴 필요 없이 바로 Deploy 할 수 있다.
//https://docs.vapor.codes/3.0/fluent/migrations/
