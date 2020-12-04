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
//: ## try* operators
example(of: "tryMap") {
    enum NameError: Error { //오류 유형을 정의한다.
        case tooShort(String)
        case unknown
    }
    
    let names = ["Scott", "Marin", "Shai", "Florent"].publisher
    //4개의 다른 문자열을 내보내는 publisher를 생성한다.
    
    names
//        .map { value in //각 문자열의 길이를 매핑한다.
//            return value.count
//        }
        .tryMap { value -> Int in // tryMap이 아닌 일반 map을 사용하면 오류가 발생한다.
            //내부에서 오류를 발생 시키려면 tryMap을 사용해야 한다.
            let length = value.count
            
            guard length >= 5 else {
                throw NameError.tooShort(value)
            }
            
            return value.count
        }
        .sink(receiveCompletion: { print("Completed with \($0)") },
              receiveValue: { print("Got value: \($0)") })
        .store(in: &subscriptions) //저장
}
//: [Next](@next)
