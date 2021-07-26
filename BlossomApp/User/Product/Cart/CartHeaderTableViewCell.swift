//
//  CartHeaderTableViewCell.swift
//  BlossomApp
//
//  Created by nim on 11/7/2564 BE.
//

import UIKit

protocol CartHeaderTableViewCellDelegate: AnyObject {
    func cartHeaderDidTapEditAddress()
}

class CartHeaderTableViewCell: UITableViewCell {
    
    struct Model {
        var dateString: String = ""
        var priceText: String = ""
        var addressText: String = ""
    }

    @IBOutlet weak var stackViewContainer: UIView!
    @IBOutlet weak var orderLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var addressTitieLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var editAddressButton: UIButton!
    
    weak var delegate: CartHeaderTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupView()
    }
    
    private func setupView() {
        self.backgroundColor = UIColor.backgroundColor
        selectionStyle = .none
        stackViewContainer.addConerRadiusAndShadow()
        orderLabel.text = ""
        priceLabel.text = ""
        addressTitieLabel.text = ""
        addressLabel.text = ""
        editAddressButton.setTitle("แก้ไขที่อยู่", for: .normal)

        orderLabel.font = FontSize.body.bold()
        priceLabel.font = FontSize.body2.regular()
        addressTitieLabel.font = FontSize.body2.regular()
        addressLabel.font = FontSize.body2.regular()

        editAddressButton.backgroundColor = UIColor.blossomPrimary3
        editAddressButton.roundCorner(radius: 17)
    }
    
    public func renderOrderHeader(_ model: Model) {
        orderLabel.text = "Order วันที่ \(model.dateString)"
        priceLabel.text = "ราคา \(model.priceText) บาท"
        addressTitieLabel.text = "ที่อยู่จัดส่ง"
        addressLabel.text = model.addressText
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func editAddressAction(_ sender: Any) {
        delegate?.cartHeaderDidTapEditAddress()
    }
    
}
