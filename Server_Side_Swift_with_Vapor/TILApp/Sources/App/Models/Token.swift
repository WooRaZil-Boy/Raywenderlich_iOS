import Foundation
import Vapor
import FluentPostgreSQL
import Authentication

final class Token: Codable {
    var id: UUID?
    var token: String //클라이언트에 제공된 문자열
    var userID: User.ID //토큰 소유자의 user id
    
    init(token: String, userID: User.ID) {
        self.token = token
        self.userID = userID
    }
    
    //Getting a token
    //password로 인증된 사용자만이 Acronym을 만들 수 있도록 설정했다. 하지만, 이런 식으로 각 request에 대해 자격 증명을 입력하도록 요청하는 것은 비실용적이다.
    //또한 입력한 암호를 암호화하고 복호화해서 대조하고, 또 DB에 String으로 저장되지 않도록 신경써줘야 한다.
    //대신에 사용자가 API 자체에 로그인을 하도록 구현할 수 있다. 사용자가 API에 로그인하면, 클라이언트가 저장할 수 있는 토큰으로 자격 증명을 할 수 있다.
}

extension Token: PostgreSQLUUIDModel {}

extension Token: Migration {
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        //외래키 제약 조건을 만들어 준다. //DB에서 실행할 마이그레이션 변경 설정
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.reference(from: \.userID, to: \User.id)
        }
    }
}

extension Token: Content {}

extension Token {
    static func generate(for user: User) throws -> Token {
        //토큰 생성 메서드 //사용자가 로그인하면, 응용 프로그램은 해당 사용자의 토큰을 만든다.
        let random = try CryptoRandom().generateData(count: 16) //16 랜덤 바이트로 토큰 생성
        
        return try Token(token: random.base64EncodedString(), userID: user.requireID())
        //랜덤 바이트로 base64 인코딩한 값을 토큰 문자열로 해 userID와 함께 토큰을 생성한다.
    }
}

extension Token: Authentication.Token {
    //Authentication.Token을 구현
    static let userIDKey: UserIDKey = \Token.userID
    //Vapor에 토큰의 어떤 속성이 user id 인지 알린다.
    typealias UserType = User
    //Vapor에 User가 어떤 유형인지 알린다.
}

extension Token: BearerAuthenticatable {
    //BearerAuthenticatable를 구현해, 토큰을 BearerAuthentication과 함께 사용할 수 있게 한다.
    //BearerAuthentication은 request를 인증하기 위해 토큰을 보내는 메커니즘이다.
    //HTTP basic authentication과 같은 Authorization 헤더를 사용하지만 Authorization: Bearer <TOKEN STRING> 식으로 사용한다.
    static let tokenKey: TokenKey = \Token.token
    //Vapor에게 토큰 키의 key 경로(여기선 토큰의 문자열)을 알린다.
}
