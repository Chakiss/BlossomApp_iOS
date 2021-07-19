//
//  SlotDateCell.swift
//  BlossomApp
//
//  Created by CHAKRIT PANIAM on 20/7/2564 BE.
//

import UIKit

class SlotDateCell: UICollectionViewCell {
    @IBOutlet weak var backgroundCellView: UIView!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var monthLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        backgroundCellView.layer.cornerRadius = 10
    }
}
