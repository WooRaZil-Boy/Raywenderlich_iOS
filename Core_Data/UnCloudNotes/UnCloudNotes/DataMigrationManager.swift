//
//  DataMigrationManager.swift
//  UnCloudNotes
//
//  Created by 근성가이 on 2018. 3. 16..
//  Copyright © 2018년 Ray Wenderlich. All rights reserved.
//

import Foundation
import CoreData

class DataMigrationManager {
  let enableMigrations: Bool
  let modelName: String
  let storeName: String = "UnCloudNotesDataModel"
  var stack: CoreDataStack {
    //CoreDataStack의 인스턴스가 생성될 때 모델을 확인해 마이그레이션을 진행한다.
    guard enableMigrations, !store(at: storeURL, isCompatibleWithModel: currentModel) else {
      //마이그레이션을 진행할 수 없거나, 현재 모델이 최신이라면
      return CoreDataStack(modelName: modelName) //현재 모델로 CoreDataStack 생성
    }
    
    performMigration() //마이그레이션 진행 후
    
    return CoreDataStack(modelName: modelName) //최신 모델로 CoreDataStack 생성
  }
  
  init(modelNamed: String, enableMigrations: Bool = false) {
    self.modelName = modelNamed
    self.enableMigrations = enableMigrations
  }
  
  func performMigration() {
    //최신 모델이 아니라면 마이그레이션을 진행한다.
    if !currentModel.isVersion4 { //최신모델이 v4가 아니라면 강제 종료.
      //현재 모델이 아닌, 이 앱의 최신 데이터 모델 버전
      fatalError("Can only handle migrations to version 4!")
    }
    
    if let storeModel = self.storeModel { //순차적으로 업데이트 해야 한다.
      if storeModel.isVersion1 { //v1이면 v2로 업데이트
        let destinationModel = NSManagedObjectModel.version2
        migrateStoreAt(URL: storeURL, fromModel: storeModel, toModel: destinationModel)
        //마이그레이션 실행
        performMigration() //다시 실행 //v2에서 v3로 업데이트 해야 한다.
      } else if storeModel.isVersion2 { //v2이면 v3로 업데이트
        let destinationModel = NSManagedObjectModel.version3
        migrateStoreAt(URL: storeURL, fromModel: storeModel, toModel: destinationModel)
        //마이그레이션 실행
        performMigration() //다시 실행 //v3에서 v4로 업데이트 해야 한다.
      } else if storeModel.isVersion3 { //v3이면 v4로 업데이트
        let destinationModel = NSManagedObjectModel.version4
        migrateStoreAt(URL: storeURL, fromModel: storeModel, toModel: destinationModel)
        //마이그레이션 실행
        //최신 버전이므로 performMigration()를 실행할 필요는 없다.
      }
    } //각각 정의된 매핑모델과 코드로 수동 마이그레이션을 진행한다.
  }
  
  private func migrateStoreAt(URL storeURL: URL, fromModel from:NSManagedObjectModel, toModel to:NSManagedObjectModel, mappingModel:NSMappingModel? = nil) {
    let migrationManager = NSMigrationManager(sourceModel: from, destinationModel: to)
    //마이그레이션을 처리하는 NSMigrationManager 생성
    
    var migrationMappingModel: NSMappingModel
    if let mappingModel = mappingModel { //매핑 모델 있으면 추가
      migrationMappingModel = mappingModel
    } else { //없으면 모델로 부터 매핑 모델 생성
      migrationMappingModel = try! NSMappingModel.inferredMappingModel(forSourceModel: from, destinationModel: to)
      //inferredMappingModel : 원본 모델과 새 모델을 매핑할 매핑 모델을 생성한다.
    }
    
    let targetURL = storeURL.deletingLastPathComponent()
    //lastPathComponent와 반대되는 기능. 마지막 컴포넌트를 제외한 경로를 반환. 파일이 어떤 경로에 있는지 알 수 있다.
    let destinationName = storeURL.lastPathComponent + "~1"
    //deletingLastPathComponent와 반대되는 기능. 마지막 경로의 컴포넌트를 반환. 파일명을 알 수 있다.
    // ~1를 붙여 파일 명을 만든다.
    let destinationURL = targetURL.appendingPathComponent(destinationName)
    //최종적인 url 생성
    //http://seorenn.blogspot.kr/2013/06/cocoa-nsstring-path.html
    
    print("From Model: \(from.entityVersionHashesByName)")
    print("To Model: \(to.entityVersionHashesByName)")
    print("Migrating store \(storeURL) to \(destinationURL)")
    print("Mapping model: \(String(describing: mappingModel))")
    
    let success: Bool
    do {
      try migrationManager.migrateStore(from: storeURL, sourceType: NSSQLiteStoreType, options: nil, with: migrationMappingModel, toDestinationURL: destinationURL, destinationType: NSSQLiteStoreType, destinationOptions: nil)
      //지정된 경로, 타입, 매핑모델 등으로 마이그레이션을 진행한다.
      success = true
    } catch {
      success = false
      print("Migration failed: \(error)")
    }
    
    if success {
      print("Migration Completed Successfully")
      
      let fileManager = FileManager.default
      do {
        try fileManager.removeItem(at: storeURL) //기존의 저장소를 제거
        try fileManager.moveItem(at: destinationURL, to: storeURL) //새 저장소를 기존 위치로 이동해 대체
      } catch {
        print("Error migrating \(error)")
      }
    }
  }
  
  private func store(at storeURL: URL, isCompatibleWithModel model: NSManagedObjectModel) -> Bool {
    //private는 function이라도 extension에 추가할 수 없다.
    //저장소가 주어진 모델과 호환되는지 확인
    let storeMetadata = metadataForStoreAtURL(storeURL: storeURL)
    
    return model.isConfiguration(withName: nil, compatibleWithStoreMetadata: storeMetadata)
    //지정된 Data Model이 저장소의 메타 데이터와 호환되는지의 여부를 반환
  }
  
  private func metadataForStoreAtURL(storeURL: URL) -> [String: Any] {
    //private는 function이라도 extension에 추가할 수 없다.
    //메타 데이터를 안전하게 검색하는데 도움을 준다.
    let metadata: [String: Any]
    do {
      metadata = try NSPersistentStoreCoordinator.metadataForPersistentStore(ofType: NSSQLiteStoreType, at: storeURL, options: nil)
      //저장소의 메타데이터를 가져온다.
    } catch {
      metadata = [:]
      print("Error retrieving metadata for store at URL:\(storeURL): \(error)")
    }
    
    return metadata
  }
  
  private var applicationSupportURL: URL {
    let path = NSSearchPathForDirectoriesInDomains(.applicationDirectory, .userDomainMask, true).first
    //디렉토리 경로를 만든다.
    //.applicationDirectory : /Application 폴더, .userDomainMask : User의 홈 디렉토리
    //expandTilde가 true이면 ~를 붙인다.
    
    return URL(fileURLWithPath: path!) //홈 디렉토리 url을 반환한다.
  }
  
  private lazy var storeURL: URL = {
    let storeFileName = "\(self.storeName).sqlite"
    
    return URL(fileURLWithPath: storeFileName, relativeTo: self.applicationSupportURL)
    //relativeTo의 경로에 fileURLWithPath를 더해 최종 경로를 참조하는 url 생성
    //storeFileName으로 저장소 url 경로를 가져온다.
  }()
  
  private var storeModel: NSManagedObjectModel? {
    return NSManagedObjectModel.modelVersionsFor(modelNamed: modelName).filter {
      self.store(at: storeURL, isCompatibleWithModel: $0)
    }.first //호환되는 모델을 찾아 반환
  }
  
  private lazy var currentModel: NSManagedObjectModel = .model(named: self.modelName)
  //Class 메서드를 DataMigrationManager.model 할 필요 없이 .model로 호출할 수도 있다.
}

extension NSManagedObjectModel {
  private class func modelURLs(in modelFolder: String) -> [URL] {
    //파라미터 이름을 가진 모든 버전의 모델을 리턴
    return Bundle.main.urls(forResourcesWithExtension: "mom", subdirectory:"\(modelFolder).momd") ?? []
    //지정된 확장자로 식별되는 서브 디렉토리에 있는 모든 파일의 URL을 반환한다.
    //Xcode가 앱을 컴파일하면, 데이터 모델도 컴파일 된다. 그 이후 .momd 폴더에 mom확장자로 각 버전 모델이 저장된다.
  }
  
  class func modelVersionsFor(modelNamed modelName: String) -> [NSManagedObjectModel] {
    //NSManagedObjectModel의 특정 인스턴스인 UnCloudNotesDataModel 반환
    //일반적으로 CoreData는 가장 최근의 Data Model 버전을 반환하지만, 이 방법을 사용하면 특정 버전 정보를 얻는다.
    return modelURLs(in: modelName).flatMap(NSManagedObjectModel.init)
    //flatMap은 Map의 일종. 배열의 각 요소를 가공해 다른 배열을 만든다.
    //nil인 요소를 버리고, 중첩된 배열의 경우 하나의 배열로 합친다.
    //해당 버전을 모델의 모두 가져와 nil을 제외한 1차원 배열로 만든다. //Map과의 차이점
    //일반 적인 Map은 각 요소에 같은 수를 더하거나 하는 등에 주로 사용한다.
    //즉 ,여기선 flatMap으로 NSManagedObjectModel 생성자를 추가하여 각 url로 NSManagedObjectModel을 만든다.
  }
  
  class func uncloudNotesModel(named modelName: String) -> NSManagedObjectModel {
    let model = modelURLs(in: "UnCloudNotesDataModel").filter { $0.lastPathComponent == "\(modelName).mom" }.first.flatMap(NSManagedObjectModel.init)
    //lastPathComponent는 URL의 마지막 경로 문자열 아이템을 돌려준다. 경로에서 파일이름만을 뽑아 낼 때 주로 사용한다.
    //http://seorenn.blogspot.kr/2013/06/cocoa-nsstring-path.html
    //위의 메서드 체이닝은 UnCloudNotesDataModel에서 해당 모델명으로 된 데이터 모델을 반환한다.
    //일반 적인 Map은 각 요소에 같은 수를 더하거나 하는 등에 주로 사용한다.
    //즉 여기선, flatMap으로 NSManagedObjectModel 생성자를 추가하여 각 url로 NSManagedObjectModel을 만든다.
    
    return model ?? NSManagedObjectModel()
  }
  
  class var version1: NSManagedObjectModel { //첫 버전(v 표시가 아예 없다)의 데이터 모델 반환
    return uncloudNotesModel(named: "UnCloudNotesDataModel")
  } //extension에서도 computed property는 추가할 수 있다.
  
  var isVersion1: Bool {
    return self == type(of: self).version1
  }
  
  class var version2: NSManagedObjectModel {
    return uncloudNotesModel(named: "UnCloudNotesDataModel v2")
  }
  
  var isVersion2: Bool {
    return self == type(of: self).version2
  }
  
  class var version3: NSManagedObjectModel {
    return uncloudNotesModel(named: "UnCloudNotesDataModel v3")
  }
  
  var isVersion3: Bool {
    return self == type(of: self).version3
  }
  
  class var version4: NSManagedObjectModel {
    return uncloudNotesModel(named: "UnCloudNotesDataModel v4")
  }
  
  var isVersion4: Bool {
    return self == type(of: self).version4
  }
  
  class func model(named modelName: String, in bundle: Bundle = .main) -> NSManagedObjectModel {
    return bundle.url(forResource: modelName, withExtension: "momd").flatMap(NSManagedObjectModel.init) ?? NSManagedObjectModel()
    //해당하는 모델을 초기화한다.
  }
}

//사용자는 v1, v2, v3, v4로 순차적으로 업데이트 하는 것이 아니라, v1에서 v3, v2에서 v4등으로 업데이트 할 수도 있다.
//이를 구현하기 위해서는 self-migrating stack을 생성해 줘야 한다.

//CoreData API에는 모델 버전을 가져오는 메서드가 없어 직접 구현해 줘야 한다.

func == (firstModel: NSManagedObjectModel, otherModel: NSManagedObjectModel) -> Bool {
  //NSManagedObjectModel에서 비교(==) 연산을 수행하려면 연산자를 추가해 줘야 한다.
  return firstModel.entitiesByName == otherModel.entitiesByName
  //동일한 버전 해시를 사용한 엔티티 컬렉션이 있으면 동일하다 판단
}
