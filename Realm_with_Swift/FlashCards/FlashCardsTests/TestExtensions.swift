/// Copyright (c) 2018 Razeware LLC
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
import RealmSwift

@testable import FlashCards

extension RealmProvider {
  func copyForTesting() -> RealmProvider {
    var conf = self.configuration //현재 provider의 configuration을 가져와서
    conf.inMemoryIdentifier = UUID().uuidString //inMemoryIdentifier 설정
    //fileURL을 자동으로 nil로 설정한다.
    conf.readOnly = false //읽기 전용 비활성화 //테스트 전에 Realm의 데이터를 추가할 수 있다.
    
    return RealmProvider(config: conf)
  }
}

extension Realm {
  //테스트를 반복할 것이므로 write 트랜잭션과 adding Objects 등을 추가하는 것이 편리하다.
  func addForTesting(objects: [Object]) {
    //각 테스트의 설정에서 테스트 Realm에 일부 데이터를 추가하는 데 사용할 메서드
    try! write {
      add(objects)
    }
  }
}

//Test을 위한 extension에서는 디스크에 있는 Realm 파일을 사용하지 않는다.
//메모리 영역에 Realm을 만들어 테스트 한다.
//테스트 대상에 대해 providers를 만든다면, 오버헤드가 발생할 수 있다. 이를 피하기 위해 기존의 providers를 복제하고
//해당 providers의 메모리 내 복사본을 반환하는 메서드를 추가한다.
//이렇게 하면 테스트를 위해 적합한 복사본을 만드는 동안 여전히 객체 스키마 및 기타 세부 정보가 보존된다.

//전체 로직은 p.179
//테스트를 위한 분리된 새로운 객체를 생성하면, View Model에서 테스트를 할 수 있다.
//전체 in-memory Realm을 만들 필요 없기 때문에 테스트 속도가 더 빨라진다.
