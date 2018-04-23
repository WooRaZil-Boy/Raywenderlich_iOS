/*
* Copyright (c) 2016 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
    let service = TaskService()
    let sceneCoordinator = SceneCoordinator(window: window!)
    //코디네이터와 서비스를 준비한다.
    
    let tasksViewModel = TasksViewModel(taskService: service, coordinator: sceneCoordinator)
    let firstScene = Scene.tasks(tasksViewModel)
    sceneCoordinator.transition(to: firstScene, type: .root)
    //필요한 경우 다른 시작화면을 지정해 줄 수 있다.
    
    return true
  }
}

//• Scene : View Controller가 관리하는 화면. 일반이나 모달일 수 있으며, View Controller와 View Model로 구성
//• View Model : 특정 Scene을 표현하기 위해 View Controller에서 사용되는 논리 및 데이터를 정의
//• Service : 응용 프로그램의 모든 Scene에 제공되는 논리적 기능 그룹.
//          ex. DB에 Storage를 서비스로 추상화. 네트워크 API에 대한 request를 네트워크 서비스로 그룹화
//• Model : 응용 프로그램의 가장 기본적인 DB. View Model과 Service 모두 Model에 접근한다.

//TaskItem(Model) : 개별 작업을 설명하는 모델
//TaskService(Service) : 작업 생성, 업데이트, 삭제, 저장, 검색을 제공하는 서비스
//storage medium : Realm, RxRealm 사용
//각 scene는 list, create, search 작업의 View로 나누어져 있다.
//scene coordinator : Scene 탐색과 프레젠테이션 관리
//로직은 p.404

//View Model은 비즈니스 로직과 Model Data를 View Controller에 전달한다.
//각 Scene에 대한 View Model을 생성하기 위한 규칙은 다음과 같다.
//• Observable 시퀀스로 데이터를 노출해야 한다. 이렇게 하면 UI에 연결될 때 자동으로 업데이트 된다.
//• Action 패턴을 사용하여 UI에 연결할 수 있는 모든 View Model의 작업을 노출한다.
//• 어떤한 Model 또는 Data 이든, public하게 접근가능해야하고, 노출되지 않은 Observable은 immutable이어야 한다.
//• 장면 간 전환은 비즈니스 논리의 일부이다. 각 View Model은 이러한 전환을 시작하고 다음 Scene의 View Model을
//  준비하지만, View Controller에 대해서는 알지 못한다.
