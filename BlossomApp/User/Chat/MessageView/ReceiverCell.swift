//
//  ReceiverCell.swift
//  BlossomApp
//
//  Created by CHAKRIT PANIAM on 19/7/2564 BE.
//

import UIKit
import GSImageViewerController

class ReceiverCell: UITableViewCell {

    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var chatImageView: UIImageView!
    
    var parent : MessageingViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        borderView.layer.cornerRadius = 10
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.chatImageView.addGestureRecognizer(tap)
        self.chatImageView.isUserInteractionEnabled = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        // handling code
        if self.chatImageView.image != nil {
            let imageInfo   = GSImageInfo(image: self.chatImageView.image!, imageMode: .aspectFit)
            let transitionInfo = GSTransitionInfo(fromView: self.chatImageView)
            let imageViewer = GSImageViewerController(imageInfo: imageInfo, transitionInfo: transitionInfo)
            parent?.present(imageViewer, animated: true, completion: nil)
        }
    }

}
