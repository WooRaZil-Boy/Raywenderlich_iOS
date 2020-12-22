/// Copyright (c) 2020 Razeware LLC
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
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import SwiftUI
import CoreData

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?

  func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
//    let contentView = MovieList()
    let context = persistentContainer.viewContext
    let contentView = MovieList().environment(\.managedObjectContext, context)
    //Core Data를 사용하도록 변경한다.

    if let windowScene = scene as? UIWindowScene {
      let window = UIWindow(windowScene: windowScene)
      window.rootViewController = UIHostingController(rootView: contentView)
      self.window = window
      window.makeKeyAndVisible()
    }
  }
  
  lazy var persistentContainer: NSPersistentContainer = {
    //lazy 속성으로 persistentContainer를 추가한다.
    //해당 속성을 처음 참조할 때, NSPersistentContainer가 생성된다.
    let container = NSPersistentContainer(name: "FaveFlicks")
    //FaveFlicks 이름의 container를 생성한다.
    //이 프로젝트에는 이미 FaveFlicks.xcdatamodeld가 있으며, 이 파일은 Core Data의 model schema를 설계한다.
    //해당 파일의 이름은 container의 이름과 일치해야 한다.
    
    container.loadPersistentStores { _, error in
      //Core Data stack을 설정하는 persistent store를 로드한다.
      
      if let error = error as NSError? {
        // You should add your own error handling code here.
        fatalError("Unresolved error \(error), \(error.userInfo)")
        //error가 발생하면 이를 기록하고 앱을 종료시킨다.
        //실제 앱에서는 앱의 state가 비정상이며 재설치가 필요하다는 dialog를 표시하여 처리한다.
        //이 error는 발생할 확률이 매우 낮고 개발자의 실수로 인한 것이므로, App Store에 출시하기 전에 처리할 수 있어야 한다.
      }
    }
    return container
  }()
  
  func saveContext() {
    let context = persistentContainer.viewContext
    //persistent container의 viewContext를 얻는다.
    //이는 main thread에서만 사용되도록 지정된 특별한 managed object context이다.
    //저장되지 않은 data를 저장하는데 이를 사용한다.
    if context.hasChanges {
      //저장할 변경 사항이 있는 경우에만 저장한다.
      do {
        try context.save()
        //context를 저장한다. 이 호출은 error를 발생시킬 수 있으므로 try/catch로 감싼다.
      } catch {
        // The context couldn't be saved.
        // You should add your own error handling here.
        let nserror = error as NSError
        fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        //error가 발생하면, 이를 기록하고 앱이 종료된다.
        //이전 method에서와 마찬가지로 여기의 모든 error는 개발 중에서만 발생해야 한다.
        //하지만 만약의 경우를 대비해 app에서 적절하게 처리한다.
      }
    }
  }
  
  func sceneDidEnterBackground(_ scene: UIScene) {
    //백 그라운드로 전환될 때
    saveContext()
    //Core Data context 저장
  }
}




