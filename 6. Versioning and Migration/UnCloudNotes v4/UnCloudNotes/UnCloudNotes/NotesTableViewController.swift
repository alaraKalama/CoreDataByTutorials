//
//  NotesTableViewController.swift
//  UnCloudNotes
//
//  Created by Bianca Hinova on 7/11/17.
//  Copyright © 2017 bb. All rights reserved.
//

import UIKit
import CoreData

class NotesTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    var stack: CoreDataStack!
    
    lazy var notes: NSFetchedResultsController<Note> = {
        let context = self.stack.context
        let request = Note.notesFetchRequest()
        let sort = NSSortDescriptor(key: "dateCreated", ascending: false)
        request.sortDescriptors = [sort]
        let notes = NSFetchedResultsController(fetchRequest: request, managedObjectContext: self.stack.context, sectionNameKeyPath: nil, cacheName: nil)
        notes.delegate = self
        return notes
    }()
    
    lazy var dateFormatter: DateFormatter = {
        var formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        return formatter
    }()
    
    var selectedNote: Note?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.clearsSelectionOnViewWillAppear = true
        do {
            try self.notes.performFetch()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "createNoteSegue" {
            let navVC = segue.destination as! UINavigationController
            let createVC = navVC.topViewController as! CreateNoteViewController
            createVC.stack = self.stack
        }
    }
    
    @IBAction func unwindToNotesTableViewController(segue: UIStoryboardSegue) {
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.notes.sections!.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.notes.fetchedObjects!.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoteCell") as! NoteCell
        let note = self.notes.object(at: indexPath)
        cell.titleLabel.text = note.title
        let date = note.dateCreated!
        cell.subtitleLabel.text = dateFormatter.string(from: date as Date)
        cell.noteImageView.image = note.image as? UIImage
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let note = self.notes.object(at: indexPath)
        self.selectedNote = note
        let detailVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NoteDetailViewController") as! NoteDetailViewController
        detailVC.note = self.selectedNote
        detailVC.stack = self.stack
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.reloadData()
    }

}
