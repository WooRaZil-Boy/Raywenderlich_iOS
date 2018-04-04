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
import RxCocoa
import SwiftyJSON

class ApiController {

  struct Weather { //JSON 매핑
    let cityName: String
    let temperature: Int
    let humidity: Int
    let icon: String

    static let empty = Weather(
      cityName: "Unknown",
      temperature: -1000,
      humidity: 0,
      icon: iconNameToChar(icon: "e")
    )
  }

  /// The shared instance
  static var shared = ApiController()

  /// The api key to communicate with openweathermap.org
  /// Create you own on https://home.openweathermap.org/users/sign_up
  private let apiKey = "5f45591484d2746f630e3c728d56e98f"

  /// API base URL
  let baseURL = URL(string: "http://api.openweathermap.org/data/2.5")!

  init() {
    Logging.URLRequests = { request in
      return true
    }
  }

  //MARK: - Api Calls

  func currentWeather(city: String) -> Observable<Weather> {
//    //서버에서 실제 데이터를 받아올 때 까지 보여줄 더미 데이터
//    // Placeholder call
//    return Observable.just(Weather(cityName: city,
//                                   temperature: 20,
//                                   humidity: 90,
//                                   icon: iconNameToChar(icon: "01d")))
//    //Weather구조체를 생성해 요소로 포함하는 Observable 반환
    
    //실제 데이터 반환
    return buildRequest(pathComponent: "weather", params: [("q", city)])
        .map { json in //받아온 Observable<JSON>에서 Weather 객체 생성
            //Error가 발생했으면 (더미의 RxSwift, 타자 중 치는 중 없는 도시 명) 여기로 안 오고 종료된다.
            //더미의 경우에는 .catchErrorJustReturn(ApiController.Weather.empty)이 없으므로 바로 종료 되어
            //.next 가 emit되지 못하고 스토리보드의 기본 값이 스크린이 보이게 된다.
            //타자를 치는 도중엔 .catchErrorJustReturn(ApiController.Weather.empty)로 처리된 되어
            //빈 Weather 객체로 계속 되고 여기서 디폴트 값인 "Unknown", -1000, 0, "e" 로 업데이트 된다.
            //더미에도 .catchErrorJustReturn(ApiController.Weather.empty)을 추가하면 같은 결과를 얻는다.
            return Weather(
                cityName: json["name"].string ?? "Unknown",
                temperature: json["main"]["temp"].int ?? -1000,
                humidity: json["main"]["humidity"].int  ?? 0,
                icon: iconNameToChar(icon: json["weather"][0]["icon"].string ?? "e")
            )
        }
  }

  //MARK: - Private Methods

  /**
   * Private method to build a request with RxCocoa
   */
  private func buildRequest(method: String = "GET", pathComponent: String, params: [(String, String)]) -> Observable<JSON> {

    let url = baseURL.appendingPathComponent(pathComponent)
    var request = URLRequest(url: url)
    let keyQueryItem = URLQueryItem(name: "appid", value: apiKey)
    let unitsQueryItem = URLQueryItem(name: "units", value: "metric")
    let urlComponents = NSURLComponents(url: url, resolvingAgainstBaseURL: true)!

    if method == "GET" {
      var queryItems = params.map { URLQueryItem(name: $0.0, value: $0.1) }
      queryItems.append(keyQueryItem)
      queryItems.append(unitsQueryItem)
      urlComponents.queryItems = queryItems
    } else {
      urlComponents.queryItems = [keyQueryItem, unitsQueryItem]

      let jsonData = try! JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
      request.httpBody = jsonData
    }

    request.url = urlComponents.url!
    request.httpMethod = method

    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    let session = URLSession.shared

//    return session.rx.data(request: request).map { JSON(data: $0) }
    return session.rx.data(request: request).map { try! JSON(data: $0) }
  }

}

/**
 * Maps an icon information from the API to a local char
 * Source: http://openweathermap.org/weather-conditions
 */
public func iconNameToChar(icon: String) -> String { //JSON의 icon 코드를 UTF-8 문자열로 변환
  switch icon {
  case "01d":
    return "\u{f11b}"
  case "01n":
    return "\u{f110}"
  case "02d":
    return "\u{f112}"
  case "02n":
    return "\u{f104}"
  case "03d", "03n":
    return "\u{f111}"
  case "04d", "04n":
    return "\u{f111}"
  case "09d", "09n":
    return "\u{f116}"
  case "10d", "10n":
    return "\u{f113}"
  case "11d", "11n":
    return "\u{f10d}"
  case "13d", "13n":
    return "\u{f119}"
  case "50d", "50n":
    return "\u{f10e}"
  default:
    return "E"
  }
}
