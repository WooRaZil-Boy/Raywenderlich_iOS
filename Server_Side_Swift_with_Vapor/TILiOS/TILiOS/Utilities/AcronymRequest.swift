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

enum AcronymUserRequestResult {
  //TILApp API(Acronym)를 호출한 결과를 나타내는 열거형
  case success(User)
  case failure
}

enum CategoryAddResult {
  //TILApp API(Category)를 호출한 결과를 나타내는 열거형
  case success
  case failure
}

struct AcronymRequest {
  let resource: URL

  init(acronymID: Int) {
    let resourceString = "https://<YOUR_VAPOR_CLOUD_URL>/api/acronyms/\(acronymID)"
    //API 기본 URL String
    
    guard let resourceURL = URL(string: resourceString) else { //URL 변환
      fatalError()
    }
    
    self.resource = resourceURL
  }

  func getUser(completion: @escaping (AcronymUserRequestResult) -> Void) {
    //API에서 해당 Acronym의 User를 가져오는 메서드. 완료 클로저를 매개 변수로 사용한다.
    let url = resource.appendingPathComponent("user") //지정된 컴퍼넌트를 추가한 URL를 반환한다.
    let dataTask = URLSession.shared.dataTask(with: url) { data, _, _ in
      //URL로 내용을 검색하고, 완료되면 데이터를 받아 클로저를 실행한다.
      //여기서는 선언만 한다. resume() 메서드로 실제로 실행한다.
      guard let jsonData = data else { //데이터를 제대로 가져왔는지 확인
        completion(.failure) //오류 발생시 fail과 함께 완료 클로저 실행
        return
      }
      
      do {
        let decoder = JSONDecoder()
        let user = try decoder.decode(User.self, from: jsonData)
        //해당 데이터를 User 형식으로 디코딩한다.
        completion(.success(user)) //문제가 없으면 success와 함께 완료 클로저 실행
      } catch {
        completion(.failure) //오류 발생시 fail과 함께 완료 클로저 실행
      }
    }
    
    dataTask.resume() //dataTask 시작
  }

  func getCategories(completion: @escaping (GetResourcesRequest<Category>) -> Void) {
    //API에서 해당 Acronym의 Category를 가져오는 메서드. 완료 클로저를 매개 변수로 사용한다.
    let url = resource.appendingPathComponent("categories") //지정된 컴퍼넌트를 추가한 URL를 반환한다.
    let dataTask = URLSession.shared.dataTask(with: url) { data, _, _ in
      //URL로 내용을 검색하고, 완료되면 데이터를 받아 클로저를 실행한다.
      //여기서는 선언만 한다. resume() 메서드로 실제로 실행한다.
      guard let jsonData = data else { //데이터를 제대로 가져왔는지 확인
        completion(.failure) //오류 발생시 fail과 함께 완료 클로저 실행
        return
      }
      
      do {
        let decoder = JSONDecoder()
        let categories = try decoder.decode([Category].self, from: jsonData)
        //해당 데이터를 Category 배열 형식으로 디코딩한다.
        completion(.success(categories)) //문제가 없으면 success와 함께 완료 클로저 실행
      } catch {
        completion(.failure) //오류 발생시 fail과 함께 완료 클로저 실행
      }
    }
    
    dataTask.resume() //dataTask 시작
  }

  func update(with updateData: Acronym, completion: @escaping (SaveResult<Acronym>) -> Void) {
    //API에서 해당 Acronym를 업데이트 하는 메서드. 완료 클로저를 매개 변수로 사용한다.
    do {
      guard let token = Auth().token else { //토큰을 가져 온다.
        Auth().logout() //토큰이 없으면 새 토큰을 얻기 위해 재 로그인해야 하므로 logOut()을 호출한다.
        return
      }
      //Acronym을 생성할 때, User를 제공할 필요 없으므로, CreateAcronymTableViewController를 단순화할 수 있다.
      //CreateAcronymTableViewController에서 Acronym을 생성할 때, User 선택 옵션이 없는 새로운 생성 View가 표시된다.
      
      
      var urlRequest = URLRequest(url: resource) //해당 경로로 URLRequest를 생성한다.
      urlRequest.httpMethod = "PUT" //update request의 HTTP 메서드는 PUT
      urlRequest.httpBody = try JSONEncoder().encode(updateData)
      //update request의 httpBody를 요청된 자원 유형(Acronym)으로 설정한다.
      urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
      //Content-Type을 application/json로 request의 header 설정. API가 디코딩할 JSON 데이터(input)를 인식하게 한다.
      urlRequest.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
      //header에 Authorization를 사용하여 request에 토큰을 추가한다.
      
      let dataTask = URLSession.shared.dataTask(with: urlRequest) { data, response, _ in
        //자원의 URL에 request body의 내용을 저장하고, 완료되면 데이터와 response를 받아 클로저를 실행한다.
        //여기서는 선언만 한다. resume() 메서드로 실제로 실행한다.
        guard let httpResponse = response as? HTTPURLResponse else {
          //HTTP Response 확인
          completion(.failure) //오류 발생시 fail과 함께 완료 클로저 실행
          return
        }
        
        guard httpResponse.statusCode == 200, let jsonData = data else {
          //HTTP Response가 있고, 그 응답 상태가 200(OK)인지, 데이터가 있는지 확인한다.
          if httpResponse.statusCode == 401 { //반환된 response의 상태가 401 Unauthorized
            //401이라면 토큰이 유효하지 않음을 의미한다.
            Auth().logout() //새로운 로그인 시퀀스를 시작하기 위해 로그아웃한다.
          }
          
          completion(.failure) //오류 발생시 fail과 함께 완료 클로저 실행
          return
        }
        
        do {
          let acronym = try JSONDecoder().decode(Acronym.self, from: jsonData)
          //response data를 Acronym 으로 디코딩한다.
          completion(.success(acronym)) //문제가 없으면 success와 함께 완료 클로저 실행
        } catch {
          completion(.failure) //오류 발생시 fail과 함께 완료 클로저 실행
        }
      }
      
      dataTask.resume() //dataTask 시작
    } catch {
      completion(.failure) //오류 발생시 fail과 함께 완료 클로저 실행
    }
  }

  func delete() {
    //API에서 해당 Acronym를 삭제하는 메서드
    guard let token = Auth().token else { //토큰을 가져 온다.
      Auth().logout() //토큰이 없으면 새 토큰을 얻기 위해 재 로그인해야 하므로 logOut()을 호출한다.
      return
    }
    //Acronym을 생성할 때, User를 제공할 필요 없으므로, CreateAcronymTableViewController를 단순화할 수 있다.
    //CreateAcronymTableViewController에서 Acronym을 생성할 때, User 선택 옵션이 없는 새로운 생성 View가 표시된다.
    
    var urlRequest = URLRequest(url: resource)
    urlRequest.httpMethod = "DELETE" //delete request의 HTTP 메서드는 DELETE
    urlRequest.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    //header에 Authorization를 사용하여 request에 토큰을 추가한다.
    
    let dataTask = URLSession.shared.dataTask(with: urlRequest)
    dataTask.resume() //dataTask 시작
  }

  func add(category: Category, completion: @escaping (CategoryAddResult) -> Void) {
    //API에서 해당 Acronym의 Category를 추가 하는 메서드. 완료 클로저를 매개 변수로 사용한다.
    guard let categoryID = category.id else { //id가 유효한지 확인
      completion(.failure)
      return
    }
    
    guard let token = Auth().token else { //토큰을 가져 온다.
      Auth().logout() //토큰이 없으면 새 토큰을 얻기 위해 재 로그인해야 하므로 logOut()을 호출한다.
      return
    }
    //Acronym을 생성할 때, User를 제공할 필요 없으므로, CreateAcronymTableViewController를 단순화할 수 있다.
    //CreateAcronymTableViewController에서 Acronym을 생성할 때, User 선택 옵션이 없는 새로운 생성 View가 표시된다.
    
    let url = resource.appendingPathComponent("categories").appendingPathComponent("\(categoryID)")
    //해당 작업에 맞는 URL 생성
    var urlRequest = URLRequest(url: url) //해당 경로로 URLRequest를 생성한다.
    urlRequest.httpMethod = "POST" //category add request의 HTTP 메서드는 POST
    urlRequest.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    //header에 Authorization를 사용하여 request에 토큰을 추가한다.
    
    let dataTask = URLSession.shared.dataTask(with: urlRequest) { _, response, _ in
      //카테고리를 추가하고, 완료되면 데이터와 response를 받아 클로저를 실행한다.
      //여기서는 선언만 한다. resume() 메서드로 실제로 실행한다.
      guard let httpResponse = response as? HTTPURLResponse else {
        //HTTP Response 확인
        completion(.failure) //오류 발생시 fail과 함께 완료 클로저 실행
        return
      }
      
      guard httpResponse.statusCode == 201 else {
        //HTTP Response가 있고, 그 응답 상태가 201(Created)인지 확인한다.
        if httpResponse.statusCode == 401 { //반환된 response의 상태가 401 Unauthorized
          //401이라면 토큰이 유효하지 않음을 의미한다.
          Auth().logout() //새로운 로그인 시퀀스를 시작하기 위해 로그아웃한다.
        }
        
        completion(.failure) //오류 발생시 fail과 함께 완료 클로저 실행
        return
      }
      
      completion(.success) //문제가 없으면 success와 함께 완료 클로저 실행
    }
    
    dataTask.resume() //dataTask 시작
  }
}
