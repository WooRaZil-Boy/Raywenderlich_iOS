/**
 * Copyright (c) 2017 Razeware LLC
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
 * Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
 * distribute, sublicense, create a derivative work, and/or sell copies of the
 * Software in any work that is designed, intended, or marketed for pedagogical or
 * instructional purposes related to programming, coding, application development,
 * or information technology.  Permission for such use, copying, modification,
 * merger, publication, distribution, sublicensing, creation of derivative works,
 * or sale is expressly withheld.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import CoreData

class CoreDataStack {

  // MARK: Properties
  fileprivate let modelName: String

  lazy var mainContext: NSManagedObjectContext = {
    return self.storeContainer.viewContext
  }()

  lazy var storeContainer: NSPersistentContainer = {

    let container = NSPersistentContainer(name: self.modelName)
    self.seedCoreDataContainerIfFirstLaunch()
    container.loadPersistentStores { (storeDescription, error) in
      if let error = error as NSError? {
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    }

    return container
  }()

  // MARK: Initializers
  init(modelName: String) {
    self.modelName = modelName
  }
}

// MARK: Internal
extension CoreDataStack {

  func saveContext () {
    guard mainContext.hasChanges else { return }

    do {
      try mainContext.save()
    } catch let nserror as NSError {
      fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
    }
  }
}

// MARK: Private
private extension CoreDataStack {

  func seedCoreDataContainerIfFirstLaunch() {
    
    

    // 1
    let previouslyLaunched = UserDefaults.standard.bool(forKey: "previouslyLaunched")
    //UserDefaults로 간단한 값을 저장해 둘 수 있다. //첫 실행시 bool이 false
    if !previouslyLaunched {
      UserDefaults.standard.set(true, forKey: "previouslyLaunched") //첫 생성시 추가

      // Default directory where the CoreDataStack will store its files
      let directory = NSPersistentContainer.defaultDirectoryURL() //기본 디렉토리
      let url = directory.appendingPathComponent(modelName + ".sqlite") //url

      // 2: Copying the SQLite file
      let seededDatabaseURL = Bundle.main.url(forResource: modelName, withExtension: "sqlite")!
      _ = try? FileManager.default.removeItem(at: url) //기본 디렉토리에 생성된 코어 데이터 파일 삭제
      do {
        try FileManager.default.copyItem(at: seededDatabaseURL, to: url) //해당 위치로 복사
      } catch let nserror as NSError {
        fatalError("Error: \(nserror.localizedDescription)")
        //보통 fatalError는 앱을 크래시 시키지만, 이 경우에는 CoreData가 없으면 앱을 실행하는 의미가 없으므로 무방.
        //fatalError를 발생시키면 최소한 스택 추적이 생성되므로 문제 해결에 도움이 된다.
      }

      // 3: Copying the SHM file
      let seededSHMURL = Bundle.main.url(forResource: modelName, withExtension: "sqlite-shm")!
      let shmURL = directory.appendingPathComponent(modelName + ".sqlite-shm")
      _ = try? FileManager.default.removeItem(at: shmURL)
      do {
        try FileManager.default.copyItem(at: seededSHMURL, to: shmURL)
      } catch let nserror as NSError {
        fatalError("Error: \(nserror.localizedDescription)")
      } //2번과 같은 방식으로 SHM 파일 교체

      // 4: Copying the WAL file
      let seededWALURL = Bundle.main.url(forResource: modelName, withExtension: "sqlite-wal")!
      let walURL = directory.appendingPathComponent(modelName + ".sqlite-wal")
      _ = try? FileManager.default.removeItem(at: walURL)
      do {
        try FileManager.default.copyItem(at: seededWALURL, to: walURL)
      } catch let nserror as NSError {
        fatalError("Error: \(nserror.localizedDescription)")
      } //2, 3번과 같은 방식으로 WAL 파일 교체
      
      //첫 실행 시에 파일을 복사해 해당 위치에 넣는다.
      //동시에 여러 CoreData에 읽고 쓰기 위해서는 SHM(shared memory file), WAL(write-ahead logging)이 필요

      print("Seeded Core Data")
    }
  }
}
