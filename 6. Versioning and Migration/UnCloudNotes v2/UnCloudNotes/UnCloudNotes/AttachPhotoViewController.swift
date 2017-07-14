//
//  AttachPhotoViewController.swift
//  UnCloudNotes
//
//  Created by Bianca Hinova on 7/11/17.
//  Copyright © 2017 bb. All rights reserved.
//

import UIKit

protocol AttachPhotoViewControllerDelegate {
    func attachPhotoViewController(_ controller: AttachPhotoViewController, didSelect image: UIImage)
}

class AttachPhotoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var delegate: AttachPhotoViewControllerDelegate?
    
    lazy var imagePicker: UIImagePickerController = {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        return picker
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addChildViewController(self.imagePicker)
        self.view.addSubview(self.imagePicker.view)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.delegate?.attachPhotoViewController(self, didSelect: image)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
}

