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

import Foundation
import PlaygroundSupport
import Combine

struct API {
  /// API Errors.
  enum Error: LocalizedError {
    case addressUnreachable(URL)
    case invalidResponse
    
    var errorDescription: String? {
      switch self {
      case .invalidResponse: return "The server responded with garbage."
      case .addressUnreachable(let url): return "\(url.absoluteString) is unreachable."
      }
    }
  }
  
  /// API endpoints.
  enum EndPoint {
    static let baseURL = URL(string: "https://hacker-news.firebaseio.com/v0/")!
    
    case stories
    case story(Int)
    
    var url: URL {
      switch self {
      case .stories:
        return EndPoint.baseURL.appendingPathComponent("newstories.json")
      case .story(let id):
        return EndPoint.baseURL.appendingPathComponent("item/\(id).json")
      }
    }
  }

  /// Maximum number of stories to fetch (reduce for lower API strain during development).
  var maxStories = 10

  /// A shared JSON decoder to use in calls.
  private let decoder = JSONDecoder()
    
    private let apiQueue = DispatchQueue(label: "API", qos: .default, attributes: .concurrent)
    //background queue
  
    func story(id: Int) -> AnyPublisher<Story, Error> {
        URLSession.shared
            .dataTaskPublisher(for: EndPoint.story(id).url)
            .receive(on: apiQueue) //큐 전환
            .map(\.data) //dataTaskPublisher는 (Data, URLResponse)를 반환한다. data만 필요하므로 매핑한다.
            .decode(type: Story.self, decoder: decoder) //디코딩
            .catch { _ in Empty<Story, Error>() } //오류 처리
            .eraseToAnyPublisher()
        
//        return Empty().eraseToAnyPublisher()
//        //Empty를 사용하면 즉시 완료된다. //코딩 시 오류 방지를 위한 임시 반환. 코드 완성 이후 제거한다.
    }
    
    func mergedStories(ids storyIDs: [Int]) -> AnyPublisher<Story, Error> {
        let storyIDs = Array(storyIDs.prefix(maxStories)) //maxStories 만큼만 id를 가져온다.
        
        precondition(!storyIDs.isEmpty) //해당 조건을 만족하지 않으면 오류를 발생 시킨다.
        
        let initialPublisher = story(id: storyIDs[0])
        //첫 번째 id로 해당 story 를 가져와 publisher를 만든다.
        let remainder = Array(storyIDs.dropFirst())
        //첫 번째 story를 제외하고 남은 story
        
        return remainder.reduce(initialPublisher) { combined, id in
            return combined
                .merge(with: story(id: id))
                .eraseToAnyPublisher()
        } //각 id에 대한 story를 가져와서 해당 publisher를 initialPublisher에 병합한다.
        //최종적으로 각 단일 story publisher가 가져온 story를 내보내고, 오류를 무시하는 publisher가 된다.
    }
    
    func stories() -> AnyPublisher<[Story], Error> {
        URLSession.shared
            .dataTaskPublisher(for: EndPoint.stories.url)
            .map(\.data) //dataTaskPublisher는 (Data, URLResponse)를 반환한다. data만 필요하므로 매핑한다.
            .decode(type: [Int].self, decoder: decoder) //디코딩
            .mapError { error -> API.Error in
                switch error {
                case is URLError: //endpoint 에서 해당 url에 접속할 수 없는 경우 오류
                    return Error.addressUnreachable(EndPoint.stories.url)
                default: //다른 오류
                    return Error.invalidResponse
                }
            }
            .filter { !$0.isEmpty } //리스트가 비었을 경우 필터링
            .flatMap { storyIDs in
                return self.mergedStories(ids: storyIDs)
            }
            .scan([]) { stories, story -> [Story] in
                return stories + [story] //값을 누적 시킨다.
            }
            .map { $0.sorted() } //정렬
            .eraseToAnyPublisher()
    }
}

let api = API()
var subscriptions = [AnyCancellable]() //메모리 해제를 위해 subscriptions을 저장해 두는 객체

//api.story(id: 1000)
//    .sink(receiveCompletion: { print($0) },
//          receiveValue: { print($0) })
//    .store(in: &subscriptions) //저장

//api.mergedStories(ids: [1000, 1001, 1002])
//    .sink(receiveCompletion: { print($0) },
//          receiveValue: { print($0) })
//    .store(in: &subscriptions) //저장

api.stories()
    .sink(receiveCompletion: { print($0) },
          receiveValue: { print($0) })
    .store(in: &subscriptions) //저장

// Run indefinitely.
PlaygroundPage.current.needsIndefiniteExecution = true
