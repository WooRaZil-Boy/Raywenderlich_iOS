import Foundation
import Combine

//Introducing publisher(for:options:)
let queue = OperationQueue()

//let subscription = queue.publisher(for: \.operationCount)
//    .sink {
//        print("Outstanding operations in queue: \($0)")
//    }




//Preparing and subscribing to your own KVO-compliant propertie
struct PureSwift {
    let a: (Int, Bool)
}

class TestObject: NSObject { //NSObject 프로토콜을 상속하는 클래스 생성 //KVO에 필요하다.
    @objc dynamic var integerProperty: Int = 0
    //관찰할 속성을 @objc dynamic로 표시한다.
    @objc dynamic var stringProperty: String = ""
    @objc dynamic var arrayProperty: [Float] = []
    
//    @objc dynamic var structProperty: PureSwift = .init(a: (0,false)) //PureSwift type
    //오류가 발생한다.
}

let obj = TestObject()

//let subscription = obj.publisher(for: \.integerProperty)
    //obj의 integerProperty 속성을 관찰하는 publisher를 생성하고 구독한다.
    //obj.publisher(for: \.stringProperty, options: [])
    //로 작성하면, 초기값을 생략할 수 있다.
//let subscription = obj.publisher(for: \.integerProperty, options: [.prior])
//    .sink {
//        print("integerProperty changes to \($0)")
//    }

let subscription2 = obj.publisher(for: \.stringProperty)
    .sink {
        print("stringProperty changes to \($0)")
    }

let subscription3 = obj.publisher(for: \.arrayProperty)
    .sink {
        print("arrayProperty changes to \($0)")
    }

obj.integerProperty = 100
obj.integerProperty = 200

obj.stringProperty = "Hello"
obj.arrayProperty = [1.0]
obj.stringProperty = "World"
obj.arrayProperty = [1.0, 2.0]
//값을 업데이트 한다.




//ObservableObject
class MonitorObject: ObservableObject {
    @Published var someProperty = false
    @Published var someOtherProperty = ""
}

let object = MonitorObject()
let subscription = object.objectWillChange.sink { //<Void, Never>로 실제 어떤 값이 변경됐는지는 알 수 없다.
    print("object will change")
}

object.someProperty = true
object.someOtherProperty = "Hello world"




//Key points
// • Key-Value Observing은 주로 Objective-C 런타임(runtime)과 NSObject 프로토콜(protocol)의 메서드(methods)에 의존(relies on)한다.
// • Apple 프레임 워크(frameworks)의 많은 Objective-C 클래스(classes)는 KVO를 준수(compliant)하는 속성(properties)을 제공한다.
// • NSObject를 상속(inheriting)하는 클래스(class)에 속해있고 @objc dynamic 특성(attributes)으로 표시된 고유한 속성(properties)을 관찰가능(observable)하게 만들 수 있다.
// • ObservableObject를 상속(inherit)하고, 속성(properties)에 @Published를 사용할 수도 있다.
//  컴파일러에서 생성한(compiler-generated) objectWillChange publisher는 @Published 속성 중 하나가 변경(changes)될 때마다 실행(triggers)된다.
//  하지만 어떤 속성이 변경(changed)되었는지는 알려주지 않는다.
