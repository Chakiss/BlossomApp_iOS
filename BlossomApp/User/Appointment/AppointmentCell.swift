//
//  AppointmentCell.swift
//  BlossomApp
//
//  Created by CHAKRIT PANIAM on 21/7/2564 BE.
//

import UIKit
import Firebase
import SwiftDate

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
                    let referenceConnectyCubeID = data?["referenceConnectyCubeID"] as? UInt ?? 0
                    let story = data?["story"] as? String ?? ""
                    let createdAt = data?["createdAt"] as? String ?? ""
                    let updatedAt = data?["updatedAt"] as? String ?? ""
                    let displayPhoto = data?["displayPhoto"] as? String ?? ""
                    let score = data?["score"] as? Double ?? 0
                    return Doctor(id: id, displayName: displayName, email: email, firstName: firstName, lastName: lastName, phonenumber: phoneNumber, connectyCubeID: referenceConnectyCubeID, story: story, createdAt: createdAt, updatedAt: updatedAt, displayPhoto: displayPhoto, score: score,documentReference: document.reference)
                }
                
                
                
                let region = Region(calendar: Calendars.buddhist, zone: Zones.asiaBangkok, locale: Locales.thai)
                let startDate = DateInRegion((self.appointment?.sessionStart?.dateValue())!, region: region)
                let endDate = DateInRegion((self.appointment?.sessionEnd?.dateValue())!, region: region)
                
                self.appointLabel.text = String(format: "วันที่ %2d %@ %d เวลา %.2d:%.2d - %.2d:%.2d",startDate.day,startDate.monthName(.default),startDate.year,startDate.hour,startDate.minute,endDate.hour,endDate.minute)
                
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
    
    func displayCustomer() {
        
        db.collection("customers")
            .document(appointment?.customerReference!.documentID ?? "")
            .getDocument { snapshot, error in
            
                let customer = snapshot?.data().map({ documentData -> Customer in
                    let id = snapshot?.documentID ?? ""
                    let createdAt = documentData["createdAt"] as? String ?? ""
                    let displayName = documentData["displayName"] as? String ?? ""
                    let email = documentData["email"] as? String ?? ""
                    let firstName = documentData["firstName"] as? String ?? ""
                    let isEmailVerified: Bool = (documentData["isEmailVerified"] ?? false) as! Bool
                    let isPhoneVerified: Bool = (documentData["isPhoneVerified"] ?? false) as! Bool
                    let lastName = documentData["lastName"] as? String ?? ""
                    let phoneNumber = documentData["phoneNumber"] as? String ?? ""
                    let platform = documentData["platform"] as? String ?? ""
                    let referenceConnectyCubeID = documentData["referenceConnectyCubeID"] as? String ?? ""
                    let referenceShipnityID = documentData["referenceShipnityID"] as? String ?? ""
                    let updatedAt = documentData["updatedAt"] as? String ?? ""
                    let gender = documentData["gender"] as? String ?? ""
                    let birthDateTimestamp = documentData["birthDate"] as? Timestamp
                    var birthDay = ""
                    var birthDayString = ""
                    var birthDayDisplayString = ""
                    if let birthDate = birthDateTimestamp?.dateValue() {
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "YYYY-MM-dd"
                        birthDayString = dateFormatter.string(from: birthDate)
                        birthDay = dateFormatter.string(from: birthDate)
                        dateFormatter.dateStyle = .medium
                        birthDayDisplayString = dateFormatter.string(from: birthDate)
                    }
                    
                    let tmpAddress = documentData["address"] as? [String : Any] ?? [:]
                    var address = Address()
                    address.address = tmpAddress["address"] as? String ?? ""
                    
                    
                    let genderString = gender
                    
                    let displayPhoto = documentData["displayPhoto"] as? String ?? ""
                    
                    let skinType = documentData["skinType"] as? String ?? ""
                    let acneType = documentData["acneType"] as? String ?? ""
                    let acneCaredDescription = documentData["acneCaredDescription"] as? String ?? ""
                    let allergicDrug = documentData["allergicDrug"] as? String ?? ""
                    
                    let documentSnapshot = snapshot?.reference
                    return Customer(id: id, createdAt: createdAt, displayName: displayName, email: email, firstName: firstName, isEmailVerified: isEmailVerified, isPhoneVerified: isPhoneVerified, lastName: lastName, phoneNumber: phoneNumber, platform: platform, referenceConnectyCubeID: referenceConnectyCubeID, referenceShipnityID: referenceShipnityID, updatedAt: updatedAt, gender: gender,genderString: genderString, birthDate: birthDay,birthDayDisplayString: birthDayDisplayString, birthDayString: birthDayString, address: address, displayPhoto: displayPhoto,skinType: skinType, acneType: acneType, acneCaredDescription: acneCaredDescription, allergicDrug: allergicDrug,documentReference: documentSnapshot!)
                })
                
                
                let region = Region(calendar: Calendars.buddhist, zone: Zones.asiaBangkok, locale: Locales.thai)
                let startDate = DateInRegion((self.appointment?.sessionStart?.dateValue())!, region: region)
                let endDate = DateInRegion((self.appointment?.sessionEnd?.dateValue())!, region: region)
                
                self.appointLabel.text = String(format: "วันที่ %2d %@ %d เวลา %.2d:%.2d - %.2d:%.2d",startDate.day,startDate.monthName(.default),startDate.year,startDate.hour,startDate.minute,endDate.hour,endDate.minute)
                
                self.doctorImageView.layer.cornerRadius = self.doctorImageView.frame.size.width/2
                self.doctorNickNameLabel.text = customer?.displayName
                self.doctorNameLabel.text = (customer?.firstName ?? "") + "  " + (customer?.lastName ?? "")
                let imageRef = self.storage.reference(withPath: customer?.displayPhoto ?? "")
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




/*
 
 
 */
