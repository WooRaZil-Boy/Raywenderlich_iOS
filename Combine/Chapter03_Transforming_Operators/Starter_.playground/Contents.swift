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

//collect()
example(of: "collect") {
    ["A", "B", "C", "D", "E"].publisher
//        .collect() //연산자 추가
        .collect(2) //최대 2개씩
        .sink(receiveCompletion: { print($0) },
              receiveValue: { print($0) })
        .store(in: &subscriptions)
}




//map(_:)
example(of: "map") {
    let formatter = NumberFormatter()
    formatter.numberStyle = .spellOut
    //숫자의 철자를 표시하는 formatter
    
    [123, 4, 56].publisher //정수 publisher
        .map { //map을 사용해 업 스트림 값을 얻고, formatter를 사용해 숫자의 철자를 반환한다.
            formatter.string(from: NSNumber(integerLiteral: $0)) ?? ""
        }
        .sink(receiveValue: { print($0) }) //구독
        .store(in: &subscriptions) //저장
}

//Map key paths
example(of: "map key paths") {
    let publisher = PassthroughSubject<Coordinate, Never>()
    //<Coordinate, Never> 유형의 publisher를 생성한다.
    //출력은 Coordinate 유형이고, 오류를 발생시켜선 안 된다.

    publisher
        .map(\.x, \.y) //키 패스를 사용하여 Coordinate의 x, y 속성에 매핑한다.
        .sink(receiveValue: { x, y in //구독
            print("The coordinate at (\(x), \(y)) is in quadrant", quadrantOf(x: x, y: y))
            //x, y 값으로 해당 좌표가 속한 사분면을 출력한다.
        })
        .store(in: &subscriptions) //저장

    publisher.send(Coordinate(x: 10, y: -8))
    publisher.send(Coordinate(x: 0, y: 5))
    //publisher를 사용해 좌표를 내보낸다.
}

//tryMap(_:)
example(of: "tryMap") {
    Just("Directory name that does not exist") //문자열 publisher
        //정상적인 디렉토리 경로가 아니므로 오류가 발생할 것이다.
        .tryMap{ try FileManager.default.contentsOfDirectory(atPath: $0) } //try 키워드를 사용해야 한다.
        //tryMap을 사용하여 경로의 내용을 가져온다.
        .sink(receiveCompletion: { print($0) }, //완료 이벤트를 수신해 출력
              receiveValue: { print($0) }) //값을 받아 출력
        .store(in: &subscriptions) //저장
}




//flatMap
example(of: "flatMap") {
  func decod(_ codes: [Int]) -> AnyPublisher<String, Never> {
    //각각 ASCII 코드를 나타내는 정수 배열을 사용하여, 오류를 발생하지 않는(Never) 문자열의 type-erased publisher를 반환하는 함수를 정의한다.
    Just(
      codes
        .compactMap { code in
          guard (32...255).contains(code) else { return nil }
          return String(UnicodeScalar(code) ?? " ")
          //출력 가능한 ASCII 코드를 문자열로 변환하는 Just publisher를 생성한다.
      }
      .joined()
      //문자열을 결합한다.

    )
    .eraseToAnyPublisher()
    //fuction의 반환 유형과 일치하도록 publisher의 type을 지운다.
  }
  
  [72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33] //ASCII 코드 배열
    .publisher //publisher로 변환
    .collect() //수집하여 배열로 만든다.
    .flatMap(decode) //flatMap을 사용하여, decoder 함수를 전달한다.
    .sink(receiveValue: { print($0) }) //내보낸 요소를 subscribe하고, 값을 출력한다.
    .store(in: &subscriptions)
}




//flatMap(maxPublishers:_:)
//example(of: "flatMap") {
//    let charlotte = Chatter(name: "Charlotte", message: "Hi, I'm Charlotte!")
//    let james = Chatter(name: "James", message: "Hi, I'm James!")
//    //두 개의 Chatter 인스턴스를 생성한다.
//
//    let chat = CurrentValueSubject<Chatter, Never>(charlotte)
//    //charlotte로 초기화된 publisher를 생성한다.
//
//    chat
////        .flatMap { $0.message } //Chatter 구조체의 publisher 유형 속성인 message에 대해 flatMap
//        .flatMap(maxPublishers: .max(2)) { $0.message } //최대 2개까지 수신
////        .sink(receiveValue: { print($0.message.value) }) //수신된 Chatter 구조체의 message를 출력한다.
//        .sink(receiveValue: { print($0) }) //수신된 값을 출력하도록 변경한다.
//        //해당 값은 이제 Chatter 인스턴스가 아니라 문자열이다.
//        .store(in: &subscriptions)
//
//    charlotte.message.value = "Charlotte: How's it going?"
//    //charlotte의 message를 변경한다.
//
//    chat.value = james //publishe의 현재 값을 james로 변경한다.
//
//    james.message.value = "James: Doing great. You?"
//    charlotte.message.value = "Charlotte: I'm doing fine thanks."
//
//    let morgan = Chatter(name: "Morgan", message: "Hey guys, what are you up to?")
//    //세 번째 Chatter 인스턴스
//
//    chat.value = morgan //chat publisher에 게시한다.
//
//    charlotte.message.value = "Did you hear something?" //Charlotte의 message를 변경한다.
//}




//replaceNil(with:)
example(of: "replaceNil") {
    ["A", nil, "C"].publisher //String? 유형의 배열에서 publisher를 생성한다.
        .eraseToAnyPublisher() //해당 버그 수정
        .replaceNil(with: "-") //업 스트림 publisher에서 수신한 nil 값을 nil이 아닌 새로운 값으로 교체한다.
//        .replaceNil(with: "-" as String?) //오류. replaceNil은 optional을 반환할 수 없다.
        .map { $0! } //force-unwrap으로 optional을 해제한다.
        .sink(receiveValue: { print($0) }) //값을 출력한다.
        .store(in: &subscriptions) //저장
}

//replaceEmpty(with:)
example(of: "replaceEmpty(with:)") {
    let empty = Empty<Int, Never>()
    //empty publisher는 즉시 완료 이벤트를 내보낸다.
    
    empty //구독하여 수신된 이벤트를 출력한다.
        .replaceEmpty(with: 1) //추가
        .sink(receiveCompletion: { print($0) },
              receiveValue: { print($0) })
        .store(in: &subscriptions) //저장
}




//scan(_:_:)
example(of: "scan") {
    var dailyGainLoss: Int { .random(in: -10...10) }
    //-10 ~ 10 사이의 임의의 정수를 생성하는 computed property
    
    let august2019 = (0..<22)
        .map { _ in dailyGainLoss }
        .publisher
    //랜덤 Int 배열에서 publisher를 22개 생성한다.
    //한 달동안 가상의 일일 주가 변동을 나타낸다.
    
    august2019
        .scan(50) { latest, current in //시작가가 50
            max(0, latest + current) //매일 각 변동분을 누적해서 추가한다.
            //max를 사용하여, 음수를 제거한다.
        }
        .sink(receiveValue: { _ in }) //구독
        .store(in: &subscriptions) //저장
}
