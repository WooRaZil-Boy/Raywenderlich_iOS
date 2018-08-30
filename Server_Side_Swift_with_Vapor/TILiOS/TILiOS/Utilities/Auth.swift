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
import UIKit

enum AuthResult {
  case success
  case failure
}

class Auth { //AppDelegate에서 응용 프로그램이 시작될 때 인증을 위해 호출한다.
  static let defaultsKey = "TIL-API-KEY"
  let defaults = UserDefaults.standard

  var token: String? { //UserDefault 객체를 변수로 만들어 observer 메서드로 구현하면 편하게 사용할 수 있다.
    get {
      return defaults.string(forKey: Auth.defaultsKey)
    }
    set {
      defaults.set(newValue, forKey: Auth.defaultsKey)
    }
  }
  
  func login(username: String, password: String, completion: @escaping (AuthResult) -> Void) {
    //username, password로 로그인
    let path = "https://rw-vapor-til.vapor.cloud/api/users/login"
  
    guard let url = URL(string: path) else { //URL 유효성 검사
      fatalError()
    }
    
    guard let loginString = "\(username):\(password)"
      .data(using: .utf8)?
      .base64EncodedString() else {
        //header에 추가할 사용자 자격 증명을 base64 인코딩으로 생성한다.
        fatalError()
    }
    
    var loginRequest = URLRequest(url: url) //로그인 request
    loginRequest.addValue("Basic \(loginString)", forHTTPHeaderField: "Authorization")
    //HTTP Basic authentication에 필요한 header 추가
    loginRequest.httpMethod = "POST"
    //login 메서드는 POST
    
    let dataTask = URLSession.shared.dataTask(with: loginRequest) { data, response, _ in
      //URLSessionDataTask를 만들어 request를 전송한다.
      //실제로 전송은 resume()를 실행해 줘야 한다.
      guard let httpResponse = response as? HTTPURLResponse,
        httpResponse.statusCode == 200,
        let jsonData = data else {
          //response 상태코드가 200이고 data(body) 유효성 검증
          completion(.failure)
          return
      }
      
      do {
        let token = try JSONDecoder().decode(Token.self, from: jsonData)
        //response body(data)를 토큰으로 디코딩
        self.token = token.token //토큰 저장
        completion(.success)
      } catch { //오류가 발생하면, .falure enum 과 함께 completion 클로저를 호출한다.
        completion(.failure)
      }
    }
    
    dataTask.resume() //dataTask 시작. request 전송
  }
  
  func logout() {
    self.token = nil //기존 토큰 삭제
    
    DispatchQueue.main.async {
      guard let applicationDelegate = UIApplication.shared.delegate as? AppDelegate else {
        return
      }
      
      let rootController = UIStoryboard(name: "Login", bundle: Bundle.main)
        .instantiateViewController(withIdentifier: "LoginNavigation")
      //Login.storyboard를 로드해, LoginTableViewController을 가져온다.
      applicationDelegate.window?.rootViewController = rootController
      //화면을 LoginTableViewController로 전환한다.
    }
  }
}
