///// Copyright (c) 2018년 Razeware LLC
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

import XCTest
@testable import TrainService
//test 시 import는 @testable키워드를 넣어줘야 한다.

class TicketTests: XCTestCase { //모듈 테스트
  func testPurchase() {
    let api = UserAPI()
    let testWallet = Wallet(username: "Tester Jones", balance: 100.0, tickets: [])
    let wait = expectation(description: "buy a ticket")
    
    api.buyTicket(lineId: 10, cost: 30, wallet: testWallet) { result in
      let newWallet = result.value!
      XCTAssertEqual(newWallet.balance, 70)
      
      let ticket = newWallet.tickets[0]
      XCTAssertEqual(ticket.cost, 30)
      XCTAssertFalse(ticket.activated)
      
      wait.fulfill()
    }
    
    waitForExpectations(timeout: 1, handler: nil)
  }
}
