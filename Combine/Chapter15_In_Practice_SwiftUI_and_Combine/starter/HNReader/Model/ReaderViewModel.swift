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
import Combine
import SwiftUI

class ReaderViewModel: ObservableObject {
  private let api = API()
    @Published private var allStories = [Story]() //@Published 래퍼 추가
    //상태가 변할때 값이 자동으로 방출된다.
    
//    private var allStories = [Story]() {
//        didSet { //제대로 작동하는지 확인하기 위한 임시 코드
//            print(allStories.count)
//        }
//    }
    private var subscriptions = Set<AnyCancellable>() //구독을 저장해서 메모리 관리

  @Published var filter = [String]() //@Published 래퍼 추가
    //상태가 변할때 값이 자동으로 방출된다.
  
  var stories: [Story] {
    guard !filter.isEmpty else {
      return allStories
    }
    return allStories
      .filter { story -> Bool in
        return filter.reduce(false) { isMatch, keyword -> Bool in
          return isMatch || story.title.lowercased().contains(keyword)
        }
      }
  }
  
  @Published var error: API.Error? = nil //@Published 래퍼 추가
    //상태가 변할때 값이 자동으로 방출된다.
    
    func fetchStories() {
        api
            .stories()
            .receive(on: DispatchQueue.main) //해당 큐 사용
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    self.error = error
                }
            }, receiveValue: { stories in
                self.allStories = stories
                self.error = nil
            })
            .store(in: &subscriptions) //저장
        
    }
}
