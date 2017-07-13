//
//  DogCell.swift
//  DogWalk
//
//  Created by Bianca Hinova on 7/6/17.
//  Copyright © 2017 bb. All rights reserved.
//

import UIKit

class DogCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.imageView.layer.cornerRadius = 40
        self.imageView.layer.masksToBounds = true
    }
    
    func configure(with dog: Dog) {
        self.nameLabel.text = dog.name
        if let data = dog.imageData as Data? {
            self.imageView.image = UIImage(data: data)
        } else {
            self.imageView.image = #imageLiteral(resourceName: "paw")
        }
    }
}
