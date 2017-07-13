//
//  CoreDataStack.swift
//  Bubble Tea Finder
//
//  Created by Bianca Hinova on 7/7/17.
//  Copyright © 2017 bb. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    
    let modelName = "Bubble_Tea_Finder"
    
    private lazy var applicationDocumentsDirectory: URL = {
       let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls.first!
    }()
    
    lazy var context: NSManagedObjectContext = {
       var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = self.coordinator
        
        return managedObjectContext
    }()
    
    private lazy var coordinator: NSPersistentStoreCoordinator = {
        let storeCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.model)
        let url = self.applicationDocumentsDirectory.appendingPathComponent(self.modelName)
        
        do {
            let options = [NSMigratePersistentStoresAutomaticallyOption : true]
            try storeCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: options)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        return storeCoordinator
    }()
    
    private lazy var model: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: self.modelName, withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    func saveContext() {
        if self.context.hasChanges {
            do {
                try self.context.save()
            } catch let error as NSError {
                print(error.localizedDescription)
                abort()
            }
        }
    }
}
