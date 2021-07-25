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
        CustomerManager.sharedInstance.getCustomer { [weak self] in
            
            guard let customer = CustomerManager.sharedInstance.customer else {
                return
            }
            
            //customer
            let userIDs = self?.dialog?.occupantIDs as! [NSNumber]
            let myConnectyID = customer.referenceConnectyCubeID! as String
            var doctorConnectyIDID = 0
            for item in userIDs {
                if item.intValue != Int(myConnectyID){
                    doctorConnectyIDID = Int(item)
                }
            }
            self?.db.collection("doctors")
                .whereField("referenceConnectyCubeID", isEqualTo: doctorConnectyIDID)
                .addSnapshotListener { snapshot, error in
    
                   let displayPhoto = snapshot?.documents.map { queryDocumentSnapshot -> String  in
                        print(queryDocumentSnapshot)
                        let data = queryDocumentSnapshot.data()
                        let displayPhoto = data["displayPhoto"]  as? String ?? ""
                        
                        return displayPhoto
                    }
                    
                    if displayPhoto?.count ?? 0 > 0 {
                        
                        let imageRef = self?.storage.reference(withPath: (displayPhoto?[0])!)
                        imageRef?.getData(maxSize: 2 * 1024 * 1024) { (data, error) in
                            if error == nil {
                                if let imgData = data {
                                    if let img = UIImage(data: imgData) {
                                        self?.profileImageView.image = img
                                        self?.profileImageView.layer.cornerRadius = self?.profileImageView.bounds.height ?? 2 / 2
                                    }
                                }
                            } else {
                                self?.profileImageView.image = UIImage(named: "placeholder")
                                
                            }
                        }
                    }
                    
                }
            
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
