//
//  Venue+CoreDataProperties.swift
//  Bubble Tea Finder
//
//  Created by Bianca Hinova on 7/7/17.
//  Copyright © 2017 bb. All rights reserved.
//
//

import Foundation
import CoreData


extension Venue {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Venue> {
        return NSFetchRequest<Venue>(entityName: "Venue")
    }

    @NSManaged public var specialCount: Int32
    @NSManaged public var phone: String?
    @NSManaged public var name: String?
    @NSManaged public var favourite: Bool
    @NSManaged public var stats: Stats?
    @NSManaged public var priceInfo: PriceInfo?
    @NSManaged public var location: Location?
    @NSManaged public var category: Category?

}

extension Venue {
    
    class func fetchAll(in context: NSManagedObjectContext, _ completion : @escaping (_ result: [Venue]?, _ error: NSError?) -> Void) {
        let request = context.persistentStoreCoordinator?.managedObjectModel.fetchRequestTemplate(forName: "FetchAllVenues") as? NSFetchRequest<Venue>
        
        let asyncRequest = NSAsynchronousFetchRequest(fetchRequest: request!, completionBlock: {(result) in
            completion(result.finalResult, nil)
        })
        do {
            let _ = try context.execute(asyncRequest)
        } catch let error as NSError {
            print(error.localizedDescription)
            completion(nil, error)
        }
    }
    
    class func fetch(with predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?, in context: NSManagedObjectContext, _ completion : @escaping (_ result: [Venue]?, _ error: NSError?) -> Void) {
        let request = NSFetchRequest<Venue>(entityName: "Venue")
        if let predicate = predicate {
            request.predicate = predicate
        }
        request.sortDescriptors = sortDescriptors
        
        let asyncRequest = NSAsynchronousFetchRequest(fetchRequest: request, completionBlock: {(result) in
            completion(result.finalResult, nil)
        })
        
        do {
            let _ = try context.execute(asyncRequest)
        } catch let error as NSError {
            print(error.localizedDescription)
            completion(nil, error)
        }
    }
    
    class func countForCheapVenues(in context: NSManagedObjectContext) -> Int {
        return Venue.countForVenues(in: context, predicateFormat: "$")
    }
    
    class func countForModerateVenues(in context: NSManagedObjectContext) -> Int {
        return Venue.countForVenues(in: context, predicateFormat: "$$")
    }
    
    class func countForExpensiveVenues(in context: NSManagedObjectContext) -> Int {
        return Venue.countForVenues(in: context, predicateFormat: "$$$")
    }
    
    class func countForVenues(in context: NSManagedObjectContext, predicateFormat: String) -> Int {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Venue")
        request.resultType = .countResultType
        let predicate = NSPredicate(format: "priceInfo.category == %@", predicateFormat)
        request.predicate = predicate
        var count: Int = 0
        do {
            let results = try context.fetch(request) as! [NSNumber]
            if results.count > 0 {
                count = results[0].intValue
            }
            
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        return count
    }
    
    class func offeringDealsSum(in context: NSManagedObjectContext) -> Int {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Venue")
        request.resultType = .dictionaryResultType
        
        let sumExpressionDesc = NSExpressionDescription()
        sumExpressionDesc.name = "sumDeals"
        sumExpressionDesc.expression = NSExpression(forFunction: "sum:", arguments: [NSExpression(forKeyPath: "specialCount")])
        sumExpressionDesc.expressionResultType = .integer32AttributeType
            
        request.propertiesToFetch = [sumExpressionDesc]
        
        do {
            let results = try context.fetch(request) as! [NSDictionary]
            let resultDict = results.first!
            let numDeals = resultDict["sumDeals"] as! Int
            return numDeals
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        return 0
    }
    
}
