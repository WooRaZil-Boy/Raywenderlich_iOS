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
  /// Register providers
  try services.register(FluentSQLiteProvider())
  
  /// Register routes to the router
  let router = EngineRouter.default()
  try routes(router)
  services.register(router, as: Router.self)
  
  /// Register our custom PokeAPI wrapper
  services.register(PokeAPI.self)
  
  /// Setup a simple in-memory SQLite database
  var databases = DatabasesConfig()
  let sqlite = try SQLiteDatabase(storage: .memory)
  databases.add(database: sqlite, as: .sqlite)
  services.register(databases)
  
  /// Configure migrations
  var migrations = MigrationConfig()
  /// Ensure there is a table ready to store the Pokemon
  migrations.add(model: Pokemon.self, database: .sqlite)
  migrations.prepareCache(for: .sqlite) //cache
  //DB에서 모델을 설정하기 위해 마이그레이션 해야하는 것처럼 Fluent가 캐시 데이터를 저장하기 위한 기본 DB 스키마를 구성하도록 허용 해야한다.
  services.register(migrations)
    
  config.prefer(SQLiteCache.self, for: KeyedCache.self)
  //Vapor 응용 프로그램의 KeyedCache로 SQLite를 사용하도록 한다.
}
