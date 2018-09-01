@testable import App
import FluentPostgreSQL
import Crypto

extension User {
    static func create(
        name: String = "Luke",
        username: String? = nil, //기본값 nil
        on connection: PostgreSQLConnection
        ) throws -> User {
        //사용자 생성. default 값을 가지고 있기 때문에 빈 파라미터로 생성해도 된다.
        
        var createUsername: String
        
        if let suppliedUsername = username { //username이 nil(default)가 아닌, 매개변수로 입력된 경우
            createUsername = suppliedUsername
        } else { //username이 nil(default)인 경우
            createUsername = UUID().uuidString //UUID 사용하여 임이의 새 사용자 생성(unique한 username이 되므로 마이그레이션 문제가 없다)
        }
        
        let password = try BCrypt.hash("password")
        let user = User(name: name, username: createUsername, password: password)
        //User 객체 생성
        
        return try user.save(on: connection).wait()
        //DB에 저장
    }
}

extension Acronym {
    static func create(
        short: String = "TIL",
        long: String = "Today I Learned",
        user: User? = nil,
        on connection: PostgreSQLConnection
        ) throws -> Acronym {
        //Acronym 생성. default 값을 가지고 있기 때문에 빈 파라미터로 생성해도 된다.
        
        var acronymsUser = user
        
        if acronymsUser == nil {
            //파라미터로 User를 지정해 주지 않았다면, default 사용자를 생성한다.
            acronymsUser = try User.create(on: connection)
        }
        
        let acronym = Acronym(
            short: short,
            long: long,
            userID: acronymsUser!.id!)
        //Acronym 객체 생성
        
        return try acronym.save(on: connection).wait()
        //DB에 저장
    }
}

extension App.Category {
    static func create(
        name: String = "Random",
        on connection: PostgreSQLConnection
        ) throws -> App.Category {
        //Category 생성. default 값을 가지고 있기 때문에 빈 파라미터로 생성해도 된다.
        
        let category = Category(name: name)
        //Category 객체 생성
        
        return try category.save(on: connection).wait()
        //DB에 저장
    }
}
