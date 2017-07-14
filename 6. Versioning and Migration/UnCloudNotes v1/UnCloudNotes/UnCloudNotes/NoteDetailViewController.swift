//
//  NoteDetailViewController.swift
//  UnCloudNotes
//
//  Created by Bianca Hinova on 7/11/17.
//  Copyright © 2017 bb. All rights reserved.
//

import UIKit
import CoreData

class NoteDetailViewController: UIViewController {

    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var bodyTextView: UITextView!
    @IBOutlet var imageView: UIImageView!
    
    var note: Note!
    var stack: CoreDataStack!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleTextField.text = self.note.title
        self.bodyTextView.text = self.note.body
    }
    
    @IBAction func updateButtonTapped(_ sender: UIButton) {
        self.note.title = self.titleTextField.text
        self.note.body = self.bodyTextView.text
        self.stack.saveContext()
        self.navigationController?.popViewController(animated: true)
    }
}
