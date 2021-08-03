//
//  FormImageCell.swift
//  BlossomApp
//
//  Created by CHAKRIT PANIAM on 3/8/2564 BE.
//

import UIKit

class FormImageCell: UITableViewCell {

    @IBOutlet var preImageView: [UIImageView]!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
//        self.consultImage[.addGestureRecognizer(tap)
//        self.consultImage.isUserInteractionEnabled = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        // handling code
//        let imageInfo   = GSImageInfo(image: self.consultImage.image!, imageMode: .aspectFit)
//        let transitionInfo = GSTransitionInfo(fromView: self.consultImage)
//        let imageViewer = GSImageViewerController(imageInfo: imageInfo, transitionInfo: transitionInfo)
//        present(imageViewer, animated: true, completion: nil)
    }
}
