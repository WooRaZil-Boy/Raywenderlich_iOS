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




//Filtering basics
example(of: "filter") {
    let numbers = (1...10).publisher //1 ~ 10까지의 정수를 내보내고 완료하는 publisher
    //Sequence 타입에서 publisher 속성을 사용해 간단하게 publisher를 생성할 수 있다.
    
    numbers
//        .filter { $0.isMultiple(of: 3) } //3의 배수만 필터링한다.
        .sink(receiveValue: { n in //구독
            print("\(n) is a multiple of 3!")
        })
        .store(in: &subscriptions) //저장
}

example(of: "removeDuplicates") {
    let words = "hey hey there! want to listen to mister mister ?"
        .components(separatedBy: " ") //words를 공백 단위로 나눈다.
        .publisher //publisher 생성. 단어들을 내보낸다.
    
    words
        .removeDuplicates() //단위별로 연속되는 중복 제거
        //hey hey there hey 에 적용한다면 hey there hey가 된다.
        .sink(receiveValue: { print($0) }) //구독
        .store(in: &subscriptions) //저장
}




//Compacting and ignoring
example(of: "compactMap") {
    let strings = ["a", "1.24", "3", "def", "45", "0.23"].publisher
    //문자열 배열을 내보내는 publisher를 생성한다.
    
    strings
        .compactMap { Float($0) } //각 String을 Floatd으로 변환한다.
        //문자열로 변환할 수 없다면 nil을 반환한다.
        .sink(receiveValue: { print($0) }) //성공적으로 Float으로 변환된 문자열만 출력한다.
        .store(in: &subscriptions) //저장
}

example(of: "ignoreOutput") {
    let numbers = (1...10_000).publisher
    //1 ~ 10,000까지 값을 내보내는 publisher를 생성한다.
    
    numbers
        .ignoreOutput() //모든 값을 생략하고 완료 이벤트만 방출한다.
        .sink(receiveCompletion: { print("Completed with: \($0)") },
              receiveValue: { print($0) })
        .store(in: &subscriptions) //저장
}




//Finding values
example(of: "first(where:)") {
    let numbers = (1...9).publisher
    //1 ~ 9까지 값을 내보내는 publisher를 생성한다.
    
    numbers
        .print("numbers") //출력확인
        .first(where: { $0 % 2 == 0 }) //처음으로 방출된 짝수를 찾는다.
        .sink(receiveCompletion: { print("Completed with: \($0)") },
              receiveValue: { print($0) })
        .store(in: &subscriptions) //저장
}

example(of: "last(where:)") {
//    let numbers = (1...9).publisher
    //1 ~ 9까지 값을 내보내는 publisher를 생성한다.
    let numbers = PassthroughSubject<Int, Never>() //변경
    
    numbers
        .last(where: { $0 % 2 == 0 }) //마지막으로 방출된 짝수를 찾는다.
        .sink(receiveCompletion: { print("Completed with: \($0)") },
              receiveValue: { print($0) })
        .store(in: &subscriptions) //저장
    
    numbers.send(1)
    numbers.send(2)
    numbers.send(3)
    numbers.send(4)
    numbers.send(5)
    numbers.send(completion: .finished) //완료
}




//Dropping values
example(of: "dropFirst") {
    let numbers = (1...10).publisher
    //1 ~ 10까지 값을 내보내는 publisher를 생성한다.
    
    numbers
        .dropFirst(8) //첫 8개의 값을 생략한다.
        .sink(receiveValue: { print($0) }) //9, 10만 출력
        .store(in: &subscriptions) //저장
}

example(of: "drop(while:)") {
    let numbers = (1...10).publisher
    //1 ~ 10까지 값을 내보내는 publisher를 생성한다.
    
    numbers
//        .drop(while: { $0 % 5 != 0 })
        .drop(while: { //한 번 조건이 충족되면 다시는 검사하지 않는다.
            print("x")
            return $0 % 5 != 0
        })
        .sink(receiveValue: { print($0) }) //5로 나누어 떨어지는 첫 번째 값을 기다린다.
        //조건이 충족되는 즉시 값들은 통과하기 시작하며, 더 이상 값이 제거되지 않는다.
        .store(in: &subscriptions) //저장
}

example(of: "drop(untilOutputFrom:)") {
    let isReady = PassthroughSubject<Void, Never>() //isReady 상태
    let taps = PassthroughSubject<Int, Never>() //사용자에 의한 탭
    //수동으로 값을 내보낼 수 있는 두 개의 PassthroughSubject를 생성한다.
    
    taps
        .drop(untilOutputFrom: isReady)
        //isReady에서 값을 하나 이상 내보낼 때까지 탭을 무시한다.
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions) //저장
    
    (1...5).forEach { n in //5개의 탭을 내보낸다.
        taps.send(n)
        
        if n == 3 { //3번째 탭일때, isReady에서 값을 내보낸다.
            isReady.send()
        }
    }
}




//Limiting values
example(of: "prefix") {
    let numbers = (1...10).publisher
    //1 ~ 10까지 값을 내보내는 publisher를 생성한다.
    
    numbers
        .prefix(2) //처음 두 값만 방출.
        //2개의 값을 내보내면 publisher는 완료된다.
        .sink(receiveCompletion: { print("Completed with: \($0)") },
              receiveValue: { print($0) })
        .store(in: &subscriptions) //저장
}

example(of: "prefix(while:)") {
    let numbers = (1...10).publisher
    //1 ~ 10까지 값을 내보내는 publisher를 생성한다.
    
    numbers
        .prefix(while: { $0 < 3}) //3보다 작을 때 통과한다.
        //3보다 크거나 같은 값을 내보내면, publisher는 완료된다.
        .sink(receiveCompletion: { print("Completed with: \($0)") },
              receiveValue: { print($0) })
        .store(in: &subscriptions) //저장
}

example(of: "prefix(untilOutputFrom:)") {
    let isReady = PassthroughSubject<Void, Never>() //isReady 상태
    let taps = PassthroughSubject<Int, Never>() //사용자에 의한 탭
    //수동으로 값을 내보낼 수 있는 두 개의 PassthroughSubject를 생성한다.
    
    taps
        .prefix(untilOutputFrom: isReady)
        //isReady에서 값을 하나 이상 내보낼 때까지 통과시킨다.
        .sink(receiveCompletion: { print("Completed with: \($0)") },
              receiveValue: { print($0) })
        .store(in: &subscriptions) //저장
    
    (1...5).forEach { n in //5개의 탭을 내보낸다.
        taps.send(n)
        
        if n == 2 { //2번째 탭일때, isReady에서 값을 내보낸다.
            isReady.send()
        }
    }
}
