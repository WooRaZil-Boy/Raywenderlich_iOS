import Foundation
import Combine

var subscriptions = Set<AnyCancellable>()

example(of: "Create a phone number lookup") {
  let contacts = [
    "603-555-1234": "Florent",
    "408-555-4321": "Marin",
    "217-555-1212": "Scott",
    "212-555-3434": "Shai"
  ]
  
  func convert(phoneNumber: String) -> Int? {
    if let number = Int(phoneNumber),
      number < 10 {
      return number
    }

    let keyMap: [String: Int] = [
      "abc": 2, "def": 3, "ghi": 4,
      "jkl": 5, "mno": 6, "pqrs": 7,
      "tuv": 8, "wxyz": 9
    ]

    let converted = keyMap
      .filter { $0.key.contains(phoneNumber.lowercased()) }
      .map { $0.value }
      .first

    return converted
  }

  func format(digits: [Int]) -> String {
    var phone = digits.map(String.init)
                      .joined()

    phone.insert("-", at: phone.index(
      phone.startIndex,
      offsetBy: 3)
    )

    phone.insert("-", at: phone.index(
      phone.startIndex,
      offsetBy: 7)
    )

    return phone
  }

  func dial(phoneNumber: String) -> String {
    guard let contact = contacts[phoneNumber] else {
      return "Contact not found for \(phoneNumber)"
    }

    return "Dialing \(contact) (\(phoneNumber))..."
  }
  
  let input = PassthroughSubject<String, Never>()
    
    //구현
    input
        .map(convert) //.map(convert(phoneNumber:))로 사용할 수도 있다.
        //입력(input)을 숫자(numbers)로 변환(convert)한다. 입력을 정수로 변환(convert)할 수 없는 경우 nil을 반환(return)하는 convert 함수(function)를 사용한다.
        .replaceNil(with: 0)
        //이전(previous) 연산자(operator)에서 nil이 반환(returned)된 경우 0으로 대체한다.
        .collect(10)
        //미국에서 사용하는 3 자리 지역 번호(area code) 및 7 자리 전화 번호 형식에 해당하는 10개의 값을 한 번에 수집(collect)한다.
        .map(format) //.map(format(digits:))로 사용할 수도 있다.
        //수집된(collected) 문자열(string) 값(value)이 연락처(contacts) dictionary에 있는 전화 번호의 형식과 일치하도록, 제공된 format 함수(function)를 사용해 형식(Format)을 지정한다.
        .map(dial) //.map(dial(phoneNumber:))로 사용할 수도 있다.
        //이전(previous) 연산자(operator)로부터 받은 입력(input)을 제공된 dial 함수(function)을 사용해 "다이얼(Dial)"한다.
        .sink(receiveValue: { print($0) }) //구독
  
  "0!1234567".forEach {
    input.send(String($0))
  }
  
  "4085554321".forEach {
    input.send(String($0))
  }
  
  "A1BJKLDGEH".forEach {
    input.send("\($0)")
  }
}

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
