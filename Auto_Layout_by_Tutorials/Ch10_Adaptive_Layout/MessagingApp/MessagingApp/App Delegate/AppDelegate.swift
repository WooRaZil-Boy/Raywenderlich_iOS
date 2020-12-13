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
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let viewController = storyboard.instantiateInitialViewController()
    window = UIWindow(frame: UIScreen.main.bounds)
    window?.rootViewController = viewController
    window?.makeKeyAndVisible()
    
    let verticalRegularTrait = UITraitCollection(verticalSizeClass: .regular)
    //세로가 regular인 trait collection을 생성한다.
    let regularAppearance = UINavigationBar.appearance(for: verticalRegularTrait)
    //UINavigationBar의 수직 .regular에 대한 appearance를 가져온다.
    let regularFont = UIFont.systemFont(ofSize: 20)
    regularAppearance.titleTextAttributes = [NSAttributedString.Key.font: regularFont]
    //폰트의 사이즈를 바꿔준다. 수직으로 사용할 수 있는 공간이 많을 때 크기가 20이 된다.
    
    let verticalCompactTrait = UITraitCollection(verticalSizeClass: .compact)
    //세로가 compact인 trait collection을 생성한다.
    let compactAppearance = UINavigationBar.appearance(for: verticalCompactTrait)
    //UINavigationBar의 수직 .compact에 대한 appearance를 가져온다.
    let compactFont = UIFont.systemFont(ofSize: 14)
    compactAppearance.titleTextAttributes = [NSAttributedString.Key.font: compactFont]
    //폰트의 사이즈를 바꿔준다. 수직으로 사용할 공간이 별로 없을 때 크기가 14가 된다.
    
    return true
  }
}

//Use your layout guides
//시스템에는 앱이 다른 기기에서 잘 작동하도록 사전 정의된 레이아웃 가이드가 함께 제공된다.
//한가지 예가 아이폰 X notch에서 콘텐츠가 밀리는 것을 방지하는 Safe Area Layout Guide 이다.




//UIAppeareance
//UIAppeareance는 UINavigationBar, UIButton, UIBarButtonItem와 같은 일부 클래스의 appearance에 접근할 수 있다.
//이러한 클래스의 속성을 변경하면, 앱 전체에서 사용할 수 있는 일관된 테마를 만들 수 있다.
