//
//  NoteCell.swift
//  UnCloudNotes
//
//  Created by Bianca Hinova on 7/11/17.
//  Copyright © 2017 bb. All rights reserved.
//

import UIKit

class NoteCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var noteImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override var reuseIdentifier: String? {
        get {
            return "NoteCell"
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
