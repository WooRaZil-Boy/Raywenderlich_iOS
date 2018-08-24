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

import Foundation

enum GetResourcesRequest<ResourceType> {
  //TILApp API(Retrieve)를 호출한 결과를 나타내는 열거형
  case success([ResourceType]) //성공
  case failure //실패
}

enum SaveResult<ResourceType> {
  //TILApp API(Save)를 호출한 결과를 나타내는 열거형
  case success(ResourceType)
  case failure
}

struct ResourceRequest<ResourceType> where ResourceType: Codable {
  //제네릭 매개 변수가 Codable을 준수해야 하는 ResourceRequest 유형 정의
  //API와 통신하고 결과를 받아오는 객체
  let baseURL = "https://rw-vapor-til.vapor.cloud/api/" //API 기본 URL
  let resourceURL: URL
  
  init(resourcePath: String) {
    guard let resourceURL = URL(string: baseURL) else {
      //특정 자원(User, Acronym, Category) URL 초기화
      fatalError()
    }
    
    self.resourceURL = resourceURL.appendingPathComponent(resourcePath)
    //지정된 컴퍼넌트를 추가한 URL를 반환한다.
  }
  
  func getAll(completion: @escaping (GetResourcesRequest<ResourceType>) -> Void) {
    //API에서 자원 유형의 모든 값을 가져오는 함수. 완료 클로저를 매개 변수로 사용한다.
    let dataTask = URLSession.shared.dataTask(with: resourceURL) { data, _, _ in
      //자원의 URL로 내용을 검색하고, 완료되면 데이터를 받아 클로저를 실행한다.
      //여기서는 선언만 한다. resume() 메서드로 실제로 실행한다.
      //Moya 나 Alamofire 등을 사용할 수도 있다.
      guard let jsonData = data else { //data가 nil인지 확인
        completion(.failure) //nil인 경우에는 위에서 작성한 Enum으로 fail 완료 클로저를 반환한다.
        return
      }
    
      do {
        let resources = try JSONDecoder().decode([ResourceType].self, from: jsonData)
        //response data를 ResourceTypes 배열로 디코딩한다.
        completion(.success(resources)) //문제가 없으면 success와 함께 완료 클로저 실행
      } catch {
        completion(.failure) //오류 발생시 fail과 함께 완료 클로저 실행
      }
    }
    
    dataTask.resume() //dataTask 시작
  }
  
  func save(_ resourceToSave: ResourceType, completion: @escaping (SaveResult<ResourceType>) -> Void) {
    //API에서 자원 유형을 저장 하는 함수. 완료 클로저를 매개 변수로 사용한다.
    do {
      var urlRequest = URLRequest(url: resourceURL) //해당 경로로 URLRequest를 생성한다.
      urlRequest.httpMethod = "POST" //save request의 HTTP 메서드는 POST
      urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
      //Content-Type을 application/json로 request의 header 설정. API가 디코딩할 JSON 데이터(input)를 인식하게 한다.
      urlRequest.httpBody = try JSONEncoder().encode(resourceToSave)
      //save request의 httpBody를 요청된 자원 유형으로 설정한다.
      
      let dataTask = URLSession.shared.dataTask(with: urlRequest) { data, response, _ in
        //자원의 URL에 request body의 내용을 저장하고, 완료되면 데이터와 response를 받아 클로저를 실행한다.
        //여기서는 선언만 한다. resume() 메서드로 실제로 실행한다.
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let jsonData = data else {
          //HTTP Response가 있고, 그 응답 상태가 200(OK)인지, 데이터가 있는 지 확인한다.
          completion(.failure) //하나라도 오류가 있다면 위에서 작성한 Enum으로 fail 완료 클로저를 반환한다.
          return
        }
        
        do {
          let resource = try JSONDecoder().decode(ResourceType.self, from: jsonData)
          //response data를 ResourceTypes 으로 디코딩한다.
          completion(.success(resource)) //문제가 없으면 success와 함께 완료 클로저 실행
        } catch {
          completion(.failure) //오류 발생시 fail과 함께 완료 클로저 실행
        }
      }
      
      dataTask.resume() //dataTask 시작
    } catch {
      completion(.failure) //오류 발생시 fail과 함께 완료 클로저 실행
    }
  }
}
