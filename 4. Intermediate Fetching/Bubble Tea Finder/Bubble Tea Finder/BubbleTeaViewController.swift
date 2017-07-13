//
//  ViewController.swift
//  Bubble Tea Finder
//
//  Created by Bianca Hinova on 7/7/17.
//  Copyright © 2017 bb. All rights reserved.
//

import UIKit
import CoreData

class BubbleTeaViewController: UIViewController, FilterViewControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noVenuesLabel: UILabel!
    
    var stack = CoreDataStack()
    var venuesFetchRequest: NSFetchRequest<Venue>?
    var venues = [Venue]() {
        didSet {
            if venues.count <= 0 {
                self.tableView.isHidden = true
                self.noVenuesLabel.isHidden = false
            } else {
                self.tableView.isHidden = false
                self.noVenuesLabel.isHidden = true
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let batchUpdate = NSBatchUpdateRequest(entityName: "Venue")
        batchUpdate.propertiesToUpdate = ["favourite" : NSNumber(value: true)]
        batchUpdate.affectedStores = self.stack.context.persistentStoreCoordinator?.persistentStores
        batchUpdate.resultType = .updatedObjectsCountResultType
        
        do {
            
            let batchResult = try self.stack.context.execute(batchUpdate) as! NSBatchUpdateResult
            print(batchResult.result!)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        self.fetchAndReload()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "filterSegue" {
            let navVC = segue.destination as! UINavigationController
            let filterVC = navVC.topViewController as! FilterViewController
            filterVC.stack = self.stack
            filterVC.delegate = self
        }
    }
    
    func fetchAndReload() {
        Venue.fetchAll(in: self.stack.context, { (venues, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            else if venues != nil {
                self.venues = venues!
                self.tableView.reloadData()
            }
        })
    }
    
    func filterViewController(_ sender: FilterViewController, didSelectPredicate predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?) {
        
        Venue.fetch(with: predicate, sortDescriptors: sortDescriptors, in: self.stack.context, {(result, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            if result != nil {
                self.venues = result!
                self.tableView.reloadData()
            }
        })
        
        
    }
    
    @IBAction func unwindToVenuListViewController(segue: UIStoryboardSegue) {
    }
    
}

extension BubbleTeaViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.venues.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VenueCell", for: indexPath)
        let venue = self.venues[indexPath.row]
        cell.textLabel?.text = venue.name
        cell.detailTextLabel?.text = venue.priceInfo?.category
        return cell
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let venue = self.venues[indexPath.row]
//    }
}

