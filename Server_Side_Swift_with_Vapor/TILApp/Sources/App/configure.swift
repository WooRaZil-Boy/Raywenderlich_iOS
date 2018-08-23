//import FluentMySQL //FluentMySQL
import FluentPostgreSQL //FluentPostgreSQL
import Vapor

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    /// Register providers first
//    try services.register(FluentSQLiteProvider())
    //FluentSQLiteProvider를 응용 프로그램이 Fluent를 통해 SQLite와 상호작용할 수 있도록 등록한다.
    
//    try services.register(FluentMySQLProvider())
//    //FluentMySQLProvider를 등록한다.
    
    try services.register(FluentPostgreSQLProvider())
    //FluentPostgreSQLProvider를 등록한다.
    
    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)
    
    /// Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    /// middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)
    
//    // Configure a SQLite database
//    let sqlite = try SQLiteDatabase(storage: .memory)
//    //.memory 저장소를 사용한다. 이렇게 설정하면, DB가 메모리에 상주하고, 디스크에 저장되지 않는다.
//    //따라서 응용 프로그램이 종료될 때 사라진다.
//
//    /// Register the configured SQLite database to the database config.
//    var databases = DatabasesConfig()
//    databases.add(database: sqlite, as: .sqlite)
//    services.register(databases)
//    //응용 프로그램 전체에서 .sqlite로 식별되는 SQLiteDatabase의 인스턴스를 등록하는 DatabasesConfig 타입을 생성한다.
    
//    let database = SQLiteDatabase(storage: .file(path: "db.sqlite")
//    try databases.add(database: database), as: .sqlite)
    //SQLite를 사용해 디스크에 저장하길 원한다면, 이런식으로 작성하면 된다.
    //파일이 없으면 지정된 경로에 DB파일을 작성한다.
    
//    // Configure a MySQL database
//    var databases = DatabasesConfig()
//    let databaseConfig = MySQLDatabaseConfig(hostname: "localhost",
//                                             username: "vapor",
//                                             password: "password",
//                                             database: "vapor")
//    let database = MySQLDatabase(config: databaseConfig)
//    databases.add(database: database, as: .mysql)
//    services.register(databases)
//    //default에서 사용하던 SQLite 대신 MySQL을 사용한다.
//    //Docker에서 지정한 값과 동일하게 MySQL을 구성한다.
    
    // Configure a PostgreSQL database
    var databases = DatabasesConfig() //DatabasesConfig로 데이터베이스를 구성한다.
//    let databaseConfig = PostgreSQLDatabaseConfig(hostname: "localhost",
//                                             username: "vapor",
//                                             database: "vapor",
//                                             password: "password")
//    //local에서 사용 시. 하드코딩
    
    let hostname = Environment.get("DATABASE_HOSTNAME") ?? "localhost"
    let username = Environment.get("DATABASE_USER") ?? "vapor"

    let databaseName: String
    let databasePort: Int
    if (env == .testing) { //테스팅 중에는 실행 DB 이름과 포트를 다른 값으로 설정한다.
        databaseName = "vapor-test"
        
        if let testPort = Environment.get("DATABASE_PORT") {
            //DB 포트를 테스트용 환경 변수로 설정한다(Linux docker-compose.yml의 포트를 가져온다).
            databasePort = Int(testPort) ?? 5433
        } else {
           databasePort = 5433
        }

    } else { //실제 응용 프로그램 실행. 테스팅과는 DB 이름과 포트를 다른 값으로 설정한다.
        databaseName = Environment.get("DATABASE_DB") ?? "vapor"
        databasePort = 5432
    }
    
    let password = Environment.get("DATABASE_PASSWORD") ?? "password"
    //Environment.get(_ :)로 Vapor Cloud가 설정한 환경 변수를 가져올 수 있다.
    //nil을 반환하면 로컬에서 실행되는 경우이므로, 기본값으로 사용한다.
    
    let databaseConfig = PostgreSQLDatabaseConfig(
        hostname: hostname,
        port: databasePort, //포트 구성
        username: username,
        database: databaseName,
        password: password)
    //vapor cloud 사용 시에는 런타임 시의 환경 변수 값으로 바꿔줘야 한다.
    
    let database = PostgreSQLDatabase(config: databaseConfig) //PostgreSQLDatabase 생성
    databases.add(database: database, as: .psql) //.psql 식별자 사용하여 DB 객체를 DatabasesConfig에 추가
    services.register(databases) //서비스에 등록
    //SQLite이나 MySQL 대신 PostgreSQL을 사용한다.
    //Docker에서 지정한 값과 동일하게 PostgreSQL을 구성한다.
    
    /// Configure migrations
    var migrations = MigrationConfig()
    //    migrations.add(model: Todo.self, database: .sqlite)
    //default 모델 마이그레이션
    
//    //SQLite
//    migrations.add(model: Acronym.self, database: .sqlite) //마이그레이션 추가
//    //Fluent는 단일 응용 프로그램에서 여러 DB를 혼합해 각 모델의 보유하는 DB를 지정한다.
//    //마이그레이션은 한 번만 실행된다.
//    //마이그레이션이 성공적으로 되면, 실행 시 콘솔창에 로그가 표시된다.
//    services.register(migrations)
//    //각 모델에 사용할 DB를 응용 프로그램에 알려주는 MigrationConfig 타입을 생성한다.
    
//    //MySQL
//    migrations.add(model: Acronym.self, database: .mysql) //MySQL DB를 지정해 준다.
//    services.register(migrations)
    
    //PostgreSQL
    migrations.add(model: User.self, database: .psql) //User 모델 추가
    //Acronym의 userID 속성이 User의 id에 연결하기 때문에 User 테이블을 먼저 생성해야 한다.
    migrations.add(model: Acronym.self, database: .psql) //PostgreSQL DB를 지정해 준다. //Acronym 모델 추기
    migrations.add(model: Category.self, database: .psql) //Category 모델 추가
    migrations.add(model: AcronymCategoryPivot.self, database: .psql) //AcronymCategoryPivot 모델 추가
    services.register(migrations)
    
    
    
    
    //Reset database
    var commandConfig = CommandConfig.default() //기본 구성으로 CommandConfig를 생성
    commandConfig.useFluentCommands() //Fluent 명령을 CommandConfig에 추가한다.
    //이를 추가하면, id 되돌리기가 있는 revert 명령과 식별자 migrate가 있는 migrate 명령이 모두 추가된다.
    services.register(commandConfig) //commandConfig를 서비스에 등록
    //Local에서 DB를 삭제한 경우, Vapor Cloud에도 반영을 해주기 위한 코드. p.142
    
}

//DB와의 연결 및 초기화 설정은 configure에서 한다.

//SQLite
//Vapor Toolbox에서 제공하는 기본 템플릿은 SQLite를 DB로 사용한다. p.82
//어떻게 사용되는지 알고 싶으면, Package.swift를 보면 된다.

//MySQL
//MySQL로 테스트하려면 Docker 컨테이너에서 MySQL 서버를 실행한다. p.84
//터미널에서 docker ps 명령어로, 모든 활성 컨테이너를 확인할 수 있다.

//PostgreSQL
//PostgreSQL로 테스트하려면 Docker 컨테이너에서 Postgres 서버를 실행한다. p.87
//터미널에서 docker ps 명령어로, 모든 활성 컨테이너를 확인할 수 있다.




//Deploying to Vapor Cloud

//Database setup
//Cloud를 사용하려면 PostgreSQLDatabaseConfig 타입을 하드코딩하지 않고, 런타임에 DB정보에 대한 환경 변수를 설정한다.

//Deploying
//Docker를 로컬 또는 Vapor Cloud와 함께 사용하도록 응용 프로그램을 구성하고 배포를 해야 한다.
//위의 DB 설정을 완료하고, Git 커밋 푸시 후, vapor cloud deploy 로 deploy한다.
//여기서 DB를 추가를 물을 시 y를 선택해 주고 설정한 DB를 고르면 된다.
//여기서는 이전과 달리 update하는 것이므로 build 유형은 update를 선택하면 된다.
