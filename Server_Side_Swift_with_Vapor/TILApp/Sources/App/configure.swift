//import FluentMySQL //FluentMySQL
import FluentPostgreSQL //FluentPostgreSQL
import Vapor
import Leaf
import Authentication

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    /// Register providers first
//    try services.register(FluentSQLiteProvider())
    //FluentSQLiteProvider를 응용 프로그램이 Fluent를 통해 SQLite와 상호작용할 수 있도록 등록한다.
    
//    try services.register(FluentMySQLProvider())
//    //FluentMySQLProvider를 등록한다.
    
    try services.register(FluentPostgreSQLProvider())
    //FluentPostgreSQLProvider를 등록한다.
    
    try services.register(LeafProvider())
    //LeafProvider를 등록한다.
    
    try services.register(AuthenticationProvider())
    //Authentication를 등록한다.
    
    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)
    
    /// Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    //대부분의 웹 사이트는 이미지 혹은 스타일 시티와 같은 정적 파일을 사용할 수 있어야 한다.
    //CDN, Nginx, Apache와 같은 서버를 사용하여 작업을 수행하지만, Vapor는 FileMiddleware로 파일을 제공한다.
    //FileMiddleware를 MiddlewareConfig에 추가하여, 파일을 제공한다.
    //기본적으로 프로젝트의 Public 디렉토리에 있는 파일을 제공한다.
    //ex. Public/styles/stylesheet.css 파일을 /styles/stylesheet.css 로 엑세스 할 수 있다.
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    middlewares.use(SessionsMiddleware.self) //Vapor는 미들웨어인 SessionsMiddleware를 사용하여 세션을 관리한다.
    //SessionsMiddleware가 응용 프로그램의 전역 미들웨어로 등록된다. 또한 모든 request에 대한 세션을 사용할 수 있다.
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
    
    let databaseConfig: PostgreSQLDatabaseConfig
    if let url = Environment.get("DATABASE_URL") { //Heroku
        databaseConfig = PostgreSQLDatabaseConfig(url: url)!
    } else { //Vapor, Local
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
        
        databaseConfig = PostgreSQLDatabaseConfig(
            hostname: hostname,
            port: databasePort, //포트 구성
            username: username,
            database: databaseName,
            password: password)
        //vapor cloud 사용 시에는 런타임 시의 환경 변수 값으로 바꿔줘야 한다.
    }
    
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
    migrations.add(model: Token.self, database: .psql) //Token 모델 추가
    
    switch env {
    case .development, .testing: //개발이거나 테스트 환경인 경우에만
        migrations.add(migration: AdminUser.self, database: .psql) //AdminUser 추가. default User 가 생성된다.
    //여기선 full model이 아니므로 add(model:database:) 대신 add(migration:database:) 를 사용한다.
    default: //일반적으로 출시된 Product라면 기본 사용자 없이, 새 사용자를 Register 해서 사용해야 한다.
        break
    }
    
    migrations.add(migration: AddTwitterURLToUser.self, database: .psql) //AddTwitterURLToUser 추가
    //Migration은 순서대로 진행되므로 기존 마이그레이션 이후에 호출되어야 한다.
    //User에 새로운 속성이 추가된다. full model이 아니므로 add(model:database:) 대신 add(migration:database:) 를 사용한다.
    migrations.add(migration: MakeCategoriesUnique.self, database: .psql) //MakeCategoriesUnique 추가
    services.register(migrations) //Vapor가 응용 프로그램이 시작될 때 해당 모델의 테이블을 생성한다.
    
    
    
    
    //Reset database
    var commandConfig = CommandConfig.default() //기본 구성으로 CommandConfig를 생성
    commandConfig.useFluentCommands() //Fluent 명령을 CommandConfig에 추가한다.
    //이를 추가하면, id 되돌리기가 있는 revert 명령과 식별자 migrate가 있는 migrate 명령이 모두 추가된다.
    services.register(commandConfig) //commandConfig를 서비스에 등록
    //Local에서 DB를 삭제한 경우, Vapor Cloud에도 반영을 해주기 위한 코드. p.142
    
    config.prefer(LeafRenderer.self, for: ViewRenderer.self)
    //ViewRenderer 유형을 요청할 때, Vapor가 LeafRenderer를 사용하도록 설정한다.
    //렌더러를 얻기 위해 일반적으로 req.view()를 사용하면 다른 템플릿 엔진으로 쉽게 전환할 수 있다.
    //req.view()에 Vapor에 ViewRenderer를 준수하는 유형을 사용해야 한다(WebsiteController).
    //Leaf가 빌드된 모듈인 TemplateKit은 PlaintextRenderer를 제공하고, Leaf는 LeafRenderer를 제공한다.
    
    
    
    
    //Web authentication
    config.prefer(MemoryKeyedCache.self, for: KeyedCache.self)
    //KeyedCache 서비스를 요청 받을 때 MemoryKeyedCache를 사용하도록 한다.
    //KeyedCache는 세션을 백업하는 key-value cache 이다.
    //KeyedCache의 구현은 여러 가지가 있다.
    
    //How it works
    //이전에 request header에 Token과 credential을 보내는 HTTP basic authentication과 bearer authentication를 사용해 API의 보안성을 높였다.
    //그러나 웹브라우저에서는 이런 방법이 불가능하다. 브라우저가 일반적인 HTML로 작성한 request에 header를 추가할 방법이 없기 때문이다.
    //이 문제를 해결하기 위해 브라우저와 웹 사이트에서는 cookie를 사용한다. 쿠키는 응용 프로그램이 사용자 컴퓨터에 저장하기 위해 브라우저로 전송하는 작은 데이터 비트이다.
    //(웹사이트에서 사용자 컴퓨터의 하드 디스크에 저장해 놓은 작은 파일로, 사용자가 해당 사이트를 다시 방문할 때 그 사이트에 알려주는 것이 주 용도. 신분증으로 생각하면 된다.)
    //사용자가 응용 프로그램에 request를 만들면, 브라우저가 사이트의 쿠키를 첨부한다. 이를 session과 결합하여 사용자를 인증한다.
    //세션을 통해 request 간에 상태를 유지할 수 있다. Vapor에서 세션을 사용하도록 설정하면, 응용 프로그램에서 고유한 ID로 쿠키를 사용자에게 제공한다.
    //이 ID는 사용자의 세션을 식별한다. 사용자가 로그인하면, Vapor는 사용자를 세션에 저장한다.
    //사용자가 로그인했는지 또는 현재 인증된 사용자를 얻고 있는지 확인해야 하는 경우 세션을 쿼리한다.
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




//Web authentication
//이전에 request header에 Token과 credential을 보내는 HTTP basic authentication과 bearer authentication를 사용해 API의 보안성을 높였다.
//그러나 웹브라우저에서는 이런 방법이 불가능하다. 브라우저가 일반적인 HTML로 작성한 request에 header를 추가할 방법이 없기 때문이다.
//이 문제를 해결하기 위해 브라우저와 웹 사이트에서는 cookie를 사용한다. 쿠키는 응용 프로그램이 사용자 컴퓨터에 저장하기 위해 브라우저로 전송하는 작은 데이터 비트이다.
//(웹사이트에서 사용자 컴퓨터의 하드 디스크에 저장해 놓은 작은 파일로, 사용자가 해당 사이트를 다시 방문할 때 그 사이트에 알려주는 것이 주 용도. 신분증으로 생각하면 된다.)
//사용자가 응용 프로그램에 request를 만들면, 브라우저가 사이트의 쿠키를 첨부한다. 이를 session과 결합하여 사용자를 인증한다.
//세션을 통해 request 간에 상태를 유지할 수 있다. Vapor에서 세션을 사용하도록 설정하면, 응용 프로그램에서 고유한 ID로 쿠키를 사용자에게 제공한다.
//이 ID는 사용자의 세션을 식별한다. 사용자가 로그인하면, Vapor는 사용자를 세션에 저장한다.
//사용자가 로그인했는지 또는 현재 인증된 사용자를 얻고 있는지 확인해야 하는 경우 세션을 쿼리한다.




//Setting up Heroku p.402
// brew install heroku/brew/heroku 로 CLI을 설치하고, heroku login 명령어로 로그인 한다.
// heroku auth:whoami 로 제대로 로그인 했는지 확인할 수 있다.

//Git
//Heroku는 앱을 deploy 하기 위해 Git을 사용해야 하기 때문에 프로젝트에 Git repository가 있어야 한다.
//git이 있는 지 확인 하려면 터미널에서 다음과 같이 입력해 보면 된다.
// git rev-parse --is-inside-work-tree
//true가 출력 되면 Git repository가 있는 것이다.

//Connect with Heroku
//heroku와 연결하기 하려면 $ heroku git:remote -a your-apps-name-here 를 입력해 Heroku에서 설정한 app name을 설정해 연결해 준다.
//Heroku 대시 보드에서 Deploy 탭을 클릭해 Existing Git repository 를 확인해 명령어를 확인해 볼 수 있다.




//Set Buildpack
//Heroku는 앱을 배포할 때 Buildpack라는 recipe를 제공한다.
//Vapor는 Vapor 앱 용 Buildpack이 있다. Buildpack을 설정하려면 터미널에서 다음 명령을 입력한다.
// heroku buildpacks:set https://github.com/vapor-community/heroku-buildpack

//Swift version file
//Buildpack 설정 후 Heroku에는 두 개의 configuration 파일이 필요하다.
//그 중 하나는 .swift-version 이다. Buildpack에서 프로젝트에 설치할 Swift 버전을 결정하는 데 사용된다.
// echo "4.1" > .swift-version

//Procfile
//Heroku에 앱을 빌드하고 나면 실행할 프로세스 유형과 실행 방법을 알아야 한다. 이를 위해 Procfile 이라는 파일을 사용한다.
// echo "web: Run serve --env production" \"--hostname 0.0.0.0 --port \$PORT" > Procfile

//Commit changes
//.swift-version 와 Procfile 를 추가했으므로 commit 해야 한다.

//Configure the database
//배포 전에 앱 내에서 DB를 구성해야 한다.
// heroku config
//그러면, 해당 프로젝트에 대한 프로비저닝 DB 정보를 출력한다. DATABASE_URL(환경 변수 이름)과 환경 변수의 값이 들어 있다(DB link).

//Configure Google environment variables
//Google 인증을 사용하고 있다면, 이전에서 한 것과 동일하게 하게 Goolge 환경 변수를 구성해 줘야 한다.

//heroku config:set \GOOGLE_CALLBACK_URL=https://<YOUR_HEROKU_URL>/oauth/google
//heroku config:set GOOGLE_CLIENT_ID=<YOUR_CLIENT_ID>
//heroku config:set GOOGLE_CLIENT_SECRET=<YOUR_CLIENT_SECRET>

//Deploy to Heroku
// git push heroku master 를 입력해 push한다.
//Heroku는 앱이 빌드되면 자동으로 시작한다. 터미널에서 heroku ps:scale web=1 를 입력해 시작할 수 도 있다.
//터미널에서 heroku open를 입력해 대시보드 탭을 바로 열 수 있다.

//Reverting your database
// heroku run Run -- revert --yes --env production 로 마지막 마이그레이션을 되돌릴 수 있다.
// heroku run Run -- revert --all --yes --env production 로 전체 DB를 되돌릴 수 있다.
// heroku run Run -- migrate --env production 로 마이그레이션을 할 수 있다.
