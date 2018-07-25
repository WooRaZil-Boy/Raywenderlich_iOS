/// Copyright (c) 2018년 Razeware LLC
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

import Moya

public enum Marvel {
  //keys
  static private let publicKey = "ed74e1cbb50552fc437204d373c79c5b"
  static private let privateKey = "e1488bb028f1360e0d03141dfa68bdb7ddea6804"
  
  case comics //Marvel API에서 사용하는 경로 Endpoint (GET /v1/public/comics)
}

extension Marvel: TargetType {
  //Moya Target 블록의 프로토콜
  public var baseURL: URL {
    //모든 Taget(서비스)에는 base URL이 있어야 한다.
    //Moya는 base URL을 사용하여 올바른 Endpoint 객체를 만든다.
    return URL(string: "https://gateway.marvel.com/v1/public")!
  }
  
  public var path: String {
    //base URL을 기준으로 모든 Target에 대한 path를 정의한다.
    switch self {
    case .comics: return "/comics"
      //comic의 API 주소는 https://gateway.marvel.com/v1/public/comics 이므로 /comics 이 된다.
    }
    //해당 앱에서는 case가 comic 하나 뿐이므로 switch를 사용할 필요는 없다.
    //하지만 앱이 확장되거나, 여러개의 분류가 있는 경우에는 switch를 사용하여 관리하는 것이 좋다.
  }
  
  public var method: Moya.Method {
    //모든 Target case에 대한 메서드를 제공해 줘야 한다.
    switch self {
    case .comics: return .get //GET
    }
  }
  
  public var sampleData: Data { //테스트를 위한 샘플
    //Unit Test 시, Moya 네트워크에 직접 접속하는 대신 이 변수에서 테스트용 회신을 만들어 낼 수 있다.
    //여기서는 단순히 빈 Data 객체를 반환한다.
    return Data()
  }
  
  public var task: Task { //Target의 가장 핵심적인 부분으로 사용하는 모든 Endpoint에 대한 열거형 case로 반환
    //plain request, data request, parameters request, upload request 등 다양한 열거형 case가 있다.
//    return .requestPlain
    
    let ts = "\(Date().timeIntervalSince1970)"
    let hash = (ts + Marvel.privateKey + Marvel.publicKey).md5
    let authParams = ["apikey": Marvel.publicKey, "ts": ts, "hash": hash]
    //MD5로 해쉬를 만들어 인증한다(Marvel API).
    
    switch self {
    case .comics:
      return .requestParameters(parameters: ["format": "comic",
                                             "formatType": "comic",
                                             "orderBy": "-onsaleDate",
                                             "dateDescriptor": "lastWeek",
                                             "limit": 50] + authParams,
                                encoding: URLEncoding.default)
      //매개변수가 있는 HTTP request 처리. API구성에 맞춘다.
      //주어진 주에 최대 50개의 만화를 최신순으로 정렬
    }
  }
  
  public var headers: [String : String]? { //Target의 모든 Endpoint에 대한 적절한 HTTP 헤더를 반환
    //모든 Marvel API Endpoint가 JSON 응답을 반환하기 때문에 모든 Endpoint에 대해
    //Content-Type: application/json 를 사용할 수 있다.
    return ["Content-Type": "application/json"]
  }
  
  public var validationType: ValidationType { //API 요청 성공에 대한 정의를 위해 사용된다.
    //다양한 열거형 case가 있다.
    return .successCodes //HTTP코드가 200에서 299 사이인 경우
  }
}

//Moya target을 생성한다(열거형).
//Moya taget을 준수하도록 TargetType 프로토콜을 준수해야 한다.




//URLSession이나 Alamofire 대신 Moya를 사용해 네트워크를 구성할 수 있다.
//Moya는 Alamofire를 사용하면서 네트워크 계층을 다른 방식으로 구조화하는 라이브러리이다.
//하나의 앱에서 여러가지 API를 동시에 사용하는 경우 Moya를 사용해 유연하게 구조화할 수 있다.

//Moya는 열거형을 사용해 네트워크 요청을 안전하게 캡슐화하는데 중점을 둔 네트워크 라이브러리이다.
//Moya는 자체적으로 네트워킹을 수행하지 않는다. Alamofire 기능을 사용해 네트워킹을 한다.
//Podfile을 확인해 보면 Moya가 Alamofirer에 의존하는 것을 알 수 있다.

//Moya에는 고유한 기본요소가 있다.
//• Provider : MoyaProvider는 모든 네트워크 서비스와 상호 작용할 때 만드는 주요 객체이다.
//  초기화 시 Target을 사용하는 일반적인 객체이다.
//• Target : 일반적으로 전체 API 서버스를 설명한다. 한 Provider에는 여러 개의 Target이 있을 수 있다.
//  각 대상 target은 서비스 가능한 Endpoint 및 request를 위한 정보가 필요하다.
//  TargetType 프로토콜을 준수하여 대상을 정의한다.
//  이 앱에선, 만화의 정보와 이미지를 가져오는 Marvel taget과 이미지를 공유하는 Imgur target이 있다.
//• Endpoint : Endpoint 객체를 사용해, HTTP Request, request body, header 등의 필요한 기본 정보를 설명한다.
//  MoyaProvider는 모든 Target을 Endpoint로 변환한다. 이는 기본적인 URLRequest가 된다.
//  Endpoint를 사용자 정의로 매핑할 수 있지만, 이 앱에서는 필요하지 않다.
//https://www.raywenderlich.com/192587/moya-tutorial-for-ios-getting-started
//Moya’s Building Blocks 그림 참고
