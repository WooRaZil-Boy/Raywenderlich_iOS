/*:
Copyright (c) 2019 Razeware LLC

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
distribute, sublicense, create a derivative work, and/or sell copies of the
Software in any work that is designed, intended, or marketed for pedagogical or
instructional purposes related to programming, coding, application development,
or information technology.  Permission for such use, copying, modification,
merger, publication, distribution, sublicensing, creation of derivative works,
or sale is expressly withheld.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

import Combine
import Foundation

// A subject you get values from
let subject = PassthroughSubject<Int, Never>()
//• 정수(integers)를 내보내(emits)는 subject.

let strings = subject //string을 내보내는 subject에서 파생된 첫 번째 publisher를 생성한다.
    .collect(.byTime(DispatchQueue.main, .seconds(0.5)))
    //• 0.5초 단위(batches)로 데이터를 그룹화(group)한다.
    //0.5초 단위로 그룹화하려면, .byTime 전략의 collect()를 사용한다.
    .map { array in
        String(array.map { Character(Unicode.Scalar($0)!) })
        //각 정수 값을 유니코드 Scalar에 매핑한 다음 map을 사용하여 전체를 문자열로 변환한다.
    }
    //• 그룹화(grouped)된 데이터를 문자열(string)로 변환한다.

let spaces = subject.measureInterval(using: DispatchQueue.main) //• 두 번째 publisher를 만든다.
    //각 문자 사이의 간격을 측정한다.
    .map { interval in //간격이 0.9초 보다 클 경우 👏 이모지를, 그렇지 않으면 빈 문자열을 매핑한다.
        interval > 0.9 ? "👏" : ""
    }
    //• 제공(feed) 중에 0.9초 이상 일시 정지(pause)된 경우, 👏 이모지(emoji)를 출력한다.

let subscription = strings
    .merge(with: spaces) //• 구독(subscription)의 첫 번째 publisher와 병합(merge)한다.
    //최종 publisher는 strings와 👏 이모지를 병합한 것이다.
    .filter { !$0.isEmpty } //빈 문자열을 걸래낸다.
    .sink {
        print($0)
        //• 출력한다.
    }

// Let's roll!
startFeeding(subject: subject)
//subject에 알지 못하는(mysterious) 데이터를 제공(feeds)하는 함수(function) 호출(call)


