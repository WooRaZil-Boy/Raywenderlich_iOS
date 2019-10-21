//
//  PersonTimelineViewModelTests.swift
//  Tweetie
//
//  Created by Marin Todorov on 12/5/16.
//  Copyright © 2016 Underplot ltd. All rights reserved.
//

import XCTest
import Accounts
import RxSwift
import RxCocoa
import Unbox
import RealmSwift
import RxBlocking

@testable import Tweetie

class PersonTimelineViewModelTests: XCTestCase {

  private func createViewModel(_ account: Driver<TwitterAccount.AccountStatus>) -> PersonTimelineViewModel {
    return PersonTimelineViewModel(
      account: account,
      username: TestData.listId.username,
      apiType: TwitterTestAPI.self)
  }

  func test_whenInitialized_storesInitParams() {
    let accountSubject = PublishSubject<TwitterAccount.AccountStatus>()
    let viewModel = createViewModel(accountSubject.asDriver(onErrorJustReturn: .unavailable))

    XCTAssertNotNil(viewModel.account)
    XCTAssertEqual(viewModel.username, TestData.listId.username)
  }

  func test_whenInitialized_bindsTweets() {
    TwitterTestAPI.reset()

    let accountSubject = PublishSubject<TwitterAccount.AccountStatus>()
    let viewModel = createViewModel(accountSubject.asDriver(onErrorJustReturn: .unavailable))

    let allTweets = TestData.tweetsJSON

    DispatchQueue.main.async {
      accountSubject.onNext(.authorized(AccessToken()))
      TwitterTestAPI.objects.onNext(allTweets)
    }

    let emitted = try! viewModel.tweets.asObservable().take(1).toBlocking(timeout: 1).toArray()
    XCTAssertEqual(emitted[0].count, 3)
    XCTAssertEqual(emitted[0][0].id, 1)
    XCTAssertEqual(emitted[0][1].id, 2)
    XCTAssertEqual(emitted[0][2].id, 3)
  }
}
