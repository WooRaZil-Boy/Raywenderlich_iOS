/*:
 [Previous](@previous)&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Next](@next)
 
 # Observer
 - - - - - - - - - -
 ![Observer Diagram](Observer_Diagram.png)
 
The observer pattern lets one object observe changes on another object. Apple added language-level support for this pattern in Swift 5.1 with the addition of Publisher in the Combine framework.
 
 This pattern involves three types:
 
 (1) The **subscriber** is the "observer" object and receives updates.
 
 (2) The **publisher** is the "observable" object and sends updates.
 
 (3) The **value** is the underlying object that's changed.
 
 ## Code Example
 */
//Observer Pattern을 사용하면, 한 객체가 다른 객체의 변경 사항을 관찰할 수 있다.
//Swift 5.1의 Combine 프레임워크에서 사용하는 Publisher를 사용해
//language-level 에서 Observer Pattern을 구현할 수 있다.
//Observer Pattern은 세 가지 파트로 구성된다.
// 1. subscriber : observer 객체이며, 업데이트를 받는다.
// 2. publisher : observable객체이며, 업데이트를 보낸다.
// 3. value : 근본적으로 변경된 객체이다.




//When should you use it?
//다른 객체에 대한 변경 사항을 받으려면, Observer Pattern을 사용한다.
//이 패턴은 MVC에서 종종 사용 되는데, ViewController에는 subscriber(s)가 있고,
//Model에는 publisher(s)가 있다. Observer Pattern을 사용하면,
//Model은 ViewController 유형에 대해 알 필요 없이
//변경 사항을 ViewController로 전달 할 수 있다.
//따라서 다른 ViewController가 동일한 Model 유형의 변경 사항을 사용하고 관찰할 수 있다.




//Playground example
//Observer Pattern은 Behavioral Pattern 중의 하나이다.
//Observer가 한 객체가 다른 객체를 관찰하는 것이기 때문이다.

import Combine //Combine을 가져온다.

public class User {
    //class 이외의 struct 또는 다른 유형에서는 @Published 속성을 사용할 수 없다.
    @Published var name: String
    //@Published 주석을 달면, Xcode에서 해당 속성에 대한 Publisher를 자동으로 생성한다.
    //let 속성은 변경되지 않기 때문에, @Published 주석을 사용할 수 없다.
    
    public init(name: String) {
        self.name = name
    }
}

let user = User(name: "Ray") //User 생성
let publisher = user.$name
//user의 name의 변경을 broadcasting 하기 위해 publisher에 엑세스 한다(user.$name).
//Published<String>.Publisher 타입을 반환한다.
//이 객체는 업데이트 사항을 받을 수 있다.

var subscriber: AnyCancellable? = publisher.sink() {
    //sink를 호출하여 subscriber를 만든다.
    //클로저에서 초기값과 값이 변경될 때 마다 호출되는 코드를 입력해 준다.
    //기본적으로 sink()는 AnyCancellable를 반환해야 하지만
    //여기에서는 나중에 nil을 입력할 수도 있도록 AnyCancellable? 를 쓴다.
    print("User's name is \($0)")
}

user.name = "Vicki" //name 변경

//  User's name is Ray
//  User's name is Vicki
//콘솔에 위와 같이 출력된다.

subscriber = nil
//subscriber를 nil로 하면, 더 이상 publisher로 부터 업데이트를 받지 않는다.
user.name = "Ray has left the building"
//subscriber가 nil 이므로 출력이 표시 되지 않는다.




//What should you be careful about?
//Observer pattern을 구현하기 전에 업데이트 되는 사항과 조건을 정의해야 한다.
//객체 또는 속성이 변경될 이유가 없다면, var 나 @Published로 선언하지 말고
//let으로 선언해야 한다.
//ex. 고유 식별자(unique identifier)는 정의되면 변경되지 않아야 하므로
//published property로 적합하지 않다.
