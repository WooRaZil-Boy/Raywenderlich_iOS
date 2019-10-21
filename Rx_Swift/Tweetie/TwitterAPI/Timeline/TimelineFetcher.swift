/*
 * Copyright (c) 2016-2017 Razeware LLC
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
import RxRealm

import RealmSwift
import Reachability
import Unbox

class TimelineFetcher {

  private let timerDelay: TimeInterval = 30
  private let bag = DisposeBag()
  private let feedCursor = Variable<TimelineCursor>(.none)

  // MARK: input
  let paused = Variable<Bool>(false)

  // MARK: output
  let timeline: Observable<[Tweet]>
  // MARK: Init with list or user

  //provide list id to fetch list's tweets
  convenience init(account: Driver<TwitterAccount.AccountStatus>, list: ListIdentifier, apiType: TwitterAPIProtocol.Type) {
    self.init(account: account, jsonProvider: apiType.timeline(of: list))
  }

  //provide username to fetch user's tweets
  convenience init(account: Driver<TwitterAccount.AccountStatus>, username: String, apiType: TwitterAPIProtocol.Type) {
    self.init(account: account, jsonProvider: apiType.timeline(of: username))
  }

  private init(account: Driver<TwitterAccount.AccountStatus>, jsonProvider: @escaping (AccessToken, TimelineCursor) -> Observable<[JSONObject]>) {
    //
    // subscribe for the current twitter account
    //
    let currentAccount: Observable<AccessToken> = account
      .filter { account in
        switch account {
        case .authorized: return true
        default: return false
        }
      }
      .map { account -> AccessToken in
        switch account {
        case .authorized(let acaccount):
          return acaccount
        default: fatalError()
        }
      }
      .asObservable()

    // timer that emits a reachable logged account
    let reachableTimerWithAccount = Observable.combineLatest(
      Observable<Int>.timer(0, period: timerDelay, scheduler: MainScheduler.instance),
      Reachability.rx.reachable,
      currentAccount,
      paused.asObservable(),
      resultSelector: { _, reachable, account, paused in
        return (reachable && !paused) ? account : nil
      })
      .filter { $0 != nil }
      .map { $0! }

    let feedCursor = Variable<TimelineCursor>(.none)

    // Re-fetch the timeline

    timeline = reachableTimerWithAccount //Observable Timer
        .withLatestFrom(feedCursor.asObservable(), resultSelector: { account, cursor in
            //feedCursor와 결합
            //트위터 타임라인에 현재 위치 저장한 뒤 이미 가져온 트윗을 나타내게 된다.
            return (account: account, cursor: cursor)
        })
        .flatMapLatest(jsonProvider) //jsonProvider는 init에 삽입된 클로저
        //각 convinience init는 다른 API를 가져온다.
        //flatMapLatest(jsonProvider)을 추가함으로써, 메인 생성자인 init(account : jsonProvider :)에서
        //각 분기를 나누지 않고 구현할 수 있다. jsonProvider는 Observable<[JSONObject]>를 반환.
        .map(Tweet.unboxMany) //Observable<[JSONObject]>를 Observable<[Tweet]>으로 매핑
        //JSON 객체를 Array<Tweet> 으로 변환한다.
        //timeline은 public observable 이기 때문에 View Model은 가장 최근의 트윗 리스트에 액세스 한다.
        //View Model은 트윗들을 디스크에 저장하거나 앱의 UI로 drive하는데 사용되는게 전부다.
        //TimelineFetcher는 트윗을 불러오고 결과를 내보낸다.
        .share(replay: 1, scope: .whileConnected) //공유
        //p.387
    
    // Store the latest position through timeline
    
    timeline
        .scan(.none, accumulator: TimelineFetcher.currentCursor)
        //timeline 구독은 반복 호출되기 때문에 동일한 트윗을 가져오는 것을 방지하기 위해
        //최종 불러온 트윗의 위치(커서)를 저장해야 한다.
        //TimelineCursor는 불러온 트윗의 가장 최근과 가장 오래된 트윗의 ID를 가지고 있는 구조체
        //scan으로 ID를 트래킹한다.
        .bind(to: feedCursor) //feedCursor는 Variable<TimelineCursor>에서 TimelineFetcher 프로퍼티
        .disposed(by: bag)
  }

  static func currentCursor(lastCursor: TimelineCursor, tweets: [Tweet]) -> TimelineCursor {
    return tweets.reduce(lastCursor) { status, tweet in
      let max: Int64 = tweet.id < status.maxId ? tweet.id-1 : status.maxId
      let since: Int64 = tweet.id > status.sinceId ? tweet.id : status.sinceId
      return TimelineCursor(max: max, since: since)
    }
  }
}

//앱이 연결되어 있는 동안 가장 최근 트윗을 자동으로 불러오는 역할을 한다. Rx 타이머로 JSON을 반복해서 구독한다.
//init가 두 개 있다. 각각 주어진 트위터 목록에서 트윗을 가져온다, 주어진 사용자의 트윗을 가져온다.
//MVVM에서 네트워킹 작업은 View Model에 삽입하는 클래스에서 따로 설정.
