@testable import App
import FluentPostgreSQL

extension User {
    static func create(
        name: String = "Luke",
        username: String = "lukes",
        on connection: PostgreSQLConnection
        ) throws -> User {
        //사용자 생성. default 값을 가지고 있기 때문에 빈 파라미터로 생성해도 된다.
        
        let user = User(name: name, username: username)
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
