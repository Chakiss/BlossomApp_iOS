//
//  ProductDetailViewController.swift
//  BlossomApp
//
//  Created by CHAKRIT PANIAM on 10/7/2564 BE.
//

import UIKit

class ProductDetailViewController: UIViewController {

    var product:Product? = nil
    
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productPriceLabel: UILabel!
    
    @IBOutlet weak var productImageView: UIImageView!
    
    @IBOutlet weak var productDescriptionLabel: UILabel!
    
    @IBOutlet weak var footerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // shadow
        self.footerView.layer.shadowColor = UIColor.black.cgColor
        self.footerView.layer.shadowOffset = CGSize(width: 3, height: 3)
        self.footerView.layer.shadowOpacity = 0.1
        self.footerView.layer.shadowRadius = 4.0
        
        self.title = product?.name
        
        productNameLabel.text = product?.name
        productPriceLabel.text = product?.price
        productDescriptionLabel.text = product?.description_long?.htmlToString
        
        let url = URL(string: product?.image ?? "")
        productImageView.kf.setImage(with: url, placeholder: UIImage(named: "placeholder"))
        productImageView.addConerRadiusAndShadow()
    }
   
}


extension String {
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return nil }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return nil
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
}
