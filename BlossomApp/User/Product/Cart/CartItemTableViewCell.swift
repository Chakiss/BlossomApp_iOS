//
//  CartItemTableViewCell.swift
//  BlossomApp
//
//  Created by nim on 11/7/2564 BE.
//

import UIKit

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
        productNameLabel.text = model.product.name ?? "" + "Lorem ipsum de sem lorean, Rek sdfhu asidu"
        amountTitleLabel.text = "จำนวน"
        amountLabel.text = "\(model.quantity)"
        priceLabel.text = "ราคา \(model.product.priceInSatang().satangToBaht().toAmountText()) บาท"
        
        let url = URL(string: model.product.image ?? "")
        productImageView.kf.setImage(with: url, placeholder: UIImage(named: "placeholder"))
        productImageView.addConerRadiusAndShadow()
    }
    
    @IBAction func decreaseItem(_ sender: Any) {
        delegate?.cellDidDecreaseItem(cell: self)
    }
    
    @IBAction func increaseItem(_ sender: Any) {
        delegate?.cellDidIncreaseItem(cell: self)
    }
    
}
