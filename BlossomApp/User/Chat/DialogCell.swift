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

class DialogCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var messageTextLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var badgeView: BadgeSwift!
    
    
    public func setLastMessageText(lastMessageText: String?, date: Date, unreadMessageCount: UInt) {
        messageTextLabel.text = lastMessageText
        dateLabel.text = date.toRelative(style: RelativeFormatter.defaultStyle(), locale: Locales.current)
        badgeView.text = "\(unreadMessageCount)"
        badgeView.isHidden = unreadMessageCount == 0
       
        
    }
    
 
   
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
