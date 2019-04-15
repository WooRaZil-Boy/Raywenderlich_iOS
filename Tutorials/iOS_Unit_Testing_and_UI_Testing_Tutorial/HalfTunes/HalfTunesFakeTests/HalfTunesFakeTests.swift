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

class HalfTunesFakeTests: XCTestCase {
  //다운로드한 데이터가 올바르게 parsing 됐는지 확인한다.
  
  var sut: SearchViewController! //System Under Test
  //해당 테스트에서는 SearchViewController의 객체들을 확인해 제대로 작동했는지 확인한다.
  //SearchViewController에서 HalfTunes의 모든 작업이 완료되므로 massive view controller problem이 발생할 수 있다.
  //네트워킹 코드를 별도의 모듈로 옮기면, 이 문제를 줄일 수 있고, 테스트가 더 쉬워진다.
  //http://williamboles.me/networking-with-nsoperation-as-your-wingman/
  
  //가짜 세션 테스트에 사용할 JSON이 필요하다.
  //https://itunes.apple.com/search?media=music&entity=song&term=abba&limit=3
  //사용할 URL에 &limit=3를 붙여줘서 JSON 파일을 가져올 수 있다. 이 파일 확장자를 json으로 바꿔 해당 폴더트리에 추가해 준다.
  
  override func setUp() {
    super.setUp()
    
    sut = UIStoryboard(name: "Main", bundle: nil)
      .instantiateInitialViewController() as? SearchViewController
    
    let testBundle = Bundle(for: type(of: self))
    let path = testBundle.path(forResource: "abbaData", ofType: "json")
    let data = try? Data(contentsOf: URL(fileURLWithPath: path!), options: .alwaysMapped)
    let url = URL(string: "https://itunes.apple.com/search?media=music&entity=song&term=abba")
    let urlResponse = HTTPURLResponse(url: url!, statusCode: 200, httpVersion: nil, headerFields: nil)
    let sessionMock = URLSessionMock(data: data, response: urlResponse, error: nil)
    sut.defaultSession = sessionMock
    //DHURLSessionMock.swift 를 사용한다.
    //DHURLSession 프로토콜이 구현되어 있고, 메서드는 URL 이나 URLRequest으로 data task를 생성한다.
    //URLSessionMock은 데이터 선택, response, error 등의 URLSession 목업 객체를 만드는 생성자를 정의한다.
    
    //가짜 데이터와 response를 설정하고 목업 객체를 만든 후 앱의 속성으로 할당한다.
  }
  
  override func tearDown() {
    sut = nil
    
    super.tearDown()
  }
  
  //모든 테스트가 깨끗히 초기화된 상태에서 시작하도록 sut 객체를 setUp()에서 생성하고, tearDown()에서 해제하는 것이 좋다.
  //http://qualitycoding.org/teardown/
  
  func test_UpdateSearchResults_ParsesData() {
    //가짜 데이터를 파싱하는 지 여부를 확인하는 테스트
    //stub을 사용하지만, 비동기인 것처럼 처리되기 때문에 비동기 테스트로 테스트해야 한다.
    
    // 1. given : 여기서 필요한 모든 값들을 설정해 준다.
    let promise = expectation(description: "Status code: 200")
    
    // 2. when : 테스트 코드를 작성한다.
    XCTAssertEqual(sut.searchResults.count, 0, "searchResults should be empty before the data task runs")
    //searchResults는 setUp()에서 새롭게 만들어지기 때문에 dataTask를 시작하기 전에는 비어 있다.
    
    let url = URL(string: "https://itunes.apple.com/search?media=music&entity=song&term=abba")
    let dataTask = sut.defaultSession.dataTask(with: url!) { data, response, error in
      if let error = error {
        print(error.localizedDescription)
      } else if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
        self.sut.updateSearchResults(data)
        //HTTP request가 성공적으로 처리되면, updateSearchResults(_:)를 호출한다.
        //updateSearchResults에서 json을 parsing 한다.
      }
      
      promise.fulfill()
    }
    
    dataTask.resume()
    wait(for: [promise], timeout: 5)
    
    // 3. then : 테스트가 실패할 경우 메시지를 출력하고 assert 함수를 사용해 종료시킨다.
    XCTAssertEqual(sut.searchResults.count, 3, "Didn't parse 3 items from fake response")
    //가짜 세션 테스트에서 작성한 JSON 파일이 3개의 세션만 있으므로(limit=3) 3개로 count 되야 한다.
    //실제로 네트워크 연결을 사용하지 않기 때문에 비동기 테스트를 실행하는 것보다 빠르게 완료된다.
  }
  
  //Performance Testing
  func test_StartDownload_Performance() {
    //성능 테스트는 해당 코드 블록을 10번 실행해, 평균 소요 시간과 표준편차를 구한다.
    //성능 테스트는 테스트하려는 코드를 measure() 클로저 안에 위치시키기만 하면 된다.
    let track = Track(name: "Waterloo", artist: "ABBA", previewUrl: "http://a821.phobos.apple.com/us/r30/Music/d7/ba/ce/mzm.vsyjlsff.aac.p.m4a")
    
    measure { //성능 테스트하려는 코드를 measure 클로저 블록 안에 위치시킨다.
      self.sut.startDownload(track)
      //테스트가 완료 되면, gutter의 measure 클로저가 시작되는 부분에 회색 다이아몬드 아이콘이 표시된다.
      //이를 선택해 통계를 확인해 볼 수 있다. Set Baseline을 선택하면 해당 테스트가 측정의 기준이 된다.
      //Baseline을 설정하면, 코드 변경 이후에 재 테스트할 때 쉽게 비교할 수 있다.
      //Baseline은 디바이스별로 저장되므로, 여러 디바이스에서 동일한 테스트를 하고,
      //특정 구성의 프로세서 속도, 메모리 등에 따라 각각 다른 Baseline을 유지할 수 있다.
    }
  }
}

//Faking Objects and Interactions
//비동기 테스트로 비동기 API가 제대로 작동하는 지 테스트 할 수 있다.
//URLSession에서 입력을 받거나 사용자의 기본 DB, iCloud 등에서 업데이트 시 제대로 작동하는지도 테스트할 수 있다.
//대부분의 앱은 시스템 또는 라이브러리 객체(제어할 수 없는 객체들)와 상호작용하기에,
//실제로 이런 객체들과 상호작용하는 테스트는 FIRST 원칙에 위배된다.
//대신, Stub에서 입력을 받거나 mock 객체를 업데이트하여 상호작용 대체할 수 있다.
//https://www.objc.io/issues/15-testing/dependency-injection/




//Fake Input From Stub
//Test navigator 탭(⌘-6)을 열고, 왼쪽 하단의 + 버튼을 눌러 New Unit Test Target... 을 선택한다.
//DHURLSessionMock.swift 를 사용한다.
//DHURLSession 프로토콜이 구현되어 있고, 메서드는 URL 이나 URLRequest으로 data task를 생성한다.
//URLSessionMock은 데이터 선택, response, error 등의 URLSession 목업 객체를 만드는 생성자를 정의한다.




//Performance Testing
//성능 테스트는 해당 코드 블록을 10번 실행해, 평균 소요 시간과 표준편차를 구한다.
//성능 테스트는 테스트하려는 코드를 measure() 클로저 안에 위치시키기만 하면 된다.
//테스트가 완료 되면, gutter의 measure 클로저가 시작되는 부분에 회색 다이아몬드 아이콘이 표시된다.
//이를 선택해 통계를 확인해 볼 수 있다. Set Baseline을 선택하면 해당 테스트가 측정의 기준이 된다.
//Baseline을 설정하면, 코드 변경 이후에 재 테스트할 때 쉽게 비교할 수 있다.
//Baseline은 디바이스별로 저장되므로, 여러 디바이스에서 동일한 테스트를 하고,
//특정 구성의 프로세서 속도, 메모리 등에 따라 각각 다른 Baseline을 유지할 수 있다.
//https://developer.apple.com/library/archive/documentation/DeveloperTools/Conceptual/testing_with_xcode/chapters/04-writing_tests.html#//apple_ref/doc/uid/TP40014132-CH4-SW8




//Code Coverage
//code coverage tool을 사용해, 아직 테스트 코드가 작성되지 않은 부분을 확인할 수 있다.
//edit scheme -> Test -> Options -> Code Coverage -> Gather coverage for에 체크한다.
//그 후, ⌘-U 로 모든 테스트를 실행해 완료 된 다음, Report navigator 탭(⌘-9)을 열어 Coverage를 선택하면 된다.
//해당 코드로 이동하려면 더블클릭이나 화살표 버튼을 누르면 된다.
//오른쪽 사이드 바에 마우스를 올려 녹색 또는 빨간색으로 강조된 코드를 확인해 볼 수 있다.
//녹색은 테스트 코드가 해당 부분을 실행했다는 의미이고, 빨간색은 실행하지 않았다는 의미이다. 숫자는 실행 횟수를 의미한다.

//100% Coverage?
//테스트 코드가 100% 모든 코드에 적용되어햐 하는 지에 대해서는 논쟁의 여지가 있다.
//특히 마지막 10 ~ 15% 를 채우는 것에 대해 서로 다른 의견들이 많다.
//하지만 분명한 것은 테스트하기 어려운 코드는 이미 잘못 설계된 경우가 많다는 것이다.




//Where to Go From Here?
//https://qualitycoding.org/tdd-sample-archives/
