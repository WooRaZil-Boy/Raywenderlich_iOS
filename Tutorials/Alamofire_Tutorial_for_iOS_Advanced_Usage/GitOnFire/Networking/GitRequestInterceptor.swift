/// Copyright (c) 2020 Razeware LLC
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
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import Foundation
import Alamofire

class GitRequestInterceptor: RequestInterceptor {
  let retryLimit = 5
  let retryDelay: TimeInterval = 10
  //두 개의 상수를 선언한다.
  //요청 재시도 횟수와 재시도 사이의 간격을 제한하는 데 도움을 준다.

  func adapt(
      _ urlRequest: URLRequest,
      for session: Session,
      completion: @escaping (Result<URLRequest, Error>) -> Void
    ) {
    var urlRequest = urlRequest
    if let token = TokenManager.shared.fetchAccessToken() {
      urlRequest.setValue("token \(token)", forHTTPHeaderField: "Authorization")
    }
    completion(.success(urlRequest))
  }
  //RequestAdapter는 RequestInterceptor로, 단일 요구 사항인 adapt(_:for:completion:)을 구현해야 한다.
  //이 method는 request을 검사하고 조정한다. completion handler는 asynchronous이므로
  //이 method는 request을 하기 전에 network 또는 disk에서 token을 가져올 수 있다.
  //여기에서 keychain의 token을 가져와 Authorization 헤더에 추가한다. GitHub OAuth Apps의 access token에는 만료 시간이 없다.
  //그러나 app을 승인한 사용자가 GitHub settings에서 해당 app을 취소할 수 있다.

  func retry(
      _ request: Request,
      for session: Session,
      dueTo error: Error,
      completion: @escaping (RetryResult) -> Void
    ) {
    let response = request.task?.response as? HTTPURLResponse
    //Retry for 5xx status codes
    if
      let statusCode = response?.statusCode,
      (500...599).contains(statusCode),
      request.retryCount < retryLimit {
      completion(.retryWithDelay(retryDelay))
    } else {
      return completion(.doNotRetry)
    }
  }
  //RequestRetrier에는 retry(_:for:dueTo:completion:)라는 단일 요구 사항이 있다.
  //request에서 error가 발생하면 method가 호출된다.
  //RetryResult로 completion block을 호출하여, request을 재시도할지 여부를 표시한다.
  //여기에서 response code에 5xx error code가 포함되어 있는지 확인한다.
  //server는 유효한 request을 이행하지 못하면, 5xx 코드를 returns한다.
  //예를 들어 유지 관리(maintenance)를 위해, service가 중단되면 503 error code를 받을 수 있다.
  //error에 5xx error code가 포함되어 있고 시도 횟수가 retryLimit보다 적을 경우, retryDelay에 지정된 지연 시간으로 request가 재 시도된다.
}
