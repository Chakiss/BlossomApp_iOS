//
//  BannerView.swift
//  
//
//  Created by CHAKRIT PANIAM on 23/2/2564 BE.
//  Copyright © 2564 BE TOTAL ACCESS COMMUNICATION PUBLIC COMPANY LIMITED. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher
import Alamofire


class BannerViewCell: UICollectionViewCell {
 
    @IBOutlet var bannerImageView: UIImageView!
    
    func drawImage(imageHilight: String) {
        
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
        
        
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        self.bannerImageView.addView(imageView)
        
        imageView.topAnchor.constraint(equalTo: bannerImageView.topAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: bannerImageView.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: bannerImageView.trailingAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: bannerImageView.bottomAnchor).isActive = true
        
        let url = URL(string: imageHilight)
        DispatchQueue.main.async {
            imageView.kf.setImage(with: url, placeholder: UIImage(named: "placeholderHero"))
        }
        
    
    }
}
