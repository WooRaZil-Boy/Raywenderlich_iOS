//
//  CoreDataStack.swift
//  Dog Walk
//
//  Created by 근성가이 on 2018. 3. 10..
//  Copyright © 2018년 Razeware. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
  //MARK: - Properties
  private let modelName: String //저장할 속성 이름
  private lazy var storeContainer: NSPersistentContainer = { //NSPersistentContainer 초기화
    let container = NSPersistentContainer(name: self.modelName) //CoreData Stack이 캡슐화된 객체
    container.loadPersistentStores { storeDescription, error in //PersistentStore를 가져온다.
      if let error = error as NSError? {
         print("Unresolved error \(error), \(error.userInfo)")
      }
    }
    
    return container
  }()
  lazy var managedContext: NSManagedObjectContext = {
    return self.storeContainer.viewContext //NSManagedObjectContext를 가져온다
  }()
  
  //storeContainer가 private이므로, 외부에서 CoreDataStack에 접근할 수 있는 속성은 managedContext 뿐이다.
  //managedContext는 나머지 CoreData Stack에 접근하는데 필요한 유일한 진입점이다.
  //PersistentStoreCoordinator는 NSManagedObjectContext의 공용 속성이다.
  //또한, ManagedObjectModel과 PersistentStore은 PersistentStoreCoordinator의 공용 속성이다.
  //결국 managedContext로 다른 CoreData Stack에 접근할 수 있다. NSPersistentContainer안에 존재
  
  //MARK: - LifeCycle
  init(modelName: String) {
    self.modelName = modelName
  }
}

extension CoreDataStack {
  func saveContext() {
    guard managedContext.hasChanges else { return } //변경 있을 때만 저장한다.
    
    do {
      try managedContext.save() //저장
    } catch let error as NSError {
      print("Unresolved error \(error), \(error.userInfo)")
    }
  }
}

//CoreData Stack은 4개의 클래스로 구성되어 있다. //4개 모두 맞물려 돌아가며, 분리하여 각각 사용하는 경우의 거의 없다.
//• NSManagedObjectModel : 데이터 모델 객체의 유형, 속성 및 관계를 나타낸다. 데이터 베이스 스키마로 생각하면 된다.
//  SQLite를 사용하는 경우, 스키마가 된다. 하지만, SQLite 외에 다른 유형으로 CoreData를 생성할 수도 있다.
//  xcdatamodel 파일을 작성하고 편집하는 특별한 컴파일러 momc가 있다. CoreData는 컴파일된 momd 폴더 내용을 사용해
//  런타임 시 NSManagedObjectModel을 초기화한다.
//• NSPersistentStore : 사용하기로 한 저장 방법을 읽고, 데이터를 쓴다. 4가지의 타입이 있다.
//  atomic은 읽기 쓰기 작업 수행 전 직렬화가 해제되고 메모리에 로드되어야 한다. non-atomic은 필요에 따라.
//  4가지 방법 외에도 JSON이나 CSV 등으로 자제적인 NSPersistentStore를 만들 수 있다.
//  - NSQLiteStoreType : SQLite 방식. non-atomic. default이며 가볍고 효율적이다.
//  - NSXMLStoreType : XML 방식. atomic. 사람이 이해하기 쉽다. OSX에서만 사용할 수 있으며 메모리 사용량이 크다.
//  - NSBinaryStoreType : 2진 데이터 방식. atomic. 잘 안 쓴다.
//  - NSInMemoryStoreType : 메모리 방식. 앱을 종료하면 데이터가 사라진다. 유닛 테스팅과 캐싱에 사용된다.
//• NSPersistentStoreCoordinator : managed object와 persistent store간의 브릿지. 캡슐화되어 있다.
//  따라서 NSManagedObjectContext는 NSPersistentStore의 종류에 상관없이 일정한 작업을 할 수 있으며,
//  여러개의 NSPersistentStore를 사용하더라도, NSPersistentStoreCoordinator로 통합해 관리할 수 있다.
//• NSManagedObjectContext : 가장 빈번하게 사용. 실제 개발 시 NSManagedObjectContext로 작업하는 경우가 대부분
//  컨텍스트는 managed object로 작업하기 위한 메모리 내의 스크래치 패드.
//  managed object 내에서 CoreData로 모든 작업을 수행한다. 컨텍스트에서 save()를 호출하기 전에는 저장되지 않는다.
//  - 컨텍스트는 생성하거나 가져오는 객체의 라이프 사이클을 관리한다. 여기에는 오류 처리, 역 관계 처리, 유효성 검사 등이 포함된다.
//  - managed object는 연결된 컨텍스트 없이 존재할 수 없다. 모든 managed object는 컨텍스트에 대한 참조를 유지한다.
//    따라서 managed object에서 컨텍스트를 가져올 수도 있다.
//    ex) let managedContext = employee.managedObjectContext
//  - managed object가 특정 컨텍스트와 연결되면, 라이프 사이클 동안 동일한 컨텍스트와 연결이 유지된다.
//  - 여러 개의 컨텍스트를 사용할 수 있다. 동일한 CoreData를 서로 다른 컨텍스트에 연결할 수도 있다.
//  - 컨텍스트는 non thread-safe이다. managed object도 마찬가지로 non thread-safe이다.
//    생성된 동일한 스레드에서만 컨텍스트 관리 및 managed object와 상호작용 할 수 있다.

//iOS 10부터 4개의 CoreData Stack을 조율하는 NSPersistentContainer를 사용할 수 있다.
//4개의 CoreData Stack을 모두 연결하면서, 더 쉽게 CoreData를 사용할 수 있다.
