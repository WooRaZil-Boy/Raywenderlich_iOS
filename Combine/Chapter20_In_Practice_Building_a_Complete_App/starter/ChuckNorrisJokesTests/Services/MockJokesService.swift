/// Copyright (c) 2020 Razeware LLC
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
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import Foundation
import Combine
@testable import ChuckNorrisJokesModel

struct MockJokesService: JokeServiceDataPublisher {
  let data: Data
  let error: URLError?
  
  init(data: Data, error: URLError? = nil) {
    self.data = data
    self.error = error
  }
  
  func publisher() -> AnyPublisher<Data, URLError> {
    let publisher = CurrentValueSubject<Data, URLError>(data)
    //mocked service의 data 속성으로 초기화된 URLError로,
    //Data 값을 내보내고 fail할 수 있는 mock publisher를 만든다.
    
    DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
      if let error = error {
        publisher.send(completion: .failure(error))
      } else {
        publisher.send(data)
      }
    }
    //오류를 보내거나 subject로 data 값을 보낸다.
    
    return publisher.eraseToAnyPublisher()
    //유형이 지워진(type-erased) publisher를 반환한다.
  }
}
