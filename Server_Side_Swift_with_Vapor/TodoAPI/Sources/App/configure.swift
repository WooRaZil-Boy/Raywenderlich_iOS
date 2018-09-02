/// Copyright (c) 2018 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import FluentSQLite
import Vapor

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
  // register providers
  try services.register(FluentSQLiteProvider())

  // register routes to the router
  let router = EngineRouter.default()
  try routes(router)
  services.register(router, as: Router.self)

  // register custom service types here
  services.register(LogMiddleware.self) //LogMiddleware 서비스 등록
  services.register(SecretMiddleware.self) //SecretMiddleware 서비스 등록

  // configure middleware
  var middleware = MiddlewareConfig()
  // register your custom middleware here
  //MiddlewareConfig를 사용해, 미들웨어를 등록해 통합할 수 있다.
  middleware.use(LogMiddleware.self)
  middleware.use(ErrorMiddleware.self)
    
  //미들웨어의 순서는 추가된 순서에 따른다. LogMiddleware가 ErrorMiddleware보다 먼저 추가되기 때문에 먼저 request를 받고, response는 마지막에 받는다.
  //따라서 LogMiddleware가 다른 미들웨어에서 수정하지 않은 클라이언트의 원본 request와 클라이언트에 나가기 직전 최종 response를 로깅할 수 있다.
  services.register(middleware)

  // configure sqlite db
  var databases = DatabasesConfig()
  let sqlite = try SQLiteDatabase(storage: .memory)
  databases.add(database: sqlite, as: .sqlite)
  services.register(databases)

  // configure migrations
  var migrations = MigrationConfig()
  migrations.add(model: Todo.self, database: .sqlite)
  services.register(migrations)

  // preferences
  config.prefer(ConsoleLogger.self, for: Logger.self)
}
