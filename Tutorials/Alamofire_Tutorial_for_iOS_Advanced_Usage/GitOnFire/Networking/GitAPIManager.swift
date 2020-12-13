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

class GitAPIManager {
  static let shared = GitAPIManager()
  let sessionManager: Session = { //custom Session 정의
    let configuration = URLSessionConfiguration.af.default //기본값
    //URLSessionConfiguration 인스턴스 생성
    //default Alamofire URLSessionConfiguration은 Accept-Encoding, Accept-Language, User-Agent 헤더를 추가한다.
//    configuration.timeoutIntervalForRequest = 30
    //timeoutIntervalForRequest를 30초로 설정한다. 해당 Session의 모든 request에 적용된다.
//    configuration.waitsForConnectivity = true //네트워크가 연결되기를 기다린 다음 request를 호출한다.
    //시뮬레이터에선 잘 안되고, 실제 device에서 잘 작동함
    
//    return Session(configuration: configuration)
    //custom configuration을 전달하여 Session 인스턴스를 생성한다.
    
    configuration.requestCachePolicy = .returnCacheDataElseLoad
    //session에 대한 requests을 cache하려면, URLSessionConfiguration의 requestCachePolicy를 returnCacheDataElseLoad로 설정한다.
    //일단 설정되면 cache는 response을 반환한다. 캐시에 response가 없으면, network request가 수행된다.

    let responseCacher = ResponseCacher(behavior: .modify { _, response in
      //Alamofire의 ResponseCacher를 사용하면 request을 cache를 저장하기 전에
      //캐시해야 하는지, 캐시해지 않고 수정해야하는지 여부를 쉽게 지정할 수 있다.
      //여기에서 cache에 저장하기 전에 .modify를 지정하여 response을 수정한다.
      //userInfo dictionary에 response의 date를 전달하여, response의 content과 함께 date도 저장한다.
      let userInfo = ["date": Date()]
      return CachedURLResponse(
          response: response.response,
          data: response.data,
          userInfo: userInfo,
          storagePolicy: .allowed)
    })
    
    let networkLogger = GitNetworkLogger() //Logger
    let interceptor = GitRequestInterceptor() //RequestInterceptor

//    return Session(configuration: configuration, eventMonitors: [networkLogger])
    
//    return Session(
//      configuration: configuration,
//      interceptor: interceptor,
//      eventMonitors: [networkLogger])
    
    return Session(
      configuration: configuration,
      interceptor: interceptor,
      cachedResponseHandler: responseCacher,
      eventMonitors: [networkLogger])
  }()

  func fetchPopularSwiftRepositories(completion: @escaping ([Repository]) -> Void) {
    searchRepositories(query: "language:Swift", completion: completion)
  }

  func fetchCommits(for repository: String, completion: @escaping ([Commit]) -> Void) {
//    let url = "https://api.github.com/repos/\(repository)/commits"
//    sessionManager.request(url)
    
//    AF.request(url)
    
    sessionManager.request(GitRouter.fetchCommits(repository))
      .responseDecodable(of: [Commit].self) { response in
        guard let commits = response.value else {
          return
        }
        completion(commits)
      }
  }

  func searchRepositories(query: String, completion: @escaping ([Repository]) -> Void) {
//    let url = "https://api.github.com/search/repositories"
//    //repositories를 검색할 URL을 지정한다.
//    var queryParameters: [String: Any] = ["sort": "stars", "order": "desc", "page": 1]
//    //query parameters 배열을 생성하여 repositories를 가져온다. start 수 내림차순으로 repository를 정렬한다.
//    queryParameters["q"] = query
//    sessionManager.request(url, parameters: queryParameters)
    
//    AF.request(url, parameters: queryParameters) { urlRequest in //기본 timeoutInterval는 60이다.
//      urlRequest.timeoutInterval = 30
//    }
    
    sessionManager.request(GitRouter.searchRepositories(query))
      .responseDecodable(of: Repositories.self) { response in
        //AF 기본 session으로 network request를 수행한다.
        //method는 수신한 response를 decode하여 completion block에서 custom model인 Repository 배열로 반환한다.
        guard let items = response.value else {
          return completion([])
        }
        completion(items.items)
      }
  }
  
  func fetchAccessToken(
    accessCode: String,
    completion: @escaping (Bool) -> Void
  ) {
//    let headers: HTTPHeaders = [
//      "Accept": "application/json"
//    ]
//    //request에 대한 header를 정의한다.
//    //"Accept": "application/json"으로 app이 JSON 형식의 response를 원한다고 server에 알려준다.
//
//    let parameters = [
//      "client_id": GitHubConstants.clientID,
//      "client_secret": GitHubConstants.clientSecret,
//      "code": accessCode
//    ]
//    //query parameters 를 정의한다.
//    //이러한 parameters는 request의 일부로 전송된다.
//
//    sessionManager.request(
//      "https://github.com/login/oauth/access_token",
//      method: .post,
//      parameters: parameters,
//      headers: headers)
//      //access token을 가져오기 위한 network request를 수행한다.
    
    sessionManager.request(GitRouter.fetchAccessToken(accessCode))
      .responseDecodable(of: GitHubAccessToken.self) { response in
        //response는 GitHubAccessToken로 decode 된다.
        guard let cred = response.value else {
          return completion(false)
        }
        TokenManager.shared.saveAccessToken(gitToken: cred)
        //TokenManager 클래스는 token을 keychain에 조정하는 것을 돕는다.
        completion(true)
      }
  }
  
  func fetchUserRepositories(completion: @escaping ([Repository]) -> Void) {
//    let url = "https://api.github.com/user/repos"
//    //repositories를 가져올 URL을 정의한다.
//    let parameters = ["per_page": 100]
//    //query parameter를 설정한다.
//    //per_page는 response 당 return되는 repositories의 최대 수를 경정한다.
//    //여기서는 페이지당 최대 100개의 결과를 얻는다.
//
//    sessionManager.request(url, parameters: parameters)
    
    sessionManager.request(GitRouter.fetchUserRepositories)
      //repositories를 가져오는 request를 수행한다.
        .responseDecodable(of: [Repository].self) { response in
          //response을 Repository의 array로 decode하고 completion block에 전달한다.
          guard let items = response.value else {
            return completion([])
          }
          completion(items)
        }
  }
}




