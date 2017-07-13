//
//  ViewController.swift
//  DogWalk
//
//  Created by Bianca Hinova on 7/5/17.
//  Copyright © 2017 bb. All rights reserved.
//

import UIKit
import CoreData

class WalksViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noWalksLabel: UILabel!
    
    var managedContext: NSManagedObjectContext!
    var dog: Dog!
    
    private lazy var dateFormatter: DateFormatter = {
       let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "\(self.dog.name!)'s Walks"
        self.imageView.layer.masksToBounds = true
        self.imageView.layer.cornerRadius = 90
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        let addBarButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.add(_:)))
        self.navigationItem.rightBarButtonItem = addBarButton
        
        self.checkWalksCountAndManageViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let data = dog.imageData as Data? {
            self.imageView.image = UIImage(data: data)
        } else {
            self.imageView.image = #imageLiteral(resourceName: "paw")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func checkWalksCountAndManageViews() {
        if self.dog.walks!.count <= 0 {
            self.tableView.isHidden = true
            self.noWalksLabel.isHidden = false
        } else {
            self.tableView.isHidden = false
            self.noWalksLabel.isHidden = true
        }
    }
    
    @IBAction func add(_ sender: AnyObject) {
        self.dog.addWalk(in: self.managedContext)
        self.tableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.checkWalksCountAndManageViews()
        return self.dog.walks?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let walk = self.dog.walks![indexPath.row] as! Walk
        cell.textLabel?.text = self.dateFormatter.string(from: walk.time! as Date)
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 12.0)
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete", handler: {(action, indexPath) -> Void in
            print("Delete action")
            let walk = self.dog.walks![indexPath.row] as! Walk
            self.dog.deleteWalk(walk, in: self.managedContext)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        })
        var result = [UITableViewRowAction]()
        result.append(deleteAction)
        return result
    }
}

