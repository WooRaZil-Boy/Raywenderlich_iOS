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

import RealmSwift
import RxSwift
import RxRealm
import RxCocoa

class ListTimelineViewModel {
  private let bag = DisposeBag()
  private let fetcher: TimelineFetcher
    
    //depedencies 주입 helper 상수
    let list: ListIdentifier
    let account: Driver<TwitterAccount.AccountStatus>
    //상수이기 때문에 초기화할 수 있는 유일한 곳은 생성자(
    //그것들은 상수이기 때문에 초기화 할 수 있는 유일한 곳은 init(account : list : apiType) 이다.

  // MARK: - Input
    //View Controller가 입력을 제공할 수 있게 일반 변수나 Rx의 Subject같은 공용 속성이 포함
    
    //DI된 변수와 init의 파라미터로 클래스 초기화 시에 input을 설정해 줄 수 있다.
    //public프로퍼티를 사용하면, View Model에 input을 제공해 줄 수 있다.
    //ex. DB 검색 앱에서, Text Field를 View Model의 input에 바인딩ㅎ한다.
    //검색 용어가 변경되면, View Model은 DB를 검색하고, output을 변경해 Table View에 새 결과가 바인딩 된다.
    var paused: Bool = false {
        //이 앱에서는 View Model은 TimelineFetcher를 일시 중지하고 다시 시작할 수 있는 input만 있다.
        //TimelineFetcher는 이미 Variable<Bool>을 사용하므로 View Model은 프록시 설정만 필요하다.
        didSet {
            fetcher.paused.value = paused //fetcher 클래스의 paused 값을 설정하는 프록시
        }
    }

  // MARK: - Output
    //View Model의 출력을 제공하는 모든 공용 속성(Observable 포함).
    //table/collection view에 drive할 객체의 목록이거나,
    //view controller가 앱의 UI에 drive할 때 사용할 다른 타입의 데이터들
    //p.388
    private(set) var tweets: Observable<(AnyRealmCollection<Tweet>, RealmChangeset?)>!
    //가져온 트윗 목록(Realm에서 Variable<Tweet>)
    private(set) var loggedIn: Driver<Bool>! //로그인 상태(Driver<Bool>)
    //View Model은 가져온 트윗 목록(Realm에서 Variable<Tweet>)과 로그인 상태(Driver<Bool>)를 내보낸다.

  // MARK: - Init
    //모든 DI를 수행하는 생성자들을 정의.
  init(account: Driver<TwitterAccount.AccountStatus>,
       list: ListIdentifier,
       apiType: TwitterAPIProtocol.Type = TwitterAPI.self) {
    
    self.account = account
    self.lisy = list

    // fetch and store tweets
    fetcher = TimelineFetcher(account: account, list: list, apiType: apiType)
    //해당 트윗을 가져온다.
    bindOutput()
    
    fetcher.timeline
        .subscribe(Realm.rx.add(update: true)) //TimelineFetcher의 output을 구독
        //결과를 Realm에 저장. Realm.rx.add는 들어온 객체들을 앱의 기본 Realm 데이터베이스에 유지한다.
        .disposed(by: bag)
  }

  // MARK: - Methods
  private func bindOutput() {
    //bind tweets
    guard let realm = try? Realm() else { return }
    
    tweets = Observable.changeset(from: realm.objects(Tweet.self))
    //Realm의 Results 클래스를 통해 쉽게 observable을 만들 수 있다.

    //bind if an account is available
    loggedIn = account //loggedIn 프로퍼티를 관리. account 구독
        .map { status in //status(true or false 매핑)
            switch status {
            case .unavailable: return false
            case .authorized: return true
            }
        }
        .asDriver(onErrorJustReturn: false)
  }
}

//사용자의 트윗을 가져온다. View Model

//View Model에서는 DI를 init에서 설정하고, 다른 클래스가 input을 할 수 있도록 프로퍼티를 추가한다.
//View Model 결과들을 다른 클래스에서 가져올 수 있도록 public으로 해 준다.
//View Model의 init 함수에 삽입 되지 않았다면 View Model은
//어떤한 View Controller, View, 다른 클래스를 알 수 없도록 구현했다.
