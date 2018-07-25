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

import UIKit
import Moya

public enum Imgur {
  static private let clientId = "87aea39283910c6"
  
  case upload(UIImage) //POST /image
  case delete(String) //DELETE /image/{imageDeleteHash}
  //Imgur API에서 사용하는 경로 Endpoint
}

extension Imgur: TargetType {
  public var baseURL: URL { //Imgur API의 기본 URL
    return URL(string: "https://api.imgur.com/3")!
  }
  
  public var path: String { //각 case에 따라 적절한 Endpoint를 반환한다.
    switch self {
    case .upload: return "/image"
    case .delete(let deletehash): return "/image/\(deletehash)"
    }
  }
  
  public var method: Moya.Method { //각 case에 따라 적절한 메서드를 반환한다.
    switch self {
    case .upload: return .post //POST
    case .delete: return .delete //DELETE
    }
  }
  
  public var sampleData: Data { //빈 Data 구조체. //test 위한 값
    return Data()
  }
  
  public var task: Task { //각각의 Endpoint에 대해 다른 Task를 반환한다.
    switch self {
    case .upload(let image):
      let imageData = image.jpegData(compressionQuality: 1.0)!
      return .uploadMultipart([MultipartFormData(provider: .data(imageData),
                                                 name: "image",
                                                 fileName: "card.jpg",
                                                 mimeType: "image/jpg")])
      //파일을 업로드하려면 uploadMultipart task를 사용한다. MultipartFormData 구조체 배열을 가진다.
      //각 MultipartFormData 요소에 적절한 속성을 사용해 인스턴스화한다.
    case .delete:
      return .requestPlain
      //삭제 시에는 단순히 plain request로 충분하다.
    }
  }
  
  public var headers: [String : String]? { //헤더 속성
    return [
      "Authorization": "Client-ID \(Imgur.clientId)",
      "Content-Type": "application/json"
    ]
  }
  
  public var validationType: ValidationType {
    return .successCodes //200 ~ 299에서 유효
  }
}

//다른 API들을 위해 각각의 Target이 필요하다. //Marvel과 비교
