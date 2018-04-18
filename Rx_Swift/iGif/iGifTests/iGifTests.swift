/*
 * Copyright (c) 2014-2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import XCTest
import RxSwift
import RxBlocking
import Nimble
import RxNimble
import OHHTTPStubs
import SwiftyJSON

@testable import iGif

class iGifTests: XCTestCase {
  
  let obj = ["array":["foo","bar"], "foo":"bar"] as [String : Any] //JSON
  let request = URLRequest(url: URL(string: "http://raywenderlich.com")!)
  let errorRequest = URLRequest(url: URL(string: "http://rw.com")!)
    //미리 정의된 데이터를 사용해 테스트를 더 쉽게 작성할 수 있다.
  
  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
    stub(condition: isHost("raywenderlich.com")) { _ in
      return OHHTTPStubsResponse(jsonObject: self.obj, statusCode: 200, headers: nil)
    }
    stub(condition: isHost("rw.com")) { _ in
      return OHHTTPStubsResponse(error: RxURLSessionError.unknown)
    }
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
    OHHTTPStubs.removeAllStubs()
  }
    
    func testData() { //data test
        let observable = URLSession.shared.rx.data(request: self.request)
        //extension으로 구현했기에 .rx로 구현가능
        expect(observable //기대값 출력
            .toBlocking() //BlockingObservable로 변환
            .firstOrNil())
            .toNot(beNil()) //nil이 아니어야 한다.
    }
    
    func testString() { //string test
        let observable = URLSession.shared.rx.string(request: self.request)
        let string = "{\"array\":[\"foo\",\"bar\"],\"foo\":\"bar\"}" //이스케이핑
        expect(observable //기대값 출력
            .toBlocking() //BlockingObservable로 변환
            .firstOrNil()) == string
    }
    
    func testJSON() { //JSON test
        let observable = URLSession.shared.rx.json(request: self.request)
        let string = "{\"array\":[\"foo\",\"bar\"],\"foo\":\"bar\"}" //이스케이핑
        let json = try? JSON(data: string.data(using: .utf8)!)
        expect(observable //기대값 출력
            .toBlocking() //BlockingObservable로 변환
            .firstOrNil()) == json
    }
    
    func testError() { //에러가 제대로 출력되는 지 테스트
        var erroredCorrectly = false
        let observable = URLSession.shared.rx.json(request: self.errorRequest)
        
        do {
            let _ = try observable.toBlocking().first()
            assertionFailure()
        } catch (RxURLSessionError.unknown) {
            erroredCorrectly = true
        } catch {
            assertionFailure()
        }
        
        expect(erroredCorrectly) == true
    }
    
  
  
}

extension BlockingObservable { //비동기 작업
  func firstOrNil() -> E? {
    do {
      return try first() //첫 요소를 생성할 때까지 스레드 차단
    } catch {
      return nil
    }
  }
}

//항상 제대로 작동하고 있는지 test하며 진행하는 것도 좋다. TDD
//RxNimble은 테스트를 더 쉽게 작성하고 코드를 간결하게 작성할 수 있게 해 준다.
//let result = try! observabe.toBlocking().first()
//expect(result).first != 0 이 코드를
//expect(observable) != 0 이런 식으로 더 짧게 쓸 수 있다.
