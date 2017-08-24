//
//  DataMigrationManager.swift
//  UnCloudNotes
//
//  Created by 근성가이 on 2017. 1. 3..
//  Copyright © 2017년 근성가이. All rights reserved.
//

import Foundation
import CoreData

class DataMigrationManager {
    let enableMigrations: Bool
    let modelName: String
    let storeName: String = "UnCloudNotesDataModel"
    var stack: CoreDataStack {
        guard enableMigrations, !store(at: storeURL, isCompatibleWithModel: currentModel) else { return CoreDataStack(modelName: modelName) } //최신 데이터 모델이면 현재 모델로 생성하고 반환.
        
        performMigration() //최신 모델이 아닌 경우 마이그레이션
        
        return CoreDataStack(modelName: modelName)
    }
    
    init(modelNamed: String, enableMigrations: Bool = false) {
        self.modelName = modelNamed
        self.enableMigrations = enableMigrations
    }
    
    private func store(at storeURL: URL, isCompatibleWithModel model: NSManagedObjectModel) -> Bool { //현재 데이터 모델이 호환 되는 지 여부 검사
        let storeMetadata = metadataForStoreAtURL(storeURL: storeURL)
        
        return model.isConfiguration(withName: nil, compatibleWithStoreMetadata: storeMetadata)
    }
    
    private func metadataForStoreAtURL(storeURL: URL) -> [String: Any] { //메타데이터 검색
        let metadata: [String: Any]
        
        do {
            metadata = try NSPersistentStoreCoordinator.metadataForPersistentStore(ofType: NSSQLiteStoreType, at: storeURL, options: nil)
        } catch {
            metadata = [: ]
            print("Error retrieving metadata for store at URL: \(storeURL): \(error)")
        }
        
        return metadata
    }
    
    private var applicationSupportURL: URL {
        let path = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true)
            .first
        
        return URL(fileURLWithPath: path!)
    }
    
    private lazy var storeURL: URL = {
       let storeFileName = "\(self.storeName).sqlite"
        
        return URL(fileURLWithPath: storeFileName, relativeTo: self.applicationSupportURL)
    }()
    
    private var storeModel: NSManagedObjectModel? {
        return NSManagedObjectModel.modelVersionsFor(modelNamed: modelName)
                .filter {
                    self.store(at: storeURL, isCompatibleWithModel: $0) }
                .first
    }

    private lazy var currentModel: NSManagedObjectModel = .model(named: self.modelName)
    
    func performMigration() { //순차적으로 마이그레이션
        if !currentModel.isVersion4 {
            fatalError("Can only handle migrations to version 4!")
        }
        
        if let storeModel = self.storeModel {
            if storeModel.isVersion1 {
                let destinationModel = NSManagedObjectModel.version2
                
                migrateStoreAt(URL: storeURL, fromModel: storeModel, toModel: destinationModel) //매핑 없을 시
                
                performMigration()
            } else if storeModel.isVersion2 {
                let destinationModel = NSManagedObjectModel.version3
                let mappingModel = NSMappingModel(from: nil, forSourceModel: storeModel, destinationModel: destinationModel)
                
                migrateStoreAt(URL: storeURL, fromModel: storeModel, toModel: destinationModel, mappingModel: mappingModel)
                
                performMigration()
            } else if storeModel.isVersion3 {
                let destinationModel = NSManagedObjectModel.version4
                let mappingModel = NSMappingModel(from: nil, forSourceModel: storeModel, destinationModel: destinationModel)
                
                migrateStoreAt(URL: storeURL, fromModel: storeModel, toModel: destinationModel, mappingModel: mappingModel)
            }
        }
    }
    
    private func migrateStoreAt(URL storeURL: URL, fromModel from: NSManagedObjectModel, toModel to: NSManagedObjectModel, mappingModel: NSMappingModel? = nil) {
        let migrationManager = NSMigrationManager(sourceModel: from, destinationModel: to)
        
        var migrationMappingModel: NSMappingModel //수동으로 매핑 모델을 맞춰준다.
        if let mappingModel = mappingModel {
            migrationMappingModel = mappingModel
        } else {
            migrationMappingModel = try! NSMappingModel
            .inferredMappingModel(forSourceModel: from, destinationModel: to)
        }
        
        let targetURL = storeURL.deletingLastPathComponent()
        let destinationName = storeURL.lastPathComponent + "~1" //두 번 이상의 마이그레이션이 필요한 경우 있기 때문에??
        let destinationURL = targetURL
            .appendingPathComponent(destinationName)
        print("From Model: \(from.entityVersionHashesByName)")
        print("To Model: \(to.entityVersionHashesByName)")
        print("Migrating store \(storeURL) to \(destinationURL)")
        print("Mapping model: \(mappingModel)")
        
        let success: Bool
        do {
            try migrationManager.migrateStore(from: storeURL, sourceType: NSSQLiteStoreType, options: nil, with: migrationMappingModel, toDestinationURL: destinationURL, destinationType: NSSQLiteStoreType, destinationOptions: nil) //마이그레이션을 실행한다.
            success = true
        } catch {
            success = false
            print("Migration failed: \(error)")
        }
        
        if success { //기존 저장소 제거하고 새 저장소로 대체
            print("Migration Completed Successfully")
            let fileManager = FileManager.default
            do {
                try fileManager.removeItem(at: storeURL)
                try fileManager.moveItem(at: destinationURL, to: storeURL)
            } catch {
                print("Error migrating \(error)")
            }
        }
    }
}

extension NSManagedObjectModel { //데이터모델이 업데이트가 필요한지, 버전은 몇 인지 수동으로 알아내는 메서드
    private class func modelURLs(in modelFolder: String) -> [URL] { //모든 모델 버전 반환
        return Bundle.main.urls(forResourcesWithExtension: "mom", subdirectory: "\(modelFolder).momd") ?? []
    }
    
    class func modelVersionsFor(modelNamed modelName: String) -> [NSManagedObjectModel] { //NSManagedObjectModel이 데이터모델 클래스 //파라미터로 입력된 특정 모델 버전을 반환 //빌드를 하고 컴파일을 하면 데이터 모델도 컴파일 되서 루트에 momd 폴더에 mom파일로 저장 된다.
        return modelURLs(in: modelName)
            .flatMap(NSManagedObjectModel.init)
    }
    
    class func uncloudNotesModel(named modelName: String) -> NSManagedObjectModel {
        let model = modelURLs(in: "UnCloudNotesDataModel")
            .filter { $0.lastPathComponent == "\(modelName).mom" }
            .first
            .flatMap(NSManagedObjectModel.init)
        
        return model ?? NSManagedObjectModel()
    }
    
    class var version1: NSManagedObjectModel { //첫 번째 버전의 데이터모델을 반환
        return uncloudNotesModel(named: "UnCloudNotesDataModel")
    }
    
    class var version2: NSManagedObjectModel {
        return uncloudNotesModel(named: "UnCloudNotesDataModel v 2")
    }
    
    class var version3: NSManagedObjectModel {
        return uncloudNotesModel(named: "UnCloudNotesDataModel v 3")
    }
    
    class var version4: NSManagedObjectModel {
        return uncloudNotesModel(named: "UnCloudNotesDataModel v 4")
    }
    
    var isVersion1: Bool { //첫 번째 버전인지 확인
        return self == type(of: self).version1
    }
    
    var isVersion2: Bool {
        return self == type(of: self).version2
    }
    
    var isVersion3: Bool {
        return self == type(of: self).version3
    }
    
    var isVersion4: Bool {
        return self == type(of: self).version4
    }
    
    class func model(named modelName: String, in bundle: Bundle = .main) -> NSManagedObjectModel { //최상위 폴더 사용하여 데이터 모델 초기화. 혀재 모델 버전을 자동으로 찾고, 해당 모델을 NSManagedObjectModel에 로드. //버전이 변경된 데이터 모델에서만 작동하게
        return
            bundle
                .url(forResource: modelName, withExtension: "momd")
                .flatMap(NSManagedObjectModel.init)
                ?? NSManagedObjectModel()
    }
}

//NSManagedObjectModel 비교를 위한 확장
func == (firstModel: NSManagedObjectModel, otherModel: NSManagedObjectModel) -> Bool {
    return firstModel.entitiesByName == otherModel.entitiesByName
}
