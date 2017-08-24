//
//  TestCoreDataStack.swift
//  CampgroundManager
//
//  Created by 근성가이 on 2017. 1. 4..
//  Copyright © 2017년 Razeware. All rights reserved.
//

import CampgroundManager
import Foundation
import CoreData

class TestCoreDataStack: CoreDataStack { //SQLite 기반 저장소 대신 인 메모리 저장소 사용. //테스트 데이터가 영향을 미칠 수 있으므로. //테스트 이후 메모리 내 저장소가 자동으로 지워진다. //그냥 SQLite에 넣고 나중에 삭제해도 되지만..
  convenience init() {
    self.init(modelName: "CampgroundManager")
  }
  
  override init(modelName: String) {
    super.init(modelName: modelName)
    
    let persistentStoreDescription = NSPersistentStoreDescription()
    persistentStoreDescription.type = NSInMemoryStoreType //메모리 기반으로 //메모리 기반으로 테스트 하므로 저장된 데이터와 충돌날 일은 없지만, 저장 로직 자체에 오류가 있는 지를 확인할 수 없다.
    
    let container = NSPersistentContainer(name: modelName)
    container.persistentStoreDescriptions = [persistentStoreDescription]
    
    container.loadPersistentStores { storeDescription, error in
      if let error = error as? NSError {
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    }
    
    self.storeContainer = container
  }
}
