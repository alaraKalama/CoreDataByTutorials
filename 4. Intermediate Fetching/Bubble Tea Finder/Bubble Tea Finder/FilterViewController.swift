//
//  FilterViewController.swift
//  Bubble Tea Finder
//
//  Created by Bianca Hinova on 7/7/17.
//  Copyright © 2017 bb. All rights reserved.
//

import UIKit

protocol FilterViewControllerDelegate {
    func filterViewController(_ sender: FilterViewController, didSelectPredicate predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?)
}

class FilterViewController: UITableViewController {
    
    // Price section
    @IBOutlet weak var cheapVenueCell: UITableViewCell!
    @IBOutlet weak var moderateVenueCell: UITableViewCell!
    @IBOutlet weak var expensiveVenueCell: UITableViewCell!
    
    // Most popular section
    @IBOutlet weak var offeringDealCell: UITableViewCell!
    @IBOutlet weak var walkingDistanceCell: UITableViewCell!
    @IBOutlet weak var userTipsCell: UITableViewCell!
    
    // Sort by section
    @IBOutlet weak var nameAZCell: UITableViewCell!
    @IBOutlet weak var nameZACell: UITableViewCell!
    @IBOutlet weak var distanceSortCell: UITableViewCell!
    @IBOutlet weak var priceSortCell: UITableViewCell!
    
    var stack: CoreDataStack!
    var delegate: FilterViewControllerDelegate?
    var selectedSortDescriptor: NSSortDescriptor?
    var selectedPredicate: NSPredicate?
    
    var selectedPredicateString: String?
    
    lazy var nameSortDescriptorAscending: NSSortDescriptor = {
        let descriptor = NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.localizedStandardCompare(_:)))
        return descriptor
    }()
    
    lazy var nameSortDescriptorDescending: NSSortDescriptor = {
        let descriptor = NSSortDescriptor(key: "name", ascending: false, selector: #selector(NSString.localizedStandardCompare(_:)))
        return descriptor
    }()
    
    lazy var distanceSortDescritor: NSSortDescriptor = {
        let descriptor = NSSortDescriptor(key: "location.distance", ascending: true)
        return descriptor
    }()
    
    lazy var priceSortDescriptor: NSSortDescriptor = {
        let descritor = NSSortDescriptor(key: "priceInfo.category", ascending: true)
        return descritor
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.populateTableView()
    }
    
    func populateTableView() {
        self.cheapVenueCell.detailTextLabel?.text = "\(Venue.countForCheapVenues(in: self.stack.context)) bubble tea places"
        self.moderateVenueCell.detailTextLabel?.text = "\(Venue.countForModerateVenues(in: self.stack.context)) bubble tea places"
        self.expensiveVenueCell.detailTextLabel?.text = "\(Venue.countForExpensiveVenues(in: self.stack.context)) bubble tea places"
        self.offeringDealCell.detailTextLabel?.text = "\(Venue.offeringDealsSum(in: self.stack.context)) total deals"
    }
    
    func generatePredicate() -> String? {
        var finalPredicateString: String? = nil
        var countOfPredicateSelections = 0
        var selectedPriceCategory: Bool = false
        var priceStringArgument: String? = nil
        let priceCategoryString = "priceInfo.category == '%@'"
        var pricePredicateString: String? = nil
        
        if self.cheapVenueCell.isSelected {
            selectedPriceCategory = true
            priceStringArgument = "$"
        }
        if self.moderateVenueCell.isSelected {
            selectedPriceCategory = true
            priceStringArgument = "$$"
        }
        if self.expensiveVenueCell.isSelected {
            selectedPriceCategory = true
            priceStringArgument = "$$$"
        }
        
        if selectedPriceCategory {
            pricePredicateString = NSString.init(format: priceCategoryString as NSString, priceStringArgument!) as String
            finalPredicateString = pricePredicateString!
            countOfPredicateSelections += 1
        }
        
        if self.offeringDealCell.isSelected {
            countOfPredicateSelections += 1
            if countOfPredicateSelections == 2 {
                let additionalString = " AND specialCount > 0"
                finalPredicateString = finalPredicateString?.appending(additionalString)
            } else {
                finalPredicateString = "specialCount > 0"
            }
        }
        
        if self.walkingDistanceCell.isSelected {
            countOfPredicateSelections += 1
            if countOfPredicateSelections > 1 {
                let additionalString = " AND location.distance < 500"
                finalPredicateString = finalPredicateString?.appending(additionalString)
            } else {
                finalPredicateString = "location.distance < 500"
            }
        }
        
        if self.userTipsCell.isSelected {
            countOfPredicateSelections += 1
            if countOfPredicateSelections > 1 {
                let additionalString = " AND stats.tipCount > 0"
                finalPredicateString = finalPredicateString?.appending(additionalString)
            } else {
                finalPredicateString = "stats.tipCount > 0"
            }
        }
        
        return finalPredicateString
        
    }
    
    func generateSortDescriptors() -> [NSSortDescriptor] {
        var descriptors = [NSSortDescriptor]()
        if self.nameAZCell.isSelected {
            let descriptor = NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.localizedStandardCompare(_:)))
            descriptors.append(descriptor)
        }
        if self.nameZACell.isSelected {
            let descriptor = NSSortDescriptor(key: "name", ascending: false, selector: #selector(NSString.localizedStandardCompare(_:)))
            descriptors.append(descriptor)
        }
        if self.distanceSortCell.isSelected {
            let descriptor = NSSortDescriptor(key: "location.distance", ascending: true)
            descriptors.append(descriptor)
        }
        if self.priceSortCell.isSelected {
            let descritor = NSSortDescriptor(key: "priceInfo.category", ascending: true)
            descriptors.append(descritor)
        }
        return descriptors
    }
    
    @IBAction func searchButtonTapped(_ sender: UIBarButtonItem) {
        var predicate: NSPredicate? = nil
        if let predicateString = self.generatePredicate() {
            predicate = NSPredicate(format: predicateString)
        }
        
        self.selectedSortDescriptor = nil
        self.delegate?.filterViewController(self, didSelectPredicate: predicate, sortDescriptors: self.generateSortDescriptors())
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Table view

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        cell.accessoryType = .checkmark
        
        switch cell {
        case self.cheapVenueCell:
            
            tableView.deselectRow(at: tableView.indexPath(for: self.moderateVenueCell)!, animated: true)
            self.moderateVenueCell.accessoryType = .none
            tableView.deselectRow(at: tableView.indexPath(for: self.expensiveVenueCell)!, animated: true)
            self.expensiveVenueCell.accessoryType = .none
            
        case self.moderateVenueCell:
            
            tableView.deselectRow(at: tableView.indexPath(for: self.cheapVenueCell)!, animated: true)
            self.cheapVenueCell.accessoryType = .none
            tableView.deselectRow(at: tableView.indexPath(for: self.expensiveVenueCell)!, animated: true)
            self.expensiveVenueCell.accessoryType = .none
            
        case self.expensiveVenueCell:
            
            tableView.deselectRow(at: tableView.indexPath(for: self.cheapVenueCell)!, animated: true)
            self.cheapVenueCell.accessoryType = .none
            tableView.deselectRow(at: tableView.indexPath(for: self.moderateVenueCell)!, animated: true)
            self.moderateVenueCell.accessoryType = .none
            
        case self.nameAZCell:
            tableView.deselectRow(at: tableView.indexPath(for: self.nameZACell)!, animated: true)
            self.nameZACell.accessoryType = .none
        case self.nameZACell:
            tableView.deselectRow(at: tableView.indexPath(for: self.nameAZCell)!, animated: true)
            self.nameAZCell.accessoryType = .none
            
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .none
    }
}
