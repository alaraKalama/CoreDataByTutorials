//
//  AddDogViewController.swift
//  DogWalk
//
//  Created by Bianca Hinova on 7/6/17.
//  Copyright © 2017 bb. All rights reserved.
//

import UIKit
import CoreData

protocol AddDogViewControllerDelegate {
    func addDogViewControllerDidAddNewDog(_ sender: AddDogViewController)
}

class AddDogViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var doneButton: UIButton!
    
    var managedContext: NSManagedObjectContext!
    var delegate: AddDogViewControllerDelegate?
    var imagePicker = UIImagePickerController()
    var imageData: NSData? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Add New Dog"
        self.doneButton.layer.cornerRadius = 10
    }
    
    func showErrorWithText(_ text: String) {
        let alert = UIAlertController(title: "Error", message: text, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func doneButtonTapped(_ sender: UIButton) {
        if let name = self.textField.text, !name.isEmpty {
            if Dog.addNewDog(name: name, imageData: self.imageData, in: self.managedContext) {
                self.delegate?.addDogViewControllerDidAddNewDog(self)
                self.navigationController?.popViewController(animated: true)
//                self.dismiss(animated: true, completion: nil)
            } else {
                self.showErrorWithText("Something went wrong")
            }
        } else {
            self.showErrorWithText("Please add dog's name")
            return
        }
    }
    
    @IBAction func addImageButtonTapped(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            self.imagePicker.delegate = self
            self.imagePicker.sourceType = .savedPhotosAlbum
            self.imagePicker.allowsEditing = true
            self.present(self.imagePicker, animated: true, completion: nil)
        }
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        self.dismiss(animated: true, completion: nil)
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            let photoData = UIImagePNGRepresentation(image)
            self.imageData = photoData as NSData?
        }
    }
}
