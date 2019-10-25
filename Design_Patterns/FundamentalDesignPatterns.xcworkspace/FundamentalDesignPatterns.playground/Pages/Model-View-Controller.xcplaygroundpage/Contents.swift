/*:
 [Previous](@previous)&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Next](@next)
 
 # Model-view-controller (MVC)
 - - - - - - - - - -
 ![MVC Diagram](MVC_Diagram.png)
 
 The model-view-controller (MVC) pattern separates objects into three types: models, views and controllers.
 
 **Models** hold onto application data. They are usually structs or simple classes.
 
 **Views** display visual elements and controls on screen. They are usually subclasses of `UIView`.
 
 **Controllers** coordinate between models and views. They are usually subclasses of `UIViewController`.
 
 ## Code Example
 */
//Model-View-Controller(MVC) 패턴은 객체를 세 가지 유형으로 구분한다.
// • Models : 응용 프로그램의 데이터를 보유한다.
//  일반적으로 struct 또는 class이다.
// • Views : 화면에 시각적인 요소와 컨트롤들을 표시한다.
//  일반적으로 UIView의 sub class이다.
// • Controllers : Model과 View를 조정(coordinate)한다.
//  일반적으로 UIViewController의 sub class이다.

//MVC는 UIKit에 적용된 디자인 패턴이기 때문에 iOS 프로그래밍에서 매우 일반적이다.
//Controller는 Model과 View의 strong property를 가지고 있어 직접 액세스할 수 있다.
//Controller는 둘 이상의 Model 또는 View를 가질 수도 있다.
//반대로 Model과 View는 이를 소유하고 있는 ViewController의 strong reference를
//가져선 안 된다. retain cycle을 발생 시키기 때문이다.
//대신 Model은 Controller의 property를 observing해서 통신하고,
//View는 IBAction으로 Controller와 통신한다.
//이를 활용해 여런 Controller간에 Model과 View를 재 사용할 수 있다.
//View는 delegate를 사용해, 이를 소유하고 있는 Controller에 대한 참조가 weak 일 수 있다.
//ex. UITableView는 이를 소유하는 ViewController에 대해 weak reference로
//delegate 및 dataSource를 가질 수 있다. 그러나 TableView는
//이들이 자신의 ViewController로 설정되어 있다는 것을 알지 못한다.
//Controller는 로직이 수행 중인 작업에 따라 달라지기 때문에 재사용하기 훨씬 어렵다.
//MVC에서는 Controller를 재사용하지 않는다.




//When should you use it?
//iOS 앱의 시작 패턴으로 MVC를 사용한다. 추가적인 패턴이 필요해 지면, 추가로 도입한다.




import UIKit

//MARK: - Address
public struct Address { //주소 구조체
    public var street: String
    public var city: String
    public var state: String
    public var zipCode: String
}

//MARK: - AddressView
public final class AddressView: UIView {
    @IBOutlet public var streetTextField: UITextField!
    @IBOutlet public var cityTextField: UITextField!
    @IBOutlet public var stateTextField: UITextField!
    @IBOutlet public var zipCodeTextField: UITextField!
}
//실제 iOS앱에서는 xib 또는 storyboard를 만들고, IBOutlet 속성을 연결한다.

//MARK : - AdressViewController
public final class AddressViewController: UIViewController {
    //MARK: - Properties
    //Controller가 소유한 View와 Model에 대한 strong reference가 있다.
    public var address: Address? {
        didSet {
            updateViewFromAddress() //Address가 변경되면 addressView 업데이트
            //Model이 Controller에 변경 사항이 있으며 View를 업데이트 해야한다고 알려준다.
        }
    }
    
    public var addressView: AddressView! {
        guard isViewLoaded else { return nil }
        //ViewController가 화면에 표시되기 전에 View가 생성되지 않도록 확인한다.
        
        return (view as! AddressView) //캐스팅
        //실제 앱에서는 xib 또는 storyboard에서 클래스를 지정해 주기 때문에 캐스팅할 필요없다.
    }
    //addressView는 getter만 있기 때문에 computed property이다.
    
    //MARK: - View Lifecycle
    public override func viewDidLoad() {
        super.viewDidLoad
        updateViewFromAddress() //addressView 업데이트
    }
    
    private func updateViewFromAddress() {
        guard let addressView = addressView, let address = address else { return }
        addressView.streetTextField.text = address.street
        addressView.cityTextField.text = address.city
        addressView.stateTextField.text = address.state
        addressView.zipCodeTextField.text = address.zipCode
    }
    
    //MARK: - Actions
    @IBAction public func updateAddressFromView(_ sender: AnyObject) {
        guard let street = addressView.streetTextField.text, street.count > 0,
            let city = addressView.cityTextField.text, city.count > 0,
            let state = addressView.stateTextField.text, state.count > 0,
            let zipCode = addressView.zipCodeTextField.text, zipCode.count > 0
            else {
                //TODO: - show an error message, handle the error, etc
                return
        }
        
        address = Address(street: street, city: city, state: state, zipCode: zipCode)
    }
    //View가 Controller에 변경 사항이 있으며 Model을 업데이트 해야한다고 알려준다.
    //실제 앱에서는 UITextField의 valueChanged 또는 UIButton의 touchUpInside 등의
    //이벤트에 @IBAction을 연결한다.
}
//Model과 View를 조정(coordinate)하는 것이 Controller의 역할이다.
//Controller는 address(Model)값으로 addressView(View)를 업데이트 한다.

//What should you be careful about?
//MVC는 한계가 있다. 모든 객체가 Model, View, Controller의 범주에 들지 않는 경우도 있다.
//MVC만 사용하는 앱은 Controller가 너무 많은 로직을 가지므로 ViewController 비대해진다.
//이런 "Massive View Controller" 문제를 해결하려면 다른 디자인 패턴도 함께 도입해야 한다.





