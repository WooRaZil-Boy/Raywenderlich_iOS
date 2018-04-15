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
import CoreLocation
import MapKit

class ApiController {

  struct Weather { //JSON 매핑
    let cityName: String
    let temperature: Int
    let humidity: Int
    let icon: String
    let lat: Double
    let lon: Double

    static let empty = Weather(
      cityName: "Unknown",
      temperature: -1000,
      humidity: 0,
      icon: iconNameToChar(icon: "e"),
      lat: 0,
      lon: 0
    )
    
    static let dummy = Weather(
        cityName: "RxCity",
        temperature: 20,
        humidity: 90,
        icon: iconNameToChar(icon: "01d"),
        lat: 0,
        lon: 0
    )
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
    
    func overlay() -> Overlay { //오버레이로 변환
        let coordinates: [CLLocationCoordinate2D] = [
            CLLocationCoordinate2D(latitude: lat - 0.25, longitude: lon - 0.25),
            CLLocationCoordinate2D(latitude: lat + 0.25, longitude: lon + 0.25)
        ]
        let points = coordinates.map { MKMapPointForCoordinate($0) }
        let rects = points.map { MKMapRect(origin: $0, size: MKMapSize(width: 0, height: 0)) }
        let fittingRect = rects.reduce(MKMapRectNull, MKMapRectUnion)
        return Overlay(icon: icon, coordinate: coordinate, boundingMapRect: fittingRect)
    }
    
    public class Overlay: NSObject, MKOverlay { //오버레이 뷰에 전달하여 실제 데이터를 지도에 렌더링할 객체
        //오버레이를 표현하는 데 필요한 정보(좌표, 직사각형 영역, 아이콘)만 있으면 된다.
        var coordinate: CLLocationCoordinate2D
        var boundingMapRect: MKMapRect
        let icon: String
        
        init(icon: String, coordinate: CLLocationCoordinate2D, boundingMapRect: MKMapRect) {
            self.coordinate = coordinate
            self.boundingMapRect = boundingMapRect
            self.icon = icon
        }
    }
    
    public class OverlayView: MKOverlayRenderer { //오버레이 렌더링 담당
        //오버레이 인스턴스와 아이콘 문자열로 새 인스턴스 생성
        var overlayIcon: String
        
        init(overlay:MKOverlay, overlayIcon:String) {
            self.overlayIcon = overlayIcon
            super.init(overlay: overlay)
        }
        
        public override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
            let imageReference = imageFromText(text: overlayIcon as NSString, font: UIFont(name: "Flaticon", size: 32.0)!).cgImage
            //해당 텍스트를 이미지로 변환
            let theMapRect = overlay.boundingMapRect
            let theRect = rect(for: theMapRect)
            
            context.scaleBy(x: 1.0, y: -1.0)
            context.translateBy(x: 0.0, y: -theRect.size.height)
            context.draw(imageReference!, in: theRect)
        }
    }
  }

  /// The shared instance
  static var shared = ApiController()

  /// The api key to communicate with openweathermap.org
  /// Create you own on https://home.openweathermap.org/users/sign_up
  private let apiKey = ""

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
                icon: iconNameToChar(icon: json["weather"][0]["icon"].string ?? "e"),
                lat: json["coord"]["lat"].double ?? 0,
                lon: json["coord"]["lon"].double ?? 0
            )
        }
  }
    
    func currentWeather(lat: Double, lon:Double) -> Observable<Weather> {
        //위도와 경도로 날씨 가져오는 메서드
        return buildRequest(pathComponent: "weather", params: [("lat", "\(lat)"), ("lon", "\(lon)")]).map() { json in
            return Weather(
                cityName: json["name"].string ?? "Unknown",
                temperature: json["main"]["temp"].int ?? -1000,
                humidity: json["main"]["humidity"].int  ?? 0,
                icon: iconNameToChar(icon: json["weather"][0]["icon"].string ?? "e"),
                lat: json["coord"]["lat"].double ?? 0,
                lon: json["coord"]["lon"].double ?? 0
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

fileprivate func imageFromText(text: NSString, font: UIFont) -> UIImage {
    
    let size = text.size(withAttributes: [NSAttributedStringKey.font: font])
    
    UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
    text.draw(at: CGPoint(x: 0, y:0), withAttributes: [NSAttributedStringKey.font: font])
    
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return image ?? UIImage()
}
