import Foundation

//Private
public class CheckingAccount: BasicAccount { //Sources 안에는 다른 모듈. 따라서 default보다 더 낮은 수준의 접근자를 써줘야 한다.
    private let accountNumber = UUID().uuidString //UUID로 유니크한 숫자를 생성
    
    private var issuedChecks: [Int] = []
    private var currentCheck = 1
    
    public override init() {}
    
    public class Check {
        let account: String
        var amount: Dollars
        private(set) var cashed = false //선언한 코드 블럭 내에서만 접근이 가능하다. 여기서는 CheckingAccount에서도 접근 불가.
        
        func cash() {
            cashed = true
        }
        
        fileprivate init(amount: Dollars, from account: CheckingAccount) { //중첩된 initializer
            //private가 아닌 fileprivate로. 이 lexicalfmf 벗어난 writeCheck에서도 사용되므로.
            self.amount = amount
            self.account = account.accountNumber
        }
    }
    
    public func writeCheck(amount: Dollars) -> Check? {
        guard balance > amount else {
            return nil
        }
        
        let check = Check(amount: amount, from: self)
        withdraw(amount: check.amount)
        
        return check
    }
    
    public func deposit(_ check: Check) {
        guard !check.cashed else {
            return
        }
        
        deposit(amount: check.amount)
        check.cash() //cashed가 private로 선언되어 있으므로, 여기서 직접 값을 바꿀 수 없다.
        //cash 메서드(cashed와 같은 코드블럭에 위치)를 이용해야만 한다.
    }
}

private extension CheckingAccount { //extension을 이와같이 private로 해줄 수도 있다.
    //이렇게 선언하고 extension하면 밑의 메서드들은 모두 private 속성을 가지게 된다.
    func inspectForFraud(with checkNumber: Int) -> Bool {
        return issuedChecks.contains(checkNumber)
    }
    
    func nextNumber() -> Int {
        let next = currentCheck
        currentCheck += 1
        
        return next
    }
}

//Extensions by protocol conformance
extension CheckingAccount: CustomStringConvertible { //이런 식으로 구현을 하게 되면, 필요한 부분만 따로 정리하고, 나중에 삭제할 일이 있을 때도 쉽게 할 수 있다.
    public var description: String {
        return "Checking Balance: $\(balance)"
    }
}
