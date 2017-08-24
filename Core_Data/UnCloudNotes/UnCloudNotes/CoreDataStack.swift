//
//  CoreDataStack.swift
//  UnCloudNotes
//
//  Created by 근성가이 on 2017. 1. 3..
//  Copyright © 2017년 근성가이. All rights reserved.
//

import Foundation
import CoreData

protocol UsesCoreDataObjects: class {
    var managedObjectContext: NSManagedObjectContext? { get set }
}

class CoreDataStack {
    private let modelName: String
    
    init(modelName: String) {
        self.modelName = modelName
    }
    
    lazy var managedContext: NSManagedObjectContext = self.storeContainer.viewContext
    var savingContext: NSManagedObjectContext {
        return storeContainer.newBackgroundContext()
    }
    
    var storeName: String = "UnCloudNotesDataModel"
    var storeURL: URL {
        let storePaths = NSSearchPathForDirectoriesInDomains(.applicationDirectory, .userDomainMask, true)
        let storePath = storePaths[0] as NSString
        let fileManager = FileManager.default
        
        do {
            try fileManager.createDirectory(atPath: storePath as String, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Error creating storePath \(storePath): \(error)")
        }
        
        let sqliteFilePath = storePath.appendingPathComponent(storeName + ".sqlite")
        
        return URL(fileURLWithPath: sqliteFilePath)
    }
    
    lazy var storeDescription: NSPersistentStoreDescription = { //shouldInferMappingModelAutomatically 설정을 통해 두 데이터 모델 차이 확인하고 매핑할 수 있다.
        let description = NSPersistentStoreDescription(url: self.storeURL)
        description.shouldMigrateStoreAutomatically = true //데이터 모델을 업데이트 한다.
        description.shouldInferMappingModelAutomatically = false //false 세팅을 하면 persistent store coordinator가 새 매핑 모델을 사용하여 마이그레이션을 한다.  
        
        return description
    }()
    
    private lazy var storeContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: self.modelName)
        container.persistentStoreDescriptions = [self.storeDescription]
        container.loadPersistentStores { storeDescription, error in
            if let error = error {
                fatalError("Unresolved error \(error)")
            }
        }
        return container
    }()
    
    func saveContext() {
        guard managedContext.hasChanges else { return }
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            fatalError("Unresolved error \(error), \(error.userInfo)")
        }
    }
}
