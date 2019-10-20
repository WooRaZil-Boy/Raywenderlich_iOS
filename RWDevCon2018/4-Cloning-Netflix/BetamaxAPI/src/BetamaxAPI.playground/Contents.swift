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

import Moya
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true




//Use Moya to download a list of all raywenderlich.com screencasts
enum BetamaxAPI { //사용하는 API 종류
    case showScreencasts //비디오 전부 가져오기
    case showVideo(id: Int) //특정 비디오 가져오기
    case getProgress(userId: String) //사용자의 진행상황 추적
    case updateProgress(userId: String, progress: ProgressParams)
    //사용자의 진행상황 업데이트
    
    //진행상황의 파라미터들은 Sources의 ProgressParams.swift에 정의되어 있다.
}

extension BetamaxAPI: TargetType { //Moya의 TargetType 구현
    //API 모델링
    var baseURL: URL {
        return URL(string: "https://videos.raywenderlich.com/api/v1")!
    }
    
    var path: String {
        switch self {
        case .showScreencasts:
            return "/videos"
        case .showVideo(id: let id):
            return "/videos/\(id)"
        case .getProgress(userId: let userId), .updateProgress(userId: let userId, progress: _):
            return "/users/\(userId)/viewings"
        }
    }
    
    var method: Method {
        switch self {
        case .updateProgress:
            return .post
        default:
            return .get
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .showScreencasts:
            return .requestParameters(parameters: ["format" : "screencast"], encoding: URLEncoding.queryString)
        case .showVideo, .getProgress:
            return .requestPlain
        case .updateProgress(userId: _, progress: let progress):
            return .requestJSONEncodable(progress)
        }
    }
    
    var headers: [String : String]? {
        return ["Content-type" : "application/json"]
    }
}

let userId = "3cd53f80-4092-11e6-a911-07cbd6133361"
let authToken = "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIzY2Q1M2Y4MC00MDkyLTExZTYtYTkxMS0wN2NiZDYxMzMzNjEiLCJpYXQiOjE1MjYwNjEwNTV9.o85W4lIR9SfU9AqLhqw4kaHcdIIcrLOhU5HF4x8EXWo"

let provider = MoyaProvider<BetamaxAPI>(plugins: [AccessTokenPlugin(tokenClosure: authToken)]) //API 사용 //GET
//토큰을 사용해 접속한다. BetamaxAPI가 AccessTokenAuthorizable를 구현해야 한다.

//provider.request(.showScreencasts) { result in
//provider.request(.showVideo(id: 1419)) { result in
provider.request(.getProgress(userId: userId)) { result in
//API를 provider로 구현했기 때문에 엔드 포인트 전환이 매우 쉽다.
    
    switch result {
    case .success(let response): //성공
        print(response.statusCode)
        
        //.showScreencasts, .showVideo
//        print(String(bytes: response.data, encoding: .utf8)!)
        
        
        
        //.getProgress
        let progress = try! response.map([ProgressParams].self, atKeyPath: "viewings")
        //ProgressParams는 구조체로 디코딩할 수 있다.
        //ProgressParams가 Decodeable이라는 사실을 사용하여 JSON 데이터를
        //ProgressParams 구조체의 배열로 매핑한다.
        print(progress.filter { $0.videoId == 471 })
        //그런 다음 배열을 필터링하여 특정 비디오의 진행 상황을 검색한다.
    case .failure(let error): //실패
        print(error)
    }
}

//인증을 거치지 않으면 401: Access denied 오류가 난다.
//제대로 인증이 됐다면, 200: Success와 함께 JSON 데이터를 받아온다.




//Updating the progress for a video
let updatedProgress = ProgressParams(videoId: 471, time: 440, duration:
    447, finished: true) //API 사용 //POST //Progress Update

provider.request(.updateProgress(userId: userId, progress: updatedProgress)) { result in
    switch result {
    case .success(let response):
        print(response.statusCode)
    case .failure(let error):
        print(error)
    }
}




//Authenticating against the API
//standard bearer authentication를 인증 방식으로 사용한다.
//전송하는 각 request에는 컨텐츠 토큰이 있는 인증 헤더가 포함되어야 한다.
//Moya로 쉽게 구현할 수 있다.
extension BetamaxAPI: AccessTokenAuthorizable { //Moya의 AccessTokenAuthorizable를 구현
    var authorizationType: AuthorizationType {
        return .bearer
    }
}






