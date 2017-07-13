//
//  ViewController.swift
//  WorldCup
//
//  Created by Bianca Hinova on 7/10/17.
//  Copyright © 2017 bb. All rights reserved.
//

import UIKit
import CoreData

class TeamsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    var stack: CoreDataStack!
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Team")
        let zoneSort = NSSortDescriptor(key: "qualifyingZone", ascending: true)
        let winsSort = NSSortDescriptor(key: "wins", ascending: false)
        let nameSort = NSSortDescriptor(key: "teamName", ascending: true)
        request.sortDescriptors = [zoneSort, winsSort, nameSort]
        self.fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: self.stack.context, sectionNameKeyPath: "qualifyingZone", cacheName: "worldCup")
        self.fetchedResultsController.delegate = self
        
        do {
            try self.fetchedResultsController.performFetch()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Secret Team", message: "Add a new team", preferredStyle: .alert)
        
        var nameTextField: UITextField!
        var zoneTextField: UITextField!
        
        alert.addTextField(configurationHandler: {(textField) in
            nameTextField = textField
            textField.placeholder = "Team Name"
        })
        
        alert.addTextField(configurationHandler: {(textFied) in
            zoneTextField = textFied
            textFied.placeholder = "Zone"
        })
        
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: {(action) in
            print("saved")
            let team = NSEntityDescription.insertNewObject(forEntityName: "Team", into: self.stack.context) as! Team
            team.teamName = nameTextField.text!
            team.qualifyingZone = zoneTextField.text!
            team.imageName = "wanderland-flag"
            self.stack.saveContext()
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: {(action) in
            
        }))
        
        self.present(alert, animated: true, completion: nil)
        
        
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections!.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.fetchedResultsController.sections![section].numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TeamCell") as! TeamCell
        self.configureCell(cell: cell, indexPath: indexPath)
        return cell
    }
    
    func configureCell(cell: TeamCell, indexPath: IndexPath) {
        let team = self.fetchedResultsController.object(at: indexPath) as! Team
        
        cell.flagImageView.image = UIImage(named: team.imageName!)
        cell.nameLabel.text = team.teamName
        cell.subLabel.text = "\(team.wins) wins"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let team = self.fetchedResultsController.object(at: indexPath) as! Team
        let wins = team.wins
        team.wins = wins + 1
        self.stack.saveContext()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.fetchedResultsController.sections![section].name
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            self.tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            self.tableView.deleteRows(at: [indexPath!], with: .automatic)
        case .update:
            let cell = self.tableView.cellForRow(at: indexPath!) as! TeamCell
            self.configureCell(cell: cell, indexPath: indexPath!)
        case .move:
            self.tableView.deleteRows(at: [indexPath!], with: .automatic)
            self.tableView.insertRows(at: [newIndexPath!], with: .automatic)
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        let indexSet = IndexSet(integer: sectionIndex)
        switch type {
        case .insert:
            self.tableView.insertSections(indexSet, with: .automatic)
        case .delete:
            self.tableView.deleteSections(indexSet, with: .automatic)
        default:
            break
        }
        
    }
}

