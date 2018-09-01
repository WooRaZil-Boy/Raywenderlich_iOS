import Foundation
import Vapor
import FluentPostgreSQL
import Authentication

final class User: Codable {
    var id: UUID? //unique //Acronym과 달리 여기선 ID가 UUID이다(Foundation 필요).
    var name: String
    var username: String
    var password: String //사용자 비밀번호
    //Codable을 구현 했으므로, 사용자를 만들 때 추가로 변경할 필요 없다.
    var twitterURL: String? //Model에 새 속성 추가
    //기존 사용자에게는 해당 속성이 없으므로 optional
    
    init(name: String, username: String, password: String, twitterURL: String? = nil) {
        self.name = name
        self.username = username
        self.password = password
        self.twitterURL = twitterURL
    }
    
    final class Public: Codable {
        //공개적인 정보를 보여주는 나타내는 User의 내부 클래스
        //User를 계속해서 사용하는 것은 암호 해시가 그대로 노출되기 때문에 좋은 방법이 아니다.
        //대신 이 내부 클래스를 사용해, 공개되도 상관없는 정보들만 response로 반환하도록 해야 한다.
        var id: UUID?
        var name: String
        var username: String
        var twitterURL: String?
        
        init(id: UUID?, name: String, username: String, twitterURL: String? = nil) {
            self.id = id
            self.name = name
            self.username = username
            self.twitterURL = twitterURL
        }
    }
}

extension User: PostgreSQLUUIDModel {}
//모델의 id 속성이 UUID 이므로 PostgreSQLModel 대신 PostgreSQLUUIDModel를 사용해야 한다.

extension User: Content {}
extension User: Parameter {}

extension User.Public: Content {}
//User.Public도 Content를 구현해 준다.

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


//Making usernames unique
extension User: Migration {
    //사용자 이름을 unique한 것으로 해서 식별할 수 있도록 한다.
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        //Parent Child Relationships에서 외래 키 제약 조건을 추가한 것과 마찬가지로, 사용지 지정 마이그레이션을 구현한다.
        //DB에서 실행할 마이그레이션 변경 설정
        return Database.create(self, on: connection) { builder in
            //User table을 생성한다.
            
//            try addProperties(to: builder)
//            //생성된 User 테이블의 column(열)에 모든 User 속성을 추가한다.
            
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.name)
            builder.field(for: \.username)
            builder.field(for: \.password)
            //twitterURL를 제외한 기존 속성을 DB에 수동으로 추가
            
            //prepare(on:)은 모델에서 찾은 모든 속성을 추가한다.
            //전체 DB를 되돌리고 처음 마이그레이션에서 모든 필드를 추가하면 모델에 추가된 새 필드가 있기 때문에 마이그레이션이 실패한다.
            //마이그레이션 시 try addProperties(to: builder)를 사용하면, 모든 필드를 추가하기 때문에 새 마이그레이션이 실패한다.
            
            builder.unique(on: \.username)
            //User에 unique index(여기서는 username)를 추가한다.
            //마이그레이션이 제대로 실행 된 후, 중복 사용자 이름을 작성하면 오류가 발생한다.
        }
    }
}

//Passwords
//Authentication(인증)은 누가인지 확인하는 프로세스로, 사용자가 특정 작업 수행할 권한 있음을 확인해 주는 권한 부여와 다르다.
//일반적으로 가장 간단하나 인증 방법은 password이다.

//Returning users from the API
//모델이 변경되었으므로 Vapor가 테이블에 새로운 열을 추가할 수 있도록 DB를 revert해야 한다.
//option-click으로 Run 버튼을 누르거나, option-command-R 을 눌러 스키마 편집기를 연다.
//Arguments 탭에서 Arguments Passed On Launch 섹션에 revert --all --yes를 입력하고, Run 한다.
//혹은 터미널에서 vapor run revert --all --yes를 입력하면 revert할 수 있다.
//한 번 revert 된 이후에는 다시 같은 스키마 편집 창에 들어가 체크를 해제해 일반적인 DB Run 을 실행한다.

extension User {
    func convertToPublic() -> User.Public { //User.Public을 반환하는 User 메서드
        return User.Public(id: id, name: name, username: username, twitterURL: twitterURL) //Public을 반환한다.
        //공개되도 상관없는 정보들만 Public class로 만들어 response로 반환한다.
        
        //새 모델에서 twitterURL이 추가되었다.
        //기존 모델에 새 특성을 추가할 때 원래의 필드만 추가하도록 초기 마이그레이션을 수정하는 것이 중요하다.
        //기본적으로 prepare(on:)은 모델에서 찾은 모든 속성을 추가한다.
    }
}

extension Future where T: User { //Future<User>에 대한 extension
    func convertToPublic() -> Future<User.Public> { //Future<User.Public>를 반환한다.
        return self.map(to: User.Public.self) { user in //unwrapping
            return user.convertToPublic() //User 객체를 User.Public으로 변환한다.
        }
    }
    
    //이 extension의 메서드로, Future<User> 에서 convertToPublic()를 호출하여 코드를 정리하고 중첩을 줄일 수 있다.
    //route handler에서 이 메서드를 사용해 Public user를 반환한다.
}

extension User: BasicAuthenticatable {
    //HTTP Basic Helper 구현
    static let usernameKey: UsernameKey = \User.username
    //Vapor에 User의 어떤 속성이 name인지 알린다.
    static let passwordKey: PasswordKey = \User.password
    //Vapor에 User의 어떤 속성이 password인지 알린다.
    
    //Basic authentication
    //HTTP basic authentication은 RFC7617로 정의된 표준화된 방법이다. 일반적으로 HTTP 요청의 인증 헤더에 증명을 포함시킨다.
    //이 헤더의 토큰을 생성하려면 사용자 이름과 암호를 결합한 후, base64로 인코딩한다.
    //ex. timc:password (base63 encoding) dGltYzpwYXNzd29yZA==
    //이의 full header는 Authorization: Basic dGltYzpwYXNzd29yZA== 가 된다.
    //Vapor에는 HTTP basic authentication을 비롯한 다양한 유형의 인증 처리 패키지가 있다. Package.swift에 추가해 주면 된다.
}

extension User: TokenAuthenticatable {
    //TokenAuthenticatable을 구현한다. 이를 구현하면 토큰이 사용자를 인증할 수 있다.
    typealias TokenType = Token
    //Vapor에 토큰의 유형을 알린다.
}

struct AdminUser: Migration {
    typealias Database = PostgreSQLDatabase
    //Migration이 필요한 DB 유형 정의

    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        //DB에서 실행할 마이그레이션 변경 설정
        let password = try? BCrypt.hash("password") //password의 해시를 생성한다.
        //실제로 운영되는 시스템이라면 "password"가 아닌 다른 문자열로 해시를 하는 것이 좋다.
        
        guard let hashedPassword = password else { //password 해시 생성이 실패한 경우 crash
            fatalError("Failed to create admin user")
        }
        
        let user = User(name: "Admin", username: "admin", password: hashedPassword)
        //기본 admin 사용자 생성
        
        return user.save(on: connection).transform(to: ())
        //생성된 기본 admin 사용자를 DB에 저장한다. transform(to:) 로 반환형을 맞춰준다.
    }
    
    static func revert(on connection: PostgreSQLConnection) -> Future<Void> {
        //Migration 변경 사항을 DB에서 되돌린다. 대개는 생성된 테이블을 삭제한다.
        return .done(on: connection) //.done은 Future<Void>를 반환한다.
    }
    
    //Database seeding
    //User 로그인은 password로 인증하지만, 나머지 User, Acronym, Category의 CRUD는 token으로 인증된 사용자만이 가능하다.
    //따라서 API는 안전하지만, 응용 프로그램의 DB를 재설정하거나 처음 설정할 때는, DB에는 User가 하나도 없다.
    //하지만, User의 생성 또한 인증이 필요하므로 새 사용자를 생성할 수 없다.
    //이를 해결하는 방법은 처음 DB를 설정할 때 Database seeding을 하고, User를 만드는 것이다.
}




//Implementing sessions
extension User: PasswordAuthenticatable {}
//PasswordAuthenticatable를 구현하면, Vapor가 로그인 할 때 username과 password로 인증할 수 있다.
//이미 BasicAuthenticatable에서 PasswordAuthenticatable 구현에 필요한 속성을 이미 구현 했다.

extension User: SessionAuthenticatable {}
//SessionAuthenticatable를 구현하면, 응용 프로그램이 세션의 일부로 사용자를 저장하고 검색 할 수 있다.

