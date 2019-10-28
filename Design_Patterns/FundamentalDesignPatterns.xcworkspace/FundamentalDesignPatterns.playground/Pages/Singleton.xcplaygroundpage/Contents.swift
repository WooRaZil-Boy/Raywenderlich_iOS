/*:
 [Previous](@previous)&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Next](@next)
 
 # Singleton
 - - - - - - - - - -
 ![Singleton Diagram](Singleton_Diagram.png)
 
 The singleton pattern restricts a class to have only _one_ instance.
 
 The "singleton plus" pattern is also common, which provides a "shared" singleton instance, but it also allows other instances to be created too.
 
 ## Code Example
 */
//Singleton Pattern은 클래스를 하나의 인스턴스로만 제한한다.
//클래스에 대한 모든 참조는 동일한 기본 인스턴스를 나타낸다.
//이 패턴은 iOS 앱 개발에서 매우 일반적이다.




//When should you use it?
//클래스의 인스턴스가 여러 개 있을 때 문제가 발생하거나 논리적이지 않은 경우 사용한다.
//공유 인스턴스(Shared Instance)가 대부분의 경우 유용하지만,
//사용자 지정 인스턴스(Custom Instance)를 만들 수 있도록 허용하려면,
//Singleton plus Pattern을 사용하는 것이 좋다.
//파일 시스템 액세스와 관련된 모든 작업을 처리하는 FileManager가 그 예이다.
//Singleton인 기본 인스턴스가 있거나 직접 Singleton을 구현하는 객체를 만들 수 있다.
//background thread에서 사용하는 경우 일반적으로 직접 만든다.




//Playground example
//Singleton은 Shared Instance를 만드는 패턴이므로, Creational Pattern 이다.
//singleton과 singleton plus 패턴은 모두 Apple Framework에서 흔하다.
//ex. UIApplication은 Singleton 이다.

import UIKit

//MARK: - Singleton
let app = UIApplication.shared
//let app2 = UIApplication() //오류
//UIApplication는 Singleton이므로 두 개 이상의 인스턴스를 만들 수 없다.

//커스텀 Singleton을 생성할 수도 있다.
public class MySingleton {
    static let shared = MySingleton() //static 속성
    //Singleton Instance가 된다.
    private init() {} //추가적인 인스턴스 생성을 막기 위해 init를 private로 선언한다.
}

let mySingleton = MySingleton.shared //Singleton 인스턴스에 access할 수 있다.
//let mySingleton2 = MySingleton() //추가로 인스턴스를 생성하려고 하면 오류가 발생한다.

//MARK: - Singleton Plus
let defaultFileManager = FileManager.default //default instance
let customFileManager = FileManager() //추가로 새 instance를 생성할 수 있다.

//커스텀 Singleton plus를 생성할 수도 있다.
public class MySingletonPlus {
    static let shared = MySingletonPlus() //Singleton 처럼 static 으로 선언한다.
    public init() {}
    //Singleton과 달리 추가 인스턴스를 만들 수 있게 init를 public으로 선언한다.
}

let singletonPlus = MySingletonPlus.shared //default instance
let singletonPlus2 = MySingletonPlus() //추가로 instance를 생성할 수도 있다.




//What should you be careful about?
//Singleton Pattern은 남용되기 매우 쉽다. Singleton을 사용해야 하는 상황이라면,
//다른 방법으로 해결할 수 있는지 먼저 고려해 본다.
//ex. ViewController에서 다른 ViewController로 데이터를 전달하는 경우,
//Singleton은 적합하지 않다. 대신 생성자나 속성으로 전달하는 것이 좋다.
//실제로 Sigleton이 필요하다고 판단되면, Singleton plus가 더 적합한지 고려한다.
//한 개 이상의 인스턴스를 생성하는 것이 문제를 일으키는지, 커스텀 인스턴스를 사용하는 것이 유용한지
//등에 따라 singleton과 singleton plus 중 어느 것을 사용할지 결정한다.
//Singleton이 문제가 되는 가장 일반적인 경우는 Test이다.
//Singleton과 같은 전역 객체에 state가 저장되어 있으면 테스트하기 매우 힘들어 진다.
//마지막으로 Singleton이 적합하지 않다는 "code smell"에 주의해야 한다.
//ex. 많은 custom 인스턴스가 필요한 경우, 일반 객체로 사용하는 것이 나을 수 있다.

