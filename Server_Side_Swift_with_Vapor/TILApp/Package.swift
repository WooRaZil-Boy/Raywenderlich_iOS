// swift-tools-version:4.0
import PackageDescription

//let package = Package(
//    name: "TILApp",
//    dependencies: [
//        // 💧 A server-side Swift web framework.
//        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),
//
//        // 🔵 Swift ORM (queries, models, relations, etc) built on SQLite 3.
//        .package(url: "https://github.com/vapor/fluent-sqlite.git", from: "3.0.0")
//    ],
//    targets: [
//        .target(name: "App", dependencies: ["FluentSQLite", "Vapor"]),
//        .target(name: "Run", dependencies: ["App"]),
//        .testTarget(name: "AppTests", dependencies: ["App"])
//    ]
//)
//Default 패키지 //SQLite

//let package = Package(
//    name: "TILApp",
//    dependencies: [
//        .package(url: "https://github.com/vapor/vapor.git",
//                 from: "3.0.0"),
//        .package(url: "https://github.com/vapor/fluent-mysql.git",
//                 from: "3.0.0-rc"),
//        //FluentMySQL dependency 추가
//        ],
//    targets: [
//        .target(name: "App", dependencies: ["FluentMySQL",
//                                            "Vapor"]),
//        .target(name: "Run", dependencies: ["App"]),
//        .testTarget(name: "AppTests", dependencies: ["App"]),
//        //App target이 FluentMySQL의 dependency 링크가 바르게 연결되도록 지정
//    ]
//)
//MySQL 패키지

let package = Package(
    name: "TILApp",
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git",
                 from: "3.0.0"),
        .package(url: "https://github.com/vapor/fluent-postgresql.git",
                 from: "1.0.0-rc"),
        //FluentPostgreSQL dependency 추가
        .package(url: "https://github.com/vapor/leaf.git",
                 from: "3.0.0-rc"),
        //Leaf dependency 추가
        .package(url: "https://github.com/vapor/auth.git",
                 from: "2.0.0-rc"),
        //auth dependency 추가
        .package(url: "https://github.com/vapor-community/Imperial.git",
                 from: "0.7.1")
        //Imperial dependency 추가(OAuth2.0)
        ],
    targets: [
        .target(name: "App", dependencies: ["FluentPostgreSQL",
                                            "Vapor",
                                            "Leaf",
                                            "Authentication",
                                            "Imperial"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"]), //테스트
        //App target이 FluentPostgreSQL의 dependency 링크가 바르게 연결되도록 지정
    ]
)
//PostgreSQL 패키지
