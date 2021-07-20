//
//  SlotTimeCell.swift
//  BlossomApp
//
//  Created by CHAKRIT PANIAM on 20/7/2564 BE.
//

import UIKit


class SlotTimeCell: UICollectionViewCell {
    @IBOutlet weak var backgroundCellView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        backgroundCellView.layer.cornerRadius = 10
    }
}
