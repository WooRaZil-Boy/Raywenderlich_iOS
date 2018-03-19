//
//  TestCoreDataStack.swift
//  CampgroundManagerTests
//
//  Created by 근성가이 on 2018. 3. 19..
//  Copyright © 2018년 Razeware. All rights reserved.
//

import CampgroundManager
//현재 TestCoreDataStack.swift 파일의 타겟 모듈은 CampgroundManagerTests 이므로
import Foundation
import CoreData

class TestCoreDataStack: CoreDataStack { //CampgroundManager의 CoreDataStack를 상속
  convenience init() { //파라미터 없이 생성해도 특정한 형식으로 초기화되도록 한다.
    self.init(modelName: "CampgroundManager")
  }
  
  override init(modelName: String) { //일반적인 이니셜라이저.
    super.init(modelName: modelName)
    
    let persistentStoreDescription = NSPersistentStoreDescription()
    //PersistentStore를 설정하는 객체
    persistentStoreDescription.type = NSInMemoryStoreType
    //테스트를 위해선 SQLite 데이터베이스 대신 메모리 내 저장소에 접근해야 한다.
    //메모리 내 저장소만 사용하므로, 디스크에 저장되지 않고 테스트에서 원하는 만큼 데이터를 쓸 수 있으며,
    //테스트가 완료되면 메모리 내 저장소가 자동으로 삭제된다.
    
    let container = NSPersistentContainer(name: modelName)
    //NSPersistentContainer는 iOS 10부터 추가. //더 쉽게 CoreData를 관리할 수 있다.
    container.persistentStoreDescriptions = [persistentStoreDescription] //설정 추가
    container.loadPersistentStores { (storeDescription, error) in //PersistentStore 불러 오기
      //초기화되면서 사용할 준비가 완료된다.
      if let error = error as NSError? {
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    }
    
    self.storeContainer = container //storeContainer 대입
  }
}

//테스트를 위해선 SQLite 데이터베이스 대신 메모리 내 저장소에 접근해야 한다.
//따라서 저장소를 변경하는 CoreData Stack의 새로운 하위 클래스를 작성한다.
