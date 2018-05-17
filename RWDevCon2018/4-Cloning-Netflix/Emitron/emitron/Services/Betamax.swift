/*
 * Copyright (c) 2018 Razeware LLC
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
import Moya
import RealmSwift

final class Betamax {
  var provider: MoyaProvider<BetamaxAPI>!
  let store = try! Realm()
  let responseQueue = DispatchQueue(label: "com.razeware.betamax", qos: .userInitiated)
  
  var token: String? {
    didSet {
      setupProvider()
    }
  }
  
  private lazy var jsonDecoder: JSONDecoder = {
    let dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    let decoder = JSONDecoder()
    //Moya에서 사용하는 기본 JSON 디코더가 betamxAPI에서 받은 JSON 구문을 분석할 수 없어 처음에는 오류가 난다.
    
    // TODO: Customise JSON Decoder
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = dateFormat
    decoder.dateDecodingStrategy = .formatted(dateFormatter)
    //JSON API에서 제공한 날짜를 분석하여 JSONDecoder의 해당 속성에 할당할 수 있는 사용자 정의 날짜 포맷터를 만든다.
    
    return decoder
  }()
  
  private func setupProvider() {
    var plugins: [PluginType] = [
      NetworkActivityPlugin(networkActivityClosure: { (changeType, _) in
        switch changeType {
        case .began:
          NetworkActivityIndicator.shared.push()
        case .ended:
          NetworkActivityIndicator.shared.pop()
        }
      })
    ]
    if let token = token {
      plugins.append(AccessTokenPlugin(tokenClosure: token))
    }
    provider = MoyaProvider<BetamaxAPI>(plugins: plugins)
  }
  
  enum Domain: String {
    case all = "All"
    case ios = "iOS"
    case android = "Android"
    case other = "Other"
    
    var predicateString: String? {
      switch self {
      case .all:
        return .none
      case .ios:
        return "ANY categories.name == 'domain:ios'"
      case .android:
        return "ANY categories.name == 'domain:android'"
      case .other:
        return "NONE categories.name == 'domain:ios' AND NONE categories.name == 'domain:android'"
      }
    }
  }
}

//: MARK:- Public Methods
extension Betamax {
  func emptyCache() {
    do {
      let realm = try Realm()
      try realm.write {
        realm.deleteAll()
      }
    } catch (let error) {
      print(error)
    }
  }
  
  func getCollections(for domain: Domain = .all) -> Results<Collection> {
    provider.request(.showCourses) { (result) in
      switch result {
      case .success(let response):
        do {
          let collections = try response.map([Collection].self, atKeyPath: "collections", using: self.jsonDecoder)
          let realm = try Realm()
          try realm.write {
            realm.add(collections, update: true)
          }
        } catch(let error) {
          print(error)
        }
      case .failure(let error):
        print(error)
      }
    }
    if let predicateString = domain.predicateString {
      return store.objects(Collection.self).filter(predicateString)
    } else {
      return store.objects(Collection.self)
    }
  }
  
  func refresh(collection: Collection) {
    provider.request(.showCourse(id: collection.id)) { (result) in
      switch result {
      case .success(let response):
        do {
          let collection = try response.map(Collection.self, atKeyPath: "collection", using: self.jsonDecoder)
          let realm = try Realm()
          try realm.write {
            realm.add(collection, update: true)
          }
        } catch(let error) {
          print(error)
        }
      case .failure(let error):
        print(error)
      }
    }
  }
  
  func getScreencasts() -> Results<Video> {
    provider.request(.showScreencasts) { (result) in
      switch result {
      case .success(let response):
        do {
          // TODO: Update to use custom JSON decoder
          let screencasts = try response.map([Video].self, atKeyPath: "videos", using: self.jsonDecoder)
          //디코더를 사용하도록 수정한다.
          //커스터 마이징한 JSON 디코더를 사용하도록 Moya에게 알린다.
          //또한, 데이터 시작 키의 경로를 설정해 준다.
          
          let realm = try Realm()
          try realm.write {
            realm.add(screencasts, update: true)
          }
        } catch(let error) {
          print(error)
        }
      case .failure(let error):
        print(error)
      }
    }
    return store.objects(Video.self).filter("format == %@", "screencast").sorted(byKeyPath: "releasedAt", ascending: false)
  }
  
  func getStreamForVideo(id: Int, callback: @escaping(Result<URL>) -> ()) {
    provider.request(.showVideo(id: id)) { (result) in
      switch result {
      case .success(let response):
        do {
          // We're not going to save this—each time we start a stream we make a request
          // this ensures that a user must remain a subscriber.
          let video = try response.map(Video.self, atKeyPath: "video", using: self.jsonDecoder)
          if let streamUrl = video.streamUrl {
            callback(.success(streamUrl))
          } else {
            callback(.error(BetamaxError.streamUnavailable))
          }
        } catch(let error) {
          callback(.error(BetamaxError(someError: error)))
        }
      case .failure(let error):
        callback(.error(BetamaxError(someError: error)))
      }
    }
  }
  
  func updateProgressFor(viewing: Viewing, time: Int) {
    do {
      try store.write {
        viewing.time = time
        viewing.dirty = true
        viewing.finished = Float(time) > 0.9 * Float(viewing.duration)
        viewing.updatedAt = Date()
      }
    } catch (let error) {
      print(error)
    }
  }
  
  func syncViewingToAPI(viewing: Viewing, userId: String, successHandler: @escaping (Viewing) -> ()) {
    provider.request(.updateProgress(progress: viewing.progressParams(for: userId))) { (result) in
      switch result {
      case .success:
        successHandler(viewing)
      case .failure(let error):
        print(error)
      }
    }
  }
  
  func requestViewingsForUser(userId: String, callback: @escaping ([Viewing]) -> ()) {
    provider.request(.getProgress(userId: userId)) { (result) in
      switch result {
      case .success(let response):
        do {
          let viewings = try response.map([Viewing].self, atKeyPath: "viewings", using: self.jsonDecoder)
          callback(viewings)
        } catch(let error) {
          print(error)
        }
      case .failure(let error):
        print(error)
      }
    }
  }
}

enum BetamaxError: String, Error {
  case streamUnavailable
  case notAuthorised
  case notFound
  case unknown
  
  init(someError: Error) {
    self = .unknown
    if let error = someError as? MoyaError {
      switch error {
      case .statusCode(let response),
           .jsonMapping(let response):
        if response.statusCode == 404 {
          self = .notFound
        } else if response.statusCode == 403 {
          self = .notAuthorised
        }
      default:
        break
      }
    }
  }
  
  var title: String {
    switch self {
    case .streamUnavailable:
      return "Stream Unavailable"
    case .notAuthorised:
      return "Not Authorized"
    case .notFound:
      return "Not Found"
    case .unknown:
      return "Unknown Error"
    }
  }
  
  var message: String {
    switch self {
    case .streamUnavailable:
      return "The requested stream is not currently available. Please try again later."
    case .notAuthorised:
      return "You are not authorized to view the selected content."
    case .notFound:
      return "The selected content cannot be found."
    case .unknown:
      return "An unknown error has occurred. Please contact support if this persists."
    }
  }
}

