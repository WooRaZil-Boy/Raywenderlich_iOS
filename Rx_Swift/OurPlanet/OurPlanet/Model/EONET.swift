/*
 * Copyright (c) 2016 Razeware LLC
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

class EONET {
  static let API = "https://eonet.sci.gsfc.nasa.gov/api/v2.1"
  static let categoriesEndpoint = "/categories"
  static let eventsEndpoint = "/events"

  static var ISODateReader: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZ"
    return formatter
  }()
    
    static var categories: Observable<[EOCategory]> = { //싱글톤
        //이 카테고리는 거의 변경되지 않으므로 싱글톤으로 만들 수도 있다. //여기선 비동기로 가져온다.
        return EONET.request(endpoint: categoriesEndpoint)
            //요청해서 Observable<[String: Any]> 타입형 반환을 받는다.
            .map { data in //map으로 categories 배열을 추출해 낸다.
                let categories = data["categories"] as? [[String: Any]] ?? []
                //EONET.request에서 반환받은 데이터(dictionary)에서 categories을 가져온다.
                //제대로 받지 못했다면 빈 배열
                
                return categories
                    .flatMap(EOCategory.init)
                    //flatMap으로 categories 배열의 요소를 init 한다.
                    //flatMap이므로 map과 달리 nil을 없앤다.
                    //이전에 init?(json:)와 flatMap으로 빈 JSON 객체를 삭제했듯이
                    //이런 식으로 구현해 주면 얘기치 않은 오류를 막을 수 있다.
                    .sorted { $0.name < $1.name } //이름 순으로 정렬
            }
            .catchErrorJustReturn([])
            //catchErrorJustReturn는 에러가 발생했을 때 설정해둔 단일 이벤트를 전달하도록 하는 연산자
            .share(replay: 1, scope: .forever)
            //categories는 싱글톤이다. 모든 구독자는 동일한 categories를 얻는다.
            //첫 번째 구독자는 request observable를 트리거한다.
            //response map은 categories 배열로 된다.
            //share(replay: 1, scope: .forever)로 모든 요소를 첫 구독 시퀀스에 릴레이 한다.
            //그 후, 데이터를 다시 요청하지 않고 마지막으로 수신된 요소를 새 구독자에게 전달한다(캐시 처럼 작동).
            //따라서 .forever 범위로 해야 한다.
    }()

  static func filteredEvents(events: [EOEvent], forCategory category: EOCategory) -> [EOEvent] {
    return events.filter { event in
      return event.categories.contains(category.id) &&
             !category.events.contains {
               $0.id == event.id
             }
    }
    .sorted(by: EOEvent.compareDates)
  }
    
    static func request(endpoint: String, query: [String: Any] = [:]) -> Observable<[String: Any]> {
        do {
            guard let url = URL(string: API)?.appendingPathComponent(endpoint), var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
                //appendingPathComponent로 컴포넌트를 url 뒤에 추가 시킨다.
                //url 뒤에 붙여질 컴포넌트를 생성한다.
                throw EOError.invalidURL(endpoint)
                //URL을 구성할 수 없는 경우 오류를 발생 시킨다.
            }
            
            components.queryItems = try query.flatMap { (key, value) in
                //queryItems : name / value 쌍으로 쿼리를 구현한다.
                //ex. http://www.example.com/index.php?key1=value1&key2=value2
                guard let v = value as? CustomStringConvertible else {
                    //CustomStringConvertible를 준수하는 유형은 인스턴스를 문자열로 자체 변환할 수 있다.
                    throw EOError.invalidParameter(key, value)
                }
                
                return URLQueryItem(name: key, value: v.description)
                //flatMap으로 nil을 제외하고 key, value로 [URLQueryItem]을 만든다.
            }
            
            guard let finalURL = components.url else { //url 유효성 검사
                throw EOError.invalidURL(endpoint)
            }
            
            let request = URLRequest(url: finalURL) //최종 url
            
            return URLSession.shared.rx.response(request: request) //rx의 URLSession
                //observable 객체를 반환한다. map에서 data를 [String: Any]로 변환해
                //최종 반환형 Observable<[String: Any]>이 된다.
                .map { _, data -> [String: Any] in
                    guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []), let result = jsonObject as? [String: Any] else {
                        //JSONSerialization으로 JSON 객체로 변환 실패하면 오류 발생
                        throw EOError.invalidJSON(finalURL.absoluteString)
                    }
                    
                    return result
                }
        } catch { //오류 처리
            return Observable.empty()
        }
    }
    
    fileprivate static func events(forLast days: Int, closed: Bool, endpoint: String) -> Observable<[EOEvent]> {
        //카테고리별 다운로드를 구현을 위해 엔드 포인트를 추가한다.
        return request(endpoint: eventsEndpoint, query: [ //이벤트의 매개변수로 쿼리
            "days": NSNumber(value: days),
            "status": (closed ? "closed" : "open")
            ])
            .map { json in //request 결과인 json 데이터를 매핑한다. //Rx의 map
                guard let raw = json["events"] as? [[String: Any]] else {
                    throw EOError.invalidJSON(endpoint)
                }
                
                return raw.flatMap(EOEvent.init)
                //flatMap으로 각 배열 요소를 초기화
                //Swift의 flatMap
            }
            .catchErrorJustReturn([])
    }
    
    static func events(forLast days: Int = 360, category: EOCategory) -> Observable<[EOEvent]> {
        let openEvents = events(forLast: days, closed: false, endpoint: category.endpoint)
        let closedEvents = events(forLast: days, closed: true, endpoint: category.endpoint)
        //각각의 이벤트 결과를 가져와서
        
//        return openEvents.concat(closedEvents) //p.207
//        //결과를 합친다.
        
        //위에서 open 이벤트와 closed 이벤트를 각각 전달했다. 그 후 concat으로 순차적으로 가져오므로 응답속도가 느리다.
        //병렬 다운로드로 속도와 안정성을 높일 수 있다. Rx에서 UI코드에 영향 주지 않는 병렬 다운로드를 쉽게 구현한다.
        return Observable.of(openEvents, closedEvents) //p.211
            .merge() //병합 //source Observable에서 emit된 각 Observable을 구독하고 중계한다.
            .reduce([]) { running, new in //결과를 배열로 reduce
                //빈 배열에서 시작해, Observables 중 하나가 이벤트를 전달할 때마다 호출된다.
                //기존 배열에 새 배열을 추가하고 반환 //시퀀스가 완료되면 단일 값을 내보내고 reduce도 완료된다.
                running + new
            }
    }
}

//서버와 통신하는 부분을 뷰 컨트롤러에서 따로 떼어내서 클래스로 만들어 주는 것이 좋은 디자인이다.
//뷰 컨트롤러에서는 서버에 엑세스 하는 부분을 추상화하고, 상태를 받아와 사용하면 된다.
//Rx를 적용하면 쉽게 디자인 패턴을 분리해 줄 수 있다.

//이전에 init?(json:)와 flatMap으로 빈 JSON 객체를 삭제했는데, 이런 식으로 구현해 주는 것이 좋다.
