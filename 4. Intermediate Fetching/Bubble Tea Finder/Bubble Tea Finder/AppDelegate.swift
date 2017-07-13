//
//  AppDelegate.swift
//  Bubble Tea Finder
//
//  Created by Bianca Hinova on 7/7/17.
//  Copyright © 2017 bb. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    lazy var coreDataStack = CoreDataStack()


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        self.importJSONSeedDataIfNeeded()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.coreDataStack.saveContext()
    }
    
    func importJSONSeedDataIfNeeded() {
        let fetchRequest = NSFetchRequest<Venue>(entityName: "Venue")
        
        var count = 0
        
        do {
            count = try self.coreDataStack.context.count(for: fetchRequest)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        if count == 0 {
            
            var venues: [Venue]? = nil
            do {
                let results = try self.coreDataStack.context.fetch(fetchRequest)
                venues = results
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            
            for venue in venues! {
                self.coreDataStack.context.delete(venue)
            }
            
            self.coreDataStack.saveContext()
            self.importJSONSeedData()
        }
    }
    
    func importJSONSeedData() {
        let jsonURL = Bundle.main.url(forResource: "seed", withExtension: "json")!
        var data: Data?
        
        do {
            data = try Data(contentsOf: jsonURL)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        var jsonDict: Dictionary<String, Any>?
        do {
            jsonDict = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? Dictionary<String, Any>
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        guard let dict = jsonDict else {
            return
        }
        
        let venueEntity = NSEntityDescription.entity(forEntityName: "Venue", in: self.coreDataStack.context)
        let locationEntity = NSEntityDescription.entity(forEntityName: "Location", in: self.coreDataStack.context)
        let categoryEntity = NSEntityDescription.entity(forEntityName: "Category", in: self.coreDataStack.context)
        let priceInfoEntity = NSEntityDescription.entity(forEntityName: "PriceInfo", in: self.coreDataStack.context)
        let statsEntity = NSEntityDescription.entity(forEntityName: "Stats", in: self.coreDataStack.context)
        
        let response = dict["response"] as! Dictionary<String, Any>
        let venuesArray = response["venues"] as! NSArray
        
        for dict in venuesArray {
            guard let venueDict = dict as? NSDictionary else {
                return
            }
            let name = venueDict.value(forKey: "name") as? String
            let contacts = venueDict.value(forKey: "contact.phone") as? NSDictionary
            let phone = contacts?.value(forKey: "phone") as? String
            let specials = venueDict.value(forKey: "specials") as? NSDictionary
            let specialCount = specials?.value(forKey: "count") as? Int32
            
            let locationDict = venueDict.value(forKey: "location") as? NSDictionary
            let priceDict = venueDict.value(forKey: "price") as? NSDictionary
            let statsDict = venueDict.value(forKey: "stats") as? NSDictionary
            
            let location = Location(entity: locationEntity!, insertInto: self.coreDataStack.context)
            location.address = locationDict?.value(forKey: "address") as? String
            location.city = locationDict?.value(forKey: "city") as? String
            location.state = locationDict?.value(forKey: "state") as? String
            location.zipcode = locationDict?.value(forKey: "postalCode") as? String
            location.distance = locationDict?.value(forKey: "distance") as? Float ?? 0
            
            let category = Category(entity: categoryEntity!, insertInto: self.coreDataStack.context)
            
            let priceInfo = PriceInfo(entity: priceInfoEntity!, insertInto: self.coreDataStack.context)
            priceInfo.category = priceDict?.value(forKey: "currency") as? String
            
            let stats = Stats(entity: statsEntity!, insertInto: self.coreDataStack.context)
            stats.checkinsCount = statsDict?.value(forKey: "checkinsCount") as? Int32 ?? 0
            stats.usersCount = statsDict?.value(forKey: "userCount") as? Int32 ?? 0
            stats.tipCount = statsDict?.value(forKey: "tipCount") as? Int32 ?? 0
            
            let venue = Venue(entity: venueEntity!, insertInto: self.coreDataStack.context)
            venue.name = name
            venue.phone = phone
            venue.specialCount = specialCount ?? 0
            venue.location = location
            venue.category = category
            venue.priceInfo = priceInfo
            venue.stats = stats
            
        }
        self.coreDataStack.saveContext()
    }
}

