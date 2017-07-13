//
//  ViewController.swift
//  BowTies
//
//  Created by Bianca Hinova on 7/5/17.
//  Copyright © 2017 bb. All rights reserved.
//

import UIKit
import CoreData

class BowTiesViewController: UIViewController {
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var timesWornLabel: UILabel!
    @IBOutlet weak var lastWornLabel: UILabel!
    @IBOutlet weak var favouriteLabel: UILabel!
    
    var managedContext: NSManagedObjectContext!
    var currentBowtie: Bowtie! {
        didSet {
            self.populate(bowtie: self.currentBowtie)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.title = "Bow Ties"
        
        self.insertSampleData()
        
        let firstTitle = self.segmentedControl.titleForSegment(at: 0)
        if let bowtie = self.getTieForSearchKey(firstTitle!) {
            self.currentBowtie = bowtie
        }
    }
    
    func getTieForSearchKey(_ searchKey: String) -> Bowtie? {
        
        let request = NSFetchRequest<Bowtie>(entityName: "Bowtie")
        request.predicate = NSPredicate(format: "searchKey = %@", searchKey)
        
        do {
            let bowties = try self.managedContext.fetch(request)
            return bowties[0]
        } catch let error as NSError {
            print("\(error.localizedDescription)")
        }
        return nil
    }
    
    func populate(bowtie: Bowtie) {
        self.imageView.image = UIImage(data: bowtie.photoData! as Data)
        self.nameLabel.text = bowtie.name
        self.ratingLabel.text = "Rating: \(bowtie.rating)/5"
        self.timesWornLabel.text = "# times worn: \(bowtie.timesWorn)"
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        self.lastWornLabel.text = "Last worn: " + dateFormatter.string(from: bowtie.lastWorn! as Date)
        self.favouriteLabel.isHidden = !bowtie.isFavourite
        view.tintColor = bowtie.tintColor as! UIColor
    }
    
    func updateRating(numericString: String) {
        let bowtie = self.currentBowtie
        bowtie?.rating = (numericString as NSString).doubleValue
        
        if self.saveChanges() {
            self.currentBowtie = bowtie
        }
    }
    
    @discardableResult
    func saveChanges() -> Bool {
        do {
            try self.managedContext.save()
            return true
        } catch let error as NSError {
            print("\(error.localizedDescription)")
            if error.domain == NSCocoaErrorDomain &&
                (error.code == NSValidationNumberTooSmallError ||
                error.code == NSValidationNumberTooLargeError) {
                self.showErrorWithText("Please provide rating between 0 and 5")
            }
            return false
        }
    }
    
    func showErrorWithText(_ text: String) {
        let alert = UIAlertController(title: "Error", message: text, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    func insertSampleData() {
        let fetchRequest = NSFetchRequest<Bowtie>(entityName: "Bowtie")
        fetchRequest.predicate = NSPredicate(format: "searchKey != nil")
        var count = 0
        do {
            try count = self.managedContext.count(for: fetchRequest)
        } catch let error as NSError {
            print("\(error.localizedDescription)")
        }
        if count <= 0 {
            let path = Bundle.main.path(forResource: "SampleData", ofType: "plist")
            let dataArray = NSArray(contentsOfFile: path!)
            for dict in dataArray! {
                let entity = NSEntityDescription.entity(forEntityName: "Bowtie", in: self.managedContext)
                let bowtie = Bowtie(entity: entity!, insertInto: self.managedContext)
                let btDict = dict as! NSDictionary
                bowtie.name = btDict["name"] as? String
                bowtie.searchKey = btDict["searchKey"] as? String
                bowtie.rating = btDict["rating"] as! Double
                let tintColor = btDict["tintColor"] as! NSDictionary
                bowtie.tintColor = self.colorFrom(dict: tintColor)
                let imageName = btDict["imageName"] as! String
                let image = UIImage(named: imageName)
                let photoData = UIImagePNGRepresentation(image!)
                bowtie.photoData = photoData as NSData?
                bowtie.lastWorn = btDict["lastWorn"] as? NSDate
                bowtie.timesWorn = btDict["timesWorn"] as! Int32
                bowtie.isFavourite = btDict["isFavourite"] as? Bool ?? false
                self.saveChanges()
            }
        }
    }
    
    func colorFrom(dict: NSDictionary) -> UIColor {
        let red = dict["red"] as! NSNumber
        let green = dict["green"] as! NSNumber
        let blue = dict["blue"] as! NSNumber
        let color = UIColor(red: CGFloat(red)/255.0, green: CGFloat(green)/255.0, blue: CGFloat(blue)/255.0, alpha: 1.0)
        return color
    }
    
    @IBAction func segmenetedControlChangedValue(_ sender: UISegmentedControl) {
        let searchKey = sender.titleForSegment(at: sender.selectedSegmentIndex)
        if let bowtie = self.getTieForSearchKey(searchKey!) {
            self.currentBowtie = bowtie
        }
    }
    
    @IBAction func wearButtonTapped(_ sender: UIButton) {
        let bowtie = self.currentBowtie
        bowtie?.timesWorn += 1
        bowtie?.lastWorn = NSDate()
        
        if self.saveChanges() {
            self.currentBowtie = bowtie
        }
    }
    
    @IBAction func rateButtonTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Rate", message: "What score you give to this bow tie?", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default, handler: { (action) in
            let textField = alert.textFields![0] as UITextField
            self.updateRating(numericString: textField.text!)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {(action) in
        })
        alert.addTextField(configurationHandler: { (textField) in
            textField.keyboardType = .numberPad
        })
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
}

