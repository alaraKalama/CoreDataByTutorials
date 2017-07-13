//
//  TeamCell.swift
//  WorldCup
//
//  Created by Bianca Hinova on 7/10/17.
//  Copyright © 2017 bb. All rights reserved.
//

import UIKit

class TeamCell: UITableViewCell {

    @IBOutlet weak var flagImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var subLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
