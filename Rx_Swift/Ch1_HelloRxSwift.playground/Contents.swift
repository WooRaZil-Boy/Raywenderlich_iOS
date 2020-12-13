//Chapter 1: Hello, RxSwift!

//RxSwift는 observable 시퀀스와 함수로 비동기 및 이벤트 기반 코드를 작성하고, 스케쥴러로 실행을 하는 라이브러리이다.
//RxSwift는 코드가 데이터에 반응하고 순차적으로 격리된 방식으로 처리할 수 있도록하는 비동기 프로그램 개발을 간소화한다.




//Introduction to asynchronous programming
//iOS는 다양한 종류의 API를 제공하여 서로 다른 스레드에서 작업을 수행하고 CPU의 다른 코어에서 수행할 수 있도록한다.
//하지만, 병렬로 실행되는 코드를 작성하는 것은 복잡하다. 특히 동일한 데이터를 다른 부분에서 작업해야 하는 경우 더욱 그렇다.

//Cocoa and UIKit asynchronous APIs
//iOS SDK에는 비동기 코드 작성을 위한 다양한 API들이 있다.
//• NotificationCenter : 디바이스의 방향을 바꾸거나 키보드가 팝업 되는 등, 관심있는 이벤트가 발생할 때마다 코드를 실행한다.
//• The delegate pattern : 함께 동작하는 다른 객체를 정의한다. 하지만 코드가 언제 실행되는 지 알 수 없는 경우도 있다.
//• Grand Central Dispatch : 작업 실행을 추상화한다. 순차적으로 코드를 실행하거나, 여러 대기열에서 우선 순위가 다른 작업을 실행할 수 있다.
//• Closures : 해당 코드에 전달하는 분리된 코드 조각으로 다른 객체에서 코드의 실행 여부, 횟수, 컨텍스트를 결정해 줄 수 있다.
//일반적으로 대부분의 코드는 비동기적으로 작동하고, UI이벤트는 본질적으로 비동기이다. 따라서 앱 코드 전체가 어떤 순서로 실행되는지 가정하는 것은 불가능하다.
//코드는 사용자 입력, 네트워크 등 다양한 이벤트 요소에 따라 다르게 실행된다.
//기본 SDK를 사용해도, 좋은 비동기코드를 작성할 수 있다. 하지만, 다양한 API가 섞이게 되면 비동기 코드 작성이 복잡해지는 경우가 많다.
//또한, 모든 비동기 API에는 보편적인 언어가 없으므로, 코드를 읽고 이해하고 실행하기 어려워 진다.

//Synchronous code
//배열을 생각해 볼 때, 동기적으로 각 배열 요소에 대한 연산을 수행하면, 컬렉션이 변경되지 않는다.
//이는 loop를 할 때, 각 요소가 있는지 확인할 필요가 없다. loop의 시작 부분에서 컬렉션 전체가 반복된다.

//var array = [1, 2, 3]
//
//for number in array {
//    print(number) // 1 2 3 출력 //4 5 6 이 나오지 않는다
//    array = [4, 5, 6]
//}
//
//print(array) // [4, 5, 6]

//Asynchronous code
//유사한 코드이지만, 버튼 탭에 대한 반응으로 반복이 실행된다.

//var array = [1, 2, 3]
//var currentIndex = 0
//
// This method is connected in Interface Builder to a button
//@IBAction func printNext(_ sender: Any) {
//    print(array[currentIndex])
//
//    if currentIndex != array.count - 1 {
//        currentIndex += 1
//    }
//}

//여기서 해당 함수 외에도, 다른 코드에서 currentIndex를 변경할 수도 있다.
//비동기 코드의 핵심 문제는 a) 작업이 수행되는 순서 b) 변경 가능한 데이터를 공유하는 순서 이다.
//RxSwift로 이 두 문제를 효과적으로 제어할 수 있다.

//Asynchronous programming glossary
//비동기 함수형 프로그래밍에 주로 쓰이는 기본 용어들

//1. State, and specifically, shared mutable state
//state는 앱의 모든 조합이라 생각하면 된다(메모리에 있는 데이터, 입력에 반응하는 아티팩트 등).
//앱에 문제가 있어 재실행하면, 동일한 조합이 다시 정상적으로 작동한다.
//비동기 구성 요소 간에 앱 state를 관리하는 것이 중요하다.

//2. Imperative programming
//명령형 프로그래밍은 프로그램의 state를 변경하는 패러다임이다.
//명령형 코드를 사용해 앱이 언제 어떻게 해야 작동해야 하는 지 정확하게 알려준다. 명령형 코드는 컴퓨터가 이해하는 코드와 유사하다.
//복잡한 비동기적인 프로그램에 명령형 코드를 작성하는 것은 어려운 일이며, 공유 state가 포함된 경우에는 더욱더 그렇다.

//3. Side effects
//side effect는 현재 코드 범위를 벗어난 곳에서 state가 변경되는 것을 말한다.
//예를 들어 디스크에 저장된 데이터를 수정하거나, text label의 텍스트를 업데이트 할 때, side effect가 발생한다.
//이 예에서 볼 수 있듯이 side effect가 나쁜 것을 의미하는 것이 아니다. 프로그램의 궁극적인 목표는 side effect를 일으키는 것이다.
//어떤 코드가 side effect를 발생시키고, 데이터를 처리하고 출력하는 지 알 수 있어야 한다.

//4. Declarative code
//명령형 프로그래밍에서는 state를 원할때 변경할 수 있지만, 함수형 프로그래밍에서는 side effect를 최소화하려고 한다.
//RxSwift 이 둘의 절충점에 있다. 선언적 코드를 사용해 동작을 정의하고,
//RxSwift는 관련 이벤트가 있을 때마다 동작을 실행하고 데이터를 제공한다.
//loop 범위에 있는 것처럼 생각하면 된다. immutable 데이터로 작업하고, 코드를 순차적이며 결정적으로 실행한다.

//5. Reactive systems
//Reactive에는 다음과 같은 특성이 있다.
//• Responsive : UI를 항상 최신 상태로 유지한다.
//• Resilient : 각 동작은 격리되어 있어 오류에 유연하다.
//• Elastic : 다양한 작업 부하를 처리한다(lazy pull 기반 데이터 수집, 이벤트 조절, 리소스 공유).
//• Message driven : 재사용 및 격리 기능을 개선하고 라이프 사이클과 클래스 구현을 분리한다.




//Foundation of RxSwift
//Rx 코드의 세 가지 building block은 observable, operator, scheduler 이다.

//Observables
//Observable<T>는 Rx 코드의 기초를 제공한다: 제네릭 데이터의 immutable 스냅샷을 전달할 수 있는 이벤트의 시퀀스를 비동기적으로 생성한다.
//다른 객체가 시간이 지남에 따라 emit하는 이벤트 또는 값을 subscribe 할 수 있도록 한다.
//Observable<T>는 하나 이상의 observer가 실시간으로 어떤 이벤트나 UI 업데이트에 반응 하거나, 데이터를 처리하고 활용할 수 있게 한다.
//Observable<T>가 구현한 ObservableType 프로토콜은 매우 간단하다.
//Observable은 다음 세 가지 유형의 이벤트만 emit할 수 있다.
//• A 'next' event : 최신(다음)의 데이터 값을 "전달"한다. Observable은 이벤트 완료 전까지 이 값을 무한정 emit할 수 있다.
//• A 'completed' event : 이벤트 시퀀스를 "성공"과 함께 종료한다. Observable은 수명 주기를 성공적으로 완료했기에 추가 이벤트를 emit 하지 않는다.
//• An 'error' event : Observable이 "오류"와 함께 종료되고, 추가 이벤트를 emit 하지 않는다.

//Observable 코드는 Observable 또는 observer에 대한 어떠한 가정도 하지 않으므로, 이벤트 시퀀스를 사용하는 것이 궁극적인 디커플링 관행이다.
//Observable을 사용하면, 클래스 간의 통신을 위해 delegate 프로토콜이나 closure를 삽입할 필요가 없어진다.
//Observable 시퀀스에는 finite과 infinite 두 가지 종류가 있다.

//Finite observable sequences
//Finite observable 시퀀스는 0, 1 혹은 그 이상의 값을 emit하고 시간이 흐른 뒤 "성공" 혹은 "오류"로 종료된다.

//ex. 인터넷에서 파일 다운로드 하는 경우, 일정하게 청크를 체크하면서 연결이 끊어지는 경우 "오류", 모든 데이터를 다운로드 한 경우 "성공" p.34
//API.download(file: "http://www...") //Observable<Data> 객체를 반환. 데이터의 값을 네트워크로 전달한다.
//    .subscribe(
//        onNext: { data in //onNext로 다음(next) 이벤트를 subscribe 한다.
//            // Append data to temporary file
//        },
//        onError: { error in //onError로 "오류" 이벤트를 subscribe 한다.
//            // Display error to user
//        },
//        onCompleted: { //onCompleted로 "성공" 이벤트를 처리한다.
//            // Use downloaded file
//        }
//    )

//Infinite observable sequences
//Infinite observable 시퀀스는 Finite observable 시퀀스와 달리 단순하게 무한히 지속된다. UI 이벤트는 보통 Infinite observable 시퀀스이다.

//ex. 앱의 디바이스 방향 변경에 대응하는 경우 p.36
//NotificationCenter 에서 UIDeviceOrientationDidChange 알림에 대한 observer를 추가한다.
//디바이스 방향 변경을 처리하기 위한 메서드 콜백을 작성한다.

//이런 디바이스 방향 변경 시퀀스는 끝이 없이 무한하게 존재해야 하므로, 시작할 때 항상 초기값을 가진다.
//사용자가 디바이스를 회전하지 않을 수도 있지만, 이렇다고 해서 이벤트가 종료되는 것이 아니라 단지 이벤트가 발생하지 않은 것이다.
//UIDevice.rx.orientation //Observable<Orientation>의 가상의 컨트롤 속성
//    .subscribe(onNext: { current in //subscribe 하고 방향에 따라 UI를 업데이트 한다.
//        switch current {
//        case .landscape:
//            // Re-arrange UI for landscape
//        case .portrait:
//            // Re-arrange UI for portrait
//        }
//    })
//onError, onCompleted 는 생략할 수 있다. "성공", "오류"는 Infinite observable에서 emit 될 수 없기 때문이다.





//Operators
//ObservableType과 Observable에서 복잡하 논리를 구현하기 위한 비동기 작업을 추상화하는 많은 메서드들이 있다.
//이 메서드는 각각 분리되어 있으면서, 조합할 수 있기 때문에 연산자라고 한다.
//연산자는 대부분 비동기 입력을 받아 side effect 없이 output을 생성하므로 퍼즐과 같이 쉽게 결합할 수 있고 큰 그림을 그릴 수 있다.
//Observable에서 emit 가능한 이벤트에 Rx 연산자를 적용하여 표현식이 최종값이 될 때까지 input과 output을 처리할 수 있다.
//최종값이 결정되면 이를 사용해 side effect를 유발할 수 있다.

//ex. Rx 연산자를 사용하도록 디바이스 방향 변경 예제를 수정하면 다음과 같다. p.37
//UIDevice.rx.orientation //UIDevice.rx.orientation으로 디바이스 방향에 대한 값을 가져올 수 있다.
//    //.landscape 이나 .portrait 값을 생성할 때마다 Rx는 해당 데이터에 연산자를 적용한다.
//    .filter { value in
//        return value != .landscape //.landscape가 아닌 값만을 통과시킨다.
//            //따라서 .landscape안 경우에는 바로 반환되어 subscribe 되지 않는다.
//        }
//        .map { _ in //filter 이후 값이 .portrait 인 경우에만 해당된다.
//            return "Portrait is the best!"
//        }
//        .subscribe(onNext: { string in //subscribe 해, 이벤트가 발생하면 alert으로 텍스트를 호출해 준다.
//            showAlert(text: string)
//        })

//이처럼 연산자를 조합하면, 단일 연산자를 수행한 것보다 훨씬 많은 작업을 쉽게 연결할 수 있다.




//Schedulers
//스케줄러는 Rx를 사용하는 Dispatch Queue로 훨씬 사용하기 편리하다.
//RxSwift에는 미리 정의된 여러가지 스케줄러가 있으며 대다수의 경우에 적용가능하므로 사용자가 따로 스케줄러를 만들지 않아도 된다.
//스케줄러는 매우 강력하며, 간단한 작업의 경우에는 사용하지 않는 경우도 많다.
//ex. GrandDispatch를 사용하는 SerialDispatchQueueScheduler로 큐를 연속적으로 실행하도록 지정할 수 있다. p.38
//ConcurrentDispatchQueueScheduler는 코드를 동시에 실행하며,
//OperationQueueScheduler로 주어진 OperationQueue에서 subscribe를 예약할 수 있다.
//이런 식으로 조합하면, 서로 같은 subscribe에 대해 여러 스케줄러에서 서로 다른 작업을 예약해 줄 수 있다.




//App architecture
//RxSwift는 앱의 아키텍처를 변경하지 않는다. 이벤트, 비동기 데이터 시퀀스, 범용 데이터 교환 등을 대체할 뿐이다.
//따라서 MVC(Model-View-Controller), MVP(Model-View-Presenter), MVVM(Model-View-ViewModel) 등 원하는 아키텍처를 구현할 수 있다.
//또한 처음부터 Rx를 사용해 프로젝트를 시작하지 않아도 된다. 기존 프로젝트를 Rx로 리펙토링하거나, 새로운 부분만 RxSwift를 사용할 수 있다.
//MVVM(Model-View-ViewModel) 아키텍처는 특히 RxSwift와 잘 어울리는 아키텍처이다.
//ViewModel을 사용하면 Observable<T> 속성을 노출할 수 있기 때문이다. 이 속성은 UIKit과 바인딩되기 때문에 ViewController와 결합이 쉽다.
//이렇게 Model 데이터를 UI로 바인딩하고 표현하는 코드를 짜는 것이 매우 간단해 진다. p.40
//책에서는 간단한 MVC 모델을 주로 사용한다.




//RxCocoa
//RxSwift는 일반적인 Rx를 구현한 것으로 Cocoa 나 UIKit을 알지 못한다.
//RxCocoa는 RxSwift의 동반 라이브러리로 UIKit및 Cocoa의 개발을 지원하는 모든 클래스를 가지고 있다.
//RxCocoa는 고급 클래스를 제공하고, 다양한 UI 구성 요소를 확장해 UI 이벤트를 subscribe 할 수 있도록 한다.
//ex. RxCocoa를 사용해 UISwitch의 상태 변경을 subscribe 한다. p.40
//toggleSwitch.rx.isOn //RxCocoa는 UISwitch에 rx.isOn 속성을 추가하여 이벤트를 Observable sequence로 subscribe 할 수 있다.
//    .subscribe(onNext: { isOn in
//        print(isOn ? "It's ON" : "It's OFF")
//    })

//이 외에도, UITextField, URLSession, UIViewController 등에 RxCocoa를 추가해 rx를 확장해 줄 수 있다.




//Installing RxSwift
//https://github.com/ReactiveX/RxSwift
//RxSwift는 MIT 라이선스로 배포하는 앱에 저작권 공지가 포함되어야 한다.
//RxSwift / RxCocoa를 앱에 포함시키는 가장 쉬운 방법은 CocoaPods 혹은 Carthage를 사용하는 것이다.

//RxSwift via CocoaPods
//use_frameworks!
//target 'MyTargetName' do
//pod 'RxSwift', '~> 4.4'
//pod 'RxCocoa', '~> 4.4'
//end




//Community
//http://community.rxswift.org
//https://github.com/RxSwiftCommunity
//http://slack.rxswift.org
