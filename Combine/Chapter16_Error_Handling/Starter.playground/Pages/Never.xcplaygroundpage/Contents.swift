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

var subscriptions = Set<AnyCancellable>()
//: ## Never
example(of: "Never sink") {
    Just("Hello")
        .sink(receiveValue: { print($0) })
        //Never 에서만 사용할 수 있는 sink의 변형. receiveCompletion 없이 값만 처리할 수 있다.
        .store(in: &subscriptions)
}

enum MyError: Error {
    case ohNo
}

example(of: "setFailureType") {
    Just("Hello")
        .setFailureType(to: MyError.self) //실패 유형을 지정
        .sink(receiveCompletion: { completion in //완료 이벤트 처리
            switch completion {
            case .failure(.ohNo):
                //failure 유형은 MyError이며, 특정 오류 처리를 위해 .failure(.ohNo)를 사용할 수 있다.
                print("Finished with Oh No!")
            case .finished:
                print("Finished successfully!")
            }
        }, receiveValue: { value in
            print("Got value: \(value)")
        }) //publisher는 failure로 완료될 수 있으므로 더 이상 sink(receiveValue:)를 사용할 수 없다.
        .store(in: &subscriptions)
}

example(of: "assign") {
    class Person { //Person 클래스 정의
        let id = UUID()
        var name = "Unknown"
    }
    
    let person = Person() //인스턴스 생성
    print("1", person.name) //name 출력
    
    Just("Shai") //Publisher<String, Never> 유형
//        .setFailureType(to: Error.self) //추가 //Publisher<String, Error> 유형이 된다.
        .handleEvents(receiveCompletion: { _ in print("2", person.name) })
        //완료 이벤트를 내보낼 때, name을 다시 출력한다.
        .assign(to: \.name, on: person) //publisher가 내보낸 값을 해당 인스턴스(person)의 속성(name)에 할당한다.
        .store(in: &subscriptions) //저장
}

example(of: "assertNoFailure") {
    Just("Hello") //Just로 오류 없는 publisher를 만든다. //Publisher<String, Never>
        .setFailureType(to: MyError.self) //failure 유형을 MyError으로 설정해 준다. //Publisher<String, Error>
//        .tryMap { _ in throw MyError.ohNo } //추가 //오류를 발생시킨다.
        .assertNoFailure() //failure 이벤트로 완료되면, fatalError로 crash된다.
        //이를 사용하면, publisher의 failure 유형이 다시 Never로 변경된다. //Publisher<String, Never>
        .sink(receiveValue: { print("Got value: \($0) ") }) //수신되 값을 출력한다.
        //assertNoFailure를 사용하여 Publisher<String, Never>으로 다시 변경되었으므로 sink(receiveValue:)를 사용할 수 있다.
        .store(in: &subscriptions) //저장
}
//: [Next](@next)


