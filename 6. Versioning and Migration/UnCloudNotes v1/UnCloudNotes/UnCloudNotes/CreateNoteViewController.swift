//
//  CreateNoteViewController.swift
//  UnCloudNotes
//
//  Created by Bianca Hinova on 7/11/17.
//  Copyright © 2017 bb. All rights reserved.
//

import UIKit
import CoreData

class CreateNoteViewController: UIViewController {

    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var bodyTextView: UITextView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet weak var attachImageButton: UIButton!
    
    var stack: CoreDataStack!
    lazy var note: Note? = {
        return Note(context: self.stack.context)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.attachImageButton.isHidden = true
    }
    
    
    @IBAction func createButtonTapped(_ sender: UIBarButtonItem) {
        let title = self.titleTextField.text ?? ""
        let body = self.bodyTextView.text
        
        self.note?.title = title
        self.note?.body = body
        self.note?.dateCreated = NSDate()
        
        self.stack.saveContext()
        self.navigationController?.dismiss(animated: true, completion: nil)
        
    }
}
