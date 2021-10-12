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
        
    }
    
    public func setLastMessageText(lastMessageText: String?, date: Date, unreadMessageCount: UInt) {
        messageTextLabel.text = lastMessageText
        dateLabel.text = date.toRelative(style: RelativeFormatter.defaultStyle(), locale: Locales.current)
        badgeView.text = "\(unreadMessageCount)"
        badgeView.isHidden = unreadMessageCount == 0
        profileImageView.layer.cornerRadius = profileImageView.bounds.height / 2
        
    }
    
    func getImageDoctor(){
        //CustomerManager.sharedInstance.getCustomer { [weak self] in
            
            guard let customer = CustomerManager.sharedInstance.customer else {
                return
            }
            
            //customer

            
            db.collection("doctors")
                .document(channel?.doctorReference!.documentID ?? "default value")
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
                        
                        let imageRef = self.storage.reference(withPath: doctor!.displayPhoto!)
                        imageRef.getData(maxSize: 2 * 1024 * 1024) { (data, error) in
                            if error == nil {
                                if let imgData = data {
                                    if let img = UIImage(data: imgData) {
                                        self.profileImageView.layer.cornerRadius = self.profileImageView.bounds.height / 2
                                        self.profileImageView.image = img

                                    }
                                }
                            } else {
                                self.profileImageView.image = UIImage(named: "placeholder")
                                
                            }
                        }
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
                                
                                
                                message.isRead = isRead
                                message.message = messageText
                                
                                message.sendFrom = sendFrom
                                message.sendTo = sendTo
                                
                                message.createdAt = createdAt
                                message.updateAt = updatedAt
                                return message
                            })
                            self.channel?.message = messages
                            
                            if let messageDisplay = self.channel?.message , messageDisplay.count > 0 {
                                
                                self.messageTextLabel.text =  messageDisplay.last?.message
                                self.dateLabel.text = messageDisplay.last?.createdAt?.dateValue().timeAgoDisplay()
                            } else {
                                self.messageTextLabel.text = "ไม่มีข้อความ"
                            }
                            

                        }
                    
                    
                    
                }
            
            
            ////
            
    
            
      //  }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
