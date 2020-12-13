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

class GitNetworkLogger: EventMonitor {
  let queue = DispatchQueue(label: "com.raywenderlich.gitonfire.networklogger") //serial queue
  //EventMonitor는 모든 events를 dispatches하는 DispatchQueue가 필요하다.
  //기본값으로 EventMonitor는 main queue를 사용한다.
  //performance를 고려하면, custom DispatchQueue를 사용하여 queue를 initialize하는 것이 좋다.
  //여기서는 session에 대한 모든 events를 처리하는 serial queue를 사용한다.
  
  func requestDidFinish(_ request: Request) {
    //request가 완료되면 호출된다.
    print(request.description)
    //request의 description을 출력하여, HTTP 메서드와 request URL을 console에 표시한다.
  }
  
  func request<Value>(
    _ request: DataRequest,
    didParseResponse response: DataResponse<Value, AFError>
  ) {
    //response가 수신되면 호출된다.
    guard let data = response.data else {
      return
    }
    
    if let json = try? JSONSerialization
        .jsonObject(with: data, options: .mutableContainers) {
      print(json)
      //JSONSserialization을 사용하여 response를 JSON으로 rendering한 다음 console에 출력한다.
    }
  }
}
