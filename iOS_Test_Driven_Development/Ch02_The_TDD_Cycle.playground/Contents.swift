//Chapter 2: The TDD Cycle

//TDD Cycle에는 Color coded라 불리는 4 단계가 있다. p.28
//    1. Red : 실제 앱 코드를 작성하기 전에 실패하는 테스트를 작성한다.
//    2. Green : 테스트를 통과하기 위한 최소한의 코드를 작성한다.
//    3. Refactor : 앱 코드와 테스트 코드를 정리한다.
//    4. Repeat : 모든 기능이 구현될 때까지 해당 주기를 다시 시행한다.
//이를 Red-Green-Refactor Cycle이라 부르기도 한다. 이 색상들은 Xcode를 포함한 대부분 코드 편집기에 표시된다.
//    • 실패하는 테스트는 빨간색 X로 표시된다.
//    • 통과한 테스트는 녹색 check로 표시된다.




//Getting started
//금전 등록기 앱을 작성한다. TDD Cyle의 첫 번째 단계인 Red 부터 시작한다.




//Red: Write a failing test
//production code를 작성하기 전에 먼저 실패하는 테스트를 작성해야 한다. 가장 먼저 테스트 클래스를 작성한다.
import Foundation
import XCTest

class CashRegisterTests: XCTestCase { //XCTestCase는 XCTest library에 있다.
    //거의 모든 경우에 XCTestCase의 subclass로 테스트 클래스를 작성한다.
//    func testInit_createsCashRegister() {
//        //테스트 함수의 이름에 대한 규칙을 정해 두는 것이 좋다.
//        //테스트가 실패하면, Xcode는 테스트 클래스 및 메서드 이름을 알려주기 때문에 확실한 규칙을 지정해 두면 문제를 신속하게 확인할 수 있다.
//        XCTAssertNotNil(CashRegister()) //CashRegister 인스턴스 생성
//        //XCTAssertNotNil은 nil일 경우 Assert를 발생시킨다(nil일 경우 실패, nil이 아니어야 성공).
//    }
    //Refactor 과정에서 삭제
    
    var availableFunds: Decimal!
    var itemCost: Decimal!
    var sut: CashRegister!
    //production code와 마찬가지로, test code를 리팩토링하는 데 필요한 속성, 메서드, 클래스를 자유롭게 정의할 수 있다.
    
    override func setUp() {
        super.setUp() //처음에 슈퍼 클래스의 메서드를 호출하여 설정한다.
        availableFunds = 100
        itemCost = 42
        sut = CashRegister(availableFunds: availableFunds)
        //중복되는 availableFunds와 sut를 설정해 준다.
    }
    
    override func tearDown() {
        availableFunds = nil
        itemCost = nil
        sut = nil
        super.tearDown() //마지막에 슈퍼 클래스의 메서드를 호출한다.
        //tearDown은 setUp과 반대의 순서로 진행한다. 먼저 해제하려는 속성들을 설정한 다음 슈퍼 클래스를 호출한다.
    }
    //XCTestCase에서 setUp(), tearDown()이라는 특수 메서드를 사용할 수 있다. setUp()은 각 테스트 메서드가 실행되기 직전에 호출되며(설정),
    //tearDown()은 각 테스트 메서드가 완료된 직후에 호출(분리) 된다. 이 메서드들은 중복되는 로직을 해소하는 데 적합한 장소이다.
    //setUp() 내에서 설정한 속성들은 반드시 tearDown에서 nil이 되어야 한다.
    //이는 XCTest 프레임 워크 작동 방식 때문인데, XCTestCase의 subclass(여기서는 CashRegisterTests)를 인스터스화하고
    //모든 테스트가 실행될 때 까지 해당 속성들을 해제하지 않는다. 따라서 tearDown에서 속성을 nil로 설정하지 않으면, 메모리 누수가 일어난다.
    //테스트의 수가 많고, 제대로 속성을 해제 처리하지 않을 경우, 메모리 및 성능에 문제가 발생할 수 있다.

}
CashRegisterTests.defaultTestSuite.run() //CashRegisterTests 내에 정의된 테스트 메서드를 실행한다.
//실패하는 테스트를 작성했기 때문에 컴파일러는 Error를 발생시킨다. 컴파일 실패는 테스트 실패 이므로, Red 단계를 완료한 것으로 볼 수 있다. 다음 단계은 Green에서 테스트 통과를 위한 코드를 작성한다.

//Green: Make the test pass
//테스트를 통과하기 위한 최소한의 코드만 작성한다. 실제 앱 코드보다 테스트 코드를 우선시할 필요는 없다. 위의 Red 단계에서 컴파일 오류를 해결하기 위한 최소한의 코드는 CashRegister를 정의하는 것이다.
class CashRegister {
    var availableFunds: Decimal
    var transactionTotal: Decimal = 0
    
//    init(availableFunds: Decimal = 0) {
//        self.availableFunds = availableFunds
//    }
    //Refactor 과정에서 변경(default value 삭제)
    
    init(availableFunds: Decimal) {
        self.availableFunds = availableFunds
    }
    
    func addItem(_ cost: Decimal) {
//        transactionTotal = cost
        //transactionTotal을 매개변수로 전달된 cost로 설정한다. 이는 실제 앱에서 구현할 때는 틀린 로직이다.
        //하지만, 테스트에서는 단순히 테스트를 통과하기 위해 최소한의 코드만을 작성하는 것을 원칙으로 한다.
        //해당 메서드는 단일 transaction을 추가하는 것이고, 이 메서드의 테스트를 위한 최소한의 코드는 그대로 cost로 설정하는 것이다.
        
        transactionTotal += cost
    }
}

//Refactor: Clean up your code
//리팩터 단계에서 앱 코드와 테스트 코드를 모두 정리한다. 이렇게 지속적으로 코드를 유지 관리하고 개선해야 한다. 리팩토링 할 수 있는 몇 가지 사항은 다음과 같다.
// • Duplicate logic : 속성, 메서드, 클래스 등에서 중복을 제거한다.
// • Comments : 주석은 내용이 수행된 방식이 아니라, 수행된 이유를 설명해야 한다. 코드 작동 방식을 설명하는 주석은 제거한다.
//  큰 메서드를 여러 메서드로 나누고, 속성과 메서드의 이름을 보다 명확하게 구성해야 한다.
// • Code smells : 때로는 특정 코드 블록이 문제가 있는 것 처럼 느껴질 때가 있다. 개발자의 직감을 믿고 이런 "code smells"를 제거한다.
//  ex. 너무 많은 가정(?), 문자열 하드코딩 등. 메서드와 클래스를 추출하고, 이름을 바꾸거나 코드를 재구성해서 이러한 문제를 해결할 수 있다.
//현재 CashRegister, CashRegisterTests는 논리가 단순해 리팩토링 할 것이 없으므로 다음 단계로 넘어간다.

//Repeat: Do it again
//앱 개발 전반에 TDD를 최대한 활용한다. 각 TDD Cycle에서 작은 단위의 작업을 수행하고, 테스트로 뒷받침되는 앱 코드를 구축한다.
//앱의 모든 기능을 완료하면, 제대로 테스트 된 시스템이 갖춰지게 된다. 현재 작은 단위의 TDD Cycle을 완료 했다. 여기에 추가적인 기능을 구현하면서 cycle을 반복한다. 앞으로 추가할 리스트는 다음과 같다.
// • availableFunds를 받는 initializer를 작성한다.
// • transaction에 추가하는 addItem 메서드를 작성한다.
// • acceptPayment 메서드를 작성한다.




//TDDing init(availableFunds:)
//TDD cycle은 실패하는 테스트를 먼저 작성한다.
extension CashRegisterTests {
    func testInitAvailableFunds_setsAvailableFunds() {
//        // given
//        let availableFunds = Decimal(100)
//
//        // when
//        let sut = CashRegister(availableFunds: availableFunds) //system under test
        
        //then
        XCTAssertEqual(sut.availableFunds, availableFunds) //두 값이 동일해야 한다(다를 시, Assert).
        //다른 메서드에서 중복으로 사용하는 availableFunds과 sut를 인스턴스 변수로 생성했기 때문에 리팩토링 할 수 있다.
    }
}
//이전 테스트보다 다소 복잡하며, 세 가지 부분(given, when, then)으로 나눠진다.
// • given : 특정 조건이 주어지면(Given a certain condition...)
// • when : 어떤 행동이 일어날 때(When a certain action happens...)
// • then : 예상된 결과가 발생한다(Then an expected result occurs).
//위의 예에선, availableFunds로 Decimal(100)이 주어지고(given), init(availableFunds:)으로 sut을 생성할 때(when), sut.availableFunds와 availableFunds이 같을 것으로 예상된다(then).
//sut은 system under test의 약어이다. 아직 init(availableFunds:)를 작성하지 않았으므로 테스트가 실패해 Red 단계가 된다. 해당 속성과, 생성자를 CashRegister에 추가해 준다.
//위의 코드를 추가해 주면, availableFunds 매개변수를 받아 초기화할 수 있다. 컴파일하면, 해당 두 테스트 모두 통과하므로 Green 단계가 완료 된다.
//세 번째 단계인 Refactor에서 코드를 정리한다. 먼저 테스트 코드에서 init() 메서드가 없어졌으므로 testInit_createsCashRegister는 더 이상 사용하지 않는다.
//실제로 testInit_createsCashRegister()는 default 매개변수인 0을 사용하여 init(availableFunds:)를 호출한다. 따라서 testInit_createsCashRegister()를 삭제한다.
//앱 코드에서는 availableFunds의 default 값이 0인 것이 합리적인지 생각해 봐야 한다. testInit와 testInitAvailableFunds를 컴파일하는 데 유용했지만, 실제로 필요한 값인지 고민해야 한다.
//궁극적으로 이 문제는 design decision 이다(상황에 따라 알맞게 판단해서 결정하면 된다).
// • default 매개 변수를 유지하는 경우, testInit_setsDefaultAvailableFunds에 availableFunds가 예상된 default 값으로 설정되는지 추가적인 테스트를 고려할 수 있다.
// • 그렇지 않은 경우, default 매개변수를 제거할 수 있다.
//여기서는 default value가 의미 없다고 가정하고 이를 삭제한다. 컴파일을 하면, 테스트가 모두 통과한 것을 알 수 있다.
//리팩토링 이후에도 테스트를 통과한다는 것은 변경 사항이 기존 기능에서 오류를 일으키지 않는다는 안정성을 보장해 준다. 이는 TDD의 주요 이점이다.
//Refactor 단계도 완료되었으므로, 다음 주기로 넘어가 다시 실패하는 테스트(Red) 단계부터 시작해 필요한 기능을 추가해 준다.




//TDDing addItem
//항상 실패하는 테스트를 먼저 작성해야 한다.
extension CashRegisterTests {
    func testAddItem_oneItem_addsCostToTransactionTotal() {
        // given
        let availableFunds = Decimal(100)
        let sut = CashRegister(availableFunds: availableFunds)
        //다른 메서드에서 중복으로 사용하는 availableFunds과 sut를 인스턴스 변수로 생성했기 때문에 리팩토링 할 수 있다.
        
//        let itemCost = Decimal(42)
        //refactor 하면서 수정
        
        // when
        sut.addItem(itemCost)
        
        //then
        XCTAssertEqual(sut.transactionTotal, itemCost) //두 값이 동일해야 한다(다를 시, Assert).
    }
}
//addItem(_:)과 transactionTotal을 아직 정의하지 않았으므로 컴파일 시 오류가 발생한다(Red).
//CashRegister에 필요한 속성과 메서드를 추가해서 테스트를 통과하도록한다(Green).
//테스트 코드는 테스트 통과를 위한 최소한의 코드를 작성하는 것을 원칙으로 하기에 실제 실행되는 앱 코드와 논리적으로 로직이 맞지 않을 수 있다.
//단일 TDD Cycle을 완료했다고 해서 모든 작업이 끝난 것이 아니다. 모든 앱의 기능을 구현해야 한다.
//해당 구현에서 누락된 기능은 여러 item을 transaction에 추가하는 것이다. 이 작업을 처리하기 전에 작업한 내용을 리팩토링하여 현재 TDD Cycle을 완료한다.
//Refactor 단계에서는 코드의 중복이 있는지 확인한다. 여기서는 testInitAvailableFunds와 testAddItem 에서 availableFunds와 sut이 중복된다.
//중복 제거를 위해 CashRegisterTests에 인스턴스 변수를 작성한다. production code와 마찬가지로, test code를 리팩토링하는 데 필요한 속성, 메서드, 클래스를 자유롭게 정의할 수 있다.
//setUp(), tearDown()이라는 특수 메서드를 사용할 수 있다. setUp()은 각 테스트 메서드가 실행되기 직전에 호출되며(설정),
//tearDown()은 각 테스트 메서드가 완료된 직후에 호출(분리) 된다. 이 메서드들은 중복되는 로직을 해소하는 데 적합한 장소이다.
//setUp() 내에서 설정한 속성들은 반드시 tearDown에서 nil이 되어야 한다.
//이는 XCTest 프레임 워크 작동 방식 때문인데, XCTestCase의 subclass(여기서는 CashRegisterTests)를 인스터스화하고
//모든 테스트가 실행될 때 까지 해당 속성들을 해제하지 않는다. 따라서 tearDown에서 속성을 nil로 설정하지 않으면, 메모리 누수가 일어난다.
//테스트의 수가 많고, 제대로 속성을 해제 처리하지 않을 경우, 메모리 및 성능에 문제가 발생할 수 있다.
//이제 해당 속성을 사용해 중복된 로직을 제거한다. 리팩토링 이후에도 테스트가 통과하면 다음 TDD Cycle을 시작한다.




//Adding two items
//testAddItem_oneItem는 하나의 item만을 전달한다. 여러 개의 item을 전달할 때의 테스트를 추가한다. 역시 실패하는 테스트 부터 시작한다(Red).
extension CashRegisterTests {
    func testAddItem_twoItems_addsCostsToTransactionTotal() {
        // given
//        let itemCost = Decimal(42)
        let itemCost2 = Decimal(20)
        
        //refactor 하면서 수정
        let expectedTotal = itemCost + itemCost2
        
        // when
        sut.addItem(itemCost)
        sut.addItem(itemCost2)
        
        // then
        XCTAssertEqual(sut.transactionTotal, expectedTotal)
    }
}
//이어서, 테스트가 통과하도록 코드를 수정한다. 콘솔의 에러 메시지를 확인해 보면, sut.transactionTotal와 expectedTotal이 일치하지 않기 때문에 테스트가 통과되지 않는다.
//이전에 transactionTotal를 cost 그대로 할당해서 일치하지 않는다. 이를 수정해 준다. 테스트가 통과하면, 리팩토링 단계로 넘어간다.
//itemCost 변수가 중복되므로 인스턴스 변수로 가져오고, setUp과 tearDown에서 추가적인 로직을 구현한다.
//sut.addItem(itemCost)가 testAddItem_oneItem와 testAddItem_twoItems에서 반복되어서 중복 된다. 하지만 이 코드는 제거해선 안 된다.
//setUp()은 모든 테스트 메서드가 실행되기 전에 실행된다. testInitAvailableFunds 테스트는 addItem(_:)을 호출할 필요가 없기 때문에
//중복된다고 해서 모든 속성과 메서드를 setUp()로 이동시켜선 안 된다.
