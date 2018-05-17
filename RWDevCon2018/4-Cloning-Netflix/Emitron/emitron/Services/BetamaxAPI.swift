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

enum BetamaxAPI {
  case showCourses
  case showScreencasts
  case showCourse(id: Int)
  case showVideo(id: Int)
  case getProgress(userId: String)
  case updateProgress(progress: ProgressParams)
}

extension BetamaxAPI : TargetType {
  var baseURL: URL {
    return URL(string: ProcessInfo.processInfo.environment["BETAMAX_ROOT_URL"]!)!
  }
  
  var path: String {
    switch self {
    case .showCourses:
      return "/collections"
    case .showScreencasts:
      return "/videos"
    case .showCourse(id: let id):
      return "/collections/\(id)"
    case .showVideo(id: let id):
      return "/videos/\(id)"
    case .getProgress(userId: let userId):
      return "/users/\(userId)/viewings"
    case .updateProgress(progress: let progress):
      return "/users/\(progress.userId)/viewings"
    }
  }
  
  var method: Moya.Method {
    switch self {
    case .updateProgress:
      return .post
    default:
      return .get
    }
  }
  
  var sampleData: Data {
    return "don't care".utf8Encoded
  }
  
  var task: Task {
    switch self {
    case .showCourses:
      return .requestParameters(parameters: ["format" : "course"], encoding: URLEncoding.queryString)
    case .showScreencasts:
      return .requestParameters(parameters: ["format" : "screencast"], encoding: URLEncoding.queryString)
    case .showCourse, .showVideo, .getProgress:
      return .requestPlain
    case .updateProgress(progress: let progress):
      return .requestJSONEncodable(progress)
    }
  }
  
  var headers: [String : String]? {
    return ["Content-type": "application/json"]
  }
}

extension BetamaxAPI: AccessTokenAuthorizable {
  var authorizationType: AuthorizationType {
    return .bearer
  }
}

extension BetamaxAPI {
  struct ProgressParams: Encodable {
    let userId: String
    let videoId: Int
    let collectionId: Int?
    let time: Int
    let duration: Int
    let finished: Bool
    
    enum CodingKeys: String, CodingKey {
      case videoId = "video_id"
      case collectionId = "collection_id"
      case time
      case duration
      case finished
    }
  }
}

extension Viewing {
  func progressParams(for userId: String) -> BetamaxAPI.ProgressParams {
    return BetamaxAPI.ProgressParams(userId: userId,
                                     videoId: videoId,
                                     collectionId: collectionId,
                                     time: time,
                                     duration: duration,
                                     finished: finished)
  }
}

// MARK: - Helpers
private extension String {
  var urlEscaped: String {
    return addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
  }
  
  var utf8Encoded: Data {
    return data(using: .utf8)!
  }
}
