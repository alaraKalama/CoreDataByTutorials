//
//  AppDelegate.swift
//  WorldCup
//
//  Created by Bianca Hinova on 7/10/17.
//  Copyright © 2017 bb. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var stack = CoreDataStack()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        self.importJSONSeedIfNeeded()
        let navVC = self.window?.rootViewController as! UINavigationController
        let teamsVC = navVC.topViewController as! TeamsViewController
        teamsVC.stack = self.stack
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
    }
    
    func importJSONSeedIfNeeded() {
        let fetchRequest = NSFetchRequest<Team>(entityName: "Team")
        
        do {
            let teamsCount = try self.stack.context.count(for: fetchRequest)
            if teamsCount <= 0 {
                self.importJSONData()
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    func importJSONData() {
        let jsonURL = Bundle.main.url(forResource: "seed", withExtension: "json")
        
        var jsonArray: NSArray!
        
        do {
            let jsonData = try Data(contentsOf: jsonURL!)
            let array = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as! NSArray
            jsonArray = array
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        let teamEntity = NSEntityDescription.entity(forEntityName: "Team", in: self.stack.context)!
        
        for dict in jsonArray {
            let jsonDict = dict as! NSDictionary
            let name = jsonDict["teamName"] as? String
            let zone = jsonDict["qualifyingZone"] as? String
            let imageName = jsonDict["imageName"] as? String
            let wins = jsonDict["wins"] as? Int32
            
            let team = Team(entity: teamEntity, insertInto: self.stack.context)
            team.teamName = name
            team.qualifyingZone = zone
            team.imageName = imageName
            team.wins = wins!
        }
        
        self.stack.saveContext()
    }


}

