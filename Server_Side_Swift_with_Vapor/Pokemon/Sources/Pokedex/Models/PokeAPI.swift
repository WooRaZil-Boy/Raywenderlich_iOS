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

import Vapor

/// A simple wrapper around the "pokeapi.co" API.
public final class PokeAPI {
  /// The HTTP client powering this API.
  let client: Client
  let cache: KeyedCache //캐시를 저장
  
  /// Creates a new `PokeAPI` wrapper from the supplied client and cache.
  public init(client: Client, cache: KeyedCache) {
    self.client = client
    self.cache = cache
  }
  
  /// Returns `true` if the supplied Pokemon name is real.
  ///
  /// - parameter client: Queries the "pokeapi.co" API to verify supplied names
  /// - parameter cache: Caches client results to minimize slow, external API calls
  public func verifyName(_ name: String, on worker: Worker) throws -> Future<Bool> {
    /// Query the PokeAPI.
    //HTTP 클라이언트를 둘러싼 wrapper. PokeAPI 보다 편리하게 쿼리할 수 있게 해 준다.

//    return self.fetchPokemon(named: name).map { res in
//      //들어온 pokemon 의 name을 확인한다.
//      switch res.http.status.code {
//      case 200..<300:
//        /// The API returned 2xx which means this is a real Pokemon name
//        //실제로 존재하는 pokemon의 name인 경우
//        return true
//      case 404:
//        /// The API returned a 404 meaning this Pokemon name was not found.
//        return false
//      default:
//        /// The API returned a 500. Only thing we can do is forward the error.
//        throw Abort(.internalServerError, reason: "Unexpected PokeAPI response: \(res.http.status)")
//      }
//    }
    
    let key = name.lowercased() //name을 소문자로 바꿔 캐시 키를 만든다.
    
    return cache.get(key, as: Bool.self).flatMap { result in //캐시에 쿼리하려는 결과가 있는지 확인한다.
        if let exists = result { //캐시에 쿼리한 결과가 있다면
            return worker.eventLoop.newSucceededFuture(result: exists) //해당 결과를 반환한다.
            //fetchPokemon(:)를 호출하지 않는다.
        }
        
        return self.fetchPokemon(named: name).flatMap { res in //캐시에 쿼리하려는 결과가 없는 경우
            switch res.http.status.code {
            case 200..<300: //실제로 존재하는 pokemon의 name인 경우
                /// The API returned 2xx which means this is a real Pokemon name
                //실제로 존재하는 pokemon의 name인 경우
                return self.cache.set(key, to: true).transform(to: true) //캐시에 저장
            case 404:
                /// The API returned a 404 meaning this Pokemon name was not found.
                return self.cache.set(key, to: false).transform(to: false) //캐시에 저장
            default:
                /// The API returned a 500. Only thing we can do is forward the error.
                let reason = "Unexpected PokeAPI response: \(res.http.status)"
                throw Abort(.internalServerError, reason: reason)
            }
        }
    }
    
    //cache를 사용하도록 바꾼다.
  }
  
  /// Fetches a pokemen with the supplied name from the PokeAPI.
  public func fetchPokemon(named name: String) -> Future<Response> {
    return client.get("https://pokeapi.co/api/v2/pokemon/\(name)")
    //pokeapi.co 라는 외부 API에 request를 보내고 pokemon 데이터를 반환받는다.
    //존재하지 않는 pokemon name인 경우 404 response를 반환한다.
    //GET을 사용하는 local에 비해 속도가 매우 느리다.
  }
}

/// Allow our custom PokeAPI wrapper to be used as a Vapor service.
extension PokeAPI: ServiceType {
  /// See `ServiceType.makeService(for:)`
  public static func makeService(for container: Container) throws -> PokeAPI {
    /// Use the container to create the Client services our PokeAPI wrapper needs.
    return try PokeAPI(client: container.make(), cache: container.make())
  }
}




//Creating a KeyedCache

