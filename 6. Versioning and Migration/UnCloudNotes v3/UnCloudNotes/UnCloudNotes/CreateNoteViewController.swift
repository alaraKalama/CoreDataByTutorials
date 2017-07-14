//
//  CreateNoteViewController.swift
//  UnCloudNotes
//
//  Created by Bianca Hinova on 7/11/17.
//  Copyright © 2017 bb. All rights reserved.
//

import UIKit
import CoreData

class CreateNoteViewController: UIViewController, AttachPhotoViewControllerDelegate {

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
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AttachImageSegue" {
            let attachVC = segue.destination as! AttachPhotoViewController
            attachVC.delegate = self
        }
    }
    
    @IBAction func createButtonTapped(_ sender: UIBarButtonItem) {
        let title = self.titleTextField.text ?? ""
        let body = self.bodyTextView.text
        
        self.note?.title = title
        self.note?.body = body
        self.note?.dateCreated = NSDate()
        
        if let attachment = NSEntityDescription.insertNewObject(forEntityName: "Attachment", into: self.stack.context) as? Attachment,
            let image = self.imageView.image {
            attachment.dateCreated = NSDate()
            attachment.image = image
            attachment.note = self.note
        }
        
        self.stack.saveContext()
        self.navigationController?.dismiss(animated: true, completion: nil)
        
    }
    
    func attachPhotoViewController(_ controller: AttachPhotoViewController, didSelect image: UIImage) {
        self.imageView.image = image
    }
}
