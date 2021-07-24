//
//  AppointmentCell.swift
//  BlossomApp
//
//  Created by CHAKRIT PANIAM on 21/7/2564 BE.
//

import UIKit
import Firebase

class AppointmentCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var doctorImageView: UIImageView!
    @IBOutlet weak var doctorNickNameLabel: UILabel!
    @IBOutlet weak var doctorNameLabel: UILabel!
    @IBOutlet weak var appointLabel: UILabel!
    
    let db = Firestore.firestore()
    let storage = Storage.storage()
    
    var appointment: Appointment?
    
    
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
    
    func displayAppointment() {

        db.collection("doctors")
            .document(appointment?.doctorReference!.documentID ?? "")
            .addSnapshotListener { snapshot, error in
               let doctor =  snapshot.map { document -> Doctor in
                    let data = document.data()
                    let id = document.documentID
                    let firstName = data?["firstName"] as? String ?? ""
                    let displayName = data?["displayName"] as? String ?? ""
                    let email = data?["email"] as? String ?? ""
                    let lastName = data?["lastName"] as? String ?? ""
                    let phoneNumber = data?["phoneNumber"] as? String ?? ""
                    let referenceConnectyCubeID = data?["referenceConnectyCubeID"] as? String ?? ""
                    let story = data?["story"] as? String ?? ""
                    let createdAt = data?["createdAt"] as? String ?? ""
                    let updatedAt = data?["updatedAt"] as? String ?? ""
                    let displayPhoto = data?["displayPhoto"] as? String ?? ""
                    let currentScore = data?["currentScore"] as? Double ?? 0
                    return Doctor(id: id, displayName: displayName, email: email, firstName: firstName, lastName: lastName, phonenumber: phoneNumber, connectyCubeID: referenceConnectyCubeID, story: story, createdAt: createdAt, updatedAt: updatedAt, displayPhoto: displayPhoto, currentScore: currentScore,documentReference: document.reference)
                }


                self.appointLabel.text = "วันที่ 24 กรกฏาคม 2654 11:00 - 11:30"

                self.doctorImageView.layer.cornerRadius = self.doctorImageView.frame.size.width/2
                self.doctorNickNameLabel.text = doctor?.displayName
                self.doctorNameLabel.text = (doctor?.firstName ?? "") + "  " + (doctor?.lastName ?? "")
                let imageRef = self.storage.reference(withPath: doctor?.displayPhoto ?? "")
                imageRef.getData(maxSize: 2 * 1024 * 1024) { (data, error) in
                    if error == nil {
                        if let imgData = data {
                            if let img = UIImage(data: imgData) {
                                self.doctorImageView.image = img
                            }
                        }
                    } else {
                        self.doctorImageView.image = UIImage(named: "placeholder")

                    }
                }
            }
    }


}
