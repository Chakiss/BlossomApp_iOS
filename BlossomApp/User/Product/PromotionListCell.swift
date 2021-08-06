//
//  PromotionListCell.swift
//  BlossomApp
//
//  Created by CHAKRIT PANIAM on 6/8/2564 BE.
//

import UIKit

class PromotionListCell: UITableViewCell {

    @IBOutlet weak var promotionImageView: UIImageView!
    @IBOutlet weak var promotionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
