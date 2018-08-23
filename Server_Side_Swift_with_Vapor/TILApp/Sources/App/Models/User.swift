import Foundation
import Vapor
import FluentPostgreSQL

final class User: Codable {
    var id: UUID? //unique //Acronym과 달리 여기선 ID가 UUID이다(Foundation 필요).
    var name: String
    var username: String
    
    init(name: String, username: String) {
        self.name = name
        self.username = username
    }
}

extension User: PostgreSQLUUIDModel {}
//모델의 id 속성이 UUID 이므로 PostgreSQLModel 대신 PostgreSQLUUIDModel를 사용해야 한다.

extension User: Content {}
extension User: Migration {}
extension User: Parameter {}

//Getting the children
extension User {
    var acronyms: Children<User, Acronym> { //Children<Parent, Child>
        //computed property로 Acronym의 user 객체를 가져온다.
        return children(\.userID)
        //Fluent의 children(_:) 메서드를 사용하여 자식을 검색한다.
    }
}

//Parent-child relationships
//부모 - 자식 관계는 한 모델이 하나 이상의 모델에 대해 "소유권"을 갖는 관계를 나타낸다.
//one-to-one, one-to-many relationship으로 나타낼 수도 있다.
//여기서는 부모(User) - 자식(Acronym)관계로 정의한다.
