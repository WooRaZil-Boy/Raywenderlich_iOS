// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Game",
    platforms: //버전 정보를 입력해 준다.
    [.iOS(.v13), .macOS(.v10_15), .watchOS(.v6), .tvOS(.v13)],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "Game",
            targets: ["Game"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "Game",
            dependencies: []),
        .testTarget(
            name: "GameTests",
            dependencies: ["Game"]),
    ]
)

//Versioning your Game package
//Package.swift의 manifest 파일을 열어, 빌드 방법을 지정해 줘야 한다.
//버전 정보를 입력하지 않으면, Xcode는 코드가 새로운 OS에서 실행될 경우,
//@available 구문을 계속해서 추가한다.

//Linking your Game package library
//products 매개변수에서는 앱과 연결하는 라이브러리를 정의한다.
//해당 라이브러리를 앱과 연결하려면, iOS app target에서 Frameworks를 연다.
//Libraries and Embedded Content 세션에서 해당 프레임워크를 추가해 준다.
//WatchKit Extension target에서도 같은 작업을 해 준다.
