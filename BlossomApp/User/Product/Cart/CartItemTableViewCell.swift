//
//  CartItemTableViewCell.swift
//  BlossomApp
//
//  Created by nim on 11/7/2564 BE.
//

import UIKit
import Firebase

protocol CartItemTableViewCellDelegate: AnyObject {
    func cellDidDecreaseItem(cell: CartItemTableViewCell)
    func cellDidIncreaseItem(cell: CartItemTableViewCell)
}

class CartItemTableViewCell: UITableViewCell {
    
    struct Model {
        var imageURL: String = ""
        var name: String = ""
        var amount: Int = 0
        var price: String = ""
    }

    @IBOutlet weak var stackViewContainer: UIView!
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var amountTitleLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var decreaseButton: UIButton!
    @IBOutlet weak var increaseButton: UIButton!
    
    weak var delegate: CartItemTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupView()
    }
    
    private func setupView() {
        self.backgroundColor = UIColor.backgroundColor
        selectionStyle = .none
        stackViewContainer.addConerRadiusAndShadow()
        productImageView.image = nil
        productNameLabel.text = ""
        amountTitleLabel.text = ""
        amountLabel.text = ""
        priceLabel.text = ""
        
        productNameLabel.font = FontSize.body2.bold()
        amountTitleLabel.font = FontSize.small.regular()
        amountLabel.font = FontSize.body.regular()
        priceLabel.font = FontSize.body2.regular()
        
        decreaseButton.backgroundColor = UIColor.blossomPrimary2
        increaseButton.backgroundColor = UIColor.blossomPrimary2
        decreaseButton.addConerRadiusAndShadow()
        increaseButton.addConerRadiusAndShadow()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public func render(_ model: CartItem) {
        if model.set != nil {
            
            Firestore.firestore().collection("set_product").document(model.set?.code ?? "").getDocument { documentSnapshot, error in
                let snapshotData = documentSnapshot?.data()
                let image = snapshotData?["image"] as? String ?? ""
                
                self.productNameLabel.text = (model.set?.name ?? "")
                self.amountTitleLabel.text = "จำนวน"
                self.amountLabel.text = "\(model.quantity)"
                
                let price = model.set?.priceInSatang().satangToBaht() ?? 0
                self.priceLabel.text = "ราคา \(price.toAmountText()) บาท"
                
                
                self.productImageView.kf.setImage(with: URL(string: image), placeholder: UIImage(named: "placeholder"))
                self.productImageView.addConerRadiusAndShadow()
                
            }
        }
        
        if model.product != nil {
            productNameLabel.text = (model.product?.name ?? "")
            amountTitleLabel.text = "จำนวน"
            amountLabel.text = "\(model.quantity)"
            
            let price = model.product?.priceInSatang().satangToBaht() ?? 0
            priceLabel.text = "ราคา \(price.toAmountText()) บาท"
            
            let url = URL(string: model.product?.image ?? "")
            productImageView.kf.setImage(with: url, placeholder: UIImage(named: "placeholder"))
            productImageView.addConerRadiusAndShadow()
        }
    }
    
    @IBAction func decreaseItem(_ sender: Any) {
        delegate?.cellDidDecreaseItem(cell: self)
    }
    
    @IBAction func increaseItem(_ sender: Any) {
        delegate?.cellDidIncreaseItem(cell: self)
    }
    
}
