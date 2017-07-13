//
//  DogsViewController.swift
//  DogWalk
//
//  Created by Bianca Hinova on 7/5/17.
//  Copyright © 2017 bb. All rights reserved.
//

import UIKit
import CoreData

class DogsViewController: UIViewController, AddDogViewControllerDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var noDogsLabel: UILabel!
    
    var dogs = [Dog]()
    var managedContext: NSManagedObjectContext!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.fetchDogs()
        self.title = "Dogs"
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddDogSegue" {
            (segue.destination as! AddDogViewController).managedContext = self.managedContext
            (segue.destination as! AddDogViewController).delegate = self
        }
        
    }
    
    func fetchDogs() {
        if let dogs = Dog.fetchAllDogs(in: self.managedContext) {
            self.dogs = dogs
            if dogs.count > 0 {
                self.noDogsLabel.isHidden = true
            }
        }
    }
    
    func addDogViewControllerDidAddNewDog(_ sender: AddDogViewController) {
        self.fetchDogs()
        self.collectionView.reloadData()
    }
}

extension DogsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dogs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DogCell", for: indexPath) as! DogCell
        let dog = self.dogs[indexPath.item]
        cell.configure(with: dog)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let dog = self.dogs[indexPath.item]
        let walksVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WalksViewController") as! WalksViewController
        walksVC.managedContext = self.managedContext
        walksVC.dog = dog
        self.navigationController?.pushViewController(walksVC, animated: true)
    }
}
