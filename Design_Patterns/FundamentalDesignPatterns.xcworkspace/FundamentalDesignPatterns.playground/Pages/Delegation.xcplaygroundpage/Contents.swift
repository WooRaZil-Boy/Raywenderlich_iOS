/*:
 [Previous](@previous)&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Next](@next)
 
 # Delegation
 - - - - - - - - - -
 ![Delegation Diagram](Delegation_Diagram.png)
 
 The delegation pattern allows an object to use a helper object to perform a task, instead of doing the task itself.
 
 This allows for code reuse through object composition, instead of inheritance.
 
 ## Code Example
 */
//Delegate 패턴은 "helper" 객체를 사용해, 작업 자체보다는 데이터를 제공하거나 작업을 수행할 수 있게 한다.
//Delegate 패턴에는 세 가지 파트가 있다.
// • object needing a delegate (delegating object) : delegate가 있는 객체이다.
//  Delegate는 retain cycle을 피하기 위해 일반적으로 weak property으로 선언된다.
// • delegate protocol : delegate가 구현해야 하는 메서드를 정의하는 프로토콜이다.
// • delegate : delegate protocol을 구현하는 "helper" 객체
//구체적인 객체 대신에 delegate protocol를 사용하면, 구현이 훨씬 유연해 진다.
//protocol을 구현하는 모든 객체를 delegate로 사용할 수 있다.




//When should you use it?
//delegate 패턴을 사용해 큰 클래스를 나누거나, 제네릭을 만들거나, 재사용 가능한 구성요소를 작성한다.
//Delegate 패턴은 Apple의 UIKit에서 매우 흔하다. DataSource와 Delegate로 명명된 객체는
//다른 객체에게 데이터를 제공하거나 무언가를 요구하기 때문에 Delegate 패턴을 따른다.
//Apple 프레임워크는 DataSource라는 용어를 사용하여 데이터를 제공하는 메서드를 그룹화 한다.
//ex. UITableViewDataSource는 화면을 표시할 UITableViewCell을 제공한다.
//Apple 프레임워크는 Delegate 프로토콜을 사용하여, 데이터 또는 이벤트를 수신하는 메서드를 그룹화 한다.
//ex. UITableViewDelegate는 TableView의 행이 눌려지면 알림을 받는다.
//이렇게 dataSource와 delegate가 UITableView를 소유한 동일한 ViewController에 설정되는 것이 일반적이다.
//(반드시 그럴 필요는 없다. 다른 객체로 설정할 수도 있다.)




//Delegate 패턴은 Behavioral Pattern 중 하나로, 한 객체가 다른 객체와 통신하는 것을 정의한다.

import UIKit

public protocol MenuViewControllerDelegate: class { //사용자 정의 protocol
  func menuViewController(_ menuViewController: MenuViewController, didSelectItemAtIndex index: Int)
}

public class MenuViewController: UIViewController {
    public weak var delegate: MenuViewControllerDelegate?
    //일반적으로 객체가 생성된 후, delegate 객체를 설정한다.
    
    @IBOutlet public var tableView: UITableView! {
        //실제 앱에서는 Interface Builder 내 tableView에 @IBOutlet을 설정하거나
        //코드에서 tableView를 만든다.
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
            //IB에서 delegate, dateSource를 직접 설정하거나 코드로 지정해 줄 수 있다.
        }
    }
    
    private let items = ["Item 1", "Item 2", "Item 3"]
    //tableView의 title
}

//MARK: - UITableViewDataSource
extension MenuViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = items[indexPath.row]
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
}

//MARK: - UITableViewDelegate
extension MenuViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.menuViewController(self, didSelectItemAtIndex: indexPath.row)
        //구현을 위임하는 객체(여기서는 MenuViewController)에 method 호출을 전달하는 것이 일반적이다.
        //이렇게 하면, delegate가 필요한 경우 caller를 사용하거나 검사할 수 있다.
    }
}

//UITableViewDataSource와 UITableViewDelegate는 delegate protocol 이다.
//delegate protocol은 "helper" 객체가 구현해야 하는 메서드를 정의한다.
//이미 구현되어 있는 protocol 외에, 사용자가 직접 필요한 protocol을 생성할 수도 있다.
//일반적으로 객체가 생성된 후, delegate 객체를 설정한다.
//구현을 위임하는 객체(여기서는 MenuViewController)에 method 호출을 전달하는 것이 일반적이다.
//이렇게 하면, delegate가 필요한 경우 caller를 사용하거나 검사할 수 있다.




//What should you be careful about?
//delegate는 유용하지만, 남용될 수 있다. 객체에 너무 많은 delegate를 만드는 것에 주의해야 한다.
//한 객체에 여러 delegate가 필요한 경우, 너무 많은 로직이 뭉쳐 있음을 나타내는 지표일 수 있다.
//하나의 포괄적인 클래스 대신 특정 사례에 대해서 객체의 기능을 분리하는 것을 고려해야 한다.
//정해진 개수는 없지만, 어떤 작업을 이해하기 위해, 클래스 간에 전환이 빈번한 경우를 살펴 볼 수 있다.
//반대로, 특정 delegate가 필요한 이유를 이해할 수 없는 경우에는 너무 작은 단위로 나눴다는 신호가 될 수 있다.
//또한, retain cycle에 주의해야 한다. 대부분의 경우, delegate는 weak property여야 한다.
//해당 객체가 반드시 delegate를 가지고 있어야 하는 게 명백한 경우에는 생성자에 delegate를 추가하거나
//? 대신 !를 사용하여, forced unwrapping하는 것이 좋다.
//forced unwrapping하면, 객체를 사용하기 전에 delegate를 설정한다.
//strong delegate가 적합하다고 생각되는 경우에는 Delegate 패턴 대신 다른 패턴을 사용하는 게 더 적합하다.
//ex. strategy pattern


