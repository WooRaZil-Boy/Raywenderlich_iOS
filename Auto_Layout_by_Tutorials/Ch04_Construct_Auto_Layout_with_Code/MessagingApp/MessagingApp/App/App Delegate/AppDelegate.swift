/// Copyright (c) 2019 Razeware LLC
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
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    //Launching a view controller from the storyboard in code
    
//    //project target의 Main Interface가 비어 있으면, 빈 검은 화면으로 앱이 시작한다.
//    //코드로 직접 스토리보드를 불러올 수 있다.
//    let storyboard = UIStoryboard(name: "TabBar", bundle: nil)
//    //스토리보드를 코드로 초기화한다.
//    let viewController = storyboard.instantiateInitialViewController()
//    //initial view controller에 대한 참조를 작성한다.
//    window = UIWindow(frame: UIScreen.main.bounds)
//    //기기의 화면 크기를 frame으로 하여 window를 설정한다.
//    window?.rootViewController = viewController
//    //initial view controller를 설정한다.
//    window?.makeKeyAndVisible()
//    //화묜에 표시하기 위해 makeKeyAndVisible를 호출해 줘야 한다. window가 표시되고 앱의 모든 window 위에 배치된다.
//    //대부분의 경우 하나의 window로 작업하지만, 앱의 콘텐츠 표시를 위해 새로운 window를 만들어야 하는 경우도 있다.
//    //ex. 앱에서 외부 디스플레이를 지원하는 경우 여러 window에서 작업할 수 있다.
//    //코드로 스토리보드를 초기화하는 경우 Interface Builder보다 해야할 작업이 일반적으로 많아진다.
    
    
    
    
    //Launching a view controller without initializing storyboard
    let viewController = TabBarController()
    window = UIWindow(frame: UIScreen.main.bounds)
    window?.rootViewController = viewController
    window?.makeKeyAndVisible()
    //스토리보드에서 코드로 viewController를 추가하면, 기본적으로 배경 view가 흰색으로 설정된다.
    //하지만, 코드로 viewControoler를 생성하면, view는 배경색이 nil이 되며 검은색이 된다.
    //코드로 viewController를 초기화할 때의 장점 중 하나는 viewController의 유형이 명시적이라는 것이다.
    //스토리보드의 initial view controller를 초기화할 때에는 반환된 viewController가 TabBarController인지 확인하는 추가 코드가 필요하다.
    
    return true
  }
}

//Interface Builder 외에도 VFL(Visual Format Language)을 사용해, 코드로 자동 레이아웃을 구성할 수 있다.
