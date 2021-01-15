//
//  BullseyeTests.swift
//  BullseyeTests
//
//  Created by youngho on 2021/01/16.
//

import XCTest
@testable import Bullseye //target이 다르므로 import 해야 한다.

class BullseyeTests: XCTestCase {
  var game: Game!
  
  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    game = Game()
  }
  
  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    game = nil
  }
  
  func testScorePositive() {
    let guess = game.target + 5
    let score = game.points(sliderValue: guess)
    XCTAssertEqual(score, 95)
  }
  
  func testScoreNegative() {
    let guess = game.target - 5
    let score = game.points(sliderValue: guess)
    XCTAssertEqual(score, 95)
  }
}

//Test Navigator(⌘ + 6)에서 좌측 하단의 + 버튼을 눌러 New Unit Test Target을 클릭해 생성한다.
//⌃ + i 로 블록의 indent를 정렬할 수 있다.

//실패하는 테스트를 작성하고, 이를 통과하도록 수정하는 TDD로 앱을 작성한다.
