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
import InfoService
import UserService

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  static let sharedModel = Model()
  static let sharedUserModel = UserModel(api: UserService.API()) //싱글톤
}

//앱을 모듈로 분리한다. 이렇게 분리해 놓으면, 다른 어플래케이션에서 쉽게 재사용할 수 있다.

//Create a new framework
//Project Editor에서 "+" 버튼을 눌러 새 target을 설정한다.
//이 후, iOS > Framework & Library > Cocoa Touch Framework 선택

//단순히 마우스로 Drag & Drop만 해도 Target이 자동으로 바뀐다.




//Create a static User Service Library
//동적 프레임워크를 정적 프레임워크로 변환한다.
//Project Editor에서 "+" 버튼을 눌러 새 target을 설정한다.
//iOS > Framework & Library > Cocoa Touch Static Library
//해당 라이브러리(UserService)에서 필요한 파일들을 이전의 동적 라이브러리 폴더에서 Drag & Drop으로 가져온다.
//target이 맞게 설정되었는지 다시 확인해볼 것
//이전의 동적 라이브러리(UserService)는 사용하지 않으므로 Project Editor에서 "-" 버튼을 눌러 삭제해 준다.
//UserServiceStatic을 선택하고, Build Phases > Target Dependencies에서
//이전 동적 라이브러리에서 의존하던 라이브러리(Helpers)를 똑같이 추가해 준다.
//TrainTime(메인 앱)을 선택하고, General > Linked Frameworks and Libraries에서 정적 라이브러리를 추가해 준다.
//UserService에서 UserServiceStatic으로 바뀌었다. 코드에서 UserService로 쓴 부분을 고쳐준다.
//Clean & Build




//Create a static Info Service library
//동적 프레임워크를 정적 프레임워크로 변환한다.
//Project Editor에서 "+" 버튼을 눌러 새 target을 설정한다.
//iOS > Framework & Library > Cocoa Touch Static Library
//해당 라이브러리(InfoService)에서 필요한 파일들을 이전의 동적 라이브러리 폴더에서 Drag & Drop으로 가져온다.
//target이 맞게 설정되었는지 다시 확인해볼 것
//이전의 동적 라이브러리(InfoService)는 사용하지 않으므로 Project Editor에서 "-" 버튼을 눌러 삭제해 준다.
//InfoServiceStatic을 선택하고, Build Phases > Target Dependencies에서
//이전 동적 라이브러리에서 의존하던 라이브러리(Helpers)를 똑같이 추가해 준다.
//TrainTime(메인 앱)을 선택하고, General > Linked Frameworks and Libraries에서 정적 라이브러리를 추가해 준다.
//InfoService에서 InfoServiceStatic으로 바뀌었다. 코드에서 InfoService로 쓴 부분을 고쳐준다.
//Clean & Build




//Create a static Helpers library
//동적 프레임워크를 정적 프레임워크로 변환한다.
//Project Editor에서 "+" 버튼을 눌러 새 target을 설정한다.
//iOS > Framework & Library > Cocoa Touch Static Library
//해당 라이브러리(Helpers)에서 필요한 파일들을 이전의 동적 라이브러리 폴더에서 Drag & Drop으로 가져온다.
//target이 맞게 설정되었는지 다시 확인해볼 것
//이전의 동적 라이브러리(Helpers)는 사용하지 않으므로 Project Editor에서 "-" 버튼을 눌러 삭제해 준다.
//다른 프레임워크(UserServiceStatic, InfoServiceStatic)에서 Helpers를 사용하고 있으므로,
//해당 프레임워크들의 선택해 Build Phases > Target Dependencies에서 HelpersStatic을 추가해 준다.
//해당 프로임워크들의 스위프트 코드에서 Helpers로 쓴 부분을 HelpersStatic으로 바꿔준다.
//TrainTime(메인 앱)을 선택하고, General > Linked Frameworks and Libraries에서 정적 라이브러리를 추가해 준다.
//Clean & Build




//Create a new facade framework

