/// Copyright (c) 2017 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?
  
  func applicationDidFinishLaunching(_ application: UIApplication) {
    
    //HealthKit authorization takes place immediately!
    authorizeHealthKit()
    window = UIWindow(frame: UIScreen.main.bounds)
    window?.rootViewController = CoordinatorViewController()
    window?.makeKeyAndVisible()
  }
  
  private func authorizeHealthKit() {
    HealthKitSetupAssistant.authorizeHealthKit { (authorized, error) in
      
      guard authorized else {
        
        let baseMessage = "HealthKit Authorization Failed"
        
        guard let error = error else { print(baseMessage); return }
        print("\(baseMessage). Reason: \(error.localizedDescription)")
        
        return
      }
      
      print("HealthKit Successfully Authorized.")
    }
  }
}

//Delegate와 Protocol 을 자주 사용하는 coordinator design pattern을 사용하면 UIViewController가 view를 표시하는 작업을 최적화 할 수 있다.
//많은 부분을 Delegate와 Protocol이 구현하기 때문에, ViewController는 작은 규모로 유지될 수 있다. ViewController는 view를 나타내는데에 집중한다.
//navigation, networking, HealthKit 등 과의 상호 작용이 모두 coordinator에게 위임된다.
//coordinator가 navigation을 처리하기 때문에 이 프로젝트는 스토리보드를 사용하지 않는다. 대신 각 UIViewController의 xib를 사용한다.
//각 ViewController 마다 담당하는 해당 page의 상호 작용을 처리하는 delegate가 있다.

//1. protocol 을 정의한다.
//2. ViewController에 delegate를 선언하고 필요한 부분에 메서드를 추가해 준다.
//3. coordinator에서 extension으로 protocol을 구현하고, delegate 메서드를 작성한다.

//coordinator는 각 ViewController를 변수로 가지고 있으면서 필요한 부분에 연결 시켜 준다.

//일반적인 디자인 패턴과 다소 다르지만, 코드 유지가 쉽고 coordinator에 navigation, networking등의 작업 책임이 있기에  ViewController가 단순해 진다.
//ViewController를 xib으로 생성하므로 빠르다.
