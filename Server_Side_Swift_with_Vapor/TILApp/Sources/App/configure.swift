import FluentSQLite
import Vapor

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    /// Register providers first
    try services.register(FluentSQLiteProvider())
    
    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)
    
    /// Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    /// middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)
    
    // Configure a SQLite database
    let sqlite = try SQLiteDatabase(storage: .memory)
    
    /// Register the configured SQLite database to the database config.
    var databases = DatabasesConfig()
    databases.add(database: sqlite, as: .sqlite)
    services.register(databases)
    
    /// Configure migrations
    var migrations = MigrationConfig()
    //    migrations.add(model: Todo.self, database: .sqlite)
    //default 모델 마이그레이션
    
    migrations.add(model: Acronym.self, database: .sqlite) //마이그레이션 추가
    //Fluent는 단일 응용 프로그램에서 여러 DB를 혼합해 각 모델의 보유하는 DB를 지정한다.
    //마이그레이션은 한 번만 실행된다.
    //마이그레이션이 성공적으로 되면, 실행 시 콘솔창에 로그가 표시된다.
    services.register(migrations)
    
}
