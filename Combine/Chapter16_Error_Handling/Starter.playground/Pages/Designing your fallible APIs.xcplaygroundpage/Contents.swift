/// Copyright (c) 2019 Razeware LLC
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

//: [Previous](@previous)
import Foundation
import Combine

var subscriptions = Set<AnyCancellable>()
//: ## Designing your fallible APIs
example(of: "Joke API") {
    class DadJokes {
        struct Joke: Codable { //Joke 구조체
            let id: String
            let joke: String
        } //API response는 Joke 인스턴스로 디코딩된다.
        
        enum Error: Swift.Error, CustomStringConvertible { //DadJokes에서 발생할 수 있는 모든 가능한 오류
            case network
            case jokeDoesntExist(id: String)
            case parsing
            case unknown
            
            var description: String { //CustomStringConvertible를 구현한다.
                //각 오류 case에 대한 상세한 설명을 제공한다.
                switch self {
                case .network:
                    return "Request to API Server failed"
                case .parsing:
                    return "Failed parsing response from server"
                case .jokeDoesntExist(let id):
                    return "Joke with ID \(id) doesn't exist"
                case .unknown:
                      return "An unknown error occurred"
                }
            }
        }
        
        func getJoke(id: String) -> AnyPublisher<Joke, Error> { //반환하는 Publisher의 타입은 <Joke, Error>
            guard id.rangeOfCharacter(from: .letters) != nil else { //모든 joke id는 숫자와 문자로 되어 있다.
                //따라서 최소한 한 개 이상의 문자가 포함되어야 한다.
                return Fail<Joke, Error>(error: .jokeDoesntExist(id: id))
                        .eraseToAnyPublisher()
            }
            
            let url = URL(string: "https://icanhazdadjoke.com/j/\(id)")!
            var request = URLRequest(url: url)
            request.allHTTPHeaderFields = ["Accept": "application/json"]
            
            return URLSession.shared
                .dataTaskPublisher(for: request) //API 호출
//                .map(\.data) //매핑
                .tryMap { data, _ -> Data in //추가 유효성 검사를 시행한다.
                    guard let obj = try? JSONSerialization.jsonObject(with: data),
                        let dict = obj as? [String: Any],
                        dict["status"] as? Int == 404 else {
                        //JSONSerialization을 사용하여, status 필드가 존재하는지 확인하고 이 값이 404인지 확인한다.
                        return data
                        //해당 농담이 존재한다면(404가 아닌 경우), 단순히 decode 연산자에 다운 스트림하도록 반환하기만 하면 된다.
                    }
                    
                    throw DadJokes.Error.jokeDoesntExist(id: id)
                    //404 상태 코드가 있다면, .jokeDesntExist(id:) 오류를 발생시킨다.
                }
                .decode(type: Joke.self, decoder: JSONDecoder()) //디코딩
                .mapError { error -> DadJokes.Error in
                    switch error {
                    case is URLError:
                        return .network
                    case is DecodingError:
                        return .parsing
                    default:
//                        return .unknown
                        return error as? DadJokes.Error ?? .unknown //세부적으로 수정해 준다.
                    }
                }
                .eraseToAnyPublisher()
        }
    }
    
    let api = DadJokes() //DaddJokes 인스턴스 생성
    let jokeID = "9prWnjyImyd" //유효한 농담 id
    let badJokeID = "123456" //잘못된 농담 id
    
    api
        .getJoke(id: jokeID) //유효한 농담 id로 DadJokes.getJoke(id:)를 호출한다.
//        .getJoke(id: badJokeID) //유효하지 않은 농담 id //오류가 발생한다.
        .sink(receiveCompletion: { print($0) },
              receiveValue: { print("Got joke: \($0)") })
        .store(in: &subscriptions) //저장
}
//: [Next](@next)
