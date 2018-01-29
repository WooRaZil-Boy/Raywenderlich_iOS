//: Chapter18: Access Control and Code Organization

let account = BasicAccount()

account.deposit(amount: 10.00)
account.withdraw(amount: 5.00)

//account.balance = 100000000.00 //프로토콜에서는 read only이지만, 구현을 변수로 해버리면, 직접 접근이 가능해져 문제가 생길 수 있다.
//access control은 해킹을 방지하는 것이 아니라, 개발자의 오류를 수정하기 위한것.

//Introducing access control
//• private: Accessible only to the defining type, all nested types and extensions on that type within the same source file.
//• fileprivate: Accessible from anywhere within the source file in which it’s defined.
//• internal: Accessible from anywhere within the module in which it’s defined. This is
//the default access level.
//• public: Accessible from anywhere within the module in which it is defined, as well as
//another software module that imports this module.
//• open: The same as public, with the additional ability of being able to be overridden by code in another module.

let johnChecking = CheckingAccount()
johnChecking.deposit(amount: 300.00)
let check = johnChecking.writeCheck(amount: 200.0)!

let janeChecking = CheckingAccount()
janeChecking.deposit(check)
janeChecking.balance //200.00

janeChecking.deposit(check)
janeChecking.balance //200.00

//Playground sources
//Navigation bar를 이용해서 플레이그라운드에서도 Sources와 Resources를 관리할 수 있다.

//internal이 default. 모듈안에서는 어디에서든 접근 가능하다.

//open
class SavingsAccoutn: BasicAccount {
    var interestRate: Double
    
    init(interestRate: Double) {
        self.interestRate = interestRate
    }
    
    func processInterest() {
        let interest = balance * interestRate
        deposit(amount: interest)
    }
}

//라이브러리를 만들때 이런 조건들이 중요하다.

//Extensions by behavior
