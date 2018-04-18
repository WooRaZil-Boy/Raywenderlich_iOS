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

fileprivate var internalCache = [String: Data]() //캐시. 딕셔너리

public enum RxURLSessionError: Error {
  case unknown
  case invalidResponse(response: URLResponse)
  case requestFailed(response: HTTPURLResponse, data: Data?)
  case deserializationFailed
}

extension ObservableType where E == (HTTPURLResponse, Data) {
    //(HTTPURLResponse, Data) 타입만을 타겟으로 하는 extension
    func cache() -> Observable<E> {
        return self.do(onNext: { (response, data) in
            if let url = response.url?.absoluteString, 200 ..< 300 ~= response.statusCode {
                //url.absoluteString으로 String 변환, 상태 코드가 정상이라면
                internalCache[url] = data //캐시 딕셔너리에 저장
            }
        })
    }
}

extension Reactive where Base: URLSession {
    //URLSession을 Rx에 맞춰 확장한다. 이후 .rx 를 통해 해당 클래스를 찾을 수 있다.
    func response(request: URLRequest) -> Observable<(HTTPURLResponse, Data)> {
        //Observable을 반환하는 래퍼를 생성해야 한다.
        //HTTPURLResponse는 request가 성공적으로 처리되었는지 확인하기 위해 검사하는 부분, Data는 실제 데이터
        
        
        return Observable.create { observer in
            let task = self.base //base가 URLSession
                .dataTask(with: request) { (data, response, error) in //completionHandler 클로저
                //URLSession는 콜백 및 작업을 기반으로 한다. request를 보내고 서버의 response를 수신하는
                //내장 메서드 dataTask(with : completionHandler :). 이 함수는 콜백을 사용해 결과를 관리한다.
                //따라서 Observable의 논리를 필요한 클로저 내에서 관리해야 한다.
                    guard let response = response, let data = data else { //올바르게 반환 안 된 경우
                        observer.on(.error(error ?? RxURLSessionError.unknown))
                        //on으로 옵저버(AnyObserver<(HTTPURLResponse, Data)>)에 이벤트를 보낸다.
                        //에러가 있으면 그 에러를 보내고, 없으면(nil)이면 RxURLSessionError.unknown를 보낸다.
                        return
                    }
                    
                    guard let httpResponse = response as? HTTPURLResponse else {
                        observer.on(.error(RxURLSessionError.invalidResponse(response: response)))
                        //on으로 옵저버(Observable)에 이벤트를 보낸다.
                        return
                    }
                    
                    //위의 guard를 모두 통과했으면, 반환이 제대로 된 경우이므로 뒤이어 로직을 계속하면 된다.
                    observer.onNext((httpResponse, data)) //.next 이벤트 emit
                    observer.on(.completed) //.completed 이벤트 emit
                    
                }
                task.resume() //task 시작. 트리거. 결과는 콜백(클로저)에 의해 처리된다.
                //명령적 프로그래밍(Imperative Programming)
            
            return Disposables.create(with: task.cancel)
            //문제가 생겨 콜백으로 처리되지 않고 Observable이 disposed되면 아무런 일이 일어나지 않는다.
            //그 경우에는 리소스를 낭비하지 않도록 task를 취소해 주는 것이 좋다.
        }
    }
    
    //response(request: )를 활용해서 각 데이터 타입 별로 처리할 수 있다.
    
    func data(request: URLRequest) -> Observable<Data> {
        if let url = request.url?.absoluteString, let data = internalCache[url] { //캐시 있으면
            return Observable
                .just(data) //캐시의 데이터를 반환한다.
        }
        
        //캐시가 없으면
        return response(request: request) //위의 메서드를 활용해 data를 가져온다.
            .cache() //캐시
            .map { (response, data) -> Data in
                if 200 ..< 300 ~= response.statusCode { //상태 코드 정상
                    return data
                } else { //오류
                    throw RxURLSessionError.requestFailed(response: response, data: data)
                }
            }
        //p.341
    }
    
    func string(request: URLRequest) -> Observable<String> {
        return data(request: request)
            .map { d in //data를 문자열로 변환
                return String(data: d, encoding: .utf8) ?? ""
            }
    }
    
    func json(request: URLRequest) -> Observable<JSON> {
        return data(request: request)
            .map { d in //data를 JSON으로 변환
                return try JSON(data: d)
            }
    }
    
    func image(request: URLRequest) -> Observable<UIImage> {
        return data(request: request)
            .map { d in //data를 UIImage로 변환
                return UIImage(data: d) ?? UIImage()
            }
    }
    
    //Observable을 반환하는 래퍼를 생성해야 한다.
    //다양한 유형의 데이터를 반환할 수 있으므로 필요한 데이터 유형을 먼저 확인하는 것이 좋다.
    //여기서는 Data, String, JSON, Image를 처리하는 래퍼를 만든다.
    //먼저 래퍼에 전달된 데이터의 유형을 확인하고 유형이 일치하지 않으면 오류를 낸다.
    //로직은 Observable의 파라미터로 들어온 데이터를 통해, map을 해 필요한 data를 뽑아내고 구독한다. p.337, p.340
    //RxSwift의 map 연산자는 오버헤드를 피하기 위해 알아서 적절히 조합되어 다중 체인이 단일 호출로 최적화 된다.
    //따라서 클로저에 너무 많이 map 연산자를 썼거나 체인으로 연결하는 것에 대해 따로 걱정할 필요 없다.
    
    //캐싱을 통해 로딩시간을 줄이고 리소스를 아낄 수 있다. 타입은 (HTTPURLResponse, Data)이 될 것이다.
    
    
    
    
}


