//
//  PatientInfoCell.swift
//  PloNY
//
//  Created by Rakesh Tripathi on 2020-01-23.
//  Copyright © 2020 Rakesh Tripathi. All rights reserved.
//

import UIKit

class PatientInfoCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var phone: UILabel!
    @IBOutlet weak var addr: UILabel!
    @IBOutlet weak var conditions: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
