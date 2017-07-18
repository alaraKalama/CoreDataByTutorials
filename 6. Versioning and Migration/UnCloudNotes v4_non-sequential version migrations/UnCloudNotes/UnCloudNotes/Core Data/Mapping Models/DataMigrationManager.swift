//
//  DataMigrationManager.swift
//  UnCloudNotes
//
//  Created by Bianca Hinova on 7/13/17.
//  Copyright © 2017 bb. All rights reserved.
//

import Foundation
import CoreData

class DataMigrationManager {
    
    let modelName: String
    var options: [AnyHashable : Any]?
    var stack: CoreDataStack {
        if !storeIsCompatibleWith(model: self.currentModel) {
            self.performMigration()
        }
        return CoreDataStack(modelName: self.modelName, options: self.options)
    }
    
    lazy var storeURL: URL = {
        var storePaths = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true)
        let firstStorePath = storePaths.first! as NSString
        let storePath = firstStorePath.strings(byAppendingPaths: [self.modelName + "sqlite"])
        return URL.init(fileURLWithPath: storePaths.first ?? "")
    }()
    
    lazy var storeModel: NSManagedObjectModel? = {
        for model in NSManagedObjectModel.modelVersionFor(name: self.modelName) {
            if self.storeIsCompatibleWith(model: model) {
                print("Store \(self.storeURL) is compatible with model \(model.versionIdentifiers)")
                return model
            }
        }
        return nil
    }()
    
    lazy var currentModel: NSManagedObjectModel = {
        if let modelURL = Bundle.main.url(forResource: self.modelName, withExtension: "momd") {
            return NSManagedObjectModel(contentsOf: modelURL) ?? NSManagedObjectModel()
        }
        return NSManagedObjectModel()
    }()
    
    init(modelName: String) {
        self.modelName = modelName
    }
    
    func performMigration() {
        if !currentModel.isVersion4() {
            fatalError("Can only handle migrations to version 4")
        }
        
        if storeModel?.isVersion1() == true {
            self.options = [NSMigratePersistentStoresAutomaticallyOption : true, NSInferMappingModelAutomaticallyOption : true]
        } else {
            self.options = [NSMigratePersistentStoresAutomaticallyOption : true, NSInferMappingModelAutomaticallyOption : false]
        }
        
        if self.storeModel?.isVersion1() == true {
            let destinationModel = NSManagedObjectModel.version2()
            self.migrateStoreAt(URL: self.storeURL, fromModel: storeModel!, toModel: destinationModel)
            self.performMigration()
        } else if self.storeModel?.isVersion2() == true {
            let destinationModel = NSManagedObjectModel.version3()
            let mappingModel = NSMappingModel(from: nil, forSourceModel: self.storeModel!, destinationModel: destinationModel)
            
            self.migrateStoreAt(URL: self.storeURL, fromModel: self.storeModel!, toModel: destinationModel, mappingModel: mappingModel)
            self.performMigration()
        } else if storeModel?.isVersion3() == true {
            let destinationModel = NSManagedObjectModel.version4()
            let mappingModel = NSMappingModel(from: nil, forSourceModel: self.storeModel!, destinationModel: destinationModel)
            
            self.migrateStoreAt(URL: self.storeURL, fromModel: self.storeModel!, toModel: destinationModel, mappingModel: mappingModel)
        }
    }
    
    func migrateStoreAt(URL storeURL: URL, fromModel from: NSManagedObjectModel, toModel to: NSManagedObjectModel, mappingModel: NSMappingModel? = nil) {
        let migrationManager = NSMigrationManager(sourceModel: from, destinationModel: to)
        
        var migrationMappingModel: NSMappingModel? = nil
        if let mappingModel = mappingModel {
            migrationMappingModel = mappingModel
        } else {
            do {
                migrationMappingModel = try NSMappingModel.inferredMappingModel(forSourceModel: from, destinationModel: to)
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
        
        let destinationURL = self.storeURL.deletingLastPathComponent()
        let destinationName = self.storeURL.lastPathComponent + "~" + "1"
        let destination = destinationURL.appendingPathComponent(destinationName)
        
        print("From model: \(from.versionIdentifiers)")
        print("To model : \(to.versionIdentifiers)")
        print("Migrating store \(storeURL) to \(destination.absoluteString)")
        print("Mapping model: \(mappingModel.debugDescription)")
        
        var success: Bool = false
        
        do {
            try migrationManager.migrateStore(from: storeURL, sourceType: NSSQLiteStoreType, options: nil, with: migrationMappingModel!, toDestinationURL: destination, destinationType: NSSQLiteStoreType, destinationOptions: nil)
            success = true
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        if success {
            print("Migration completed successfully")
            let fileManager = FileManager.default
            do {
                try fileManager.removeItem(at: self.storeURL)
                try fileManager.moveItem(at: destination, to: self.storeURL)
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }
    
    func storeIsCompatibleWith(model: NSManagedObjectModel) -> Bool {
        let storeMetadata = self.metadataForStoreAt(url: self.storeURL)
        return model.isConfiguration(withName: nil, compatibleWithStoreMetadata: storeMetadata)
    }
    
    func metadataForStoreAt(url: URL) -> [String : Any] {
        var metadata: [String : Any]? = nil
        do {
            metadata = try NSPersistentStoreCoordinator.metadataForPersistentStore(ofType: NSSQLiteStoreType, at: url, options: nil)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        return metadata ?? [:]
    }
}

extension NSManagedObjectModel {
    class func modelVersionFor(name: String) -> [NSManagedObjectModel] {
        let urls = Bundle.main.urls(forResourcesWithExtension: "mom", subdirectory: "\(name).momd") ?? []
        
        return urls.map { NSManagedObjectModel(contentsOf: $0) }
            .filter{ $0 != nil }
            .map { $0! }
    }
    
    class func uncloudNotesModel(named name: String) -> NSManagedObjectModel {
        if let modelURL = Bundle.main.url(forResource: name, withExtension: "mom", subdirectory: "UnCloudNotes.momd") {
            return NSManagedObjectModel(contentsOf: modelURL) ?? NSManagedObjectModel()
        }
        return NSManagedObjectModel()
    }
    
    class func version1() -> NSManagedObjectModel {
        return uncloudNotesModel(named: "UnCloudNotes")
    }
    
    func isVersion1() -> Bool {
        return self == NSManagedObjectModel.version1()
    }
    
    class func version2() -> NSManagedObjectModel {
        return uncloudNotesModel(named: "UnCloudNotes v2")
    }
    
    func isVersion2() -> Bool {
        return self == NSManagedObjectModel.version2()
    }
    
    class func version3() -> NSManagedObjectModel {
        return uncloudNotesModel(named: "UnCloudNotes v3")
    }
    
    func isVersion3() -> Bool {
        return self == NSManagedObjectModel.version3()
    }
    
    class func version4() -> NSManagedObjectModel {
        return uncloudNotesModel(named: "UnCloudNotes v4")
    }
    
    func isVersion4() -> Bool {
        return self == NSManagedObjectModel.version4()
    }
    
}
