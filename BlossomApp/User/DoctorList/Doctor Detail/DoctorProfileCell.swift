//
//  DoctorProfileCell.swift
//  BlossomApp
//
//  Created by CHAKRIT PANIAM on 24/7/2564 BE.
//

import UIKit

class DoctorProfileCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var profileLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        containerView.addConerRadiusAndShadow()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
