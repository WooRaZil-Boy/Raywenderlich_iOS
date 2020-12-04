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
//:## Mapping errors
example(of: "map vs tryMap") {
    enum NameError: Error { //오류 유형 정의
        case tooShort(String)
        case unknown
    }
    
    Just("Hello") //"Hello" 문자열을 내보내는 Just 생성
        .setFailureType(to: NameError.self) //failure 유형 설정
//        .map { $0 + " World!" } //map을 사용해 문자열 추가
//        .tryMap { $0 + " World!" }
//        //tryMap을 사용하면, 특정 NameError 유형이 아닌 Swift의 일반 Error 유형이 된다.
        .tryMap { throw NameError.tooShort($0) } //수정 //try* 연산자는 error를 발생 시킬 수 있다.
        .mapError { $0 as? NameError ?? .unknown } //추가
        //tryMap을 사용하면 error를 발생시킬 수 있지만, error 유형이 기본 Error로 지워진다.
        //mapError을 사용해 다시 error 유형을 매핑해 줄 수 있다.
        //반드시 fallback error를 지정해 줘야 한다. Publisher<String, NameError> 로 된다.
        .sink(receiveCompletion: { completion in
            switch completion { //모든 failure 사례에서 적합한 메시지를 출력한다.
            case .finished:
                print("Done!")
            case .failure(.tooShort(let name)):
                print("\(name) is too short!")
            case .failure(.unknown):
                print("An unknown name error occurred")
            }
        }, receiveValue: { print("Got value \($0)") })
        .store(in: &subscriptions) //저장
}
//: [Next](@next)


