//
//  SavedContactTableViewCell.swift
//  Simple Names
//
//  Created by Ruslan Arhypenko on 3/28/19.
//  Copyright © 2019 Ruslan Arhypenko. All rights reserved.
//

import UIKit

class SavedContactTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
