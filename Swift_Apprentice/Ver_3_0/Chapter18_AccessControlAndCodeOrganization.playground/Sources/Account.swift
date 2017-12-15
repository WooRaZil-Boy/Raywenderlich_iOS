//Problems introduced by lack of access control
protocol Account {
    associatedtype Currency
    
    var balance: Currency { get } //read only
    func deposit(amount: Currency)
    func withdraw(amount: Currency)
}

public typealias Dollars = Double

open class BasicAccount: Account { // 다른 모듈의 메서드나 프로퍼티를 오버라이드 하려면 open이 필요하다.
    //    var balance: Dollars = 0.0 //get으로 되어 있지만, 기능 구현을 위해 변수로 선언해 버리면 balance에 직접 접근가능해 진다.
    public private(set) var balance: Dollars = 0.0 //한정자 선언. 비공개 설정.
    
    public init() {}
    
    public func deposit(amount: Dollars) {
        balance += amount
    }
    
    public func withdraw(amount: Dollars) {
        if amount <= balance {
            balance -= amount
        } else {
            balance = 0
        }
    }
}
