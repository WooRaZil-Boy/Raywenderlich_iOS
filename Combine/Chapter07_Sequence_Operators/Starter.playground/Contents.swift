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

//Finding values
example(of: "min") {
    let publisher = [1, -50, 246, 0].publisher
    //4개의 다른 숫자를 내보내는 publisher를 생성한다.
    
    publisher
        .print("publisher")
        .min() //min 연산자를 사용하여 publisher가 내보낸 값 중 최소 값을 찾는다.
        .sink(receiveValue: { print("Lowest value is \($0)") }) //출력
        .store(in: &subscriptions) //저장
}

example(of: "min non-Comparable") {
    let publisher = ["12345", "ab", "hello world"]
        .compactMap { $0.data(using: .utf8) } // [Data]
        .publisher // Publisher<Data, Never>
    //다양한 문자열에서 생성된 세 개의 Data 객체를 내보내는 publisher를 생성한다.
    
    publisher
        .print("publisher")
        .min(by: { $0.count < $1.count })
        //Data 유형은 Comparable을 구현하지 않았기 때문에, min(by:) 연산자를 사용한다.
        //여기서는 바이트 수가 가장 적은 Data 객체를 찾는다.
        .sink(receiveValue: { data in
            let string = String(data: data, encoding: .utf8)!
            //Data를 String으로 변환한다.
            print("Smallest data is \(string), \(data.count) bytes")
        })
        .store(in: &subscriptions) //저장
}

example(of: "max") {
    let publisher = ["A", "F", "Z", "E"].publisher
    //4개의 다른 문자를 내보내는 publisher를 생성한다.
    
    publisher
        .print("publisher")
        .max() //max 연산자를 사용하여 최대 값을 찾는다.
        .sink(receiveValue: { print("Highest value is \($0)") }) //출력
        .store(in: &subscriptions) //저장
}

example(of: "first") {
    let publisher = ["A", "B", "C"].publisher
    //3개의 문자를 내보내는 publisher를 생성한다.
    
    publisher
        .print("publisher")
        .first() //첫 번째로 내보낸 값만 통과시킨다.
        .sink(receiveValue: { print("First value is \($0)") }) //출력
        .store(in: &subscriptions) //저장
}

example(of: "first(where:)") {
    let publisher = ["J", "O", "H", "N"].publisher
    //3개의 문자를 내보내는 publisher를 생성한다.
    
    publisher
        .print("publisher")
        .first(where: {"Hello World".contains($0) }) //Hello World에 포함된 첫 번째 문자를 찾는다.
        .sink(receiveValue: { print("First match is \($0)") }) //출력
        .store(in: &subscriptions) //저장
}

example(of: "last") {
    let publisher = ["A", "B", "C"].publisher
    //3개의 문자를 내보내는 publisher를 생성한다.
    
    publisher
        .print("publisher")
        .last() //마지막 값만 내보낸다.
        .sink(receiveValue: { print("Last value is \($0)") }) //출력
        .store(in: &subscriptions) //저장
}

example(of: "output(at:)") {
    let publisher = ["A", "B", "C"].publisher
    //3개의 문자를 내보내는 publisher를 생성한다.
    
    publisher
        .print("publisher")
        .output(at: 1) //인덱스 1에서 방출된 값. 즉, 두 번째 값만 통과시킨다.
        .sink(receiveValue: { print("Value at index 1 is \($0)") }) //출력
        .store(in: &subscriptions) //저장
}

example(of: "output(in:)") {
    let publisher = ["A", "B", "C", "D", "E"].publisher
    //5개의 서로 다른 문자를 내보내는 publisher를 생성한다.
    
    publisher
        .output(in: 1...3) //인덱스 1 ~ 3 까지에서 방출된 값만 통과시킨다.
        .sink(receiveCompletion: { print($0) },
              receiveValue: { print("Value in range: \($0)") }) //출력
        .store(in: &subscriptions) //저장
}




//Querying the publisher
example(of: "count") {
    let publisher = ["A", "B", "C"].publisher
    //3개의 문자를 내보내는 publisher를 생성한다.
    
    publisher
        .print("publisher")
        .count() //업 스트림 publisher가 내보내는 값의 개수를 나타내는 단일 값을 방출한다.
        .sink(receiveValue: { print("I have \($0) items") }) //출력
        .store(in: &subscriptions) //저장
}

example(of: "contains") {
    let publisher = ["A", "B", "C", "D", "E"].publisher
    //5개의 서로 문자를 내보내는 publisher를 생성한다.
//    let letter = "C"
    let letter = "F" //없는 문자
    //포함 여부를 확인할 문자
    
    publisher
        .print("publisher")
        .contains(letter) //해당 문자를 업 스트림 publisher에서 내보냈는지 확인한다.
        .sink(receiveValue: { contains in //contains 야부에 따라 적절한 메시지를 출력한다.
            print(contains ? "Publisher emitted \(letter)!"
                           : "Publisher never emitted \(letter)!")
        })
        .store(in: &subscriptions) //저장
}

example(of: "contains(where:)") {
    struct Person {
        let id: Int
        let name: String
    }
    //id와 name으로 구조체 Person을 정의한다.
    
    let people = [
        (456, "Scott Gardner"),
        (123, "Shai Mishali"),
        (777, "Marin Todorov"),
        (214, "Florent Pillet")
    ]
        .map(Person.init) //생성
        .publisher
    //Person의 다른 4개의 인스턴스를 내보내는 publisher를 생성한다.
    
    people
//        .contains(where: { $0.id == 800 }) //id가 800인 Person이 있는지 확인한다.
        .contains(where: { $0.id == 800 || $0.name == "Marin Todorov" })
        .sink(receiveValue: { contains in
            print(contains ? "Criteria matches!"
                           : "Couldn't find a match for the criteria")
            //내보낸 결과에 따라 적절한 메시지를 출력한다.
        })
        .store(in: &subscriptions) //저장
}

example(of: "allSatisfy") {
//    let publisher = stride(from: 0, to: 5, by: 2).publisher
    //0 ~ 5 사이의 숫자를 2단계씩 내보내는 publisher를 생성한다(0, 2, 4).
    let publisher = stride(from: 0, to: 5, by: 1).publisher
    //0 ~ 5 사이의 숫자를 1단계씩 내보내는 publisher를 생성한다(0, 1, 2, 3, 4).
    
    stride(from: 0, to: 5, by: 1)
    
    publisher
        .print("publisher")
        .allSatisfy { $0 % 2 == 0 } //'모든' 방출된 값이 짝수인지 확인한다.
        .sink(receiveValue: { allEven in
            print(allEven ? "All numbers are even"
                          : "Something is odd...")
            //내보낸 결과에 따라 적절한 메시지를 출력한다.
        })
        .store(in: &subscriptions) //저장
}

example(of: "reduce") {
    let publisher = ["Hel", "lo", " ", "Wor", "ld", "!"].publisher
    //6개의 문자열을 내보내는 publisher를 생성한다.
    
    publisher
        .print("publisher")
//        .reduce("") { accumulator, value in
//            //seed와 함께 reduce를 사용한다. 내보낸 값을 추가하여 최종 문자열 결과를 만든다.
//            accumulator + value
//        }
        .reduce("", +) //위의 코드를 축약한다.
        .sink(receiveValue: { print("Reduced into: \($0)") })
        .store(in: &subscriptions) //저장
    
}


