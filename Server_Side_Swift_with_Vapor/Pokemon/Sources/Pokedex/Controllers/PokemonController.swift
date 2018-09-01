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

/// Controllers querying and storing new Pokedex entries.
final class PokemonController {
  /// Lists all known pokemon in our pokedex.
  func index(_ req: Request) throws -> Future<[Pokemon]> {
    return Pokemon.query(on: req).all()
  }
  
  /// Stores a newly discovered pokemon in our pokedex.
  func create(_ req: Request, _ newPokemon: Pokemon) throws -> Future<Pokemon> {
    /// Check to see if the pokemon already exists
    return Pokemon.query(on: req).filter(\.name == newPokemon.name).count().flatMap { count -> Future<Bool> in
      /// Ensure number of Pokemon with the same name is zero
      guard count == 0 else {
        throw Abort(.badRequest, reason: "You already caught \(newPokemon.name).")
      }
      
      /// Check if the pokemon is real. This will throw an error aborting
      /// the request if the pokemon is not real.
      return try req.make(PokeAPI.self).verifyName(newPokemon.name, on: req)
      }.flatMap { nameVerified -> Future<Pokemon> in
        /// Ensure the name verification returned true, or throw an error
        guard nameVerified else {
          throw Abort(.badRequest, reason: "Invalid Pokemon \(newPokemon.name).")
        }
        
        /// Save the new Pokemon
        return newPokemon.save(on: req)
    }
  }
}



//캐시는 느린 프로세스를 빠르게 하는 방법이며, 웹 응응 프로그램을 빌드하는 동안 발생할 수 있는 느린 프로세스는 다음과 같다.
// • 대형 DB 쿼리
// • 외부 서비스 request(다른 API)
// • 복잡한 계산(ex. 큰 문서의 파싱)
//이런 느린 프로세스의 결과를 캐싱하면 앱의 속도가 빨라지고, response 속도가 향상된다.

//Cache storage
//DatabaseKit의 일부로 Vapor는 KeyedCache 프로토콜을 사용한다.
//이 프로토콜은 캐시 저장 방법에 대한 공통 인터페이스를 생성한다. 구조는 다음과 같다.

//public protocol KeyedCache {
//    func get<D>(_ key: String, as decodable: D.Type) -> Future<D?> where D: Decodable
//    //지정된 키의 캐시에서 저장된 데이터에 접근한다. 해당 키에 대한 데이터가 없으면 nil을 반환한다.
//    func set<E>(_ key: String, to encodable: E) -> Future<Void> where E: Encodable
//    //지정된 키의 캐시에 데이터를 저장한다. 이전 값이 있다면 덮어쓴다.
//    func remove(_ key: String) -> Future<Void>
//    //지정된 키의 캐시에서 데이터가 존재하는 경우 제거한다.
//}

//각 메서드는 캐시와 상호 작용이 비동기로 발생할 수 있으므로 Future를 반환한다.

//In-memory caches
//Vapor에서 MemoryKeyedCache 와 DictionaryKeyedCache 의 두 개의 메모리 키반 캐시가 제공된다.
//이러한 캐시는 프로그램의 실행 메모리에 데이터를 저장한다. 따라서 외부 종속성이 없기 때문에 두 캐시 모두 개발 및 테스트에 적합하다.
//그러나 응용 프로그램이 다시 시작될 때 저장한 캐시가 지워지고, 응용 프로그램의 여러 인스턴스 간에 공유할 수 없기 때문에 모든 용도에 완벽하지 않다.
//MemoryKeyedCache 와 DictionaryKeyedCache 의 차이점은 그리 크지 않다.

// • Memory cache
//MemoryKeyedCache의 내용은 모든 응용 프로그램의 이벤트 루프에서 공유된다.
//즉, 캐시에 항목이 저장되면 나중에 모든 request에 할당된 이벤트 루프에 관계없이 동일한 항목이 표시된다.
//하지만, 이 캐시는 thread safe 하지 않으므로, 동기화 된 액세스가 필요하다.
//따라서 MemoryKeyedCache는 릴리즈된 프로덕션 시스템에서 사용하기는 적합하지 않다.

// • Dictionary cache
//DictionaryKeyedCache의 내용으 각 이벤트 루프에 대해 local이다.
//즉, 다른 이벤트 루프에 할당 된 후속 request에 캐시된 다른 데이터가 표시될 수 있다.
//performance-based 같은 성능 기반 캐싱에 적합하지만, 세션 저장과 같은 용도로 DictionaryKeyedCache를 사용하는 경우 문제가 생길 수 있다.
//DictionaryKeyedCache 는 이벤트 루프 간에 메모리를 공유하지 않기 때문에 릴리즈된 프로덕션 시스템에서 사용하기는 적합하다.

//Database caches
//모든 DatabaseKit 기반 캐시는 구성된 DB를 캐시 저장소로 사용하여 지원한다.
//Vapor의 Fluent 매핑(FluentPostgreSQL, FluentMySQL 등) 및 데이터베이스 드라이버(PostgreSQL, MySQL, Redis 등)가 모두 포함된다.
//캐시된 데이터를 재 시작 시에도 유지하고, 응용 프로그램의 여러 인스턴스 간에 공유 할 수 있게 하려면 DB에 저장하는 것이 좋다.
//애플리케이션에 이미 DB가 구성되어 있다면 쉽게 설정할 수 있다.
//응용 프로그램의 기본 DB를 캐싱에 사용하거나 별도의 특수 DB를 사용할 수 있다.
//ex. 캐시에는 Redis DB를 사용하는 것이 일반적이다.

// • Redis
//Redis는 오픈 소스 캐시 Storage 서비스이다. 일반적으로 웹 응용 프로그램의 캐시 DB로 사용되며, Vapor Cloud, Heroku 등 대부분의 Deploy 서비스에서 지원된다.
//Redis DB는 구성하기 매우 쉽고 응용 프로그램을 다시 시작할 때 캐시 된 데이터를 유지하고 응용 프로그램의 여러 인스턴스 간에 캐시를 공유할 수 있다.




//API request에서 지연이 자주 발생한다. 통신하는 API 자체가 느릴 수 있고, 외부 API는 일정 시간 동안 사용자가 request할 수 있는 수와 속도에 제한을 주기도 한다.
//캐싱을 사용하면 이런 외부 API쿼리의 결과를 local에 저장하여 API를 훨씬 빠르게 사용할 수 있다.
