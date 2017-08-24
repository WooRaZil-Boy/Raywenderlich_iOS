//
//  CoreDataStack.swift
//  EmployeeDirectory
//
//  Created by 근성가이 on 2017. 1. 4..
//  Copyright © 2017년 근성가이. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    //MARK: - Properties
    private let modelName: String
    
    lazy var mainContext: NSManagedObjectContext = {
       return self.storeContainer.viewContext
    }()
    
    private lazy var storeContainer: NSPersistentContainer = {
       let container = NSPersistentContainer(name: self.modelName)
        container.loadPersistentStores { storeDescription, error in
            if let error = error {
                fatalError("Unresolved error \(error), \(error.localizedDescription)")
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
