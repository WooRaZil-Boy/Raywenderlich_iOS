//
//  CoreDataStack.swift
//  DogWalk
//
//  Created by 근성가이 on 2016. 12. 31..
//  Copyright © 2016년 근성가이. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    private let modelName: String
    
    init(modelName: String) {
        self.modelName = modelName
    }
    
    private lazy var storeContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: self.modelName)
        container.loadPersistentStores { storeDescription, error in //loadPersistentStores 호출하는 게 다임.
            if let error = error as NSError? {
                print("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    lazy var managedContext: NSManagedObjectContext = { //NSPersistentContainer는 공용 접근자를 가지고 있지만, CoreDataStack은 다르게? //lazy 속성 때문에 CoreDataStack의 공개적으로 액세스 할 수있는 유일한 부분은 NSManagedObjectContext
        return self.storeContainer.viewContext
    }()
}

extension CoreDataStack {
    func saveContext () {
        guard managedContext.hasChanges else { return }
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Unresolved error \(error), \(error.userInfo)")
        }
    }
}
