//
//  ListTimelineViewModel.swift
//  Tweetie
//
//  Created by Marin Todorov on 12/5/16.
//  Copyright © 2016 Underplot ltd. All rights reserved.
//

import XCTest
import Accounts
import RxSwift
import RxCocoa
import RxBlocking
import Unbox
import RealmSwift
import RxRealm

@testable import Tweetie

class ListTimelineViewModelTests: XCTestCase {

  private func createViewModel(_ account: Driver<TwitterAccount.AccountStatus>) -> ListTimelineViewModel {
    return ListTimelineViewModel(
      account: account,
      list: TestData.listId,
      apiType: TwitterTestAPI.self)
  }

  func test_whenInitialized_storesInitParams() {
    let accountSubject = PublishSubject<TwitterAccount.AccountStatus>()
    let viewModel = createViewModel(accountSubject.asDriver(onErrorJustReturn: .unavailable))

    XCTAssertNotNil(viewModel.account)
    XCTAssertEqual(viewModel.list.username+viewModel.list.slug, TestData.listId.username+TestData.listId.slug)
    XCTAssertFalse(viewModel.paused)
  }

  func test_whenInitialized_bindsTweets() {
    Realm.useCleanMemoryRealmByDefault(identifier: #function)

    let realm = try! Realm()
    try! realm.write {
      realm.add(TestData.tweets)
    }

    let accountSubject = PublishSubject<TwitterAccount.AccountStatus>()
    let viewModel = createViewModel(accountSubject.asDriver(onErrorJustReturn: .unavailable))
    let result = viewModel.tweets

    let emitted = try! result!.toBlocking(timeout: 1).first()!
    XCTAssertTrue(emitted.0.count == 3)
  }
}
