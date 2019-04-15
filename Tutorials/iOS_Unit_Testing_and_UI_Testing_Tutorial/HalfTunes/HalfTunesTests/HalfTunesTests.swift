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

import XCTest //테스팅 프레임워크 import
@testable import HalfTunes //테스트 할 프로젝트 import

class HalfTunesTests: XCTestCase {
  //비동기로 API가 제대로 작동되는 지 확인한다.
  
  var sut: URLSession! //System Under Test
  //이 클래스의 모든 테스트는 기본적으로 URLSession를 사용하여 Apple 서버에 request를 보낸다.

  override func setUp() {
    super.setUp()
    
    sut = URLSession(configuration: .default) //객체 생성
    //이 테스트 클래스의 모든 테스트는 sut 객체의 속성과 메서드에 액세스할 수 있게 된다.
  }

  override func tearDown() {
    sut = nil
    
    super.tearDown()
  }
  
  //모든 테스트가 깨끗히 초기화된 상태에서 시작하도록 sut 객체를 setUp()에서 생성하고, tearDown()에서 해제하는 것이 좋다.
  //http://qualitycoding.org/teardown/
  
  //Using XCTestExpectation to Test Asynchronous Operations
  func testValidCallToiTunesGetsHTTPStatusCode200() {
    //iTunes에 유효한 쿼리를 보내면 상태코드 200을 반환하는지 확인한다.
    
    // 1. given : 여기서 필요한 모든 값들을 설정해 준다.
    let url = URL(string: "https://itunes.apple.com/search?media=music&entity=song&term=abba")
//    let url = URL(string: "https://itune.apple.com/search?media=music&entity=song&term=abba")
    //잘못된 URL

    let promise = expectation(description: "Status code: 200")
    //XCTestExpectation 객체 반환. description 매개변수로 예상되는 결과를 서술해 준다.
    
    // 2. when : 테스트 코드를 작성한다.
    let dataTask = sut.dataTask(with: url!) { data, response, error in
      
      // 3. then : 테스트가 실패할 경우 메시지를 출력하고 assert 함수를 사용해 종료시킨다.
      if let error = error {
        XCTFail("Error: \(error.localizedDescription)")
        return
      } else if let statusCode = (response as? HTTPURLResponse)?.statusCode {
        if statusCode == 200 { //제대로 완료되었을 때
          promise.fulfill()
          //비동기 메서드의 완료 핸들러 성공 조건 클로저에서 promise.fulfill()을 호출하여 제대로 작동했음을 표시한다.
        } else {
          XCTFail("Status code: \(statusCode)")
        }
      }
    }
    dataTask.resume()
    
    wait(for: [promise], timeout: 5)
    //제대로 작동 완료되거나 timeout 간격이 끝날 때까지 테스트가 계속 실행되도록 유지한다.
  }
  
  //Failing Fast
  func testCallToiTunesCompletes() {
    //잘못된 URL로 교체하면, 테스트가 실패하는 것을 확인할 수 있다.
    //하지만 이는 timeout에 걸려 실패한 것으로 나오기 때문에 request가 실패한 경우에 대한 코드를 추가로 작성해 주어야 한다.
    //지금까지의 테스트 코드는 항상 request가 성공할 것이라는 가정으로 작성했다.
    //request가 성공하기를 기다리는 대신 비동기 메서드의 완료 핸들러가 호출될 때까지 대기한다.
    //이렇게 변경하면, 서버에서 OK 혹은 Error 상태를 받자마자 호출되어 request의 성공 여부를 판단할 수 있다.
    
    // 1. given : 여기서 필요한 모든 값들을 설정해 준다.
    let url = URL(string: "https://itunes.apple.com/search?media=music&entity=song&term=abba")
//    let url = URL(string: "https://itune.apple.com/search?media=music&entity=song&term=abba")
    //잘못된 URL
    let promise = expectation(description: "Completion handler invoked")
    var statusCode: Int?
    var responseError: Error?
    
    // 2. when : 테스트 코드를 작성한다.
    let dataTask = sut.dataTask(with: url!) { data, response, error in
      statusCode = (response as? HTTPURLResponse)?.statusCode
      responseError = error
      promise.fulfill()
    }
    dataTask.resume()
    
    wait(for: [promise], timeout: 5)
    
    // 3. then : 테스트가 실패할 경우 메시지를 출력하고 assert 함수를 사용해 종료시킨다.
    XCTAssertNil(responseError) //Nil이 아닐 때 Assert
    XCTAssertEqual(statusCode, 200) //StatusCode가 200이 아닐 시 Assert
    //위의 testValidCallToiTunesGetsHTTPStatusCode200 테스트 코드와 달리,
    //비동기 결과를 기다리지 않고 request가 실패 시 바로 Assert한다.
  }
}

//Using XCTestExpectation to Test Asynchronous Operations
//네트워크를 사용하는 앱. URLSession을 AlamoFire로 대체하도록 수정하면서 테스트 코드를 작성한다.
//URLSession는 비동기이다. 비동기 메서드를 테스트하려면 XCTestExpectation를 사용해 비동기 작업이 완료될때 까지 기다려야 한다.
//비동기 테스트는 일반적인 단위 테스트와 달리 속도가 느리기 때문에 별도로 유지해야 한다.




//Failing Fast
//잘못된 URL로 교체하면, 테스트가 실패하는 것을 확인할 수 있다.
//하지만 이는 timeout에 걸려 실패한 것으로 나오기 때문에 request가 실패한 경우에 대한 코드를 추가로 작성해 주어야 한다.
//지금까지의 테스트 코드는 항상 request가 성공할 것이라는 가정으로 작성했다.
//request가 성공하기를 기다리는 대신 비동기 메서드의 완료 핸들러가 호출될 때까지 대기한다.
//이렇게 변경하면, 서버에서 OK 혹은 Error 상태를 받자마자 호출되어 request의 성공 여부를 판단할 수 있다.
//비동기 코드의 결과를 기다리지 않고 바로 연이어 Assert 테스트 함수를 작성하면 된다.
