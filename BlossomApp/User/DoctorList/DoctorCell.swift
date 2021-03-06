//
//  DoctorCell.swift
//  BlossomApp
//
//  Created by CHAKRIT PANIAM on 8/7/2564 BE.
//

import UIKit

class DoctorCell: UITableViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var doctorImageView: UIImageView!
    @IBOutlet weak var doctorNickNameLabel: UILabel!
    @IBOutlet weak var doctorNameLabel: UILabel!
    @IBOutlet weak var doctorStarLabel: UILabel!
    @IBOutlet weak var doctorReviewLabel: UILabel!
    @IBOutlet weak var doctorAppointmentLabel: UILabel!
    
    @IBOutlet weak var doctorHaveSlotLabel: UILabel!
    
    var doctor: Doctor?
    
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
        
        var count = 0
        for review in reviews {
            if review.doctorReference == doctor?.documentReference {
                count += 1
            }
        }
        
        self.doctorReviewLabel.text = "\(count) รีวิว"
    }
    
    func calculateAppointMent(appointment: [Appointment])  {
        var count = 120
        for appoint in appointment {
            if appoint.doctorReference == doctor?.documentReference {
                count += 1
            }
        }
        
        self.doctorAppointmentLabel.text = "รักษา \(count) ครั้ง"
    }

}
