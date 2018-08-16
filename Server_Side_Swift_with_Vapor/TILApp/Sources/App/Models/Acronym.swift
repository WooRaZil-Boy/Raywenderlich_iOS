import Vapor
import FluentSQLite

final class Acronym: Codable {
    //Fluent 모델. 모든 Fluent 모델은 Codalbe을 구현해야 한다.
    //가능하면 final로 선언해 상속을 제한하는 것이 성능 상에 좋다.
    var id: Int? //id는 DB에 저장될 때 설정된다.
    var short: String
    var long: String
    
    init(short: String, long: String) {
        self.short = short
        self.long = long
    }
}

extension Acronym: Model {
    //Fluent 모델
    typealias Database = SQLiteDatabase
    //Fluent에서 사용할 모델 템플릿은 SQLite를 사용하도록 구성되어 있다.
    typealias ID = Int
    //Fluent의 ID 유형
    public static var idKey: IDKey = \Acronym.id
    //ID 속성의 경로
    
}

extension Acronym: SQLiteModel {}
//Fluent는 각 DB의 모델 Helper 프로토콜을 제공하므로 따로 ID 유형이나 키를 지정할 필요 없다.
//여기에선 id가 Int이지만, UUID(SQLiteUUIDModel) 혹은 String (SQLiteStringModel)모델도 있다.
//특정한 id 유형에 맞춘 프로토콜을 구현해야 한다.

extension Acronym: Migration {}
//모델을 DB에 저장하려면 table을 작성해야 한다. Fluent는 마이그레이션 작업을 수행한다.
//이 작업으로 모델의 저장, 변경, 스키마 등을 작성하는 데 사용할 수 있다.
//Fluent는 Codable을 구현했으므로 모델 스키마를 추정할 수 있다.
//모델을 변경하거나 속성을 바꾸는 등의 복잡한 작업을 수행할 수 있지만, 기본 모델의 경우 단순히 선언해 주는 것으로 충분하다.

//Migration을 구현했으므로, Fluent가 앱이 시작할 때 테이블을 생성할 수 있다.
//configure.swift에서 지정해 줄 수 있다.

extension Acronym: Content {}
//사용가자 입력한 데이터를 저장할 때, Vapor에서는 Codable을 사용한다.
//Content는 다양한 형식 간에 모델 및 기타 데이터를 변환할 수 있는 Codable 래퍼이다.
//사용자가 웹 페이지에서 아래처럼 JSON payload가 포함된 POST 요청을 보내면 된다.
//{
//    "short": "OMG",
//    "long": "Oh My God"
//}

//이 POST request를 처리하고 저장하는 것은 routes에 추가해 주면 된다.





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


