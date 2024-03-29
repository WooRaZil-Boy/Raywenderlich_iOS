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

import Foundation
import RxSwift
import SwiftyJSON

class ApiController {
  
  static let shared = ApiController()
  
  private let apiKey = "9HRizMOPHujwF5lrHR49nCKShQxyDvyX"
  
  func search(text: String) -> Observable<[JSON]> {
    let url = URL(string: "http://api.giphy.com/v1/gifs/search")!
    var request = URLRequest(url: url)
    let keyQueryItem = URLQueryItem(name: "api_key", value: apiKey)
    let searchQueryItem = URLQueryItem(name: "q", value: text)
    let urlComponents = NSURLComponents(url: url, resolvingAgainstBaseURL: true)!
    
    urlComponents.queryItems = [searchQueryItem, keyQueryItem]
    
    request.url = urlComponents.url!
    request.httpMethod = "GET"
    
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    return URLSession.shared.rx.json(request: request) //URLSession+Rx에서 확장 했으므로 .rx 사용가능
        .map() { json in
            return json["data"].array ?? [] //배열로 반환
        }
  }
}
