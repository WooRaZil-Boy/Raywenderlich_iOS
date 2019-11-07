/*:
 [Previous](@previous)&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Next](@next)
 
 # Model-View-ViewModel (MVVM)
 - - - - - - - - - -
 ![MVVM Diagram](MVVM_Diagram.png)
 
 The Model-View-ViewModel (MVVM) pattern separates objects into three types: models, views and view-models.
 
 - **Models** hold onto application data. They are usually structs or simple classes.
 - **View-models** convert models into a format that views can use.
 - **Views** display visual elements and controls on screen. They are usually subclasses of `UIView`.
 
 ## Code Example
 */
//Model-View-ViewModel(MVVM)은 객체를 3가지 그룹으로 분리하는 Design Pattern이다.
// • Model : 앱 데이터를 보유한다. 일반적으로 Struct 혹은 Class 이다.
// • View : 시각적 요소와 컨트롤을 표시한다. 일반적으로 UIView의 subclass 이다.
// • View Model : Model 정보를 View에서 표시할 수 있는 value로 변환한다.
//  참조를 전달할 수 있어야 하므로 일반적으로 class이다.
//MVC(Model-View-Controller)와 매우 유사한 패턴이다.
//위의 다이어그램에도 ViewController가 포함되어 있다.
//MVVM에도 ViewController가 존재하지만, 그 역할은 최소화된다.
//여기서는 MVC 프로젝트를 MVVM으로 리팩토링한다.




//When should you use it?
//Modeol을 View의 다른 표현으로 변환해야 할 때 이 패턴을 사용한다.
//ex. View Model을 사용하여 Date를 date-formatted String 으로 변환,
//  Decimal을 currency-formatted String 으로 변환 등
//MVVC 패턴은 MVC를 보완한다.
//View Model없이 ViewController에 Model을 View로 변환하는 코드를 넣을 수 있다(MVC).
//하지만, ViewController는 view lifecycle event, IBAction 콜백 등
//상당히 많은 작업을 처리한다. 따라서 ViewController가 비대해지기 때문에
//MVC는 Massive View Controller 라고 농담하기도 한다.
//ViewController가 과도하게 커지는 경우, MVC 이외의 다른 패턴을 고려해 보는 것이 좋다.
//MVVM은 여러 Model 간의 변환이 필요한 대규모 ViewController를 줄이는 좋은 방법이다.




//Playground example
//애완동물을 분양하는 앱의 일부로 Pet View를 작성한다.

import PlaygroundSupport
import UIKit

//MARK: - Model
public class Pet {
    public enum Rarity {
        case common
        case uncommon
        case rare
        case veryRare
    }
    
    public let name: String //이름
    public let birthday: Date //생일
    public let rarity: Rarity //희귀도
    public let image: UIImage //이미지
    
    public init(name: String, birthday: Date, rarity: Rarity, image: UIImage) {
        self.name = name
        self.birthday = birthday
        self.rarity = rarity
        self.image = image
    }
}
//해당 속성들을 View에 표시해야 하지만, birthday, rarity는 바로 표시할 수 없다.
//먼저 View Model로 변환한 후 표시해야 한다.

//MARK: - ViewModel
public class PetViewModel {
    private let pet: Pet
    private let calendar: Calendar
    
    public init(pet: Pet) {
        self.pet = pet
        self.calendar = Calendar(identifier: .gregorian)
    }
    
    public var name: String { //computed property
        return pet.name
    }
    //모든 애완동물 이름에 접두어(prefix)를 추가해야 한다면, 여기서 간단히 구현할 수 있다.
    
    public var image: UIImage { //computed property
        return pet.image
    }
    
    public var ageText: String { //computed property
        let today = calendar.startOfDay(for: Date())
        let birthday = calendar.startOfDay(for: pet.birthday)
        let components = calendar.dateComponents([.year], from: birthday, to: today)
        let age = components.year!
        //Calendar를 사용해, 생일과 오늘 날짜의 차이를 연도로 계산해서 반환한다.
        
        return "\(age) years old"
    }
    
    public var adoptionFeeText: String { //computed property
        switch pet.rarity {
        case .common:
            return "$50.00"
        case .uncommon:
            return "$75.00"
        case .rare:
            return "$150.00"
        case .veryRare:
            return "$500.00"
        }
    }
    //희귀도에 따라 애완동물의 분양 가격을 String으로 변환하여 반환한다.
}

//MARK: - View
public class PetView: UIView {
    public let imageView: UIImageView
    public let nameLabel: UILabel
    public let ageLabel: UILabel
    public let adoptionFeeLabel: UILabel
    
    public override init(frame: CGRect) {
        var childFrame = CGRect(x: 0, y: 16, width: frame.width, height: frame.height / 2)
        imageView = UIImageView(frame: childFrame)
        imageView.contentMode = .scaleAspectFit
        
        childFrame.origin.y += childFrame.height + 16
        childFrame.size.height = 30
        nameLabel = UILabel(frame: childFrame)
        nameLabel.textAlignment = .center
        
        childFrame.origin.y += childFrame.height
        ageLabel = UILabel(frame: childFrame)
        ageLabel.textAlignment = .center
        
        childFrame.origin.y += childFrame.height
        adoptionFeeLabel = UILabel(frame: childFrame)
        adoptionFeeLabel.textAlignment = .center
        
        super.init(frame: frame)
        
        backgroundColor = .white
        addSubview(imageView)
        addSubview(nameLabel)
        addSubview(ageLabel)
        addSubview(adoptionFeeLabel)
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
      fatalError("init?(coder:) is not supported")
    }
}
//이미지와 3개의 text를 표시하는 PetView를 작성한다.

extension PetViewModel {
    public func configure(_ view: PetView) {
        view.nameLabel.text = name
        view.imageView.image = image
        view.ageLabel.text = ageText
        view.adoptionFeeLabel.text = adoptionFeeText
    }
}

//MARK: - Example
let birthday = Date(timeIntervalSinceNow: (-2 * 86400 * 366))
let image = UIImage(named: "stuart")!
let stuart = Pet(name: "Stuart", birthday: birthday, rarity: .veryRare, image: image)
//Pet 생성

let viewModel = PetViewModel(pet: stuart) //ViewModel 생성

let frame = CGRect(x: 0, y: 0, width: 300, height: 420)
let view = PetView(frame: frame) //View 생성

//view.nameLabel.text = viewModel.name
//view.imageView.image = viewModel.image
//view.ageLabel.text = viewModel.ageText
//view.adoptionFeeLabel.text = viewModel.adoptionFeeText
//ViewModel을 사용해, view의 subview들을 설정한다.

viewModel.configure(view) //ViewModel class의 메서드로 해당 설정 코드를 옮겨준다.

PlaygroundPage.current.liveView = view
//Playground의 Assistant editor에서 해당 view를 렌더링하도록 설정한다.
//렌더링 되지 않는다면, Editor ▸ Live View 를 체크한다.

//ViewModel을 가져와서 속성일 일일이 설정해주기 보다, 메서드를 사용해 ViewModel 내부에서
//처리되도록 하는 것이 더 깔끔한 구현방법이다(configure(_:) 사용).
//View가 하나인 View-Model에서는 이렇게 View Model 안에 View를 구성하는 코드를 넣는 것이 좋다.
//하지만, View-Model에서 제어하는 View가 2개 이상이라면, 위와 같이 View Model에
//View를 구성하는 메서드를 작성하는 것이 혼란스러울 수 있다.
//이 경우에는 각 View 마다 구성 코드를 별도로 가지고 있는 것이 더 간단할 수 있다.




//What should you be careful about?
//앱에서 Model-to-View 변환이 빈번하게 일어나는 경우에 MVVM을 사용하기 좋다.
//하지만, 모든 객체가 Model, View, ViewModel의 범주에 깔끔하게 들어 맞지는 않는다.
//이런 경우에는 다른 디자인 패턴과 함께 MVVM을 사용해야 한다.
//또한, 앱을 처음 만들 때 MVVM이 그다지 유용하지 않고 오히려 MVC가 나은 출발점이 될 수 있다.
//규모가 커지고, 로직이 많아질 때 디자인 패턴을 MVVM으로 변경하는 것이 더 좋을 수 있다.



