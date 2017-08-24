//
//  CoreDataStack.swift
//  SurfJournal
//
//  Created by 근성가이 on 2017. 1. 5..
//  Copyright © 2017년 근성가이. All rights reserved.
//

import CoreData

class CoreDataStack {
    //MARK: - Properties
    fileprivate let modelName: String
    lazy var mainContext: NSManagedObjectContext = {
        return self.storeContainer.viewContext
    }()
    
    lazy var storeContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: self.modelName)
        self.seedCoreDataContainerIfFirstLaunch()
        container.loadPersistentStores { storeDescription, error in
            if let error = error as? NSError {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        return container
    }()
    
    //MARK: - Initializers
    init(modelName: String) {
        self.modelName = modelName
    }
}

//MARK: - Internal
extension CoreDataStack {
    func saveContext() {
        guard mainContext.hasChanges else { return }
        
        do {
            try mainContext.save()
        } catch let error as NSError {
            fatalError("Unresolved error \(error), \(error.userInfo)")
        }
    }
}

//MARK: - Private
private extension CoreDataStack {
    func seedCoreDataContainerIfFirstLaunch() {
        //1
        let previouslyLaunched = UserDefaults.standard.bool(forKey: "previouslyLaunched")
        if !previouslyLaunched {
            UserDefaults.standard.set(true, forKey: "previouslyLaunched")
            
            //Default directory where the CoreDataStack will store its files
            let directory = NSPersistentContainer.defaultDirectoryURL() //coreData 폴더 가져오기
            let url = directory.appendingPathComponent(modelName + ".sqlite")
            
            //2: Copying the SQLite file
            let seededDatabaseURL = Bundle.main.url(forResource: modelName, withExtension: "sqlite")!
            _ = try? FileManager.default.removeItem(at: url)
            
            do {
                try FileManager.default.copyItem(at: seededDatabaseURL, to: url)
            } catch let error as NSError {
                fatalError("Error: \(error.localizedDescription)")
            }
            
            //3: Copying the SHM file
            let seededSHMURL = Bundle.main.url(forResource: modelName, withExtension: "sqlite-shm")!
            let shmURL = directory.appendingPathComponent(modelName + "sqlite-shm")
            _ = try? FileManager.default.removeItem(at: shmURL)
            
            do {
                try FileManager.default.copyItem(at: seededSHMURL, to: shmURL)
            } catch let error as NSError {
                fatalError("Error: \(error.localizedDescription)")
            }
            
            //4: Copying the WAL file
            let seededWALURL = Bundle.main.url(forResource: modelName, withExtension: "sqlite-wal")!
            let walURL = directory.appendingPathComponent(modelName + ".sqlite-wal")
            _ = try? FileManager.default.removeItem(at: walURL)
            
            do {
                try FileManager.default.copyItem(at: seededWALURL, to: walURL)
            } catch let error as NSError {
                fatalError("Error: \(error.localizedDescription)")
            }
            
            print("Seed Core Data")
        }
    }
}
