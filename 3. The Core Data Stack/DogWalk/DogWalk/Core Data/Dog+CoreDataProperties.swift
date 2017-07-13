//
//  Dog+CoreDataProperties.swift
//  DogWalk
//
//  Created by Bianca Hinova on 7/6/17.
//  Copyright © 2017 bb. All rights reserved.
//
//

import Foundation
import CoreData


extension Dog {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Dog> {
        return NSFetchRequest<Dog>(entityName: "Dog")
    }

    @NSManaged public var imageData: NSData?
    @NSManaged public var name: String?
    @NSManaged public var walks: NSOrderedSet?

}

// MARK: Generated accessors for walks
extension Dog {

    @objc(insertObject:inWalksAtIndex:)
    @NSManaged public func insertIntoWalks(_ value: Walk, at idx: Int)

    @objc(removeObjectFromWalksAtIndex:)
    @NSManaged public func removeFromWalks(at idx: Int)

    @objc(insertWalks:atIndexes:)
    @NSManaged public func insertIntoWalks(_ values: [Walk], at indexes: NSIndexSet)

    @objc(removeWalksAtIndexes:)
    @NSManaged public func removeFromWalks(at indexes: NSIndexSet)

    @objc(replaceObjectInWalksAtIndex:withObject:)
    @NSManaged public func replaceWalks(at idx: Int, with value: Walk)

    @objc(replaceWalksAtIndexes:withWalks:)
    @NSManaged public func replaceWalks(at indexes: NSIndexSet, with values: [Walk])

    @objc(addWalksObject:)
    @NSManaged public func addToWalks(_ value: Walk)

    @objc(removeWalksObject:)
    @NSManaged public func removeFromWalks(_ value: Walk)

    @objc(addWalks:)
    @NSManaged public func addToWalks(_ values: NSOrderedSet)

    @objc(removeWalks:)
    @NSManaged public func removeFromWalks(_ values: NSOrderedSet)

}

extension Dog {
    
    class func fetchAllDogs(in context: NSManagedObjectContext) -> [Dog]? {
        let request = NSFetchRequest<Dog>(entityName: "Dog")
        do {
            let dogs = try context.fetch(request)
            return dogs
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        return nil
    }
    
    @discardableResult
    class func addNewDog(name: String, imageData: NSData?, in context: NSManagedObjectContext) -> Bool {
        let entity = NSEntityDescription.entity(forEntityName: "Dog", in: context)
        let newDog = Dog(entity: entity!, insertInto: context)
        newDog.name = name
        newDog.imageData = imageData
        do {
            try context.save()
        } catch let error as NSError {
            print("Error saving new dog -> " + error.localizedDescription)
            return false
        }
        return true
    }
    
    func addWalk(in context: NSManagedObjectContext) {
        let walkEntity = NSEntityDescription.entity(forEntityName: "Walk", in: context)
        let walk = Walk(entity: walkEntity!, insertInto: context)
        walk.time = NSDate()
        if let walks = self.walks?.mutableCopy() as? NSMutableOrderedSet {
            walks.add(walk)
            self.walks = walks.copy() as? NSOrderedSet
        }
        
        do {
            try context.save()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    func deleteWalk(_ walkToDelete: Walk, in context: NSManagedObjectContext) {
        context.delete(walkToDelete)
        do {
            try context.save()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
}
