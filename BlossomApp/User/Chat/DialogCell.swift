//
//  DialogCell.swift
//  Chat
//
//  Created by ConnectyCube team.
//  Copyright © 2018 ConnectyCube. All rights reserved.
//

import UIKit
import SwiftDate
import BadgeSwift
import ConnectyCube
import Firebase

class DialogCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var messageTextLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var badgeView: BadgeSwift!
    
    var dialog: ChatDialog?
    let db = Firestore.firestore()
    let storage = Storage.storage()
    
    var channel: Channel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.badgeView.isHidden = true
        
    }
    
    public func setLastMessageText(lastMessageText: String?, date: Date, unreadMessageCount: UInt) {
        messageTextLabel.text = lastMessageText
        dateLabel.text = date.toRelative(style: RelativeFormatter.defaultStyle(), locale: Locales.current)
        badgeView.text = "\(unreadMessageCount)"
        badgeView.isHidden = unreadMessageCount == 0
        profileImageView.layer.cornerRadius = profileImageView.bounds.height / 2
        
    }
    
    func getDoctor(){
        //CustomerManager.sharedInstance.getCustomer { [weak self] in
            
            guard let customer = CustomerManager.sharedInstance.customer else {
                return
            }
            
            //customer

            
            db.collection("doctors")
                .document(channel?.doctorReference!.documentID ?? "")
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
                    
                
                    
                    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width/2
                    self.titleLabel.text = (doctor?.firstName ?? "") + "  " + (doctor?.lastName ?? "")
                    self.messageTextLabel.text = ""
                    if doctor!.displayPhoto?.count ?? 0 > 0 {
                        
                        let imageRef = self.storage.reference().child(doctor!.displayPhoto!)
                        let placeholderImage = UIImage(named: "placeholder")
                        self.profileImageView.sd_setImage(with: imageRef, placeholderImage: placeholderImage)
                        
                        
                    }

                    
                    self.db.collection("channels")
                        .document(self.channel?.id ?? "")
                        .collection("messages")
                        .order(by: "createdAt")
                        .getDocuments { messageData, error in
                            let messages = (messageData?.documents.map {messageSnapshot -> Message in
                                
                                
                                let data = messageSnapshot.data()
                                var message = Message(id: messageSnapshot.documentID)
                                
                                let isRead = data["isRead"]  as? Bool ?? nil
                                let messageText = data["message"] as? String ?? ""
                                let sendFrom = data["sendFrom"]  as? DocumentReference ?? nil
                                let sendTo = data["sendTo"]  as? DocumentReference ?? nil
                                let createdAt = data["createdAt"]  as? Timestamp ?? nil
                                let updatedAt = data["updatedAt"]  as? Timestamp ?? nil
                                let images = data["images"]  as? [String] ?? []
                                
                                message.isRead = isRead
                                message.message = messageText
                                
                                message.sendFrom = sendFrom
                                message.sendTo = sendTo
                                
                                message.createdAt = createdAt
                                message.updateAt = updatedAt
                                message.images = images
                                return message
                            })
                            self.channel?.message = messages
                            
                            if let messageDisplay = self.channel?.message , messageDisplay.count > 0 {
                                
                                self.messageTextLabel.text =  messageDisplay.last?.message
                                self.dateLabel.text = messageDisplay.last?.createdAt?.dateValue().timeAgoDisplay()
                                if messageDisplay.last?.images?.count ?? 0 > 0 {
                                    self.messageTextLabel.text = "ส่งรูปภาพ"
                                }
                                
                                self.badgeView.text = ""
                                self.badgeView.isHidden = true
                                for message in messageDisplay {
                                    if message.isRead  == false{
                                        self.badgeView.text = "N"
                                        self.badgeView.isHidden = false
                                    }
                                }
                            } else {
                                self.messageTextLabel.text = "ไม่มีข้อความ"
                            }
                            
                            

                        }
                    
                    
                    
                }
            
            
            ////
            
    
            
      //  }
    }
    
    func getCutomerData() {
        db.collection("customers")
            .document(channel?.customerReference!.documentID ?? "")
            .addSnapshotListener { snapshot, error in
                let customer = (snapshot?.data().map({ documentData -> Customer in
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
                    address.zipcodeID = tmpAddress["zipcodeID"] as? Int ?? 0
                    address.provinceID = tmpAddress["provinceID"] as? Int ?? 0
                    address.districtID = tmpAddress["districtID"] as? Int ?? 0
                    address.subDistrictID = tmpAddress["subDistrictID"] as? Int ?? 0
                    address.formattedAddress = tmpAddress["formattedAddress"] as? String ?? ""
                    
                    
                    
                    let genderString = gender
                    
                    let displayPhoto = documentData["displayPhoto"] as? String ?? ""
                    
                    let skinType = documentData["skinType"] as? String ?? ""
                    let acneType = documentData["acneType"] as? String ?? ""
                    let acneCaredDescription = documentData["acneCaredDescription"] as? String ?? ""
                    let allergicDrug = documentData["allergicDrug"] as? String ?? ""
                    
                    let documentSnapshot = snapshot?.reference
                    
                    let nickName = documentData["nickName"] as? String ?? ""
                    
                    return Customer(id: id, createdAt: createdAt, displayName: displayName, email: email, firstName: firstName, isEmailVerified: isEmailVerified, isPhoneVerified: isPhoneVerified, lastName: lastName, phoneNumber: phoneNumber, platform: platform, referenceConnectyCubeID: referenceConnectyCubeID, referenceShipnityID: referenceShipnityID, updatedAt: updatedAt, gender: gender,genderString: genderString, birthDate: birthDay,birthDayDisplayString: birthDayDisplayString, birthDayString: birthDayString, address: address, displayPhoto: displayPhoto,skinType: skinType, acneType: acneType, acneCaredDescription: acneCaredDescription, allergicDrug: allergicDrug,documentReference: documentSnapshot!,nickName: nickName
                    )
                    
                }))
                
            
                
                self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width/2
                self.titleLabel.text = (customer?.firstName ?? "") + "  " + (customer?.lastName ?? "")
                self.messageTextLabel.text = ""
                if customer?.displayPhoto?.count ?? 0 > 0 {
                    
                    let imageRef = self.storage.reference().child(customer!.displayPhoto!)
                    let placeholderImage = UIImage(named: "placeholder")
                    self.profileImageView.sd_setImage(with: imageRef, placeholderImage: placeholderImage)
                    
                   
                }

                
                self.db.collection("channels")
                    .document(self.channel?.id ?? "")
                    .collection("messages")
                    .order(by: "createdAt")
                    .getDocuments { messageData, error in
                        let messages = (messageData?.documents.map {messageSnapshot -> Message in
                            
                            
                            let data = messageSnapshot.data()
                            var message = Message(id: messageSnapshot.documentID)
                            
                            let isRead = data["isRead"]  as? Bool ?? nil
                            let messageText = data["message"] as? String ?? ""
                            let sendFrom = data["sendFrom"]  as? DocumentReference ?? nil
                            let sendTo = data["sendTo"]  as? DocumentReference ?? nil
                            let createdAt = data["createdAt"]  as? Timestamp ?? nil
                            let updatedAt = data["updatedAt"]  as? Timestamp ?? nil
                            let images = data["images"]  as? [String] ?? []
                            
                            message.isRead = isRead
                            message.message = messageText
                            
                            message.sendFrom = sendFrom
                            message.sendTo = sendTo
                            
                            message.createdAt = createdAt
                            message.updateAt = updatedAt
                            message.images = images
                            return message
                        })
                        self.channel?.message = messages
                        
                        if let messageDisplay = self.channel?.message , messageDisplay.count > 0 {
                            
                            self.messageTextLabel.text =  messageDisplay.last?.message
                            self.dateLabel.text = messageDisplay.last?.createdAt?.dateValue().timeAgoDisplay()
                            if messageDisplay.last?.images?.count ?? 0 > 0 {
                                self.messageTextLabel.text = "ส่งรูปภาพ"
                            }
                            
                            self.badgeView.text = ""
                            self.badgeView.isHidden = true
                            for message in messageDisplay {
                                if message.isRead  == false{
                                    self.badgeView.text = "N"
                                    self.badgeView.isHidden = false
                                }
                            }
                            
                        } else {
                            self.messageTextLabel.text = "ไม่มีข้อความ"
                        }
                        

                    }
                
                
                
            }
        
        
        ////
        

        
  //  }
    }
    
    func getAdmin(){
        
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width/2
        self.profileImageView.image = UIImage(named: "placeholder")
        self.titleLabel.text = "Admin blossom"
        self.messageTextLabel.text = ""
        
        let user = Auth.auth().currentUser
        
        db.collection("channels")
            .document(user?.uid ?? "")
            .collection("messages")
            .order(by: "createdAt")
            .addSnapshotListener { messageData, error in
                let messages = (messageData?.documents.map {messageSnapshot -> Message in
                    
                    
                    let data = messageSnapshot.data()
                    var message = Message(id: messageSnapshot.documentID)
                    
                    let isRead = data["isRead"]  as? Bool ?? nil
                    let messageText = data["message"] as? String ?? ""
                    let images = data["images"]  as? [String] ?? []
                    let from = data["from"]  as? String ?? ""
                    let sendFrom = data["sendFrom"]  as? DocumentReference ?? nil
                    let sendTo = data["sendTo"]  as? DocumentReference ?? nil
                    let createdAt = data["createdAt"]  as? Timestamp ?? nil
                    let updatedAt = data["updatedAt"]  as? Timestamp ?? nil
                    
                    
                    
                    message.isRead = isRead
                    message.message = messageText
                    
                    message.sendFrom = sendFrom
                    message.sendTo = sendTo
                    
                    message.createdAt = createdAt
                    message.updateAt = updatedAt
                    message.images = images
                    
                    message.from = from
                    return message
                })
                
                //self.adminMessage = messages ?? []
                //self.tableView.reloadData()
                //self.scrollToBottom()
                //self.channel?.message = messages
                
                if let messageDisplay = messages , messageDisplay.count > 0 {
                    
                    self.messageTextLabel.text =  messageDisplay.last?.message
                    self.dateLabel.text = messageDisplay.last?.createdAt?.dateValue().timeAgoDisplay()
                    if messageDisplay.last?.images?.count ?? 0 > 0 {
                        self.messageTextLabel.text = "ส่งรูปภาพ"
                    }
                    
                    self.badgeView.text = ""
                    self.badgeView.isHidden = true
                    for message in messageDisplay {
                        if message.isRead  == false{
                            self.badgeView.text = "N"
                            self.badgeView.isHidden = false
                        }
                    }
                    
                } else {
                    self.messageTextLabel.text = "ไม่มีข้อความ"
                }
                
                
            }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
