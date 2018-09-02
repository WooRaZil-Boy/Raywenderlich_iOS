import App
import Dispatch
import XCTest
import Foundation

final class AppTests : XCTestCase {
    func testNothing() throws {
        XCTAssert(true)
        
        let bar = Date()
        let foo = Date.init(timeIntervalSinceNow: 500)
        print("Bar: \(bar)")
        print("Foo: \(foo)")
        print("")
    }

    static let allTests = [
        ("testNothing", testNothing),
    ]
}
