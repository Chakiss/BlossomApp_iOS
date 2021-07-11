//
//  ProductCell.swift
//  BlossomApp
//
//  Created by CHAKRIT PANIAM on 10/7/2564 BE.
//

import UIKit

protocol ProductCellDelegate: AnyObject {
    func productCellDidAddToCart(cell: ProductCell)
}

class ProductCell: UITableViewCell {
    
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var productImageView: UIImageView!
    
    weak var delegate: ProductCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func addToCart(_ sender: Any) {
        delegate?.productCellDidAddToCart(cell: self)
    }
    
}
