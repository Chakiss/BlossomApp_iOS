//
//  AppointmentCell.swift
//  BlossomApp
//
//  Created by CHAKRIT PANIAM on 21/7/2564 BE.
//

import UIKit

class AppointmentCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var doctorImageView: UIImageView!
    @IBOutlet weak var doctorNickNameLabel: UILabel!
    @IBOutlet weak var doctorNameLabel: UILabel!
    @IBOutlet weak var appointLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        containerView.addConerRadiusAndShadow()
        
        doctorImageView.layer.cornerRadius = doctorImageView.bounds.height / 2
        doctorImageView.layer.shadowColor = UIColor.black.cgColor
        doctorImageView.layer.shadowOffset = CGSize(width: 3, height: 3)
        doctorImageView.layer.shadowOpacity = 0.1
        doctorImageView.layer.shadowRadius = 4.0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func calculateReview(reviews: [Reviews]){
        
    }


}
