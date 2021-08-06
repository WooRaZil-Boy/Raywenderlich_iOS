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

final class StackExchangeClient {
  private lazy var baseURL: URL = {
    return URL(string: "http://api.stackexchange.com/2.2/")!
  }()
  
  let session: URLSession
  
  init(session: URLSession = URLSession.shared) {
    self.session = session
  }
  
  func fetchModerators(with request: ModeratorRequest, page: Int, completion: @escaping (Result<PagedModeratorResponse, DataResponseError>) -> Void) {
    let urlRequest = URLRequest(url: baseURL.appendingPathComponent(request.path))
    //URLRequest 생성자를 사용하여 request를 생성한다. moderators를 가져오는 데 필요한 path를 baseURL에 추가한다.
    //최종 경로는 다음과 같다.
    //http://api.stackexchange.com/2.2/users/moderators
    let parameters = ["page": "\(page)"].merging(request.parameters, uniquingKeysWith: +)
    //원하는 page 번호에 대한 query parameter를 작성하여 ModeratorRequest instance에 정의된 default parameters(page와 site가 제외되어 있음)와 병합한다.
    //page는 request을 수행할 때마다 자동으로 계산되고, site는 ModeratorsSearchViewController의 UITextField에서 읽어온다.
    let encodedURLRequest = urlRequest.encode(with: parameters)
    //이전 단계에서 생성한 parameters로 URL을 인코딩한다.
    //최종 URL은 다음과 같다.
    //http://api.stackexchange.com/2.2/users/moderators?site=stackoverflow&page=1&filter=!-*jbN0CeyJHb&sort=reputation&order=desc
    //해당 request로 URLSessionDataTask를 생성한다.
    
    session.dataTask(with: encodedURLRequest, completionHandler: { data, response, error in
      guard let httpResponse = response as? HTTPURLResponse,
            httpResponse.hasSuccessStatusCode,
            let data = data else {
        completion(Result.failure(DataResponseError.network))
        return
      }
      //URLSession data task에서 반환된 response를 확인한다. 유효하지 않으면 completion handler를 호출하고 network error를 반환한다.
      
      guard let decodedResponse = try? JSONDecoder().decode(PagedModeratorResponse.self, from: data) else {
        completion(Result.failure(DataResponseError.decoding))
        return
      }
      //response가 유효하면, Swift Codable API를 사용하여 JSON을 PagedModeratorResponse 객체로 디코딩한다.
      //오류가 발견되면 decoding error와 함께 completion handler를 호출 호출한다.

      completion(Result.success(decodedResponse))
      //마지막으로 모든 것이 정상이면 completion handler를 호출하여, UI에 새로운 content를 사용할 수 있음을 알린다.
    }).resume()
  }
}
