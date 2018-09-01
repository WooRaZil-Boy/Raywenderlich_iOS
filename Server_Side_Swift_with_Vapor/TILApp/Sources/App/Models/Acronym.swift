import Vapor
//import FluentSQLite
//import FluentMySQL
import FluentPostgreSQL

final class Acronym: Codable {
    //Fluent 모델. 모든 Fluent 모델은 Codalbe을 구현해야 한다.
    //가능하면 final로 선언해 상속을 제한하는 것이 성능 상에 좋다.
    var id: Int? //id는 DB에 저장될 때 설정된다.
    var short: String
    var long: String
    var userID: User.ID //부모 - 자식 관계 설정 //User의 id 객체이므로 UUID이다.
    
    init(short: String, long: String, userID: User.ID) {
        self.short = short
        self.long = long
        self.userID = userID
    }
}

//extension Acronym: Model {
//    //Fluent 모델
//    typealias Database = SQLiteDatabase
//    //Fluent에서 사용할 모델 템플릿은 SQLite를 사용하도록 구성되어 있다.
//    typealias ID = Int
//    //Fluent의 ID 유형
//    public static var idKey: IDKey = \Acronym.id
//    //ID 속성의 경로
//
//}

//extension Acronym: SQLiteModel {}
//Fluent는 각 DB의 모델 Helper 프로토콜을 제공하므로 따로 ID 유형이나 키를 지정할 필요 없다.
//여기에선 id가 Int이지만, UUID(SQLiteUUIDModel) 혹은 String (SQLiteStringModel)모델도 있다.
//특정한 id 유형에 맞춘 프로토콜을 구현해야 한다.

//extension Acronym: MySQLModel {}
//MySQL 모델로 지정한다.

extension Acronym: PostgreSQLModel {}
//PostgreSQL 모델로 지정한다.

extension Acronym: Content {}
//사용가자 입력한 데이터를 저장할 때, Vapor에서는 Codable을 사용한다.
//Content는 다양한 형식 간에 모델 및 기타 데이터를 변환할 수 있는 Codable 래퍼이다.
//사용자가 웹 페이지에서 아래처럼 JSON payload가 포함된 POST 요청을 보내면 된다.
//{
//    "short": "OMG",
//    "long": "Oh My God"
//}

//이 POST request를 처리하고 저장하는 것은 routes에 추가해 주면 된다.

extension Acronym: Parameter {}
//검색, 수정, 삭제 등에서 특정 파라미터를 추가하려면 Parameter를 구현해야 한다.

//Getting the parent
extension Acronym {
    var user: Parent<Acronym, User> { //Parent<Child, Parent>
        //computed property로 Acronym의 user 객체를 가져온다.
        return parent(\.userID)
        //Fluent의 parent(_:) 메서드를 사용하여 부모를 검색한다.
    }
    
    //Setting up the relationship
    //Vapor에서 부모 - 자식 관계를 모델링하는 것은 DB의 관계를 모델링 하는 것과 같다.
    //여기서 User는 Acronym을 소유하기 때문에 Acronym에 대한 참조를 사용자에 추가한다.
    //새로운 관계가 추가되었다면(userID), 응용 프로그램을 실행하기 전에 DB를 재설정해야 한다.
    //Fluent는 테이블에 새로운 컬럼이 추가된 걸 알 지 못하므로, 마이그레이션을 다시 실행하도록 해야 한다.
    //출시 전에는 그냥 DB를 삭제하고 다시 설치하는 것이 편하다. p.133
}

extension Acronym: Migration {
    //모델을 DB에 저장하려면 table을 작성해야 한다. Fluent는 마이그레이션 작업을 수행한다.
    //이 작업으로 모델의 저장, 변경, 스키마 등을 작성하는 데 사용할 수 있다.
    //Fluent는 Codable을 구현했으므로 모델 스키마를 추정할 수 있다.
    //모델을 변경하거나 속성을 바꾸는 등의 복잡한 작업을 수행할 수 있지만, 기본 모델의 경우 단순히 선언해 주는 것으로 충분하다.
    
    //Migration을 구현했으므로, Fluent가 앱이 시작할 때 테이블을 생성할 수 있다.
    //configure.swift에서 지정해 줄 수 있다.
    
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> { //Foreign key constraints
        //prepare(on)을 override한다. //DB에서 실행할 마이그레이션 변경 설정
        return Database.create(self, on: connection) { builder in
            //DB에 Acronym 테이블을 생성한다.
            try addProperties(to: builder)
            //모든 필드를 DB에 추가한다(수동으로 추가할 필요가 없다).
            builder.reference(from: \.userID, to: \User.id)
            //Acronym의 userID 속성과 User의 id 속성 사이에 참조를 추가한다.
        }
    }
    //출시 전이라면, DB를 삭제하고 다시 추가하는 것이 편하다.
    
    //Foreign key constraints
    //외래키 제약 조건으로 두 테이블 간의 연결을 나타낼 수 있다. 이는 유효성 검사에 자주 사용된다.
    //현재 User 테이블과 Acronym 테이블 사이에는 링크 없이 Fluent가 링크에 대한 유일한 정보를 가지고 있다.
    //외래 키 제약 조건을 사용하면 다음과 같은 많은 이점이 있다.
    //• 존재하지 않는 User로 Acronym을 생성할 수 없도록 한다.
    //• 모든 Acronym를 삭제하지 않으면 User를 삭제할 수 없다.
    //• Acronym 테이블을 삭제하지 않으면 User 테이블을 삭제할 수 없다.
    //외래 키 제약 조건은 마이그레이션에서 설정된다.
}

//Sibling relationships
extension Acronym {
    var categories: Siblings<Acronym, Category, AcronymCategoryPivot> {
        //Siblings<Base, Related, Through>
        //실제로 두 모델 사이의 관계를 만들려면 피벗을 사용해야 한다.
        return siblings()
        //Fluent의 siblings() 함수를 메서드로 모든 Category를 검색한다.
    }
}







//Fluent
//Fluent는 Vapor의 ORM(object relational mapping) 툴이다.
//이것은 Vapor 애플리케이션과 데이터베이스 작업을 더 쉽게 수행할 수 있도록 설계되어 있다.
//Fluent와 같은 ORM을 사용하면 몇 가지 이점이 있다.
//가장 큰 장점은 데이터베이스를 직접 사용할 필요가 없다는 것이다.
//데이터베이스와 직접 상호작용할 때 보통 쿼리를 문자열로 작성하는데, 이런 타입들은 안전하지 않으며(오타) 사용하는 것이 어렵기도 하다.
//Fluent는 동일한 앱에서도 여러 DB 엔진 중 하나를 사용할 수 있게 한다.
//또한 Swifty한 방식으로 모델과 상호작용할 수 있으므로 쿼리를 작성할 필요가 없다.

//모델은 데이터를 Swift로 표현한 것으로 Fluent에서 사용된다. 모델은 DB에 저장하고 액세스하는 사용자 프로파일과 같은 객체이다.
//Fluent는 DB와 상호작용할 때 type-safe model을 반환해 컴파일 시에도 안전적으로 제공된다.




//Vapor를 사용할 때 Xcode 프로젝트는 폐기될 수도 있기 때문에(Xcode 에디터를 사용하는 것은 선택사항이다.)
//Xcode 외부에서 프로젝트 파일을 만드는 것이 가장 좋다.
//Swift Package Manager가 올바른 대상에 링크되도록 만든다.
//터미널에서 touch Sources/App/Models/Acronym.swift 이런 식으로 생성할 수 있다.













