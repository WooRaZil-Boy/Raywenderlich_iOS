import FluentPostgreSQL
import Vapor

struct MakeCategoriesUnique: Migration {
    //카테고리 생성시 중복되지 않도록 하는 마이그레이션.
    typealias Database = PostgreSQLDatabase //Migration에서 사용할 DB 유형 정의
    
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        //Migration 시 DB 변경 사항
        return Database.update(Category.self, on: connection) { builder in
            //Category 모델은 이미 DB에 있으므로 update 한다.
            builder.unique(on: \.name)
            //업데이트는 클로저 내에서 이뤄진다. name 필드에 고유한 index를 추가한다.
        }
    }
    
    static func revert(on connection: PostgreSQLConnection) -> Future<Void> {
        //prepare(on:)에서 했던 일을 취소해야 할 때
        return Database.update(Category.self, on: connection) { builder in
            //기존 Category 모델을 수정하기 때문에 update 한다.
            builder.deleteUnique(from: \.name)
            //업데이트는 클로저 내에서 이뤄진다. name 필드에 고유한 index를 제거한다.
        }
    }
}

//Making categories unique
//카테고리를 생성할 때 중복된 카테고리명이면 생성되지 않도록 마이그레이션 한다.

//Bulder를 Run 할 때 마이그레이션이 제대로 됐는지 콘솔 창에서 확인할 수 있다.
